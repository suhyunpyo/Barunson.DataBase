IF OBJECT_ID (N'dbo.SP_UPDATE_S2_CARD_LIKE_FOR_GUID', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_S2_CARD_LIKE_FOR_GUID
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    
*/

CREATE PROCEDURE [dbo].[SP_UPDATE_S2_CARD_LIKE_FOR_GUID]
        @COMPANY_SEQ    AS INT
    ,   @SALES_GUBUN    AS VARCHAR(10)
	,   @UID			AS VARCHAR(50)
    ,	@GUID			AS VARCHAR(50)
AS
BEGIN
	
    SET NOCOUNT ON;

    UPDATE  S2_CARD_LIKE
    SET     UID = @UID
    WHERE   1 = 1
    AND     GUID = @GUID
    AND     COMPANY_SEQ = @COMPANY_SEQ
    AND     SALES_GUBUN = @SALES_GUBUN

END
GO
