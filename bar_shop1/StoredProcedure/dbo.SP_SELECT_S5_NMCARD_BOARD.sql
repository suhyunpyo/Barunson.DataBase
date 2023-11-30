IF OBJECT_ID (N'dbo.SP_SELECT_S5_NMCARD_BOARD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S5_NMCARD_BOARD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM S5_nmCARDORDER WHERE ADDr= 's4guests4guest'

EXEC SP_SELECT_S5_NMCARD_BOARD 0, 's4guests4guest', 1, 5

*/

CREATE PROCEDURE [dbo].[SP_SELECT_S5_NMCARD_BOARD]
	@ORDER_SEQ			AS INT
,	@MCARD_ADDRESS		AS VARCHAR(50)
,	@CURRENT_PAGE		AS INT
,	@RECORD_PER_PAGE	AS INT = 10

AS
BEGIN

	SELECT	CAST(ROW_NUM AS VARCHAR(10)) ROW_NUM
		,	BOARD_SEQ
		,	ORDER_SEQ
		,	NAME
		,	CONTENTS
		,	CONVERT(VARCHAR(19), REGDATE, 120) AS REG_DATE
	FROM	(

		SELECT	ROW_NUMBER() OVER(ORDER BY MCARD_BOARD.BOARD_SEQ DESC) AS ROW_NUM
			,	MCARD_BOARD.BOARD_SEQ
			,	MCARD_BOARD.ORDER_SEQ
			,	MCARD_BOARD.NAME
			,	MCARD_BOARD.CONTENTS
			,	MCARD_BOARD.REGDATE
		FROM	S5_NMCARDBOARD MCARD_BOARD
		JOIN	S5_NMCARDORDER MCARD ON MCARD_BOARD.ORDER_SEQ = MCARD.ORDER_SEQ
		WHERE	1 = 1
		AND		CASE WHEN @ORDER_SEQ > 0		THEN MCARD.ORDER_SEQ	ELSE @ORDER_SEQ		END = @ORDER_SEQ
		AND		CASE WHEN @MCARD_ADDRESS <> ''	THEN MCARD.ADDR			ELSE @MCARD_ADDRESS END = @MCARD_ADDRESS

	) A

	WHERE	1 = 1
	AND		A.ROW_NUM >= (@CURRENT_PAGE - 1) * @RECORD_PER_PAGE + 1
	AND		A.ROW_NUM <= @CURRENT_PAGE * @RECORD_PER_PAGE

END

GO