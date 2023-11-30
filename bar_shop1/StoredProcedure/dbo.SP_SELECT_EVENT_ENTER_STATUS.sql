IF OBJECT_ID (N'dbo.SP_SELECT_EVENT_ENTER_STATUS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_EVENT_ENTER_STATUS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM S4_EVENTMUSIC_REPLY WHERE COMPANY_SEQ = 5001

EXEC [SP_SELECT_EVENT_ENTER_STATUS] 5001, 104, 'tnrldi5'

*/



CREATE PROCEDURE [dbo].[SP_SELECT_EVENT_ENTER_STATUS]
	@P_COMPANY_SEQ AS INT
,	@P_EVENT_NUMBER AS INT
,	@P_USER_ID AS VARCHAR(50)
	AS
BEGIN

SET NOCOUNT ON;

DECLARE @RESULT AS VARCHAR(1)

SET @RESULT =	(
					SELECT	TOP 1 'Y'
					FROM	S4_EVENTMUSIC_REPLY
					WHERE	1 = 1
					AND		COMPANY_SEQ = @P_COMPANY_SEQ
					AND		REG_NUM = @P_EVENT_NUMBER
					AND		UID = @P_USER_ID
				)

SELECT	ISNULL(@RESULT, 'N') AS RESULT

END
GO