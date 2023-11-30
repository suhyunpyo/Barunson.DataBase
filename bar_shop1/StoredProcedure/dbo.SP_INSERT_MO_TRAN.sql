IF OBJECT_ID (N'dbo.SP_INSERT_MO_TRAN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MO_TRAN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*



*/

CREATE PROCEDURE [dbo].[SP_INSERT_MO_TRAN]
    @P_ACCEPTTIME       AS  VARCHAR(14)
,   @P_MODIFIED         AS  VARCHAR(14)
,   @P_NUMBER           AS  VARCHAR(20)
,   @P_SENDER           AS  VARCHAR(20)
,   @P_MSG              AS  VARCHAR(160)
,   @P_SN               AS  VARCHAR(8)
,   @P_NET              AS  VARCHAR(10)
,   @P_STATUS           AS  VARCHAR(1)
,   @P_SITE_GUBUN       AS  VARCHAR(14)


AS
BEGIN

    INSERT INTO [invtmng].[MO_TRAN] 
        
        (MO_ACCEPTTIME, MO_MODIFIED, MO_NUMBER, MO_SENDER, MO_MSG, MO_SN, MO_NET, MO_STATUS, SITE_GUBUN, REG_DATE)

	VALUES 

	    ( @P_ACCEPTTIME, @P_MODIFIED, @P_NUMBER, @P_SENDER, @P_MSG, @P_SN, @P_NET , @P_STATUS, @P_SITE_GUBUN, GETDATE()) 

END



GO