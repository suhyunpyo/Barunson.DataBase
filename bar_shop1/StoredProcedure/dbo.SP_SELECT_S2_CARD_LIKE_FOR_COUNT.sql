IF OBJECT_ID (N'dbo.SP_SELECT_S2_CARD_LIKE_FOR_COUNT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S2_CARD_LIKE_FOR_COUNT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    EXEC SP_INSERT_S2_CARD_LIKE 36142, 'bae008181', 'F094D888-3D56-4456-8C39-13CC98D66540', 5001, 'SB'
*/

CREATE PROCEDURE [dbo].[SP_SELECT_S2_CARD_LIKE_FOR_COUNT]
		@CARD_SEQ       AS INT
	,	@UID			AS VARCHAR(50)
    ,	@GUID			AS VARCHAR(50)
    ,   @COMPANY_SEQ    AS INT
    ,   @SALES_GUBUN    AS VARCHAR(10)
AS
BEGIN
	
    SELECT  COUNT(*) AS CARD_LIKE_TOTAL_COUNT
        ,   SUM(CASE WHEN (UID = @UID AND UID <> '') OR GUID = @GUID THEN 1 ELSE 0 END) AS CARD_LIKE_USER_COUNT
    FROM    S2_CARD_LIKE
    WHERE   1 = 1
    AND     CARD_SEQ = @CARD_SEQ
    AND     COMPANY_SEQ = @COMPANY_SEQ
    AND     SALES_GUBUN = @SALES_GUBUN

END
GO
