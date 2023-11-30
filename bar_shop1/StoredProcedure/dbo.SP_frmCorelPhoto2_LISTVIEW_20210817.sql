IF OBJECT_ID (N'dbo.SP_frmCorelPhoto2_LISTVIEW_20210817', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_frmCorelPhoto2_LISTVIEW_20210817
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
EXEC SP_frmCorelPhoto2_LISTVIEW '', '', '9', '0', '0', '2020-10-26', '2020-10-26', 0, 0, '3', '20201022', '20201022', '0', '', 10000
EXEC SP_frmCorelPhoto2_LISTVIEW '', '', '14', '0', '0', '2020-10-26', '2020-10-26', 0, 0, '3', '20201022', '20201022', '0', '', 10000
EXEC SP_frmCorelPhoto2_LISTVIEW '', '', '3', '0', '0', '2020-10-26', '2020-10-26', 0, 0, '3', '20201022', '20201022', '0', '', 10000

EXEC SP_frmCorelPhoto2_LISTVIEW '', '', '9', '0', '0', '2020-10-26', '2020-10-26', 0, 0, '3', '20201025', '20201027', '0', '', 10000
EXEC SP_frmCorelPhoto2_LISTVIEW '3143978', '', '0', '0', '0', '2021-03-30', '2021-04-30', 0, 0, '3', '20210430', '20210430', '0', '', 10000
*/
CREATE PROCEDURE [dbo].[SP_frmCorelPhoto2_LISTVIEW_20210817]
	@ORDER_SEQ AS VARCHAR(20)		--주문번호
	, @CARD_CODE AS VARCHAR(30)		--카드코드
	, @ORDER_TYPE AS VARCHAR(2)		--오더타입
	, @PrintCompleted AS CHAR(1)	--인쇄완료건	
	, @ChasuChk AS CHAR(1)	--차수검색체크 
	, @ChasuSDATE AS CHAR(10)	--차수날짜 BEGIN		2019-07-31
	, @ChasuEDATE AS CHAR(10)	--차수날짜 END		2019-07-31
	, @ChasuS AS INT	--차수번호 BEGIN
	, @ChasuE AS INT	--차수번호 END
	, @SrchCase AS CHAR(1)		--검색일 구분(주문일, 컨펌일, 인쇄대기일, 인쇄시작일)
	, @SrchSDate AS CHAR(8)		--검색일 BEGIN		20190731
	, @SrchEDate AS CHAR(8)		--검색일 END			20190731
	, @OrderBy AS CHAR(1)		--정렬방법
	, @PRINTER_SEQ AS CHAR(1) = NULL--인쇄소
	, @PageSize AS INT = 100000
AS

SET NOCOUNT ON   

BEGIN

	SELECT @ChasuS  = CASE WHEN ISNULL(LTRIM(RTRIM(@ChasuS)), 0) = 0 THEN NULL ELSE LTRIM(RTRIM(@ChasuS)) END
		, @ChasuE  = CASE WHEN ISNULL(LTRIM(RTRIM(@ChasuE)), 0) = 0 THEN NULL ELSE LTRIM(RTRIM(@ChasuE)) END
	
	DECLARE @bWhereBypass CHAR(1)
	SET @bWhereBypass = 'N'

	IF ISNULL(@ORDER_SEQ, '') <> '' OR ISnULL(@CARD_CODE, '') <> ''
	BEGIN 
		SET @bWhereBypass = 'Y'
	END
	   


--약도카드, 내지 중에 태산에서 작업해야 할 주문건 
SELECT DISTINCT order_seq 
INTO #TAESAN_SUB_CARD
FROM custom_order_plist CP 
JOIN S2_Card CD ON CP.card_seq = CD.Card_Seq 
JOIN CARD_COREL CC ON CD.Card_Code = CC.Card_Code AND ISNULL(CC.WEPOD_YORN, 'N') = 'Y'
WHERE CP.print_type IN ( 'P' , 'I' ) 
	AND @ORDER_TYPE IN ('0', '8' )


--포켓카드중에 내부디지털 작업해야 할 주문건 
SELECT DISTINCT order_seq 
INTO #POCKET_SUB_CARD
FROM (select * from custom_order_plist where print_type='S') CP 
JOIN S2_Card CD ON CP.card_seq = CD.Card_Seq 
JOIN HardCodingList CC ON CD.Card_Code = CC.hardcode 
WHERE @ORDER_TYPE IN ('0', '12' ) AND CC.HardID = 'DigitalCardCode' AND CC.HardUse = 'Y'


	SELECT   A.order_name
		, A.order_Seq
		, A.order_Date
		, A.order_type
		, A.src_printW_date
		, A.isCompose
		, B.card_code
		, C.isCustomDColor
		, A.pay_type
		, A.up_order_seq
		, A.order_add_flag 

		   ,   CASE    WHEN A.OUTSOURCING_TYPE IS NULL THEN '' 
					   ELSE CASE WHEN LEN(A.OUTSOURCING_TYPE) = 1 THEN (SELECT DTL_NAME FROM COMMON_CODE WHERE CMMN_CODE = ('10700' + CAST(A.OUTSOURCING_TYPE AS VARCHAR(10)))) 
								 ELSE (SELECT DTL_NAME FROM COMMON_CODE WHERE CMMN_CODE = ('1070' + CAST(A.OUTSOURCING_TYPE AS VARCHAR(10)))) END 
			   END AS OUTSOURCING_COMPANY_NAME 
		   ,   ISNULL(OUTSOURCING_MERGE_TYPE_CODE, '115001') AS OUTSOURCING_MERGE_TYPE_CODE 
		   ,   ISNULL(OUTSOURCING_PRINTING_HOUSE_TYPE_CODE, '') AS OUTSOURCING_PRINTING_HOUSE_TYPE_CODE 
		   ,   ISNULL((SELECT TOP 1 CAST(PSEQ AS VARCHAR(10)) + '-' + CAST(OSEQ AS VARCHAR(10)) FROM Custom_Order_Chasu WHERE Order_Seq = A.Order_Seq), '') AS CHASU 
		   ,   ISNULL((SELECT MAX('Y') FROM Custom_Order_History WHERE Order_Seq = A.Order_Seq AND HTYPE = '검증취소'), 'N') AS VERIFY_YORN 
		   ,  src_printer_seq
		   , proc_date1
	INTO #ResultData
	FROM Custom_Order AS A 
	JOIN S2_Card AS B ON A.Card_Seq = B.Card_Seq
	JOIN S2_CardOption AS C ON A.Card_Seq = C.Card_Seq 
	JOIN Card_Corel AS D ON B.Card_Code = D.Card_Code 
	LEFT JOIN Custom_Order_Chasu AS E ON A.Order_Seq = E.Order_Seq 
	LEFT JOIN (select order_seq, count(order_seq) cnt from custom_order_plist where  print_type <> 'E' group by order_seq ) T ON A.order_seq =  T.order_seq 

	WHERE 1 = 1 
		AND A.settle_Status = 2  

		
		AND ( 
			 ISNULL(@PRINTER_SEQ,'') = ''--전체
			 OR	CASE WHEN ISNULL(A.src_printer_seq,0) <> 2 THEN 0 ELSE 2 END = @PRINTER_SEQ  
		)	
		

		--주문번호로 검색
		AND ( 
				ISNULL(@ORDER_SEQ, '') = '' OR A.order_seq = LTRIM(RTRIM(@ORDER_SEQ) )
		)
		
		--카드코드로 검색
		AND ( 
				ISNULL(@CARD_CODE, '') = '' OR B.card_code LIKE '%'+LTRIM(RTRIM(@CARD_CODE))+'%'  
		)
		 
		--주문진행 상태에 따른 검색  @PrintCompleted = 인쇄완료여부
		AND ( 
				( @bWhereBypass = 'Y')	--조건통과
			OR	( A.src_closecopy_date IS NOT NULL AND A.status_seq BETWEEN 9 AND CASE @PrintCompleted WHEN '0' THEN 11 ELSE 15 END   ) 
		)		
		  
		--차수체크 검색시 차수기간 검색조건
		AND ( 
				( @bWhereBypass = 'Y' OR @ChasuChk = '0')	--조건통과
			OR	( @ChasuChk = '1' 
					AND A.order_seq IN ( SELECT E.order_seq FROM Custom_Order_Chasu E WHERE E.pdate BETWEEN @ChasuSDATE AND @ChasuEDATE ) 				
				) 	
		)	
		

		--특정기간으로 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ChasuChk = '1' OR @SrchCase NOT IN ('0', '1', '2', '3'))	--조건통과			
			OR	( @ChasuChk = '0' AND @SrchCase = '0' AND CONVERT(CHAR(8), A.order_date, 112) BETWEEN @SrchSDate AND @SrchEDate ) 
			OR	( @ChasuChk = '0' AND @SrchCase = '1' AND CONVERT(CHAR(8), A.src_confirm_date, 112) BETWEEN @SrchSDate AND @SrchEDate ) 
			OR	( @ChasuChk = '0' AND @SrchCase = '2' AND CONVERT(CHAR(8), A.src_printW_date, 112) BETWEEN @SrchSDate AND @SrchEDate ) 
			OR	( @ChasuChk = '0' AND @SrchCase = '3' AND CONVERT(CHAR(8), A.src_print_date, 112) BETWEEN @SrchSDate AND @SrchEDate ) 		
		)


		--삼성동판 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '3' )	--조건통과
			OR	( @ORDER_TYPE = '3' 
					AND ( A.order_type = '7' OR C.isLetterPress = '1' OR C.PrintMethod <> '000' )
					AND B.card_code NOT IN (SELECT HardCode FROM HardCodingList WHERE HardID = 'SAMSUNG_GOLDFOIL' AND HardUse = 'Y')
					--AND (select count(1) from custom_order_plist where order_seq = A.order_seq AND print_type <> 'E') > 0  
					AND A.card_seq NOT IN (SELECT card_seq FROM CopperPlateExclude  ) 
					AND ISNULL(T.cnt,0) > 0
				)
		)

		--레이저컷(외부) 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '4' )	--조건통과
			OR	( @ORDER_TYPE = '4' AND C.isLaser = '1' )
		)

		--레이저컷(내부) 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '5' )	--조건통과
			OR	( @ORDER_TYPE = '5' AND C.isLaser = '2' )
		)

		--지구나무 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '6' )	--조건통과
			OR	( @ORDER_TYPE = '6' AND C.isJigunamu IN ('1', '2', '3') )
		)

		--산타아트 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '7' )	--조건통과
			OR	( @ORDER_TYPE = '7' AND C.isLetterPress = '1' )
		)

		--태산 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '8' )	--조건통과
			OR	( @ORDER_TYPE = '8' AND A.order_type = '6' AND ISNULL(C.isInternalDigital, '') <> '1' AND C.isCustomDColor = '1' AND D.WEPOD_YORN = 'Y'  )
			OR  ( @ORDER_TYPE = '8' AND EXISTS ( SELECT Order_seq FROM #TAESAN_SUB_CARD where A.order_seq = order_seq  ) )
			
			--OR  ( @ORDER_TYPE = '8' AND A.order_seq IN ( SELECT Order_seq FROM #TAESAN_SUB_CARD ) )
			 
			
		)
		
		--삼성금박 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '9' )	--조건통과
			OR	( @ORDER_TYPE = '9' AND A.order_type = '7' --이니셜 
			AND B.card_code IN (SELECT HardCode FROM HardCodingList WHERE HardID = 'SAMSUNG_GOLDFOIL' AND HardUse = 'Y') )
		)

		--광일(현대금박) 검색시 -  #5945 외주 가공처 변경 (금박   현대 금박 추가)
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '16' )	--조건통과
			OR	( @ORDER_TYPE = '16' AND A.order_type = '7' --이니셜 
			AND B.card_code IN (SELECT HardCode FROM HardCodingList WHERE HardID = 'HYUNDAI_GOLDFOIL' AND HardUse = 'Y') )
		)

		--원모어띵 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '10' )	--조건통과
			OR	( @ORDER_TYPE = '10' AND B.card_code LIKE 'PR0%' )
		)

		--제이플레져 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '11' )	--조건통과
			OR	( @ORDER_TYPE = '11' AND B.card_code LIKE 'PR1%' )
		)

		--마디카드(내부) 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '12' )	--조건통과
			OR	( @ORDER_TYPE = '12' AND (C.isMasterDigital = '1' OR A.ORDER_SEQ in (SELECT ORDER_SEQ FROM #POCKET_SUB_CARD)) and proc_date2 is not null)
		)

		--페니클레 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '13' )	--조건통과
			OR	( @ORDER_TYPE = '13' AND B.card_code LIKE 'PR2%' )
		)
		
		--디지털(내부) 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '14' )	--조건통과
			OR	( @ORDER_TYPE = '14' AND A.order_type in ('6','7') AND (C.isInternalDigital = '1' OR  A.ORDER_SEQ in (SELECT ORDER_SEQ FROM #POCKET_SUB_CARD))  and proc_date2 is not null)		-- AND A.order_type = '6' 일단 주석처리.
		)
			   		 
		--@ORDER_TYPE 전체 검색시
		AND ( 
				( @bWhereBypass = 'Y' OR @ORDER_TYPE <> '0' OR @ChasuChk = '1'  )	--조건통과
			OR	( @ORDER_TYPE = '0' 
					AND ( A.order_type = '7' OR C.isLetterPress = '1' OR C.PrintMethod <> '000' )
					AND B.card_code NOT IN (SELECT HardCode FROM HardCodingList WHERE HardID = 'SAMSUNG_GOLDFOIL' AND HardUse = 'Y')
					AND B.card_code NOT IN (SELECT HardCode FROM HardCodingList WHERE HardID = 'HYUNDAI_GOLDFOIL' AND HardUse = 'Y') -- #5945 외주 가공처 변경 (금박   현대 금박 추가)
					AND (select count(1) from custom_order_plist where order_seq = A.order_seq AND print_type <> 'E') > 0  
					AND A.card_seq NOT IN (SELECT card_seq FROM CopperPlateExclude  ) 
				)
			OR	( @ORDER_TYPE = '0' AND C.isLaser = '1' )
			OR	( @ORDER_TYPE = '0' AND C.isLaser = '2' )
			OR	( @ORDER_TYPE = '0' AND C.isJigunamu IN ('1', '2', '3') )
			OR	( @ORDER_TYPE = '0' AND C.isLetterPress = '1' )
			OR	( @ORDER_TYPE = '0' AND A.order_type = '6' AND ISNULL(C.isInternalDigital, '') <> '1' AND C.isCustomDColor = '1' AND D.WEPOD_YORN = 'Y'  )
			OR  ( @ORDER_TYPE = '0' AND EXISTS ( SELECT Order_seq FROM #TAESAN_SUB_CARD where A.order_seq = order_seq  ) )
			OR	( @ORDER_TYPE = '0' AND A.order_type = '7' AND B.card_code IN (SELECT HardCode FROM HardCodingList WHERE HardID = 'SAMSUNG_GOLDFOIL' AND HardUse = 'Y') )
			OR	( @ORDER_TYPE = '0' AND B.card_code LIKE 'PR0%' )
			OR	( @ORDER_TYPE = '0' AND B.card_code LIKE 'PR1%' )
			OR	( @ORDER_TYPE = '0' AND (C.isMasterDigital = '1' OR A.ORDER_SEQ in (SELECT ORDER_SEQ FROM #POCKET_SUB_CARD))  )
			OR	( @ORDER_TYPE = '0' AND B.card_code LIKE 'PR2%' )
			OR	( @ORDER_TYPE = '0' AND A.order_type = '6' AND C.isInternalDigital = '1'  )
		)
		

SELECT TOP (@PageSize) *, B.pseq 
FROM #ResultData A
LEFT JOIN Custom_Order_Chasu B ON A.order_seq = B.order_seq
WHERE A.order_seq IN ( SELECT DISTINCT A.order_seq FROM #ResultData A JOIN custom_order_plist B ON A.order_seq = B.order_seq AND B.isNotPrint = 0 )
		
		--차수체크 검색시 차수번호 검색조건
		AND ( 
					( @bWhereBypass = 'Y' OR @ChasuChk = '0')	--조건통과
				OR	( @ChasuChk = '1' AND B.pseq BETWEEN ISNULL(ISNULL(@ChasuS, @ChasuE), 0) AND ISNULL(ISNULL(@ChasuE, @ChasuS), 999) )  
			) 	

ORDER BY ( CASE WHEN @OrderBy = '0' THEN A.src_printW_date ELSE 1 END )
	, ( CASE WHEN @OrderBy = '1' THEN B.pseq ELSE 1 END )
	, ( CASE WHEN @OrderBy = '2' THEN A.order_seq  ELSE 1 END )
	, ( CASE WHEN @OrderBy = '3' THEN A.card_code  ELSE '1' END )
	, ( CASE WHEN @OrderBy NOT IN ( '0', '1', '2', '3') THEN A.card_code  ELSE '1' END )
	, A.src_printW_date, A.order_seq
END
GO
