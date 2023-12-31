IF OBJECT_ID (N'dbo.SP_INSERT_S5_NMCARDBOARD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_S5_NMCARDBOARD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM S5_NMCARDBOARD

*/

CREATE PROCEDURE [dbo].[SP_INSERT_S5_NMCARDBOARD]
    @ORDER_SEQ          AS  INT
,   @NAME               AS  VARCHAR(20)
,   @CONTENTS           AS  NVARCHAR(500)
,   @IP					AS  NVARCHAR(50)
,   @HTTP_USER_AGENT	AS	NVARCHAR(500)


AS
BEGIN

    INSERT INTO  S5_NMCARDBOARD (ORDER_SEQ, NAME, CONTENTS, IP, HTTP_USER_AGENT, REGDATE) 
	SELECT	    @ORDER_SEQ      
			,   @NAME           
			,   @CONTENTS       
			,   @IP				
			,   @HTTP_USER_AGENT
			,	GETDATE()

END
GO
