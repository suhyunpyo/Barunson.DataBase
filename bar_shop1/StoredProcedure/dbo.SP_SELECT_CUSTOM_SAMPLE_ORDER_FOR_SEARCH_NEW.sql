IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

/*

	EXEC SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH 
			'', '', 'SA , SB , ST , SS , B , C , H ,', 0
		,	0, '2017-09-13', '2017-09-20'
		,	'', '', '', 0, '', 1, ''


	EXEC SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH    '2'  , 'kdh3633'  , ' SA,  SB , ST , SS , B , C , H , U , D , Q , P , SG , X , XB , G '  ,  0 ,  0 , '2017-09-13'  , '2017-09-20'  , ''  , ''  , ''  ,  0 , ''  ,  0 , '' 


	EXEC SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH    ''  , ''  , ' SA,  SB , ST , SS '  ,  0 ,  0 , '2017-09-13'  , '2017-09-20'  , ''  , ''  , ''  ,  0 , ''  ,  0 , 'EXCEL_WITH_ITEM' 


    EXEC SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH    ''  , ''  , ' SA , C , SB ,  ST , SS , B , H , U , D , Q , P , SG , X , XB , G , '  ,  0 ,  0 , '2018-02-20'  , '2018-02-20'  , ''  , ''  , ''  ,  0 , ''  ,  0 , 'EXCEL_WITH_ITEM'  , 0 

    EXEC SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH    ''  , ''  , ' SA , C , SB ,  ST , SS , B , H , U , D , Q , P , SG , X , XB , G , '  ,  0 ,  0 , '2018-02-20'  , '2018-02-20'  , ''  , ''  , ''  ,  0 , ''  ,  0 , 'EXCEL_WITH_ITEM'  , 0 


    EXEC SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH    ''  , ''  , ' SA , C , SB ,  ST , SS , B , H , U , D , Q , P , SG , X , XB , G , '  ,  0 ,  0 , '2018-01-01'  , '2018-01-31'  , ''  , ''  , ''  ,  0 , ''  ,  0 , 'EXCEL'  , 0

*/

CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH_NEW]
    @P_SEARCH_TYPE			AS VARCHAR(10)
,	@P_SEARCH_VALUE			AS VARCHAR(50)
,	@P_SALES_GUBUN_LIST		AS VARCHAR(100)
,	@P_STATUS_SEQ			AS INT
,	@P_SEARCH_DATE_TYPE		AS INT
,	@P_SEARCH_START_DATE	AS VARCHAR(10)
,	@P_SEARCH_START_HOUR	AS VARCHAR(2)
,	@P_SEARCH_END_DATE		AS VARCHAR(10)
,	@P_SEARCH_END_HOUR		AS VARCHAR(2)
,	@P_ONCLICK_SAMPLE		AS VARCHAR(1)
,	@P_ERP_PART_CODE		AS VARCHAR(20)
,   @P_JOIN_DEVICE			AS VARCHAR(20)
,	@P_PRINT_STATUS			AS INT
,	@P_PACK_TYPE			AS VARCHAR(10)
,	@P_ORDER_BY_TYPE		AS INT
,	@P_LIST_TYPE			AS VARCHAR(50)
,   @P_MEMBER_TYPE          AS INT = 0
,	@P_ONCLICK_SAMPLE_DIV	AS VARCHAR(5) = '00'
,	@P_FreeBrand 			AS VARCHAR(1) = ''
,	@P_FreeBrand_DIV		AS VARCHAR(5) = '00'

AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	--SET @P_SALES_GUBUN_LIST = REPLACE(@P_SALES_GUBUN_LIST, 'B , C', 'B')

	DECLARE @SEARCH_DATE_START_OF_DAY AS DATETIME
	DECLARE @SEARCH_DATE_END_OF_DAY AS DATETIME
	SET @SEARCH_DATE_START_OF_DAY = CAST(@P_SEARCH_START_DATE + ' ' + @P_SEARCH_START_HOUR + ':00:00' AS DATETIME)
	SET @SEARCH_DATE_END_OF_DAY = CAST(@P_SEARCH_END_DATE + ' ' + @P_SEARCH_END_HOUR + ':59:59' AS DATETIME)


	Declare @sampleorderseqs as table (sample_order_seq int)

	IF @P_SEARCH_DATE_TYPE = 0 
	  Begin
		insert into @sampleorderseqs
		Select [sample_order_seq] From CUSTOM_SAMPLE_ORDER with(nolock) Where REQUEST_DATE >= @SEARCH_DATE_START_OF_DAY And REQUEST_DATE <= @SEARCH_DATE_END_OF_DAY
	  End
	Else IF @P_SEARCH_DATE_TYPE = 1 
	   Begin
		insert into @sampleorderseqs
		Select [sample_order_seq] From CUSTOM_SAMPLE_ORDER with(nolock) Where SETTLE_DATE >= @SEARCH_DATE_START_OF_DAY And SETTLE_DATE <= @SEARCH_DATE_END_OF_DAY
	  End
	Else IF @P_SEARCH_DATE_TYPE = 2 
	   Begin
		insert into @sampleorderseqs
		Select [sample_order_seq] From CUSTOM_SAMPLE_ORDER with(nolock) Where PREPARE_DATE >= @SEARCH_DATE_START_OF_DAY And PREPARE_DATE <= @SEARCH_DATE_END_OF_DAY
	  End
	Else IF @P_SEARCH_DATE_TYPE = 3 
	   Begin
		insert into @sampleorderseqs
		Select [sample_order_seq] From CUSTOM_SAMPLE_ORDER with(nolock) Where DELIVERY_DATE >= @SEARCH_DATE_START_OF_DAY And DELIVERY_DATE <= @SEARCH_DATE_END_OF_DAY
	  End



	SELECT	1 AS STATUS
			,	CASE 
						WHEN @P_PACK_TYPE = 'PACK' THEN MEMBER_FAX
						ELSE ''
				END AS ORDER_BY_MULTI_PACK
			,	CASE	
						WHEN @P_ORDER_BY_TYPE = 1 THEN CSO.SETTLE_DATE
						WHEN @P_ORDER_BY_TYPE = 2 THEN CSO.PREPARE_DATE
						WHEN @P_ORDER_BY_TYPE = 3 THEN CSO.DELIVERY_DATE
						ELSE GETDATE()
				END AS ORDER_BY_DATE,
				VUI.INTERGRATION_DATE --회원가입일
			,	CSO.SAMPLE_ORDER_SEQ
			,	CSO.SALES_GUBUN
			,	C.ERP_PARTCODE
			,	CSO.COMPANY_SEQ
			,	CSO.REQUEST_DATE
			,	DATEPART(HOUR, CSO.REQUEST_DATE) AS REQUEST_HOUR
			,	CSO.PREPARE_DATE
			,	CSO.SETTLE_DATE
			,	DATEPART(HOUR, CSO.SETTLE_DATE) AS SETTLE_HOUR
			,	CSO.SETTLE_PRICE
			,	CSO.STATUS_SEQ

			,	ISNULL(CAST(CSO.MEMBER_FAX AS VARCHAR(20)), '') AS MEMBER_FAX
			,	ISNULL(CAST(CSO.MULTI_PACK_SEQ AS VARCHAR(20)), '') AS MULTI_PACK_SEQ
			,	ISNULL(CAST(CSO.MULTI_PACK_SUB_SEQ AS VARCHAR(20)), '') AS MULTI_PACK_SUB_SEQ
			,	ISNULL(CONVERT(VARCHAR(19), CSO.MULTI_PACK_REG_DATE, 120), '') AS MULTI_PACK_REG_DATE
			,	CASE WHEN CSO.MULTI_PACK_SEQ IS NULL THEN 'N' ELSE 'Y' END AS MULTI_PACK_YORN
			,	CSO.DELIVERY_DATE
			,	CSO.CANCEL_DATE
			,	CSO.DELIVERY_PRICE
			,	CSO.MEMBER_ID
			,	CSO.MEMBER_EMAIL
			,	CSO.MEMBER_NAME
			,	CSO.MEMBER_PHONE
			,	CSO.MEMBER_HPHONE
			,	CSO.MEMBER_ZIP
			,	CSO.MEMBER_ADDRESS + ' ' + CSO.MEMBER_ADDRESS_DETAIL AS MEMBER_ADDRESS
			,	DATEDIFF(YEAR, CASE WHEN ISDATE(VUI.BIRTH) = 1 THEN VUI.BIRTH ELSE GETDATE() END, GETDATE()) AS MEMBER_AGE
			,	C.COMPANY_NAME
			,	CSO.INVOICE_PRINT_YORN
			,	CSO.JOB_ORDER_PRINT_YORN
			,	CSO.DSP_PRINT_YORN
			,	CASE WHEN CSO.JOIN_DIVISION = 'WEB' THEN 'PC' WHEN CSO.JOIN_DIVISION = 'MOBILE' THEN 'MOBILE' ELSE '' END AS INFLOW_ROUTE
			,	ISNULL(CSO.ISONECLICKSAMPLE, 'N') AS ISONECLICKSAMPLE

			-- EXCEL 출력시에 필요한 항목
			,	CASE WHEN ISNULL(VUI.CHK_SMS, 'N') = 'Y' OR ISNULL(CSO.ChkNonUserSMSEMail, 'N') = 'Y' THEN 'Y' ELSE 'N' END AS SMS_YORN
			,	CASE WHEN ISNULL(CSO.MEMBER_ID, '') <> '' AND ISNULL(VUI.WEDD_YEAR, '') <> '' AND ISNULL(VUI.WEDD_MONTH, '') <> '' AND ISNULL(VUI.WEDD_DAY, '') <> '' THEN ISNULL(VUI.WEDD_YEAR + '-' + VUI.WEDD_MONTH + '-' + VUI.WEDD_DAY, '') 
                     ELSE ISNULL(CSO.WEDD_DATE, '')
                END AS WEDDING_DAY

			,   CASE WHEN CSO.SALES_GUBUN = 'SD' THEN CSO.MEMBER_ID ELSE (CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN '비회원' WHEN VUI.UID IS NULL THEN '탈퇴회원' ELSE CSO.MEMBER_ID END) END  AS [USER_ID]
			,   CASE WHEN CSO.SALES_GUBUN = 'SD' THEN '회원' ELSE (CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN '비회원' WHEN VUI.UID IS NULL THEN '탈퇴회원' ELSE '회원' END) END AS MEMBER_YORN
		
			-- EXCEL 출력시에 필요한 항목
			,   CASE 
						WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
						THEN ISNULL	(csos.ActualSampleSites, CSO.SALES_GUBUN)
						ELSE ''
				END AS ACTUAL_SAMPLE_SITE
		
			-- EXCEL 출력시에 필요한 항목
			,   CASE 
						WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
						THEN ISNULL	(csos.ActualOrderCount, 0)
						ELSE 0
				END AS ACTUAL_ORDER_CNT 

			-- EXCEL 출력시에 필요한 항목
			,   CASE 
						WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
						THEN ISNULL	(csos.ActualOrderSites, '')
						ELSE ''
				END AS ACTUAL_ORDER_SITE,

				청첩장주문일 =  CASE WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
									THEN ISNULL	(CONVERT(VARCHAR(10), csos.LatestOrderDate, 120), '')
									ELSE ''
									END ,
				청첩장결제일  =  CASE WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
									THEN ISNULL	(CONVERT(VARCHAR(10), csos.LatestSettleDate, 120), '')
									ELSE ''
									END ,
				청첩장배송일 =   CASE WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
									THEN ISNULL	(CONVERT(VARCHAR(10), csos.LatestSrcSendDate, 120), '')
									ELSE ''
									END ,
				회원가입사이트 =   CASE WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0 
									THEN 

											CASE
												WHEN VUI.REFERER_SALES_GUBUN = 'SB' THEN '바른손카드'
												WHEN VUI.REFERER_SALES_GUBUN = 'SS' THEN '프리미어페이퍼'
												WHEN VUI.REFERER_SALES_GUBUN = 'H' THEN '바른손몰(H)'
												WHEN VUI.REFERER_SALES_GUBUN = 'SA' THEN '비핸즈카드'
												WHEN VUI.REFERER_SALES_GUBUN = 'B' THEN '바른손몰(B)'
												WHEN VUI.REFERER_SALES_GUBUN = 'C' THEN '비핸즈카드 제휴'
												WHEN VUI.REFERER_SALES_GUBUN = 'ST' THEN '더카드'
												ELSE '기타'
											END 

									ELSE ''
									END 
				,회원가입일 = VUI.INTERGRATION_DATE
				-- EXCEL 출력시에 필요한 항목
				,   CASE 
						WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
						THEN ISNULL	(csos.ActualOrderCardSeqs, '')
						ELSE ''
					END AS ACTUAL_ORDER_CARD_SEQS
				
				,ADDR = CSO.MEMBER_ADDRESS
				,ADDR_DETAIL = CSO.MEMBER_ADDRESS_DETAIL
				,IsNull(convert(char(1), csos.HasLazer), '0') as HasLazer
				,IsNull(convert(char(1), csos.HasDigital), '0') as HasDigital
				,IsNull(convert(char(1), csos.HasPressure), '0') as HasPressure
				,IsNull(convert(char(1), csos.HasRolled), '0') as HasRolled
				,IsNull(OneClickSampleDiv, '') as OneClickSampleDiv,
				NonUserYn
				, SampleFreeParentSeq
				, CASE WHEN SampleFreeBrand = 'B' THEN '바' WHEN SampleFreeBrand = 'D' THEN '디' WHEN SampleFreeBrand = 'P' THEN '프' ELSE '' END as SampleFreeBrand
        INTO    #TEMP_CUSTOM_SAMPLE_ORDER
		FROM	CUSTOM_SAMPLE_ORDER AS CSO 
			Left Join Custom_Sample_Order_Statistics as csos on cso.sample_order_seq = csos.sample_order_seq
			LEFT JOIN COMPANY AS C  ON CSO.COMPANY_SEQ = C.COMPANY_SEQ
			Left JOIN S2_USERINFO_THECARD AS VUI ON CSO.MEMBER_ID = VUI.UID AND INTEGRATION_MEMBER_YORN = 'Y'
		WHERE	CSO.sample_order_seq in (Select sample_order_seq From @sampleorderseqs)
		AND 	CSO.DELIVERY_CHANGO = '1'
		AND		CSO.STATUS_SEQ >= 1 
		AND		(@P_STATUS_SEQ = 0 OR CSO.STATUS_SEQ = @P_STATUS_SEQ)
		AND		CSO.SALES_GUBUN IN ( SELECT VALUE FROM FN_SPLIT(REPLACE(@P_SALES_GUBUN_LIST, ' ', ''), ',') )
		AND		(@P_JOIN_DEVICE = '' OR (@P_JOIN_DEVICE <> '' AND CSO.JOIN_DIVISION = @P_JOIN_DEVICE))
		AND		(@P_ERP_PART_CODE = '' OR (@P_ERP_PART_CODE <> '' AND C.ERP_PARTCODE = @P_ERP_PART_CODE))
		-- 검색어 검색
		AND		(
					@P_SEARCH_TYPE = ''
					OR
					(
							@P_SEARCH_TYPE = '0'
						AND CASE WHEN ISNUMERIC(@P_SEARCH_VALUE) = 1 THEN CSO.SAMPLE_ORDER_SEQ ELSE 0 END
							=
							CASE WHEN ISNUMERIC(@P_SEARCH_VALUE) = 1 THEN CAST(@P_SEARCH_VALUE AS INT) ELSE 0 END
					)
					OR
					(
							@P_SEARCH_TYPE = '1'
						AND CSO.MEMBER_NAME LIKE '%' + @P_SEARCH_VALUE + '%'
					)
					OR
					(
							@P_SEARCH_TYPE = '2'
						AND CSO.MEMBER_ID LIKE '%' + @P_SEARCH_VALUE + '%'
					)
					OR
					(
							@P_SEARCH_TYPE = '4'
						AND REPLACE(CSO.member_hphone, '-', '') = REPLACE(@P_SEARCH_VALUE, '-', '')
					)
					OR
					(
							@P_SEARCH_TYPE = '5'
						AND CSO.DELIVERY_CODE_NUM = @P_SEARCH_VALUE
					)
				)

		-- 인쇄 상태 검색
		AND		(
					@P_PRINT_STATUS = 0
					OR
					(
							@P_PRINT_STATUS = 1
						AND	INVOICE_PRINT_YORN = 'Y'
					)
					OR
					(
							@P_PRINT_STATUS = 2
						AND	JOB_ORDER_PRINT_YORN = 'Y'
					)
					OR
					(
							@P_PRINT_STATUS = 3
						AND	DSP_PRINT_YORN = 'Y'
					)
				)        
	
		-- 원클릭 샘플 검색
		AND		(
					@P_ONCLICK_SAMPLE <> '1'
					OR
					(
							@P_ONCLICK_SAMPLE = '1'
						AND CSO.ISONECLICKSAMPLE = 'Y'
					)
				)
		-- 원클릭 샘플중에 그룹별 검색이 존재하면 해당 그룹만 나오게
		AND		(	
					@P_ONCLICK_SAMPLE_DIV = '00' -- 전체 원클릭 샘플
					OR
					(
						@P_ONCLICK_SAMPLE_DIV <> '00' -- 그룹별 검색
						AND CSO.OneClickSampleDiv = @P_ONCLICK_SAMPLE_DIV
					)
				)
		-- 타브랜드 샘플 검색
		AND		(	
					@P_FreeBrand <> '1'
					OR
					(
						@P_FreeBrand = '1'
						AND CSO.SampleFreeBrand IS NOT NULL
						AND CSO.SampleFreeBrand <> ''
					)
				)
		-- 타브랜드 샘플 중에 그룹별 검색이 존재하면 해당 그룹만 나오게
		AND		(	
					@P_FreeBrand_DIV = '00' -- 전체 원클릭 샘플
					OR
					(
						@P_FreeBrand_DIV <> '00' -- 그룹별 검색
						AND CSO.SampleFreeBrand = @P_FreeBrand_DIV
					)
				)
		-- 묶음 배송건 검색
		AND		(
					@P_PACK_TYPE = ''
					OR
					(
						@P_PACK_TYPE = 'PACK'
						AND CSO.MEMBER_FAX IS NOT NULL
					)
					OR
					(
						@P_PACK_TYPE = 'NORMAL'
						AND CSO.MEMBER_FAX IS NULL
					)
				)

        -- 회원/비회원 검색
        AND     (
					@P_MEMBER_TYPE = 0
            		OR
					(
    					@P_MEMBER_TYPE = 1 AND ISNULL(CSO.MEMBER_ID, '') <> ''
                    )
                    OR
                    (
                        @P_MEMBER_TYPE = 2 AND ISNULL(CSO.MEMBER_ID, '') = ''
                    )
                )
	--주문의 아이템개수별
	IF @P_LIST_TYPE = 'EXCEL_WITH_ITEM' 
	  BEGIN
		SELECT	DISTINCT
			CST.*
		,	CASE WHEN CST.ACTUAL_ORDER_CNT > 0 THEN 'Y' ELSE 'N' END AS ACTUAL_ORDER_YORN
		,   CHARINDEX(CAST(CSOI.CARD_SEQ AS VARCHAR(10)), CST.ACTUAL_ORDER_CARD_SEQS) AS ACTUAL_CARD_SAME_YORN
		,	ISNULL(SCV.OLD_CODE	    , '') AS OLD_CODE
		,	ISNULL(SCV.CARD_CODE	, '') AS CARD_CODE
		,	ISNULL(SCV.BRAND_NAME	, '') AS BRAND_NAME
		,	ISNULL(SCV.CARD_PRICE	, 0)  AS CARD_PRICE
		,	ISNULL(CSOI.CARD_PRICE	, 0)  AS CARD_SALE_PRICE
		,   '' AS IP
		,	PRODUCT_KIND = ''
		,	레이저여부	= CASE WHEN SCO.ISLASER <> '0' THEN '1' ELSE '0'  END 
		,	디지털여부	= CASE WHEN SCO.IsInternalDigital = '1' THEN '1' ELSE '0' END 
		,	형압여부	= CASE WHEN SUBSTRING(LTRIM(SCO.PRINTMETHOD),3,1) = '1' THEN '1' ELSE '0' END
		,	박여부		= CASE WHEN SUBSTRING(SCO.PRINTMETHOD, 1,1)  <> '0'  THEN '1' ELSE '0' END 
		FROM	#TEMP_CUSTOM_SAMPLE_ORDER CST
		LEFT OUTER JOIN	CUSTOM_SAMPLE_ORDER_ITEM CSOI ON CST.SAMPLE_ORDER_SEQ = CSOI.SAMPLE_ORDER_SEQ 
		LEFT OUTER JOIN	S2_CARDVIEWN AS SCV ON CSOI.CARD_SEQ = SCV.CARD_SEQ
		LEFT Outer Join S2_CARDOPTION as SCO On SCV.CARD_SEQ = SCO.CARD_SEQ
		ORDER BY CST.ORDER_BY_MULTI_PACK ASC
				,CST.ORDER_BY_DATE DESC
				,CST.SAMPLE_ORDER_SEQ DESC

	  END
	ELSE	--주문건별
	  BEGIN
		SELECT	DISTINCT
			CST.*
		,	CASE WHEN CST.ACTUAL_ORDER_CNT > 0 THEN 'Y' ELSE 'N' END AS ACTUAL_ORDER_YORN
		,   0 AS ACTUAL_CARD_SAME_YORN
		,	'' AS OLD_CODE
		,	'' AS CARD_CODE
		,	'' AS BRAND_NAME
		,	0  AS CARD_PRICE
		,	0  AS CARD_SALE_PRICE
		,   '' AS IP
		,	PRODUCT_KIND = ''
		,	레이저여부	= CST.HasRolled
		,	디지털여부	= CST.HasDigital
		,	형압여부	= CST.HasPressure
		,	박여부		= CST.HasRolled
		FROM	#TEMP_CUSTOM_SAMPLE_ORDER CST
		ORDER BY CST.ORDER_BY_MULTI_PACK ASC
				,CST.ORDER_BY_DATE DESC
				,CST.SAMPLE_ORDER_SEQ DESC
	  END
   
END

GO