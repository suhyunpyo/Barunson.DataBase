IF OBJECT_ID (N'dbo.up_backend_coop_contract_edit', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_contract_edit
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:29    23:12]  JJH: 
	관련페이지 : shopadm/custom/SQM/cust_qa_mng.asp
	내용	   : 제휴사 계약 등록/수정
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_contract_edit]
	@KIND			varchar(20)
,	@CON_ID		INT
,	@COMPANY_SEQ		INT
,	@CONTRACT_NM		varchar(20)
,	@CONTRACT_KIND	varchar(2)
,	@CONTRACT_VAL		INT
,	@CONTRACT_SDT	DATETIME
,	@CONTRACT_EDT	DATETIME
,	@ADMIN_ID		varchar(20)
as
	IF @KIND = 'ADD'
		BEGIN
			INSERT INTO dbo.CONTRACT_TBL(
						COMPANY_SEQ
						,CONTRACT_NM
						,CONTRACT_KIND
						,CONTRACT_VAL
						,CONTRACT_SDT
						,CONTRACT_EDT
						,REG_ID
						,STAT )
					VALUES(@COMPANY_SEQ
						,@CONTRACT_NM
						,@CONTRACT_KIND
						,@CONTRACT_VAL
						,@CONTRACT_SDT
						,@CONTRACT_EDT
						,@ADMIN_ID
						,'S2' )
		END
	IF @KIND = 'UPDATE'
		BEGIN
			UPDATE dbo.CONTRACT_TBL SET 
						CONTRACT_NM		= @CONTRACT_NM
						,CONTRACT_KIND		= @CONTRACT_KIND
						,CONTRACT_VAL		= @CONTRACT_VAL
						,CONTRACT_SDT		= @CONTRACT_SDT
						,CONTRACT_EDT		= @CONTRACT_EDT
						,CHG_ID			= @ADMIN_ID
						,CHG_DT		= GETDATE()
			WHERE CON_ID = @CON_ID
		END

GO
