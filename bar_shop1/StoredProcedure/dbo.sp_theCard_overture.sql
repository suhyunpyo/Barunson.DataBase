IF OBJECT_ID (N'dbo.sp_theCard_overture', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_theCard_overture
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_theCard_overture]
    @B_REMOTE_ADDR char(15)
as
begin       
    UPDATE THE_CARD_OVERTURE
    SET MOM_OVERTURE_ID = @B_REMOTE_ADDR  
    WHERE B_REMOTE_ADDR = @B_REMOTE_ADDR    
end
GO