IF OBJECT_ID (N'dbo.SP_SELECT_COUPON_APPLY_CARD_SEARCH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_COUPON_APPLY_CARD_SEARCH
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

	EXEC SP_SELECT_CUSTOM_RANKING 5003, 'BRMO', 'ALL', '', 'RANKING'
	EXEC SP_SELECT_CUSTOM_RANKING 5000, 'SBBT', 'ALL', '', 'RANKING'

	EXEC SP_SELECT_CUSTOM_RANKING 5007, '3', 'ALL', 'b', 'SEARCH'



*/
CREATE PROCEDURE [dbo].[SP_SELECT_COUPON_APPLY_CARD_SEARCH]
	--	@P_COMPANY_SEQ		AS INT
	--,	@P_RANKING_TYPE		AS VARCHAR(20)
	--,	@P_BRAND_TYPE		AS VARCHAR(20)
		@P_CARD_CODE		AS VARCHAR(50)
	,	@P_LIST_TYPE		AS VARCHAR(20) -- CUSTOM, RANKING, SEARCH
	,	@P_COUPON_MST_SEQ	AS INT

AS
BEGIN
		IF @P_LIST_TYPE = 'SEARCH'
			BEGIN

				SELECT	SC.CARD_SEQ		AS CardSeq
					,	MAX(SC.CARD_CODE)	AS CardCode
					,	MAX(SC.CARD_NAME)	AS CardName
					,	MAX(SC.CARD_PRICE)	AS CardPrice
					,	MAX(SC.CARDBRAND)	AS CardBrand
					,	MAX(CASE 
								WHEN SCSS.Company_Seq = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN SCSS.Company_Seq = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN SCSS.Company_Seq = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
								WHEN SCSS.Company_Seq = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN SCSS.Company_Seq = 5007 THEN 'http://file.barunsoncard.com/thecard/'		+ SC.CARD_CODE + '/210.jpg'
								ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						END) AS ImageUrl

				FROM	S2_CARD SC
				JOIN	S2_CARDSALESSITE SCSS	ON SC.CARD_SEQ = SCSS.CARD_SEQ
				JOIN    S2_CardDetail SCD		ON SC.CARD_SEQ = SCD.CARD_SEQ
				JOIN	S2_CARDOPTION SCO		ON SC.CARD_SEQ = SCO.CARD_sEQ
				WHERE	1 = 1
				--AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
				AND		SCSS.ISDISPLAY = 1
				AND		(SC.CARD_CODE LIKE '%' + @P_CARD_CODE + '%' OR SC.CARD_NAME LIKE '%' + @P_CARD_CODE + '%')
				--AND		SC.CARD_DIV = 'A01'
				GROUP BY SC.CARD_SEQ
		
				ORDER BY SC.Card_Seq DESC
			END
		ELSE
			
			BEGIN

				SELECT	SC.CARD_SEQ		AS CardSeq
					,	MAX(SC.CARD_CODE)	AS CardCode
					,	MAX(SC.CARD_NAME)	AS CardName
					,	MAX(SC.CARD_PRICE)	AS CardPrice
					,	MAX(SC.CARDBRAND)	AS CardBrand
					,	MAX(CASE 
								WHEN SCSS.Company_Seq = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN SCSS.Company_Seq = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN SCSS.Company_Seq = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
								WHEN SCSS.Company_Seq = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN SCSS.Company_Seq = 5007 THEN 'http://file.barunsoncard.com/thecard/'		+ SC.CARD_CODE + '/210.jpg'
								ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						END) AS ImageUrl

				FROM	S2_CARD SC
				JOIN	S2_CARDSALESSITE SCSS	ON SC.CARD_SEQ = SCSS.CARD_SEQ
				JOIN    S2_CardDetail SCD		ON SC.CARD_SEQ = SCD.CARD_SEQ
				JOIN	S2_CARDOPTION SCO		ON SC.CARD_SEQ = SCO.CARD_sEQ
				JOIN    COUPON_APPLY_CARD CAC	ON SC.CARD_SEQ = CAC.CARD_SEQ 
				WHERE	1 = 1
				--AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
				AND		SCSS.ISDISPLAY = 1
				AND		(SC.CARD_CODE LIKE '%' + @P_CARD_CODE + '%' OR SC.CARD_NAME LIKE '%' + @P_CARD_CODE + '%')
				AND     CAC.COUPON_MST_SEQ = @P_COUPON_MST_SEQ
				--AND		SC.CARD_DIV = 'A01'
				GROUP BY SC.CARD_SEQ
		
				ORDER BY SC.Card_Seq DESC
			END


END
GO
