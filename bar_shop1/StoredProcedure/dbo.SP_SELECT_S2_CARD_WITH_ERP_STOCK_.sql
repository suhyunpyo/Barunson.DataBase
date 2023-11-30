IF OBJECT_ID (N'dbo.SP_SELECT_S2_CARD_WITH_ERP_STOCK_', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S2_CARD_WITH_ERP_STOCK_
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

exec sp_executesql N' EXEC SP_SELECT_S2_CARD_WITH_ERP_STOCK_    @P_CARD_SET_PRICE_MIN  ,  @P_CARD_SET_PRICE_MAX  ,  @P_CARD_KIND_SEQ  ,  @P_CARD_BRAND  ,  @P_CARD_CODE_OR_CARD_NAME  ,  @P_PRODUCTION_STATUS_NAME  ,  @P_SAMPLE_ORDER_AVAILABLE_YORN  ,  @P_SITE_SEARCH_VALUE  ,  @P_SALES_TYPE  ,  @P_MIN_STOCK_UNDER_YORN  ,  @P_PAGE_SIZE  ,  @P_PAGE_NUMBER  ,  @P_ORDER_BY_NAME  ,  @P_ORDER_BY_TYPE ',N'@P_CARD_SET_PRICE_MIN int,@P_CARD_SET_PRICE_MAX int,@P_CARD_KIND_SEQ int,@P_CARD_BRAND nvarchar(4000),@P_CARD_CODE_OR_CARD_NAME nvarchar(4000),@P_PRODUCTION_STATUS_NAME nvarchar(25),@P_SAMPLE_ORDER_AVAILABLE_YORN nvarchar(4000),@P_SITE_SEARCH_VALUE nvarchar(29),@P_SALES_TYPE nvarchar(4000),@P_MIN_STOCK_UNDER_YORN nvarchar(1),@P_PAGE_SIZE int,@P_PAGE_NUMBER int,@P_ORDER_BY_NAME nvarchar(8),@P_ORDER_BY_TYPE nvarchar(4)',@P_CARD_SET_PRICE_MIN=0,@P_CARD_SET_PRICE_MAX=99999,@P_CARD_KIND_SEQ=0,@P_CARD_BRAND=N'',@P_CARD_CODE_OR_CARD_NAME=N'',@P_PRODUCTION_STATUS_NAME=N'정상판매|단종예정|발주대기|폐기대상|폐기|공백',@P_SAMPLE_ORDER_AVAILABLE_YORN=N'',@P_SITE_SEARCH_VALUE=N'5001|5006|5007|5003|5000|5008',@P_SALES_TYPE=N'',@P_MIN_STOCK_UNDER_YORN=N'N',@P_PAGE_SIZE=99999,@P_PAGE_NUMBER=1,@P_ORDER_BY_NAME=N'REG_DATE',@P_ORDER_BY_TYPE=N'DESC'

*/
CREATE PROCEDURE [dbo].[SP_SELECT_S2_CARD_WITH_ERP_STOCK_]
		@P_CARD_SET_PRICE_MIN AS INT
	,	@P_CARD_SET_PRICE_MAX AS INT
	,	@P_CARD_KIND_SEQ AS INT
	,	@P_CARD_BRAND AS VARCHAR(50)
	,	@P_CARD_CODE_OR_CARD_NAME AS VARCHAR(50)
	,	@P_PRODUCTION_STATUS_NAME AS VARCHAR(200)
	,	@P_SAMPLE_ORDER_AVAILABLE_YORN AS VARCHAR(1)
	,	@P_SITE_SEARCH_VALUE AS VARCHAR(100)
	,	@P_SALES_TYPE AS VARCHAR(10)
	,	@P_MIN_STOCK_UNDER_YORN AS VARCHAR(10)
	,	@P_PAGE_SIZE AS INT
	,	@P_PAGE_NUMBER AS INT
	,	@P_ORDER_BY_NAME AS VARCHAR(50)
	,	@P_ORDER_BY_TYPE AS VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @T_PRODUCTION_STATUS_NAME TABLE ( PRODUCTION_STATUS_NAME VARCHAR(20) )
	DECLARE @T_SITE_SEARCH_VALUE TABLE ( COMPANY_SEQ INT )

	DECLARE @T_PRODUCTION_STATUS_NAME_COUNT AS INT
	DECLARE @T_SITE_SEARCH_VALUE_COUNT AS INT



	INSERT INTO @T_PRODUCTION_STATUS_NAME (PRODUCTION_STATUS_NAME)
	SELECT CAST(VALUE AS VARCHAR(20)) FROM dbo.[ufn_SplitTable] (@P_PRODUCTION_STATUS_NAME, '|')

	INSERT INTO @T_SITE_SEARCH_VALUE (COMPANY_SEQ)
	SELECT CAST(VALUE AS INT) FROM dbo.[ufn_SplitTable] (@P_SITE_SEARCH_VALUE, '|')

	-- 공백을 '' 으로 치환
	UPDATE	@T_PRODUCTION_STATUS_NAME
	SET		PRODUCTION_STATUS_NAME = ''
	WHERE	PRODUCTION_STATUS_NAME = '공백'


	SET @T_PRODUCTION_STATUS_NAME_COUNT = ISNULL((SELECT COUNT(*) FROM @T_PRODUCTION_STATUS_NAME), 0)
	SET @T_PRODUCTION_STATUS_NAME_COUNT = CASE WHEN @T_PRODUCTION_STATUS_NAME_COUNT = 0 THEN 10 ELSE @T_PRODUCTION_STATUS_NAME_COUNT END
	SET @T_SITE_SEARCH_VALUE_COUNT = ISNULL((SELECT COUNT(*) FROM @T_SITE_SEARCH_VALUE), 0)
	SET @T_SITE_SEARCH_VALUE_COUNT = CASE WHEN @T_SITE_SEARCH_VALUE_COUNT = 0 THEN 10 ELSE @T_SITE_SEARCH_VALUE_COUNT END



	SELECT	*
	FROM	(
				SELECT	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REG_DATE						ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'INVENTORY_AVAILABLE_QTY'	THEN C.ERP_INVENTORY_AVAILABLE_QTY	ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_BARUNSONCARD'		THEN C.DISPLAY_BARUNSONCARD			ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_BHANDSCARD'		THEN C.DISPLAY_BHANDSCARD			ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_THECARD'			THEN C.DISPLAY_THECARD				ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_PREMIERPAPER'		THEN C.DISPLAY_PREMIERPAPER			ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_OUTBOUND'			THEN C.DISPLAY_OUTBOUND				ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_BARUNSONMALL'	    THEN C.DISPLAY_BARUNSONMALL			ELSE 0 END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_DEARDEER'	  	 	THEN C.DISPLAY_DEARDEER			ELSE 0 END ASC
												,	C.CARD_SEQ ASC
													
											) AS ROW_NUM
					,	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REG_DATE						ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'INVENTORY_AVAILABLE_QTY'	THEN C.ERP_INVENTORY_AVAILABLE_QTY	ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_BARUNSONCARD'		THEN C.DISPLAY_BARUNSONCARD			ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_BHANDSCARD'		THEN C.DISPLAY_BHANDSCARD			ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_THECARD'			THEN C.DISPLAY_THECARD				ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_PREMIERPAPER'		THEN C.DISPLAY_PREMIERPAPER			ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_OUTBOUND'			THEN C.DISPLAY_OUTBOUND				ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_BARUNSONMALL'	    THEN C.DISPLAY_BARUNSONMALL			ELSE 0 END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'DISPLAY_DEARDEER'	    	THEN C.DISPLAY_DEARDEER		    	ELSE 0 END DESC
												,	C.CARD_SEQ DESC
													
											) AS ROW_NUM_DESC
					,	*
                    ,   STUFF(( SELECT '|' + SCKI.CardKind FROM S2_CardKindInfo SCKI WHERE SCKI.CardKind_Seq IN ( SELECT ISNULL(SCKIND.CardKind_Seq,0) FROM S2_CardKind SCKIND WHERE SCKIND.Card_Seq = C.Card_Seq) FOR XML PATH('')),1,1,'')  AS CARDKIND_NAME



				FROM	(
							SELECT	DISTINCT 
									SC.CARD_SEQ
								,	SC.CARD_CODE	
								,	SC.CARD_ERPCODE AS ERP_CODE
								,	SC.CARD_NAME
								,	SC.CARDSET_PRICE AS CARD_SET_PRICE
								/*
								,	SC.CARD_PRICE

								,	CASE WHEN ISNULL(SCO.ISSAMPLE, '') = '1' THEN 'Y' ELSE 'N' END AS SAMPLE_ORDER_YORN
								,	CASE WHEN ISNULL(SCO.ISSAMPLEEND, '') = '1' THEN 'Y' ELSE 'N' END AS SAMPLE_END_YORN

								,	ISNULL(CONVERT(VARCHAR(10), SC.ERP_EXPECTED_ARRIVAL_DATE, 120), '') AS ERP_EXPECTED_ARRIVAL_DATE
								,	ISNULL(SC.ERP_EXPECTED_ARRIVAL_DATE_USE_YORN, 'N') AS ERP_EXPECTED_ARRIVAL_DATE_USE_YORN
								,	ISNULL(SC.ERP_MIN_STOCK_QTY, 0) AS ERP_MIN_STOCK_QTY
								,	ISNULL(SC.ERP_MIN_STOCK_QTY_USE_YORN, 'N') AS ERP_MIN_STOCK_QTY_USE_YORN

								,	CASE WHEN ISNULL(SC.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC.CARD_IMAGE END AS CARD_IMAGE_FULL_URL

								,	ISNULL(SC_ENVELOPE			.ENVELOPE			, '') AS ENVELOPE
								,	ISNULL(SC_INPAPER			.INPAPER			, '') AS INPAPER
								,	ISNULL(SC_ACC1				.ACC1				, '') AS ACC1
								,	ISNULL(SC_ACC2				.ACC2				, '') AS ACC2
								,	ISNULL(SC_MAP_CARD			.MAP_CARD			, '') AS MAP_CARD
								,	ISNULL(SC_GREETING_CARD		.GREETING_CARD		, '') AS GREETING_CARD
								,	ISNULL(SC_ENVELOPE_LINING	.ENVELOPE_LINING	, '') AS ENVELOPE_LINING

								,	CASE WHEN ISNULL(SC_ENVELOPE		.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC_ENVELOPE			.CARD_IMAGE END AS ENVELOPE_IMAGE_FULL_URL
								,	CASE WHEN ISNULL(SC_INPAPER			.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC_INPAPER			.CARD_IMAGE END AS INPAPER_IMAGE_FULL_URL
								,	CASE WHEN ISNULL(SC_ACC1			.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC_ACC1				.CARD_IMAGE END AS ACC1_IMAGE_FULL_URL
								,	CASE WHEN ISNULL(SC_ACC2			.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC_ACC2				.CARD_IMAGE END AS ACC2_IMAGE_FULL_URL
								,	CASE WHEN ISNULL(SC_MAP_CARD		.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC_MAP_CARD			.CARD_IMAGE END AS MAP_CARD_IMAGE_FULL_URL
								,	CASE WHEN ISNULL(SC_GREETING_CARD	.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC_GREETING_CARD	.CARD_IMAGE END AS GREETING_CARD_IMAGE_FULL_URL
								,	CASE WHEN ISNULL(SC_ENVELOPE_LINING	.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC_ENVELOPE_LINING	.CARD_IMAGE END AS ENVELOPE_LINING_IMAGE_FULL_URL
		
								,	CASE	
											WHEN UPPER(SC.CARDBRAND) = 'A'	THEN '티아라카드'
											WHEN UPPER(SC.CARDBRAND) = 'B'	THEN '바른손카드'
											WHEN UPPER(SC.CARDBRAND) = 'G'	THEN '가랑카드'
											WHEN UPPER(SC.CARDBRAND) = 'H'	THEN '해피카드'
											WHEN UPPER(SC.CARDBRAND) = 'P'	THEN 'W페이퍼'
											WHEN UPPER(SC.CARDBRAND) = 'S'	THEN '프리미어페이퍼'
											WHEN UPPER(SC.CARDBRAND) = 'T'	THEN '티로즈'
											WHEN UPPER(SC.CARDBRAND) = 'W'	THEN '위시메이드'
											WHEN UPPER(SC.CARDBRAND) = 'Y'	THEN '예카드'
											WHEN UPPER(SC.CARDBRAND) = 'N'	THEN '비핸즈카드'
											WHEN UPPER(SC.CARDBRAND) = 'C'	THEN '더카드'
											WHEN UPPER(SC.CARDBRAND) = 'I'	THEN '글로벌'
											WHEN UPPER(SC.CARDBRAND) = 'D'	THEN '디얼디어'
																			ELSE '기타' 
									END AS BRAND_NAME
	
								,	CASE	
											WHEN S2CD.CARD_FOLDING  = 'S1'	THEN '세로1번 접기'
											WHEN S2CD.CARD_FOLDING  = 'S2'	THEN '세로2번 접기'
											WHEN S2CD.CARD_FOLDING  = 'G1'	THEN '가로1번 접기'
											WHEN S2CD.CARD_FOLDING  = 'G2'	THEN '가로2번 접기'
											WHEN S2CD.CARD_FOLDING  = 'S3'	THEN '세로3번 접기'
											WHEN S2CD.CARD_FOLDING  = 'G3'	THEN '가로3번 접기'
											WHEN S2CD.CARD_FOLDING  = 'S4'	THEN '세로4번 접기'
											WHEN S2CD.CARD_FOLDING  = 'G4'	THEN '가로4번 접기'
											WHEN S2CD.CARD_FOLDING  = 'ETC' THEN '기타'
											WHEN S2CD.CARD_FOLDING  = 'E0'	THEN '엽서형'
											WHEN S2CD.CARD_FOLDING  = '0'	THEN '기타'
																			ELSE '접선없음' 
									END AS FOLDING_TYPE
				
								,	CASE	WHEN S2CD.CARD_SHAPE = '2'		THEN '직사각형(가로)'
											WHEN S2CD.CARD_SHAPE = '3'		THEN '직사각형(세로)'
																			ELSE '정사각형' 
									END AS SHAPE_TYPE
	
								,	ISNULL((SELECT CD.CARD_MATERIAL FROM S2_CARDDETAIL CD JOIN S2_CARD C ON C.CARD_SEQ = CD.CARD_SEQ WHERE CD.CARD_SEQ = SC.CARD_SEQ), '')   AS MATERIAL
								,	SC.CARD_WSIZE AS SIZE_WIDTH
								,	SC.CARD_HSIZE AS SIZE_HEIGHT
								*/
								,	CASE ISNULL((1 + SCSS_BARUNSONCARD.ISDISPLAY),0) WHEN 0 THEN '미등록' WHEN 1 THEN '전시안함' ELSE '전시' END AS DISPLAY_BARUNSONCARD
								,	CASE ISNULL((1 + SCSS_BHANDSCARD.ISDISPLAY),0) WHEN 0 THEN '미등록' WHEN 1 THEN '전시안함' ELSE '전시' END AS DISPLAY_BHANDSCARD
								,	CASE ISNULL((1 + SCSS_THECARD.ISDISPLAY),0) WHEN 0 THEN '미등록' WHEN 1 THEN '전시안함' ELSE '전시' END AS DISPLAY_THECARD
								,	CASE ISNULL((1 + SCSS_PREMIERPAPER.ISDISPLAY),0) WHEN 0 THEN '미등록' WHEN 1 THEN '전시안함' ELSE '전시' END AS DISPLAY_PREMIERPAPER
								,	CASE ISNULL((1 + SCSS_BARUNSONMALL.ISDISPLAY),0) WHEN 0 THEN '미등록' WHEN 1 THEN '전시안함' ELSE '전시' END AS DISPLAY_BARUNSONMALL
								,	CASE ISNULL((1 + SCSS_OUTBOUND.ISDISPLAY),0) WHEN 0 THEN '미등록' WHEN 1 THEN '전시안함' ELSE '전시' END AS DISPLAY_OUTBOUND

								,	ISNULL((1 + SCSS_DEARDEER.ISDISPLAY		)					, 0 ) AS DISPLAY_DEARDEER
								/*
								,	SCSS_BARUNSONCARD.DISPLAY_DATE									AS DISPLAYDATE_BARUNSONCARD
								,	SCSS_BHANDSCARD.DISPLAY_DATE									AS DISPLAYDATE_BHANDSCARD
								,	SCSS_THECARD.DISPLAY_DATE										AS DISPLAYDATE_THECARD 
								,	SCSS_PREMIERPAPER.DISPLAY_DATE									AS DISPLAYDATE_PREMIERPAPER
								,	SCSS_OUTBOUND.DISPLAY_DATE										AS DISPLAYDATE_OUTBOUND
								,	SCSS_BARUNSONMALL.DISPLAY_DATE									AS DISPLAYDATE_BARUNSONMALL
								,	SCSS_DEARDEER.DISPLAY_DATE								    	AS DISPLAYDATE_DEARDEER
								*/
								,	ISNULL(SCES.CARD_TYPE_NAME									, '') AS ERP_CARD_TYPE_NAME			
								,	ISNULL(SCES.ORIGIN_NAME										, '') AS ERP_ORIGIN_NAME				
								,	ISNULL(SCES.PRODUCTION_STATUS_NAME							, '') AS ERP_PRODUCTION_STATUS_NAME	
								/*
								,	ISNULL(SCES.CLOSING_COST									, 0 ) AS ERP_CLOSING_COST			
								,	ISNULL(SCES.CONSUMER_PRICE									, 0 ) AS ERP_CONSUMER_PRICE			
								,	ISNULL(SCES.INVENTORY_CURRENT_QTY							, 0 ) AS ERP_INVENTORY_CURRENT_QTY	
								,	ISNULL(SCES.INVENTORY_REQUEST_QTY							, 0 ) AS ERP_INVENTORY_REQUEST_QTY	
								*/
								,	ISNULL(SCES.INVENTORY_AVAILABLE_QTY							, 0 ) AS ERP_INVENTORY_AVAILABLE_QTY	
								/*
								,	ISNULL(SCES.INVENTORY_NOT_MAKE_QTY							, 0 ) AS ERP_INVENTORY_NOT_MAKE_QTY	
								,	ISNULL(SCES.INVENTORY_CHINA_QTY								, 0 ) AS ERP_INVENTORY_CHINA_QTY		
								,	ISNULL(SCES.INVENTORY_MOVING_QTY							, 0 ) AS ERP_INVENTORY_MOVING_QTY	
								,	ISNULL(SCES.TOTAL_SALE_PRICE_30_DAY							, 0 ) AS ERP_TOTAL_SALE_PRICE_30_DAY	
								,	ISNULL(SCES.TOTAL_SALE_PRICE_90_DAY							, 0 ) AS ERP_TOTAL_SALE_PRICE_90_DAY	
								,	ISNULL(SCES.TOTAL_SALE_PRICE_180_DAY						, 0 ) AS ERP_TOTAL_SALE_PRICE_180_DAY
								,	ISNULL(SCES.TOTAL_SALE_PRICE_365_DAY						, 0 ) AS ERP_TOTAL_SALE_PRICE_365_DAY
								,	ISNULL(CONVERT(VARCHAR(10), SCES.ERP_FIRST_REG_DATE, 120)	, '') AS ERP_FIRST_REG_DATE
								,	(SELECT CardDiscount_Code FROM S2_CardDiscountInfo WHERE CardDiscount_Seq = SCSS_BARUNSONCARD.CardDiscount_Seq ) AS DISCOUNT_BARUNSONCARD
								,	(SELECT CardDiscount_Code FROM S2_CardDiscountInfo WHERE CardDiscount_Seq = SCSS_BHANDSCARD.CardDiscount_Seq ) AS DISCOUNT_BHANDSCARD
								,	(SELECT CardDiscount_Code FROM S2_CardDiscountInfo WHERE CardDiscount_Seq = SCSS_THECARD.CardDiscount_Seq ) AS DISCOUNT_THECARD
								,	(SELECT CardDiscount_Code FROM S2_CardDiscountInfo WHERE CardDiscount_Seq = SCSS_PREMIERPAPER.CardDiscount_Seq ) AS DISCOUNT_PREMIERPAPER
								,	(SELECT CardDiscount_Code FROM S2_CardDiscountInfo WHERE CardDiscount_Seq = SCSS_BARUNSONMALL.CardDiscount_Seq ) AS DISCOUNT_BARUNSONMALL
								,	(SELECT CardDiscount_Code FROM S2_CardDiscountInfo WHERE CardDiscount_Seq = SCSS_DEARDEER.CardDiscount_Seq ) AS DISCOUNT_DEARDEERMALL
								,	(SELECT CardDiscount_Code FROM S2_CardDiscountInfo WHERE CardDiscount_Seq = SCSS_OUTBOUND.CardDiscount_Seq ) AS DISCOUNT_OUTBOUND

                                ,   ISNULL(ROUND(SC.CardSet_Price * ((100 - (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_BARUNSONCARD.CardDiscount_Seq AND MinCount = 300)) * 0.01), 0), 0)  AS  DISCOUNT_BARUNSONCARD_PRICE
                                ,   ISNULL(ROUND(SC.CardSet_Price * ((100 - (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_BHANDSCARD.CardDiscount_Seq AND MinCount = 300)) * 0.01), 0), 0)   AS DISCOUNT_BHANDSCARD_PRICE
                                ,   ISNULL(ROUND(SC.CardSet_Price * ((100 - (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_THECARD.CardDiscount_Seq AND MinCount = 300)) * 0.01), 0), 0)  AS DISCOUNT_THECARD_PRICE
                                ,   ISNULL(ROUND(SC.CardSet_Price * ((100 - (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_PREMIERPAPER.CardDiscount_Seq AND MinCount = 300)) * 0.01), 0), 0)   AS DISCOUNT_PREMIERPAPER_PRICE
                                ,   ISNULL(ROUND(SC.CardSet_Price * ((100 - (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_BARUNSONMALL.CardDiscount_Seq AND MinCount = 300)) * 0.01), 0), 0)   AS DISCOUNT_BARUNSONMALL_PRICE
								,   ISNULL(ROUND(SC.CardSet_Price * ((100 - (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_DEARDEER.CardDiscount_Seq AND MinCount = 300)) * 0.01), 0), 0)   AS DISCOUNT_DEARDEER_PRICE

                                ,   ISNULL( (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_BARUNSONCARD.CardDiscount_Seq AND MinCount = 300 ), 0) AS  DISCOUNT_BARUNSONCARD_RATE
                                ,   ISNULL( (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_BHANDSCARD.CardDiscount_Seq AND MinCount = 300 ), 0) AS  DISCOUNT_BHANDSCARD_RATE
                                ,   ISNULL( (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_THECARD.CardDiscount_Seq AND MinCount = 300 ), 0) AS  DISCOUNT_THECARD_RATE
                                ,   ISNULL( (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_PREMIERPAPER.CardDiscount_Seq AND MinCount = 300 ), 0) AS  DISCOUNT_PREMIERPAPER_RATE
                                ,   ISNULL( (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_BARUNSONMALL.CardDiscount_Seq AND MinCount = 300 ), 0) AS  DISCOUNT_BARUNSONMALL_RATE
                                ,   ISNULL( (SELECT Discount_Rate FROM S2_CardDiscount WHERE  CardDiscount_Seq = SCSS_DEARDEER.CardDiscount_Seq AND MinCount = 300 ), 0) AS  DISCOUNT_DEARDEER_RATE
                                ,   S2CD.Env_GroupSeq AS EnvGroupSeq
                                ,   ISNULL((SELECT SCIGI.CardItemGroup FROM S2_CardItemGroupInfo SCIGI where SCIGI.CardItemGroup_Seq = s2cd.Env_GroupSeq ),'') AS EnvGroupName
								*/
								,SC.REGDATE AS REG_DATE
								/*
                                ,   CASE WHEN ISNULL(SCO.IsEmbo, '') = '1' THEN '유료' 
                                         WHEN ISNULL(SCO.IsEmbo, '') = '2' THEN '무료'
                                         ELSE '없음' END AS IsEmbo                    --송진인쇄
                                ,   ( SELECT code_value FROM manage_code mc WHERE mc.code_type = 'embo_color' AND mc.use_yorn = 'Y' AND CODE = SCO.IsEmboColor) AS IsEmboColor --고객컬러지정
                                ,   REPLACE(REPLACE(REPLACE(REPLACE(SCO.embo_print, 'C', '카드'), 'I', '내지'), 'G', '인사말카드'), 'P', '약도카드') AS EmboPrint     --품목(카드,내지,인사말카드,약도카드)
                                --,   SCO.embo_print AS EmboPrint
                                ,   CASE WHEN ISNULL(SCO.IsInPaper, '') = '1' THEN '유료' 
                                         WHEN ISNULL(SCO.IsInPaper, '') = '2' THEN '무료'
                                         ELSE '안함' END AS IsInPaper                 --속지부착
                                ,   CASE WHEN ISNULL(SCO.IsJaebon, '') = '1' THEN '유료' 
                                         WHEN ISNULL(SCO.IsJaebon, '') = '2' THEN '무료'
                                         ELSE '안함' END AS IsJaebon                 --속지삽입
                                ,   CASE WHEN ISNULL(SCO.IsHandmade, '') = '1' THEN '유료' 
                                         WHEN ISNULL(SCO.IsHandmade, '') = '2' THEN '무료'
                                         ELSE '안함' END AS IsHandmade                 --부속품부착
                                ,   CASE WHEN ISNULL(SCO.IsEnvInsert, '') = '1' THEN '유료' 
                                         WHEN ISNULL(SCO.IsEnvInsert, '') = '2' THEN '무료'
                                         ELSE '안함' END AS IsEnvInsert                 --봉투삽입
                                ,   CASE WHEN ISNULL(SCO.IsLiningJaebon, '') = '1' THEN '유료' 
                                         WHEN ISNULL(SCO.IsLiningJaebon, '') = '2' THEN '무료'
                                         ELSE '안함' END AS IsLiningJaebon              --라이닝제본
                                ,   CASE WHEN ISNULL(SCO.IsHanji, '') = '1' THEN '일반한지' 
                                         WHEN ISNULL(SCO.IsHanji, '') = '2' THEN '고급가로형 한지'
                                         WHEN ISNULL(SCO.IsHanji, '') = '3' THEN '고급세로형 한지'
                                         ELSE '안함' END AS IsHanji              --한지카드
                                ,   ( SELECT code_value FROM manage_code mc WHERE mc.code_type = 'src_printer_seq' AND mc.use_yorn = 'Y' AND CODE = S2CD.Card_PrintOffice) AS CardPrintOffice --카드인쇄소
                                ,   CASE WHEN ISNULL(S2CD.CuttingLineType, '') = '0' THEN '3mm' ELSE '1.5mm' END AS CuttingLineType              --재단선길이
                                ,   CASE WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = '0' THEN '없음'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'G' THEN '금박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'S' THEN '은박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'C' THEN '동박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'B' THEN '먹박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'I' THEN '코인박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'P' THEN '구리박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'L' THEN '청박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'V' THEN '보라박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'K' THEN '펄핑크박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'E' THEN '펄블루박'
                                         WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),1,1) = 'H' THEN '초콜릿박'
                                         ELSE '없음' END AS PrintMethod1              --박

                                ,   CASE WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),2,1) = '1' THEN '유광' 
                                         ELSE '없음' END AS PrintMethod2                   --광
                                
                                ,   CASE WHEN SUBSTRING(ISNULL(SCO.PrintMethod,''),3,1) = '1' THEN '형압' 
                                         ELSE '없음' END AS PrintMethod3                   --압
                             ,   REPLACE(REPLACE(REPLACE(REPLACE(SCO.outsourcing_print, 'C', '카드'), 'I', '내지'), 'G', '인사말카드'), 'P', '약도카드') AS outsourcing_print     --특수인쇄품목(카드,내지,인사말카드,약도카드)
                                ,   CASE WHEN ISNULL(SCO.IsLaser, '') = '1' THEN '외부' 
                                         WHEN ISNULL(SCO.IsLaser, '') = '2' THEN '내부'
                                         ELSE '없음' END AS IsLaser              --레이저컷
                                ,   CASE WHEN ISNULL(SCO.IsLetterPress,'0') = '1' THEN '적용' 
                                         ELSE '없음' END AS IsLetterPress                   --레터프레스
                                ,   CASE WHEN ISNULL(SCO.IsMasterDigital,'0') = '1' THEN '적용' 
                                         ELSE '없음' END AS IsMasterDigital                   --마디카드(내부)
                                ,   CASE WHEN ISNULL(SCO.IsInternalDigital,'0') = '1' THEN '적용' 
                                         ELSE '없음' END AS IsInternalDigital                 --디지털카드(내부)
										 */
							FROM	S2_CARD SC
							JOIN	S2_CARDKIND SCK ON SC.CARD_SEQ = SCK.CARD_SEQ

							LEFT JOIN	S2_CARDOPTION SCO ON SC.CARD_SEQ = SCO.CARD_SEQ

							LEFT JOIN	(SELECT CD.CARD_SEQ, C.CARD_CODE AS ENVELOPE,			C.CARD_IMAGE FROM S2_CARDDETAIL CD JOIN S2_CARD C ON C.CARD_SEQ = CD.ENV_SEQ			) SC_ENVELOPE			ON SC_ENVELOPE			.CARD_SEQ = SC.CARD_SEQ
							LEFT JOIN	(SELECT CD.CARD_SEQ, C.CARD_CODE AS INPAPER,			C.CARD_IMAGE FROM S2_CARDDETAIL CD JOIN S2_CARD C ON C.CARD_SEQ = CD.INPAPER_SEQ		) SC_INPAPER			ON SC_INPAPER			.CARD_SEQ = SC.CARD_SEQ
							LEFT JOIN	(SELECT CD.CARD_SEQ, C.CARD_CODE AS ACC1,				C.CARD_IMAGE FROM S2_CARDDETAIL CD JOIN S2_CARD C ON C.CARD_SEQ = CD.ACC1_SEQ			) SC_ACC1				ON SC_ACC1				.CARD_SEQ = SC.CARD_SEQ
							LEFT JOIN	(SELECT CD.CARD_SEQ, C.CARD_CODE AS ACC2,				C.CARD_IMAGE FROM S2_CARDDETAIL CD JOIN S2_CARD C ON C.CARD_SEQ = CD.ACC2_SEQ			) SC_ACC2				ON SC_ACC2				.CARD_SEQ = SC.CARD_SEQ
							LEFT JOIN	(SELECT CD.CARD_SEQ, C.CARD_CODE AS MAP_CARD,			C.CARD_IMAGE FROM S2_CARDDETAIL CD JOIN S2_CARD C ON C.CARD_SEQ = CD.MAPCARD_SEQ		) SC_MAP_CARD			ON SC_MAP_CARD			.CARD_SEQ = SC.CARD_SEQ
							LEFT JOIN	(SELECT CD.CARD_SEQ, C.CARD_CODE AS GREETING_CARD,		C.CARD_IMAGE FROM S2_CARDDETAIL CD JOIN S2_CARD C ON C.CARD_SEQ = CD.GREETINGCARD_SEQ	) SC_GREETING_CARD		ON SC_GREETING_CARD		.CARD_SEQ = SC.CARD_SEQ
							LEFT JOIN	(SELECT CD.CARD_SEQ, C.CARD_CODE AS ENVELOPE_LINING,	C.CARD_IMAGE FROM S2_CARDDETAIL CD JOIN S2_CARD C ON C.CARD_SEQ = CD.LINING_SEQ			) SC_ENVELOPE_LINING	ON SC_ENVELOPE_LINING	.CARD_SEQ = SC.CARD_SEQ

							LEFT JOIN	S2_CARDDETAIL S2CD ON SC.CARD_SEQ = S2CD.CARD_SEQ
							LEFT JOIN	S2_CARD_ERP_STOCK SCES ON SC.CARD_CODE = SCES.CARD_CODE AND SC.CARD_ERPCODE = SCES.CARD_CODE_ERP

							LEFT JOIN	S2_CARDSALESSITE SCSS_BARUNSONCARD	ON SC.CARD_SEQ = SCSS_BARUNSONCARD.CARD_SEQ		AND SCSS_BARUNSONCARD.COMPANY_SEQ	= 5001
							LEFT JOIN	S2_CARDSALESSITE SCSS_PREMIERPAPER	ON SC.CARD_SEQ = SCSS_PREMIERPAPER.CARD_SEQ		AND SCSS_PREMIERPAPER.COMPANY_SEQ	= 5003
							LEFT JOIN	S2_CARDSALESSITE SCSS_BHANDSCARD	ON SC.CARD_SEQ = SCSS_BHANDSCARD.CARD_SEQ		AND SCSS_BHANDSCARD.COMPANY_SEQ		= 5006
							LEFT JOIN	S2_CARDSALESSITE SCSS_THECARD		ON SC.CARD_SEQ = SCSS_THECARD.CARD_SEQ			AND SCSS_THECARD.COMPANY_SEQ		= 5007
							LEFT JOIN	S2_CARDSALESSITE SCSS_OUTBOUND		ON SC.CARD_SEQ = SCSS_OUTBOUND.CARD_SEQ			AND SCSS_OUTBOUND.COMPANY_SEQ		= 5008
							LEFT JOIN	S2_CARDSALESSITE SCSS_BARUNSONMALL  ON SC.CARD_SEQ = SCSS_BARUNSONMALL.CARD_SEQ		AND SCSS_BARUNSONMALL.COMPANY_SEQ	= 5000
							LEFT JOIN	S2_CARDSALESSITE SCSS_DEARDEER  	ON SC.CARD_SEQ = SCSS_DEARDEER.CARD_SEQ			AND SCSS_DEARDEER.COMPANY_SEQ	= 7717

							WHERE	1 = 1
							AND		SC.CARD_DIV IN ( 'A01' , 'C03' )
                            AND     SC.DISPLAY_YORN = 'Y'
							AND		SCO.Master_2Color = 1
						
                            AND     (
										(    @P_PRODUCTION_STATUS_NAME = ''
                     OR  SCES.PRODUCTION_STATUS_NAME IN (SELECT PRODUCTION_STATUS_NAME FROM @T_PRODUCTION_STATUS_NAME)
										
										)
										OR (
											CHARINDEX('단종예정', @P_PRODUCTION_STATUS_NAME,0) > 0
											AND SCES.PRODUCTION_STATUS_NAME LIKE '단종예정%'
										) 
										OR (
											CHARINDEX('발주대기', @P_PRODUCTION_STATUS_NAME,0) > 0
											AND SCES.PRODUCTION_STATUS_NAME LIKE '발주대기%'
										) 
										OR (
											EXISTS (SELECT PRODUCTION_STATUS_NAME FROM @T_PRODUCTION_STATUS_NAME WHERE PRODUCTION_STATUS_NAME = '폐기')
											AND SCES.PRODUCTION_STATUS_NAME LIKE '폐기 %'
										) 
										OR (
											CHARINDEX('폐기대상', @P_PRODUCTION_STATUS_NAME,0) > 0
											AND SCES.PRODUCTION_STATUS_NAME LIKE '폐기대상%'
										) 
										OR (
											CHARINDEX('정상판매', @P_PRODUCTION_STATUS_NAME,0) > 0
											AND SCES.PRODUCTION_STATUS_NAME LIKE '정상판매%'
										) 
                                    )
							
							AND		SC.CARDSET_PRICE >= @P_CARD_SET_PRICE_MIN
							AND		SC.CARDSET_PRICE < @P_CARD_SET_PRICE_MAX

							AND		CASE WHEN @P_CARD_KIND_SEQ = 0 THEN 0 ELSE SCK.CARDKIND_SEQ END = @P_CARD_KIND_SEQ
							AND		CASE WHEN @P_CARD_BRAND = '' THEN '' ELSE SC.CARDBRAND END = @P_CARD_BRAND

							AND		SC.CARDBRAND <> 'X' /* 디얼디어 판매상품 제외 */

							AND		(
											CASE WHEN @P_CARD_CODE_OR_CARD_NAME = '' THEN '' ELSE SC.CARD_CODE END LIKE '%' + @P_CARD_CODE_OR_CARD_NAME + '%'
										OR	CASE WHEN @P_CARD_CODE_OR_CARD_NAME = '' THEN '' ELSE SC.CARD_NAME END LIKE '%' + @P_CARD_CODE_OR_CARD_NAME + '%'
										OR	CASE WHEN @P_CARD_CODE_OR_CARD_NAME = '' THEN '' ELSE CAST(SC.CARD_SEQ AS VARCHAR(10)) END = @P_CARD_CODE_OR_CARD_NAME
									)

							AND		CASE	WHEN @P_SAMPLE_ORDER_AVAILABLE_YORN = '' THEN '' 
											ELSE CASE WHEN ISNULL(SCO.ISSAMPLE, '') = '1' THEN '1' ELSE '' END
									END 
									= 
									CASE WHEN @P_SAMPLE_ORDER_AVAILABLE_YORN = 'Y' THEN '1' ELSE '' END

							AND		SCES.PRODUCTION_STATUS_NAME IN (SELECT PRODUCTION_STATUS_NAME FROM @T_PRODUCTION_STATUS_NAME)

							AND		(
										(
												@T_SITE_SEARCH_VALUE_COUNT < 6
											AND	(
														(SCSS_BARUNSONCARD.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)	AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BARUNSONCARD.ISJUMUN END = @P_SALES_TYPE)
													OR	(SCSS_PREMIERPAPER.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)	AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_PREMIERPAPER.ISJUMUN END = @P_SALES_TYPE)
													OR	(SCSS_BHANDSCARD.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)		AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BHANDSCARD.ISJUMUN END = @P_SALES_TYPE)
													OR	(SCSS_THECARD.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)			AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_THECARD.ISJUMUN END = @P_SALES_TYPE)
													OR	(SCSS_OUTBOUND.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)		AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_OUTBOUND.ISJUMUN END = @P_SALES_TYPE)
													OR	(SCSS_BARUNSONMALL.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)	AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BARUNSONMALL.ISJUMUN END = @P_SALES_TYPE)
													OR	(SCSS_DEARDEER.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)		AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_DEARDEER.ISJUMUN END = @P_SALES_TYPE)
												)
										)
										OR
										(
												@T_SITE_SEARCH_VALUE_COUNT >= 6
											AND (
														CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BARUNSONCARD.ISJUMUN END = @P_SALES_TYPE
													OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_PREMIERPAPER.ISJUMUN END = @P_SALES_TYPE
													OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BHANDSCARD.ISJUMUN END = @P_SALES_TYPE
													OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_THECARD.ISJUMUN END = @P_SALES_TYPE
													OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_OUTBOUND.ISJUMUN END = @P_SALES_TYPE
													OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BARUNSONMALL.ISJUMUN END = @P_SALES_TYPE
													OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_DEARDEER.ISJUMUN END = @P_SALES_TYPE
												)
										)
									)

							AND		CASE WHEN @P_MIN_STOCK_UNDER_YORN = 'Y' THEN ISNULL(SCES.INVENTORY_AVAILABLE_QTY, 0) ELSE 0 END  <= CASE WHEN @P_MIN_STOCK_UNDER_YORN = 'Y' THEN ISNULL(SC.ERP_MIN_STOCK_QTY, 0) ELSE 0 END
							
						) C

			) A

	WHERE	1 = 1
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END > (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE
		
	ORDER BY 
		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END ASC
	
END
GO
