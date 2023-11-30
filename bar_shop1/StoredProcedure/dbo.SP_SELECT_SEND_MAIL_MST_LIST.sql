IF OBJECT_ID (N'dbo.SP_SELECT_SEND_MAIL_MST_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SEND_MAIL_MST_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC [SP_SELECT_SEND_MAIL_MST_LIST] 'Y'

*/

CREATE PROC [dbo].[SP_SELECT_SEND_MAIL_MST_LIST]  
    @SEND_YORN              CHAR(1)


AS  
SET NOCOUNT ON
BEGIN
    
    SELECT  TOP 50 
            MID
        ,   SNAME
        ,   SMAIL
        ,   RNAME
        ,   RMAIL
        ,   MTITLE
        ,   MCONTENT 
    FROM    TNEO_QUEUE 
    WHERE   ISSEND = @SEND_YORN

    ORDER BY ORG_DATE ASC
	
END


GO
