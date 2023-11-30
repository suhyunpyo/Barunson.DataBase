IF OBJECT_ID (N'dbo.SP_UPDATE_CARD_COREL_FOR_AUTO_CHOAN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_CARD_COREL_FOR_AUTO_CHOAN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_UPDATE_CARD_COREL_FOR_AUTO_CHOAN]
    @P_CARD_CODE AS NVARCHAR(50)
,   @P_AUTO_CHOAN_YORN AS CHAR(1)
AS
BEGIN
    
    SET NOCOUNT OFF

    UPDATE  CARD_COREL
    SET     AUTO_CHOAN_YORN = @P_AUTO_CHOAN_YORN
    WHERE   CARD_CODE = @P_CARD_CODE

END
GO
