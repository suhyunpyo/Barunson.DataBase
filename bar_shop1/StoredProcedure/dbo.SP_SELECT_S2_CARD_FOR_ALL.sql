IF OBJECT_ID (N'dbo.SP_SELECT_S2_CARD_FOR_ALL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S2_CARD_FOR_ALL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

EXEC SP_SELECT_S2_CARD_FOR_ALL '1|14|2|6|7|3|4|5|', 'C06|B02', '', '5001|5003|5006|5007|5000','1','1','1','1','1','1','1',20,1
EXEC SP_SELECT_S2_CARD_FOR_ALL 0, '', '', '5001|5003|5006|5007|5000','1','1','1','1','1','1','1',20,1


1	청첩장
2	초대장
3	감사장
4	카드형답례장
5	한지형답례장
6	기업행사
7	고희연/회갑연
8	기성웨딩
9	맞춤웨딩
10	미니청첩장
14	커스텀 디지탈카드
15	메시지카드
16	결혼답례카드


청첩장 : 1, 14
초대장 : 2, 6, 7
감사장 : 3, 4, 5

*/

CREATE PROCEDURE [dbo].[SP_SELECT_S2_CARD_FOR_ALL]
		@P_CARD_KIND_SEQ			AS VARCHAR(100)
	,	@P_ETC_CARD_DIV_VALUE		AS VARCHAR(100)
	,	@P_CARD_CODE_OR_CARD_NAME	AS VARCHAR(50)
	,	@P_SITE_SEARCH_VALUE		AS VARCHAR(100)
	,	@P_SALES_TYPE				AS VARCHAR(10) = '1'
	,	@P_ISCOLOR					AS CHAR(1)
	,	@P_ISEMBO					AS CHAR(1)
	,	@P_ISINPAPER				AS CHAR(1)
	,	@P_ISENVINSERT				AS CHAR(1)
	,	@P_ISHANDMADE				AS CHAR(1)
	,	@P_ISQUICK					AS CHAR(1)
	,	@P_PAGE_SIZE				AS INT
	,	@P_PAGE_NUMBER				AS INT

AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @T_SITE_SEARCH_VALUE TABLE ( COMPANY_SEQ INT )
	DECLARE @T_SITE_SEARCH_VALUE_COUNT AS INT

	set	@P_ISCOLOR = case when  @P_ISCOLOR = '' OR @P_ISCOLOR is null then '0' else @P_ISCOLOR end;
	set	@P_ISEMBO = case when  @P_ISEMBO = '' OR @P_ISEMBO is null then '0' else @P_ISEMBO end;
	set	@P_ISINPAPER = case when  @P_ISINPAPER = '' OR @P_ISINPAPER is null then '0' else @P_ISINPAPER end;
	set	@P_ISENVINSERT = case when  @P_ISENVINSERT = '' OR @P_ISENVINSERT is null then '0' else @P_ISENVINSERT end;
	set	@P_ISHANDMADE = case when  @P_ISHANDMADE = '' OR @P_ISHANDMADE is null then '0' else @P_ISHANDMADE end;
	set	@P_ISQUICK = case when  @P_ISQUICK = '' OR @P_ISQUICK is null then '0' else @P_ISQUICK end;


	INSERT INTO @T_SITE_SEARCH_VALUE (COMPANY_SEQ)
	SELECT CAST(VALUE AS INT) FROM dbo.[ufn_SplitTable] (@P_SITE_SEARCH_VALUE, '|')

	--SELECT * FROM @T_SITE_SEARCH_VALUE

	SET @T_SITE_SEARCH_VALUE_COUNT = ISNULL((SELECT COUNT(*) FROM @T_SITE_SEARCH_VALUE), 0)
	SET @T_SITE_SEARCH_VALUE_COUNT = CASE WHEN @T_SITE_SEARCH_VALUE_COUNT = 0 THEN 10 ELSE @T_SITE_SEARCH_VALUE_COUNT END

	--SELECT @T_SITE_SEARCH_VALUE_COUNT

	SELECT		DISTINCT
				MAX(SC.CARD_SEQ) AS CardSeq
			,	MAX(SC.CARD_CODE) AS CardCode
			,	MAX(SC.CARD_NAME) AS CardName
			,	MAX(SC.Card_Price) AS CardPrice
			,   MAX(SC.CardBRAND) AS CardBrand
			--,	SC.CARD_DIV
			--,	SC.CARD_ERPCODE AS ERP_CODE
			--,	( SELECT CODE_VALUE FROM MANAGE_CODE MC WHERE CODE_TYPE = 'card_div' and CODE = SC.CARD_DIV) AS CARD_TYPE
			--,   SCK.CardKind_Seq
			--,   ( SELECT SCKI.CardKind FROM S2_CardKindInfo SCKI WHERE CardKind_Seq = SCK.CardKind_Seq ) AS CARDKIND
			--,	ISNULL((1 + SCSS_BARUNSONCARD.ISDISPLAY		), 0) AS DISPLAY_BARUNSONCARD
			--,	ISNULL((1 + SCSS_BHANDSCARD.ISDISPLAY		), 0) AS DISPLAY_BHANDSCARD
			--,	ISNULL((1 + SCSS_THECARD.ISDISPLAY			), 0) AS DISPLAY_THECARD 
			--,	ISNULL((1 + SCSS_PREMIERPAPER.ISDISPLAY		), 0) AS DISPLAY_PREMIERPAPER
			--,	ISNULL((1 + SCSS_BARUNSONMALL.ISDISPLAY		), 0) AS DISPLAY_BARUNSONMALL
			--,	(case when SCO.IsColorInpaper = '0' then 'X' else 'O' end ) AS '컬러인쇄'        --IsColorPrint
			--,	(case when SCO.IsEmbo = '0' then 'X' else 'O' end ) AS '송진인쇄'          --IsEmbo
			--,	(case when SCO.IsInPaper = '0' then 'X' else 'O' end ) AS '속지부착'       --IsInPaper
			--,	(case when SCO.IsEnvInsert = '0' then 'X' else 'O' end ) AS '봉투삽입'     --IsEnvInsert
			--,	(case when SCO.IsHandmade = '0' then 'X' else 'O' end ) AS '부속품부착'  --IsHandmade
			--,	(case when SCO.IsQuick = '0' then 'X' else 'O' end ) AS '퀵제작'  --IsQuick
			,	MAX(CASE 
							WHEN SCSS_BARUNSONMALL.Company_Seq = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
							WHEN SCSS_BARUNSONCARD.Company_Seq = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
							WHEN SCSS_PREMIERPAPER.Company_Seq = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
							WHEN SCSS_BHANDSCARD.Company_Seq = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'	+ SC.CARD_CODE + '/210.jpg'
							WHEN SCSS_THECARD.Company_Seq = 5007 THEN 'http://file.barunsoncard.com/thecard/'		+ SC.CARD_CODE + '/210.jpg'
							ELSE							'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC.CARD_IMAGE 
					END) AS ImageUrl
			--,	CASE WHEN ISNULL(SC.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC.CARD_IMAGE END AS ImageUrl

	FROM	S2_CARD SC
		LEFT JOIN	S2_CARDKIND	SCK	ON	SC.Card_Seq = SCK.CARD_SEQ
		LEFT JOIN	S2_CardDetail SCD	ON SC.CARD_SEQ = SCD.CARD_SEQ
		LEFT JOIN	S2_CardOption SCO	ON SC.CARD_SEQ = SCO.CARD_SEQ
		LEFT JOIN	S2_CARDSALESSITE SCSS_BARUNSONCARD	ON SC.CARD_SEQ = SCSS_BARUNSONCARD.CARD_SEQ		AND SCSS_BARUNSONCARD.COMPANY_SEQ = 5001
		LEFT JOIN	S2_CARDSALESSITE SCSS_PREMIERPAPER	ON SC.CARD_SEQ = SCSS_PREMIERPAPER.CARD_SEQ		AND SCSS_PREMIERPAPER.COMPANY_SEQ = 5003
		LEFT JOIN	S2_CARDSALESSITE SCSS_BHANDSCARD	ON SC.CARD_SEQ = SCSS_BHANDSCARD.CARD_SEQ		AND SCSS_BHANDSCARD.COMPANY_SEQ = 5006
		LEFT JOIN	S2_CARDSALESSITE SCSS_THECARD		ON SC.CARD_SEQ = SCSS_THECARD.CARD_SEQ			AND SCSS_THECARD.COMPANY_SEQ = 5007
		LEFT JOIN	S2_CARDSALESSITE SCSS_BARUNSONMALL  ON SC.CARD_SEQ = SCSS_BARUNSONMALL.CARD_SEQ		AND SCSS_BARUNSONMALL.COMPANY_SEQ = 5000
	
	WHERE	1 = 1

	AND		SC.CARD_GROUP = 'I'



	AND		(
					/* 식권 / 방명록 / 라이닝봉투 */
					/* 20191115 수정 */
					--CASE WHEN @P_ETC_CARD_DIV_VALUE = '' THEN '' ELSE SC.CARD_DIV END IN (SELECT ISNULL(VALUE, '') FROM dbo.FN_SPLIT(@P_ETC_CARD_DIV_VALUE, '|'))

					/* 청첩장 / 감사장 / 초대장 */
				/*OR*/	(
							--CASE WHEN @P_CARD_KIND_SEQ = 0 THEN 0 ELSE SCK.CARDKIND_SEQ END = @P_CARD_KIND_SEQ  --청처장 , 감사장/답례장, 안내장/초대장
							CASE WHEN @P_CARD_KIND_SEQ = '' THEN '' ELSE SCK.CARDKIND_SEQ END IN (SELECT ISNULL(VALUE, '') FROM dbo.FN_SPLIT(@P_CARD_KIND_SEQ, '|'))
							
						/*
						AND	(	
								
										( @P_ISCOLOR = 1 AND SCO.IsColorInpaper = @P_ISCOLOR )				--컬러인쇄
								OR		( @P_ISEMBO = 1 AND SCO.IsEmbo = @P_ISEMBO) 						--송진인쇄
								OR		( @P_ISINPAPER = 1 AND SCO.IsInPaper = @P_ISINPAPER) 				--속지부착
								OR		( @P_ISENVINSERT = 1 AND SCO.IsEnvInsert = @P_ISENVINSERT) 			--봉투삽입
								OR		( @P_ISHANDMADE = 1 AND SCO.IsHandmade = @P_ISHANDMADE) 			--부속부착
								OR		( @P_ISQUICK = 1 AND SCO.IsQuick = @P_ISQUICK)						--퀵제작
								
							)
						*/
						--AND 	
						/*
						 (
	
							((convert(int,@P_ISCOLOR) + convert(int,@P_ISEMBO) + convert(int,@P_ISEMBO) + convert(int,@P_ISINPAPER) + convert(int,@P_ISENVINSERT) +convert(int, @P_ISHANDMADE) + convert(int,@P_ISQUICK)) = 0 
							    or
										( @P_ISCOLOR = 1 AND SCO.IsColorInpaper = @P_ISCOLOR )				--컬러인쇄
								OR		( @P_ISEMBO = 1 AND SCO.IsEmbo = @P_ISEMBO) 						--송진인쇄
								OR		( @P_ISINPAPER = 1 AND SCO.IsInPaper = @P_ISINPAPER) 				--속지부착
								OR		( @P_ISENVINSERT = 1 AND SCO.IsEnvInsert = @P_ISENVINSERT) 			--봉투삽입
								OR		( @P_ISHANDMADE = 1 AND SCO.IsHandmade = @P_ISHANDMADE) 			--부속부착
								OR		( @P_ISQUICK = 1 AND SCO.IsQuick = @P_ISQUICK)						--퀵제작
							)
							and (
							(convert(int,@P_ISCOLOR) + convert(int,@P_ISEMBO) + convert(int,@P_ISEMBO) + convert(int,@P_ISINPAPER) + convert(int,@P_ISENVINSERT) +convert(int, @P_ISHANDMADE) + convert(int,@P_ISQUICK)) > 0
							or 
								SCO.IsColorInpaper = '0' 
								AND SCO.IsEmbo ='0'
								AND SCO.IsInPaper ='0'
								AND SCO.IsEnvInsert ='0'
								AND SCO.IsHandmade ='0'
								AND SCO.IsQuick ='0'
							)
							)
						*/
						AND	
							(
								(
										@T_SITE_SEARCH_VALUE_COUNT < 5
									AND	(
												(SCSS_BARUNSONCARD.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)	AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BARUNSONCARD.ISJUMUN END = @P_SALES_TYPE)
											OR	(SCSS_PREMIERPAPER.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)	AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_PREMIERPAPER.ISJUMUN END = @P_SALES_TYPE)
											OR	(SCSS_BHANDSCARD.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)	AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BHANDSCARD.ISJUMUN END = @P_SALES_TYPE)
											OR	(SCSS_THECARD.COMPANY_SEQ	   IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)	AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_THECARD.ISJUMUN END = @P_SALES_TYPE)
											OR	(SCSS_BARUNSONMALL.COMPANY_SEQ IN (SELECT COMPANY_SEQ FROM @T_SITE_SEARCH_VALUE)	AND CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BARUNSONMALL.ISJUMUN END = @P_SALES_TYPE)
										)
								)
								OR
								(
										@T_SITE_SEARCH_VALUE_COUNT >= 5
									AND (
												CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BARUNSONCARD.ISJUMUN END = @P_SALES_TYPE
											OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_PREMIERPAPER.ISJUMUN END = @P_SALES_TYPE
											OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BHANDSCARD.ISJUMUN END = @P_SALES_TYPE
											OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_THECARD.ISJUMUN END = @P_SALES_TYPE
											OR  CASE WHEN @P_SALES_TYPE = '' THEN '' ELSE SCSS_BARUNSONMALL.ISJUMUN END = @P_SALES_TYPE
										)
								)
							)

					)
			)

	/* 검색어 */
	AND		(
					CASE WHEN @P_CARD_CODE_OR_CARD_NAME = '' THEN '' ELSE SC.CARD_CODE END LIKE '%' + @P_CARD_CODE_OR_CARD_NAME + '%'
				OR	CASE WHEN @P_CARD_CODE_OR_CARD_NAME = '' THEN '' ELSE SC.CARD_NAME END LIKE '%' + @P_CARD_CODE_OR_CARD_NAME + '%'
			)
	
	GROUP BY SC.CARD_SEQ
END

GO
