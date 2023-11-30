IF OBJECT_ID (N'dbo.UP_UPDATE_SAMPLEREVIEW_CONFIRM', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_UPDATE_SAMPLEREVIEW_CONFIRM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UP_UPDATE_SAMPLEREVIEW_CONFIRM]
/***************************************************************
작성자	:	표수현
작성일	:	2022-06-15
DESCRIPTION	:	
SPECIAL LOGIC	: 

****************************************************************** 
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
	@ER_IDX INT
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE	@USERNAME NVARCHAR(40)
	DECLARE	 @EMAIL VARCHAR(100)
	DECLARE	@MEMYN INT

			
	SELECT	@USERNAME = ER_USERNAME, 
			@EMAIL = ER_EMAIL 
	FROM S4_EVENT_REVIEW
	WHERE ER_IDX  =@ER_IDX


	SELECT @MEMYN = COUNT(1) 
	FROM	S2_USERINFO
	WHERE	UNAME = @USERNAME AND 
			UMAIL = @EMAIL

 IF @MEMYN > 0 BEGIN 
		
		IF EXISTS(SELECT * FROM S4_EVENT_REVIEW WHERE  AGAIN_CONFIRM = 1 AND ER_IDX  =@ER_IDX) BEGIN 
		
			SELECT RETURNVALUE =  'FAIL2'
		
		END ELSE BEGIN 

			UPDATE S4_EVENT_REVIEW 
			SET AGAIN_CONFIRM = 1 
			WHERE ER_IDX  =@ER_IDX

			SELECT RETURNVALUE =  'SUCCESS'
		END 
		

 END ELSE BEGIN 

	SELECT RETURNVALUE = 'FAIL'

 END 


END

GO
