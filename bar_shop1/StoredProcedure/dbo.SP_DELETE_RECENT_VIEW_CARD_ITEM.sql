IF OBJECT_ID (N'dbo.SP_DELETE_RECENT_VIEW_CARD_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_DELETE_RECENT_VIEW_CARD_ITEM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DELETE_RECENT_VIEW_CARD_ITEM]
    @P_COMPANY_SEQ          AS INT
,   @P_UID                  AS VARCHAR(50)
,   @P_GUID                 AS VARCHAR(50)
,   @P_CARD_SEQ             AS INT

AS

BEGIN    
    
    DELETE  
    FROM    RECENT_VIEW_CARD_ITEM
    FROM    RECENT_VIEW_CARD_ITEM RVCI 
    JOIN    RECENT_VIEW_CARD_MST RVCM ON RVCI.RECENT_VIEW_CARD_MST_SEQ = RVCM.RECENT_VIEW_CARD_MST_SEQ
    WHERE   1 = 1
    AND     RVCM.COMPANY_SEQ = @P_COMPANY_SEQ
    AND     RVCI.CARD_SEQ = @P_CARD_SEQ
    AND     CASE WHEN @P_UID = '' THEN '' ELSE RVCM.UID END
            =
            CASE WHEN @P_UID = '' THEN '' ELSE @P_UID   END

    AND     CASE WHEN @P_UID <> '' THEN '' ELSE RVCM.GUID END
            =
            CASE WHEN @P_UID <> '' THEN '' ELSE @P_GUID END

END
GO