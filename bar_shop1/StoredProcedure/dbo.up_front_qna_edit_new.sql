IF OBJECT_ID (N'dbo.up_front_qna_edit_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_qna_edit_new
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:26    8:04]  JJH: 
	관련페이지 : wedd_qna.asp
	내용	   : 고객 Q&A 등록
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_front_qna_edit_new]
	@MEMBER_ID		varchar(50)
,	@MEMBER_NAME		varchar(100)
,	@E_MAIL			varchar(100)
,	@TEL_NO		varchar(100)
,	@Q_KIND		varchar(100)
,	@Q_TITLE		varchar(100)
,	@Q_CONTENT		varchar(1000)
,	@CON_ID		INT
as
--	DECLARE	@COMPANY_SEQ 	INT
--	SELECT @COMPANY_SEQ =COMPANY_SEQ   FROM dbo.CONTRACT_TBL WHERE CON_ID = @CON_ID
--	IF (ISNULL(@COMPANY_SEQ,-1) = -1) SET @COMPANY_SEQ = 1
	
INSERT INTO dbo.SQM_QA_TBL(COMPANY_SEQ
			,MEMBER_ID
			,MEMBER_NAME
			,E_MAIL
			,TEL_NO
			,Q_KIND
			,Q_TITLE
			,Q_CONTENT
			,A_STAT
			,REG_DT)
VALUES(			1
			,@MEMBER_ID
			,@MEMBER_NAME
			,@E_MAIL
			,@TEL_NO
			,@Q_KIND
			,@Q_TITLE
			,@Q_CONTENT			
			,'S1'
			,GETDATE())
GO
