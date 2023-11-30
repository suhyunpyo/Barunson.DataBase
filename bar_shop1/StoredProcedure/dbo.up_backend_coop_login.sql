IF OBJECT_ID (N'dbo.up_backend_coop_login', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_login
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:27    23:20]  JJH: 
	관련페이지 : /coop_admin/login.asp
	내용	   : 로그인 조회
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_login]
	@ID		varchar(20)
,	@PASSWD	varchar(20)
as
	SELECT  * FROM dbo.COMPANY WHERE LOGIN_ID = @ID AND PASSWD = @PASSWD AND ONOFF='Y' and STATUS in ('S1','S2')

GO
