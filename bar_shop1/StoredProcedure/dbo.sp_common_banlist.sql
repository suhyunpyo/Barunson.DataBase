IF OBJECT_ID (N'dbo.sp_common_banlist', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_common_banlist
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_common_banlist]
    @p_service_type char(2)
AS
    
    SELECT service_type
         , ban_type
         , content
         , send_yn
    FROM   ata_banlist
    WHERE  service_type = @p_service_type
    AND    ban_type  <> 'R'
    AND    ban_status_yn = 'Y'

RETURN
GO
