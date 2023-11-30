IF OBJECT_ID (N'dbo.SP_INSERT_S2_CARD_LIKE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_S2_CARD_LIKE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    EXEC SP_INSERT_S2_CARD_LIKE 36142, 'bae008181', 'F094D888-3D56-4456-8C39-13CC98D66540', 5001, 'SB'
*/

CREATE PROCEDURE [dbo].[SP_INSERT_S2_CARD_LIKE]
		@CARD_SEQ       AS INT
	,	@UID			AS VARCHAR(50)
    ,	@GUID			AS VARCHAR(50)
    ,   @COMPANY_SEQ    AS INT
    ,   @SALES_GUBUN    AS VARCHAR(10)
AS
BEGIN
	
    SET NOCOUNT ON;

    IF NOT EXISTS   (
                        SELECT  *
                        FROM    S2_CARD_LIKE
                        WHERE   1 = 1
                        AND     CARD_SEQ = @CARD_SEQ
                        AND     ((UID = @UID AND UID <> '') OR GUID = @GUID)
                        AND     COMPANY_SEQ = @COMPANY_SEQ
                        AND     SALES_GUBUN = @SALES_GUBUN
                    )
        BEGIN
            
            INSERT INTO S2_CARD_LIKE (CARD_SEQ, COMPANY_SEQ, SALES_GUBUN, GUID, UID)
            VALUES (@CARD_SEQ, @COMPANY_SEQ, @SALES_GUBUN, @GUID, @UID)

        END

END
GO
