IF OBJECT_ID (N'dbo.up_backend_Getcoop_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_Getcoop_info
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   :   [2003:07:28    13:28]  JJH: 
	관련페이지 : coop_admin/A_Info/coop_info.asp
	내용	   :  해당제휴사 정보
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_Getcoop_info]
	@COMPANY_SEQ		int
as
	SELECT * FROM dbo.COMPANY WHERE COMPANY_SEQ = @COMPANY_SEQ

GO
