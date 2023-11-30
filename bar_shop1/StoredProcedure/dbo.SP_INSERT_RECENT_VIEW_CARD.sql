IF OBJECT_ID (N'dbo.SP_INSERT_RECENT_VIEW_CARD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_RECENT_VIEW_CARD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_INSERT_RECENT_VIEW_CARD]

    @P_COMPANY_SEQ  AS INT
,   @P_UID          AS VARCHAR(50)
,   @P_GUID         AS VARCHAR(50)
,   @P_CARD_SEQ     AS INT

AS

BEGIN
    
    SET NOCOUNT ON;

    DECLARE @RECENT_VIEW_CARD_MST_SEQ AS INT

    SET @RECENT_VIEW_CARD_MST_SEQ = ISNULL((
                                                SELECT  RECENT_VIEW_CARD_MST_SEQ
                                                FROM    RECENT_VIEW_CARD_MST 
                                                WHERE   1 = 1
                                                AND     UID         = @P_UID 
                                                AND     GUID        = @P_GUID
                                                AND     COMPANY_SEQ = @P_COMPANY_SEQ
                                            ), 0)

    IF @RECENT_VIEW_CARD_MST_SEQ = 0 
        BEGIN

            INSERT INTO RECENT_VIEW_CARD_MST (COMPANY_SEQ, UID, GUID)
            VALUES ( @P_COMPANY_SEQ, @P_UID, @P_GUID )

            SET @RECENT_VIEW_CARD_MST_SEQ = SCOPE_IDENTITY()

        END

    INSERT INTO RECENT_VIEW_CARD_ITEM (RECENT_VIEW_CARD_MST_SEQ, CARD_SEQ)
    VALUES ( @RECENT_VIEW_CARD_MST_SEQ, @P_CARD_SEQ )

    SELECT @RECENT_VIEW_CARD_MST_SEQ

END
GO
