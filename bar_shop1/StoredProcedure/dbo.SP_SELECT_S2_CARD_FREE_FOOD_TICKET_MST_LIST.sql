IF OBJECT_ID (N'dbo.SP_SELECT_S2_CARD_FREE_FOOD_TICKET_MST_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S2_CARD_FREE_FOOD_TICKET_MST_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_SELECT_S2_CARD_FREE_FOOD_TICKET_MST_LIST '', 5006

*/
CREATE PROCEDURE [dbo].[SP_SELECT_S2_CARD_FREE_FOOD_TICKET_MST_LIST]
	@USE_YORN AS CHAR(1)
,	@COMPANY_SEQ AS INT
AS
BEGIN

    SELECT	
			ROW_NUMBER()OVER(ORDER BY SCFFTM.REG_DATE DESC) AS ROW_NUM
		,	SCFFTM.SEQ
		,	SCFFTM.CARD_SEQ
		,	C.COMPANY_NAME
		,	SC.CARD_CODE
		,	SC.CARD_NAME
		,	SC.CARD_IMAGE		
		,	SCFFTM.COMPANY_SEQ
		,	CONVERT(VARCHAR(10), SCFFTM.START_DATE, 120) AS START_DATE
		,	CONVERT(VARCHAR(10), SCFFTM.END_DATE, 120) AS END_DATE
		,	SCFFTM.USE_JEHU_YORN
		,	SCFFTM.USE_YORN
		,	SCFFTM.REG_DATE

	FROM	S2_CARD_FREE_FOOD_TICKET_MST SCFFTM
	JOIN	S2_CARD SC ON SCFFTM.CARD_SEQ = SC.CARD_SEQ
	JOIN	COMPANY C ON SCFFTM.COMPANY_SEQ = C.COMPANY_SEQ
	--JOIN	S2_CARDSALESSITE SCSS ON SCFFTM.CARD_SEQ = SCSS.CARD_SEQ AND SCFFTM.COMPANY_SEQ = SCSS.COMPANY_SEQ

	WHERE	1 = 1
	AND		CASE WHEN @USE_YORN = '' THEN '' ELSE SCFFTM.USE_YORN END = @USE_YORN
	AND		CASE WHEN @COMPANY_SEQ = 0 THEN 0 ELSE SCFFTM.COMPANY_SEQ END = @COMPANY_SEQ

END
GO
