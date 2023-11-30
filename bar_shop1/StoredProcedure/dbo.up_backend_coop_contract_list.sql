IF OBJECT_ID (N'dbo.up_backend_coop_contract_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_contract_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:26    14:10]  JJH: 
	관련페이지 : shopadm/custom/SQM/cust_qa_mng.asp
	내용	   : 제휴사 목록
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_contract_list]
	@COMPANY_SEQ		int
as
	SELECT CON_ID
		,COMPANY_SEQ
		,CONTRACT_NM
		,CONTRACT_KIND
		,CONTRACT_VAL
		,CONVERT(varchar(8),CONTRACT_SDT,112) as CONTRACT_SDT
		,CONVERT(varchar(8),CONTRACT_EDT,112) as CONTRACT_EDT
		,REG_ID
		,REG_DT
		,CHG_ID
		,CHG_DT
		,STAT
		 FROM dbo.CONTRACT_TBL WHERE COMPANY_SEQ = @COMPANY_SEQ 
				AND	STAT = 'S2'
				ORDER BY COMPANY_SEQ

GO
