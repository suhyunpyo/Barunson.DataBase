IF OBJECT_ID (N'dbo.SP_INSERT_OUTSOURCING_ORDER_MST_FOR_BBARUNSON_20200721_backup', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_OUTSOURCING_ORDER_MST_FOR_BBARUNSON_20200721_backup
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
/*  
  
SELECT * FROM COMMON_CODE  
SELECT * FROM OUTSOURCING_ORDER_MST  
EXEC SP_INSERT_OUTSOURCING_ORDER_MST '100011', null, 'BH4704', '테스트', 100, '용지 종류', '용지 크기', 1, 0, 'Y', 'Y', 'Y', 'Y', 'Y', '금', 'Y', '107001', '108001'  
  
UPDATE OUTSOURCING_ORDER_MST SET   
BOTH_SIDE_YORN = 'Y'  
,OSI_YORN = 'Y'  
,CUTOUT_YORN = 'Y'  
,GLOSSY_YORN = 'Y'  
,PRESS_YORN = 'Y'  
,FOIL_TYPE_NAME = '금'  
,LASER_CUT_YORN = 'Y'  
  
  
SELECT * FROM S2_CARD WHERE CARD_CODE = 'BH4145'  
SELECT * FROM S2_CARDOPTION WHERE CARD_SEQ = 34955  
  
EXEC SP_INSERT_OUTSOURCING_ORDER_MST_FOR_BBARUNSON 2143980, '관리자', '107001'  
  
*/  
  
CREATE PROCEDURE [dbo].[SP_INSERT_OUTSOURCING_ORDER_MST_FOR_BBARUNSON_20200721_backup]  
    @P_ORDER_SEQ                  AS INT  
,   @P_REQUESTOR_NAME             AS NVARCHAR(100)  
,   @P_COMPANY_TYPE_CODE          AS VARCHAR(6)  
,   @PDF_CARDCODE          AS VARCHAR(20)  

AS  
BEGIN  
  
	DECLARE	@SITE_TYPE_CODE         AS VARCHAR(6)  
		,   @ERP_PART_TYPE_CODE     AS VARCHAR(6)  
		,   @SITE_NAME              AS NVARCHAR(200)  
		,   @CARD_SEQ               AS INT  
		,   @ORDER_QTY              AS INT  
		,   @ORDER_NAME             AS NVARCHAR(200)  
		,   @ORDER_STATUS_CODE      AS VARCHAR(6)  
		,   @PAPER_TYPE_NAME        AS NVARCHAR(400)  
		,   @PAPER_SIZE             AS NVARCHAR(400)  
		,   @PAGES_PER_SHEET_VALUE  NUMERIC(18, 2)  
		,   @PRINT_LOSS_VALUE       NUMERIC(18, 2)  
		,   @BOTH_SIDE_YORN         CHAR(1)  
		,   @LASER_CUT_YORN         CHAR(1)  
		,   @OSI_YORN               CHAR(1)  
		,   @CUTOUT_YORN            CHAR(1)  
		,   @GLOSSY_YORN            CHAR(1)  
		,   @PRESS_YORN             CHAR(1)  
		,   @FOIL_TYPE_NAME         AS NVARCHAR(100)  
		,   @DELIVERY_TYPE_CODE     AS VARCHAR(6)  
		,   @PRINT_FILE_URL         AS VARCHAR(500)  
		
		,   @CARD_CODE              AS NVARCHAR(20)  
		,   @ERP_CARD_CODE          AS NVARCHAR(20)  
		,   @SRC_CLOSECOPY_DATE     AS VARCHAR(6)  
		,   @PRINT_FILE_NAME_ORIGINAL AS VARCHAR(200)  
		,   @PRINT_FILE_NAME_DOWNLOAD AS VARCHAR(200)  
		,   @PRINT_FILE_DEFAULT_URL   AS VARCHAR(100)  
		,   @PRINT_CHASU   AS VARCHAR(20)  

  
	 /* Initialize */      
	 SET	@ORDER_STATUS_CODE = '100011'   --주문완료  
	 SET	@PAPER_TYPE_NAME = ''  
	 SET	@PAPER_SIZE = ''  
	 SET	@PAGES_PER_SHEET_VALUE = 1        
	 SET	@PRINT_LOSS_VALUE = 0  
	 SET	@BOTH_SIDE_YORN = 'N'  
	 SET	@LASER_CUT_YORN = 'N'  
	 SET	@OSI_YORN = 'N'  
	 SET	@CUTOUT_YORN = 'N'  
	 SET	@GLOSSY_YORN = 'N'  
	 SET	@PRESS_YORN = 'N'  
	 SET	@FOIL_TYPE_NAME = ''  
	 SET	@DELIVERY_TYPE_CODE = '108001'  
	 SET	@PRINT_FILE_DEFAULT_URL = 'http://sasikfile.bhandscard.com/sasik_work/OutsourcingPrintFile/pdf_download.asp?'  
	 SET	@SRC_CLOSECOPY_DATE = CONVERT(VARCHAR(6), GETDATE(), 112)  
	 SET	@ERP_PART_TYPE_CODE = '111099'  

	 /* 주문 정보 셋팅 */  
	 SELECT	@CARD_SEQ = MAX(CO.CARD_SEQ)  
		,   @ORDER_NAME = MAX(CO.ORDER_NAME)  
		,   @ORDER_QTY = MAX(CO.ORDER_COUNT)  
		,   @SRC_CLOSECOPY_DATE = CONVERT(VARCHAR(6), MAX(ISNULL(CO.SRC_CLOSECOPY_DATE, GETDATE())), 112)  
		,   @SITE_TYPE_CODE =	CASE    
									WHEN MAX(CO.SALES_GUBUN) = 'SB' THEN '109001'  
									WHEN MAX(CO.SALES_GUBUN) IN ( 'SA' , 'C' ) THEN '109002'  
									WHEN MAX(CO.SALES_GUBUN) = 'ST' THEN '109003'  
									WHEN MAX(CO.SALES_GUBUN) = 'SS' THEN '109004'  
									WHEN MAX(CO.SALES_GUBUN) = 'B' THEN '109005'  
									WHEN MAX(CO.SALES_GUBUN) = 'H' THEN '109006'  
									WHEN MAX(CO.SALES_GUBUN) = 'D' THEN '109007'  
									WHEN MAX(CO.SALES_GUBUN) = 'Q' THEN '109008'  
									WHEN MAX(CO.SALES_GUBUN) = 'P' THEN '109009'  
									WHEN MAX(CO.SALES_GUBUN) = 'SG' THEN '109010'  
									WHEN MAX(CO.SALES_GUBUN) = 'SD' THEN '109011'  
									ELSE '109000'  
								END  
		,   @SITE_NAME      =   CASE    
									WHEN MAX(CO.SALES_GUBUN) = 'SB' THEN '바른손카드'  
									WHEN MAX(CO.SALES_GUBUN) IN ( 'SA' , 'C' ) THEN '비핸즈카드'  
									WHEN MAX(CO.SALES_GUBUN) = 'ST' THEN '더카드'  
									WHEN MAX(CO.SALES_GUBUN) = 'SS' THEN '프리미어페이퍼'  
									WHEN MAX(CO.SALES_GUBUN) = 'B' THEN '바른손몰(B)'  
									WHEN MAX(CO.SALES_GUBUN) = 'H' THEN '바른손몰(H)'  
									WHEN MAX(CO.SALES_GUBUN) = 'D' THEN '대리점'  
									WHEN MAX(CO.SALES_GUBUN) = 'Q' THEN '지역대리점'  
									WHEN MAX(CO.SALES_GUBUN) = 'P' THEN '아웃바운드'  
									WHEN MAX(CO.SALES_GUBUN) = 'SG' THEN '해외영업'  
									WHEN MAX(CO.SALES_GUBUN) = 'SD' THEN '디얼디어'  
									ELSE '109000'  
								END  
		,   @ERP_PART_TYPE_CODE = ISNULL((SELECT TOP 1 CMMN_CODE FROM COMMON_CODE WHERE CLSS_CODE = '111' AND RMRK_CLMN = MAX(C.ERP_PARTCODE)), '111099')  

	FROM    CUSTOM_ORDER CO  
	INNER JOIN	COMPANY C ON CO.COMPANY_SEQ = C.COMPANY_SEQ  
	WHERE   CO.ORDER_SEQ = @P_ORDER_SEQ  
  
	/* 셋트 수량이 0일 경우 */  
	IF @ORDER_QTY = 0  
	BEGIN  
	/*
		SELECT  @ORDER_QTY = MAX(COI.item_count)  
		FROM    CUSTOM_ORDER CO  
		INNER JOIN    CUSTOM_ORDER_ITEM COI ON CO.ORDER_SEQ = COI.ORDER_SEQ AND CO.CARD_SEQ = COI.CARD_SEQ  
		WHERE   CO.ORDER_SEQ = @P_ORDER_SEQ  
	*/
		IF @P_COMPANY_TYPE_CODE = '107008'		/*태산인 경우 사고건 포함하여 각각의 껀이 넘어올 수 있음 2020.05.20 김수경 추가. */
		BEGIN
			SELECT TOP 1 @ORDER_QTY = MAX(A.print_count)  
			FROM    custom_order_plist AS A JOIN S2_CARD  AS SC ON A.CARD_SEQ = SC.CARD_SEQ
			WHERE A.ORDER_SEQ = @P_ORDER_SEQ AND SC.Card_Code=@PDF_CARDCODE
		END
		ELSE
		BEGIN
			SELECT  @ORDER_QTY = MAX(COI.item_count)  
			FROM    CUSTOM_ORDER CO  
			INNER JOIN    CUSTOM_ORDER_ITEM COI ON CO.ORDER_SEQ = COI.ORDER_SEQ AND CO.CARD_SEQ = COI.CARD_SEQ  
			WHERE   CO.ORDER_SEQ = @P_ORDER_SEQ		  
		END
	END  
  
  
	--태산일 경우 PDF생성코드로 card_seq
	IF @P_COMPANY_TYPE_CODE = '107008'  
	BEGIN  
			SELECT TOP 1 @CARD_SEQ = A.card_seq
			FROM custom_order_plist AS A
			JOIN S2_CARD AS SC ON A.CARD_SEQ = SC.CARD_SEQ AND SC.Card_Code = @PDF_CARDCODE
			WHERE A.order_seq = @P_ORDER_SEQ 
	END
	ELSE 
	BEGIN 
		
		IF EXISTS ( 
			SELECT B.card_Code 
			FROM custom_order_plist A JOIN S2_Card B ON A.card_seq = B.Card_Seq 
			WHERE A.order_seq = @P_ORDER_SEQ
				AND B.card_code in ( SELECT HardCode FROM HardCodingList WHERE HardID = 'DigitalCardCode' ) 
		)
		BEGIN 
				SELECT TOP 1 @CARD_SEQ = A.card_seq
				FROM custom_order_plist A 
				JOIN S2_Card B ON A.card_seq = B.Card_Seq 
				WHERE A.order_seq = @P_ORDER_SEQ
					AND B.card_code in ( SELECT HardCode FROM HardCodingList WHERE HardID = 'DigitalCardCode' )
		END 
	END 

	   
	
	/* 카드 코드 셋팅 */  
	IF EXISTS(SELECT CARD_SEQ FROM S2_CARD WHERE CARD_SEQ = @CARD_SEQ)
	BEGIN  
		SELECT  @CARD_CODE = LTRIM(RTRIM(CARD_CODE))
			,   @ERP_CARD_CODE = LTRIM(RTRIM(CARD_ERPCODE))
		FROM    S2_CARD   
		WHERE   CARD_SEQ = @CARD_SEQ  
	END  


    /* 2018-04-18 : BH7604, BH7606인 경우에는 디지털카드의 ERP코드로 대치한다. */
    IF ( @ERP_CARD_CODE IN ( 'BH7604', 'BH7606') )
		SET @ERP_CARD_CODE = 'BH7604_I'


	/* 양면 / 단면 */  
	IF (EXISTS(SELECT * FROM CARD_COREL WHERE CARD_CODE = @CARD_CODE))  
	BEGIN  
		SELECT  TOP 1  
			@BOTH_SIDE_YORN = BOTH_SIDE_YORN  
		FROM    CARD_COREL   
		WHERE   CARD_CODE = @CARD_CODE  
	END  

	/* 박/광/압 */  
	IF (EXISTS(SELECT * FROM S2_CARDOPTION WHERE CARD_SEQ = @CARD_SEQ))  
	BEGIN  
		SELECT  TOP 1 @FOIL_TYPE_NAME = CASE SUBSTRING(PRINTMETHOD, 1, 1) 
												WHEN 'G' THEN '금박'  
												WHEN 'S' THEN '은박'  
												WHEN 'C' THEN '동박'  
												WHEN 'B' THEN '먹박'  
											ELSE ''  
										END  
			,   @GLOSSY_YORN = CASE WHEN SUBSTRING(PRINTMETHOD, 2, 1) = '1' THEN 'Y' ELSE 'N' END  
			,   @PRESS_YORN  = CASE WHEN SUBSTRING(PRINTMETHOD, 3, 1) = '1' THEN 'Y' ELSE 'N' END  
		FROM    S2_CARDOPTION   
		WHERE   CARD_SEQ = @CARD_SEQ  
	END  

	/* 레이저 업체 */  
	IF @P_COMPANY_TYPE_CODE = '107004' OR @P_COMPANY_TYPE_CODE = '107005'  
	BEGIN  
		SET @LASER_CUT_YORN = 'Y'  
		SET @DELIVERY_TYPE_CODE = '108002'  
	END  
  


  
	/* ERP 정보 셋팅 */  
	IF (EXISTS(SELECT * FROM [erpdb.bhandscard.com].[XERP].dbo.VW_CARD_PRINT_INFO_WITH_WEPOD WHERE CARD_CODE = @ERP_CARD_CODE))  
	BEGIN  
		SELECT  TOP 1  
				@PAPER_TYPE_NAME = PAPER_NAME  
			,   @PAPER_SIZE = CHILDITEMSPEC  
			,   @PAGES_PER_SHEET_VALUE = PAPER_COMPOSITION  
			,   @CUTOUT_YORN = CASE WHEN CUTOUT_USE = 'O' THEN 'Y' ELSE 'N' END  
			,   @OSI_YORN = CASE WHEN OSI_USE = 'O' THEN 'Y' ELSE 'N' END  
		FROM    [erpdb.bhandscard.com].[XERP].dbo.VW_CARD_PRINT_INFO_WITH_WEPOD  
		WHERE   CARD_CODE = @ERP_CARD_CODE  
  
		/* LOSS */  
		SET @PRINT_LOSS_VALUE = CASE WHEN @CARD_CODE IN ('BH7724', 'BH7750', 'BH7754', 'BH8741', 'BH8759', 'BH8776M', 'BH8782', 'BH8788', 'BH8903', 'BH8904', 'BH8907', 'BH8908') THEN 20 
										ELSE  
										CASE WHEN @PAGES_PER_SHEET_VALUE = 3 THEN  
													CASE WHEN @ORDER_QTY < 350 THEN 5  
															WHEN @ORDER_QTY >= 350 AND @ORDER_QTY < 400 THEN 6  
															WHEN @ORDER_QTY >= 400 AND @ORDER_QTY < 450 THEN 7  
															WHEN @ORDER_QTY >= 450 AND @ORDER_QTY < 550 THEN 8  
															WHEN @ORDER_QTY >= 550 AND @ORDER_QTY < 600 THEN 9  
															WHEN @ORDER_QTY >= 600 THEN 10  
															ELSE 10  
													END  
												WHEN @PAGES_PER_SHEET_VALUE = 4 THEN  
													CASE   
														WHEN @ORDER_QTY < 450 THEN 5  
														WHEN @ORDER_QTY >= 450 AND @ORDER_QTY < 550 THEN 6  
														WHEN @ORDER_QTY >= 550 AND @ORDER_QTY < 600 THEN 7  
														WHEN @ORDER_QTY >= 600 AND @ORDER_QTY < 700 THEN 8  
														WHEN @ORDER_QTY >= 700 AND @ORDER_QTY < 800 THEN 9  
														WHEN @ORDER_QTY >= 800 THEN 10  
														ELSE 10  
													END  
										END  
								END  

	END





	--태산일 경우는 PDF생성시 주문번호뒤에 카드코드가 포함된 파일명이 생성됨.
	IF @P_COMPANY_TYPE_CODE = '107008'
	BEGIN 
		SET	@PRINT_FILE_NAME_ORIGINAL = CAST(@P_ORDER_SEQ AS VARCHAR(20)) + '_' + @CARD_CODE + '.pdf'  
	END
	ELSE
	BEGIN
		SET	@PRINT_FILE_NAME_ORIGINAL = CAST(@P_ORDER_SEQ AS VARCHAR(20)) + '.pdf'  
	END 


	/* 원본 파일 이름, 다운로드시 파일 이름 */  
	SET @PRINT_FILE_NAME_ORIGINAL = '\' + @SRC_CLOSECOPY_DATE + '\' + @PRINT_FILE_NAME_ORIGINAL  

	SELECT @PRINT_FILE_NAME_ORIGINAL = CASE @P_COMPANY_TYPE_CODE 
											WHEN '107001' THEN '\Haksul'
											WHEN '107002' THEN '\Wepod'
											WHEN '107003' THEN '\SamsungDongpan'		--삼성동판
											WHEN '107004' THEN '\LaserCafe'
											WHEN '107005' THEN '\LaserCutInside'
											WHEN '107006' THEN '\Wepod'
											WHEN '107007' THEN '\SantaArt'
											WHEN '107008' THEN '\Taesan'				--태산
											WHEN '107009' THEN '\SamsungDongpan'		--삼성금박
											WHEN '107010' THEN '\OneMoreThing'
											WHEN '107011' THEN '\JPleasure'
											WHEN '107012' THEN '\MasterDigitalCard'
											WHEN '107013' THEN '\Penicle'
											WHEN '107014' THEN '\InternalDigitalCard'
											WHEN '107015' THEN '\RedPrinting'
										ELSE '\Other' END + @PRINT_FILE_NAME_ORIGINAL  


										
	--아웃소싱 페이지에서 PDF다운받을시 파일명 지정.
	SET	@PRINT_FILE_NAME_DOWNLOAD = CAST(@P_ORDER_SEQ AS VARCHAR(20)) + '_' + @CARD_CODE + '.pdf'  


	/* 동판 - 형압 일경우 파일명에 형압 표시 */  
	--삼성동판
	IF @P_COMPANY_TYPE_CODE = '107003'  
	BEGIN  
		SET @PRINT_FILE_NAME_DOWNLOAD = ''  
  
		IF @PRESS_YORN = 'Y'  
			SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '_형압'  
  
		IF @GLOSSY_YORN = 'Y'  
			SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '_유광'  
  
		IF @FOIL_TYPE_NAME <> ''  
			SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '_' + @FOIL_TYPE_NAME  
  
		SET @PRINT_FILE_NAME_DOWNLOAD = CAST(@P_ORDER_SEQ AS VARCHAR(100)) + @PRINT_FILE_NAME_DOWNLOAD + '_' + LTRIM(RTRIM(@CARD_CODE)) + '.pdf'  
	END  
      
	
	/* 위피오디 / 지구나무 / 태산 / 원모어띵 / 제이플레져 / 마디카드(내부) / 페니클레 / 디지털(내부) */  
	IF ( @P_COMPANY_TYPE_CODE IN ( '107002', '107006', '107008', '107010', '107011', '107012', '107013', '107014' ))
	BEGIN  
		SET @PRINT_FILE_NAME_DOWNLOAD = CAST(@P_ORDER_SEQ AS VARCHAR(100)) + '_' + @PAPER_TYPE_NAME  
		SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '_조판수(_' + CAST(FLOOR(@PAGES_PER_SHEET_VALUE) AS VARCHAR(10)) + '_)'  
		SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '_주문수량(_' + CAST(FLOOR(@ORDER_QTY) AS VARCHAR(10)) + '_)'  
		SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '_' + LTRIM(RTRIM(@CARD_CODE)) + '.pdf'  
	END  

	/* 레이저컷 외부, 내부 */  
	IF ( @P_COMPANY_TYPE_CODE IN ( '107004', '107005' ))
	BEGIN  
		SET @PRINT_FILE_NAME_DOWNLOAD = CAST(@P_ORDER_SEQ AS VARCHAR(100)) + '_' + LTRIM(RTRIM(@CARD_CODE))  
		SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '_주문수량(_' + CAST(FLOOR(@ORDER_QTY) AS VARCHAR(10)) + '_)'  
		SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '_사이트명(_' + @SITE_NAME + '_)'  
		SET @PRINT_FILE_NAME_DOWNLOAD = @PRINT_FILE_NAME_DOWNLOAD + '.pdf'  
  
		SET @PRINT_LOSS_VALUE = 10

		IF @ORDER_QTY > 500  
			SET @PRINT_LOSS_VALUE = 15  
	END  
  
	SET @PRINT_FILE_URL = @PRINT_FILE_DEFAULT_URL + 'file_url=' + @PRINT_FILE_NAME_ORIGINAL + '&dn_file_name=' + @ORDER_NAME + '_' + @PRINT_FILE_NAME_DOWNLOAD  

	
	--인쇄 차수
	SELECT TOP 1 @PRINT_CHASU = ISNULL(LTRIM(RTRIM(pdate)), '')+'-'+ISNULL(TRY_CAST(pseq AS VARCHAR(3)), '')+'-'+ISNULL(TRY_CAST(oseq AS VARCHAR(3)), '')+'차'
	FROM custom_order_chasu WITH(NOLOCK)
	WHERE order_seq = @P_ORDER_SEQ


  
	INSERT INTO OUTSOURCING_ORDER_MST     
	(		ORDER_STATUS_CODE  
		,   ORDER_TYPE_CODE  
		,	ORDER_SUB_TYPE_CODE  
		,   SITE_TYPE_CODE  
		,   ERP_PART_TYPE_CODE  
		,   ORDER_SEQ  
		,   CARD_CODE  
		,   ORDER_NAME  
		,   ORDER_QTY  
		,   PAPER_TYPE_NAME  
		,   PAPER_SIZE  
		,   PAGES_PER_SHEET_VALUE  
		,   PRINT_LOSS_VALUE  
		,   BOTH_SIDE_YORN  
		,   OSI_YORN  
		,   CUTOUT_YORN  
		,   GLOSSY_YORN  
		,   PRESS_YORN  
		,   FOIL_TYPE_NAME  
		,   LASER_CUT_YORN  
		,   REQUESTOR_NAME  
		,   COMPANY_TYPE_CODE  
		,   DELIVERY_TYPE_CODE  
		,   PRINT_FILE_URL  
		,	PRINT_CHASU
	)  
	VALUES    
	(		@ORDER_STATUS_CODE      
		,   '110001'   
		,	'120001'  
		,   @SITE_TYPE_CODE   
		,   @ERP_PART_TYPE_CODE  
		,   @P_ORDER_SEQ                
		,	CASE WHEN @ERP_CARD_CODE <> @CARD_CODE THEN @ERP_CARD_CODE+'('+@CARD_CODE+')' ELSE ISNULL(@ERP_CARD_CODE, @CARD_CODE) END	--,   @ERP_CARD_CODE                
		,   @ORDER_NAME               
		,   @ORDER_QTY                
		,   @PAPER_TYPE_NAME          
		,   @PAPER_SIZE               
		,   @PAGES_PER_SHEET_VALUE    
		,   @PRINT_LOSS_VALUE         
		,   @BOTH_SIDE_YORN         
		,   @OSI_YORN               
		,   @CUTOUT_YORN            
		,   @GLOSSY_YORN            
		,   @PRESS_YORN             
		,   @FOIL_TYPE_NAME         
		,   @LASER_CUT_YORN         
		,   @P_REQUESTOR_NAME  
		,   @P_COMPANY_TYPE_CODE  
		,   @DELIVERY_TYPE_CODE  
		,   @PRINT_FILE_URL  
		,	@PRINT_CHASU
	)  
  
END

GO
