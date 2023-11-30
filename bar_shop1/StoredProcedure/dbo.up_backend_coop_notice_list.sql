IF OBJECT_ID (N'dbo.up_backend_coop_notice_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_notice_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   :   [2003:07:28    13:28]  JJH: 
	관련페이지 : coop_admin/A_Info/coop_info.asp
	내용	   : 공지사항
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_notice_list]
as
	SELECT TOP 20 * FROM dbo.ADMIN_NOTICE  ORDER BY IID DESC

GO
