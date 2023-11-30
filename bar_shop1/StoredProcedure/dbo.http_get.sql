IF OBJECT_ID (N'dbo.http_get', N'P') IS NOT NULL DROP PROCEDURE dbo.http_get
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[http_get]( @url varchar(200))
 As
 
DECLARE @Object INT
 
DECLARE @xStrINT INT

 

EXEC @xStrINT = master..sp_OACreate 'MSXML2.XMLHTTP',@Object OUT

IF @xStrINT <> 0
 
   BEGIN
 
           EXEC master..sp_OAGetErrorInfo @Object RETURN
 
   END
 
EXEC @xStrINT = master..sp_OAMethod @Object, 'Open',NULL,'GET',@url,'false'



IF @xStrINT <> 0
 
   BEGIN
 
           EXEC master..sp_OAGetErrorInfo @Object RETURN
 
   END
 
EXEC @xStrINT = master..sp_OAMethod @Object,'Send'


IF @xStrINT <> 0
 
   BEGIN
 
           EXEC master..sp_OAGetErrorInfo @Object RETURN
 
   END
 
EXEC @xStrINT = master..sp_OADestroy @Object
GO
