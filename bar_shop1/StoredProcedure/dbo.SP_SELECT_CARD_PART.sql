IF OBJECT_ID (N'dbo.SP_SELECT_CARD_PART', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CARD_PART
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_CARD_PART 'C05','', 10, 1, 'REG_DATE', 'DESC'

*/

CREATE PROCEDURE [dbo].[SP_SELECT_CARD_PART]
		@P_CARD_DIV AS VARCHAR(50)
	,	@P_CARD_CODE_OR_CARD_NAME AS VARCHAR(50)
	,	@P_PAGE_SIZE AS INT
	,	@P_PAGE_NUMBER AS INT
	,	@P_ORDER_BY_NAME AS VARCHAR(50)
	,	@P_ORDER_BY_TYPE AS VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON

	SELECT	*
	FROM	(
				SELECT	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REG_DATE						ELSE 0 END ASC
												,	C.CARD_SEQ ASC
													
											) AS ROW_NUM
					,	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REG_DATE						ELSE 0 END DESC
												,	C.CARD_SEQ DESC
													
											) AS ROW_NUM_DESC
					,	*
				FROM	(
							SELECT	DISTINCT 
									SC.CARD_SEQ
								,	SC.CARD_CODE	
								,	SC.CARD_NAME
								,	SC.CARDSET_PRICE AS CARD_SET_PRICE
								,	SC.CARD_PRICE
								,	CASE WHEN ISNULL(SC.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC.CARD_IMAGE END AS CARD_IMAGE_FULL_URL
								,	SC.REGDATE AS REG_DATE
								,   SC.CardFactory_Price
								,	ISNULL((1 + SCSS_BARUNSONCARD.ISDISPLAY		), 0) AS DISPLAY_BARUNSONCARD
								,	ISNULL((1 + SCSS_BHANDSCARD.ISDISPLAY		), 0) AS DISPLAY_BHANDSCARD
								,	ISNULL((1 + SCSS_THECARD.ISDISPLAY			), 0) AS DISPLAY_THECARD 
								,	ISNULL((1 + SCSS_PREMIERPAPER.ISDISPLAY		), 0) AS DISPLAY_PREMIERPAPER
								,	ISNULL((1 + SCSS_BARUNSONMALL.ISDISPLAY		), 0) AS DISPLAY_BARUNSONMALL
								,	ISNULL((1 + SCSS_OUTBOUND.ISDISPLAY			), 0) AS DISPLAY_OUTBOUND

							FROM	S2_CARD SC
							--JOIN	S2_CARDKIND SCK ON SC.CARD_SEQ = SCK.CARD_SEQ
							LEFT JOIN	S2_CARDSALESSITE SCSS_BARUNSONCARD	ON SC.CARD_SEQ = SCSS_BARUNSONCARD.CARD_SEQ		AND SCSS_BARUNSONCARD.COMPANY_SEQ = 5001
							LEFT JOIN	S2_CARDSALESSITE SCSS_PREMIERPAPER	ON SC.CARD_SEQ = SCSS_PREMIERPAPER.CARD_SEQ		AND SCSS_PREMIERPAPER.COMPANY_SEQ = 5003
							LEFT JOIN	S2_CARDSALESSITE SCSS_BHANDSCARD	ON SC.CARD_SEQ = SCSS_BHANDSCARD.CARD_SEQ		AND SCSS_BHANDSCARD.COMPANY_SEQ = 5006
							LEFT JOIN	S2_CARDSALESSITE SCSS_THECARD		ON SC.CARD_SEQ = SCSS_THECARD.CARD_SEQ			AND SCSS_THECARD.COMPANY_SEQ = 5007
							LEFT JOIN	S2_CARDSALESSITE SCSS_BARUNSONMALL  ON SC.CARD_SEQ = SCSS_BARUNSONMALL.CARD_SEQ		AND SCSS_BARUNSONMALL.COMPANY_SEQ = 5000
							LEFT JOIN	S2_CARDSALESSITE SCSS_OUTBOUND		ON SC.CARD_SEQ = SCSS_OUTBOUND.CARD_SEQ			AND SCSS_OUTBOUND.COMPANY_SEQ = 5008

							WHERE	1 = 1
							--AND		SC.CARD_GROUP IN ( 'I' )

							AND		(
										    CASE WHEN @P_CARD_DIV = 'C05' THEN  SC.Card_Div else '' end  IN (SELECT value from dbo.FN_SPLIT('C05,C07', ','))
										OR	CASE WHEN @P_CARD_DIV = 'C06' THEN  SC.Card_Div else '' end  IN (SELECT value from dbo.FN_SPLIT('C01,C02,C06,C09,C10,C11', ',') )
										OR  SC.Card_Div IN (@P_CARD_DIV)
									)

							AND		(
											CASE WHEN ISNULL(@P_CARD_CODE_OR_CARD_NAME, '') = '' THEN '' ELSE SC.CARD_DIV END  NOT IN ('A01','A03')  AND SC.CARD_CODE LIKE '%' + @P_CARD_CODE_OR_CARD_NAME + '%'
										OR	CASE WHEN ISNULL(@P_CARD_CODE_OR_CARD_NAME, '') = '' THEN '' ELSE SC.CARD_NAME END LIKE '%' + @P_CARD_CODE_OR_CARD_NAME + '%'
									)

						) C

			) A

	WHERE	1 = 1
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END > (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE
		
	ORDER BY 
		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END ASC
	
END


GO
