IF OBJECT_ID (N'dbo.up_backend_QnA_Edit', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_QnA_Edit
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:26    14:10]  JJH: 
	관련페이지 : shopadm/custom/SQM/cust_qa_mng.asp
	내용	   :Q&A 결과 UPDATE
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_QnA_Edit]
	@QA_IID		varchar(10)
,	@A_CONTENT	varchar(1000)
,	@ADMIN_ID	varchar(20)
,	@STAT		varchar(2)
as
	UPDATE dbo.SQM_QA_TBL SET 
			A_CONTENT 	= @A_CONTENT
			,A_ID		= @ADMIN_ID
			,A_DT		= GETDATE()
			,A_STAT		= @STAT
	WHERE QA_IID = @QA_IID

GO
