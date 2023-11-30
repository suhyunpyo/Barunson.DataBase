IF OBJECT_ID (N'dbo.SP_T_USER_QNA_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_USER_QNA_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_USER_QNA_INSERT]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - QNA 추가 / 삭제
SPECIAL LOGIC	:
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN	CHAR(2) = 'I',	--  I(대문자 I) : 저장 /  D : 삭제
 @SALES_GUBUN VARCHAR(2) = NULL,
 @COMPANY_SEQ INT = NULL,
 @ORDER_SEQ bigint = NULL,
 @MEMBER_ID VARCHAR(50) = NULL,
 @MEMBER_NAME VARCHAR(50) = NULL,
 @E_MAIL  VARCHAR(50) = NULL,
 @Q_TITLE  VARCHAR(100) = NULL,
 @Q_CONTENT TEXT = NULL,
 @TEL_NO  VARCHAR(20) = NULL,  
 @USER_UPFILE1  VARCHAR(100) = NULL,
 @QA_IID INT = NULL,
 @STAT VARCHAR(4) = NULL
AS 

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

 DECLARE @Order_Code bigint

 if @ORDER_SEQ is not null and @ORDER_SEQ <> '' and @ORDER_SEQ > 0  begin 
	select @Order_Code = replace(Order_Code, 'M', '')
	from barunson.DBO.TB_ORDER
	where Order_ID = @ORDER_SEQ
 end 

 
 IF UPPER(@USER_UPFILE1) = 'HTTPS://WWW.BARUNSONMCARD.COM/UPLOAD/QNA/' BEGIN 
	SET @USER_UPFILE1 = ''
 END 


 IF @GUBUN = 'I' BEGIN

	INSERT INTO BAR_SHOP1.DBO.S2_USERQNA (SALES_GUBUN, COMPANY_SEQ, ORDER_SEQ, MEMBER_ID, MEMBER_NAME,
											  E_MAIL, Q_TITLE, Q_CONTENT, TEL_NO, USER_UPFILE1, REG_DT, A_STAT)
	VALUES (@SALES_GUBUN, @COMPANY_SEQ, @Order_Code, @MEMBER_ID, @MEMBER_NAME,
				@E_MAIL, @Q_TITLE, @Q_CONTENT, @TEL_NO, @USER_UPFILE1, GETDATE(), @STAT)


 END ELSE IF  @GUBUN = 'D' BEGIN 

	DELETE FROM BAR_SHOP1.DBO.S2_USERQNA 
	WHERE QA_IID = @QA_IID

 END ELSE IF  @GUBUN = 'U' BEGIN 

	UPDATE BAR_SHOP1.DBO.S2_USERQNA 
	SET SALES_GUBUN = @SALES_GUBUN,
		COMPANY_SEQ = @COMPANY_SEQ, 
		ORDER_SEQ = @Order_Code, 
		MEMBER_ID = @MEMBER_ID, 
		MEMBER_NAME = @MEMBER_NAME,
		E_MAIL = @E_MAIL, 
		Q_TITLE = @Q_TITLE, 
		Q_CONTENT = @Q_CONTENT, 
		TEL_NO = @TEL_NO, 
		USER_UPFILE1 = @USER_UPFILE1, 
		REG_DT =  GETDATE(), 
		A_STAT = @STAT
	WHERE QA_IID = @QA_IID

 END
GO
