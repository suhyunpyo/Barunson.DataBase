IF OBJECT_ID (N'dbo.up_backend_coop_contract_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_contract_info
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   :   [2003:07:29    23:02]  JJH: 
	관련페이지 :  custom/A_Info/coop_info.asp
	내용	   :  제휴사 베너 정보
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_contract_info]
	@CON_ID	int
as
	SELECT * FROM dbo.CONTRACT_TBL WHERE CON_ID = @CON_ID

GO
