IF OBJECT_ID (N'dbo.UP_INSERT_REVIEW_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_INSERT_REVIEW_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UP_INSERT_REVIEW_NEW]
/***************************************************************
작성자	:	표수현
작성일	:	2022-06-15
DESCRIPTION	:	
SPECIAL LOGIC	: 
UP_INSERT_REVIEW_NEW 5000, 12345, 0, 0000, '제목', 'reviews_URL', 5, 'sample', '', 0,'테스트','reviews_URL_a','reviews_URL_b' , '1@1.com'
****************************************************************** 
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
	@COMPANY_SEQ		INT,
	@ORDER_SEQ			INT,
	@CARD_SEQ			INT,
	@CARD_CODE			NVARCHAR(20),
	@REVIEWS_TITLE		NVARCHAR(150),
	@REVIEWS_URL		NVARCHAR(250),
	@SCORE				INT,
	@CONTENT			NTEXT,
	@USERID				NVARCHAR(20),
	@ER_TYPE			INT,
	@USER_NAME			NVARCHAR(20),
	@REVIEWS_URL_A		NVARCHAR(250),
	@REVIEWS_URL_B		NVARCHAR(250),	
	@EMAIL				VARCHAR(100),
	@RESULT				INT=0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
		iF @USERID IS NULL BEGIN  SET @USERID = '' END 
			
		DECLARE @ID	INT;
		DECLARE @EXIST_CNT INT;

		SELECT @EXIST_CNT = COUNT(*) FROM S4_EVENT_REVIEW WHERE ER_REVIEW_URL = @REVIEWS_URL AND ER_COMPANY_SEQ = @COMPANY_SEQ

		IF @EXIST_CNT = 0
			BEGIN
			
				BEGIN TRAN

				/*리뷰 기본정보 등록*/
    			INSERT INTO S4_EVENT_REVIEW (ER_COMPANY_SEQ, ER_ORDER_SEQ, ER_TYPE, ER_CARD_SEQ, ER_CARD_CODE, ER_USERID, ER_REVIEW_TITLE, ER_REVIEW_URL, ER_REVIEW_CONTENT, ER_REVIEW_STAR, ER_USERNAME, ER_REVIEW_URL_A, ER_REVIEW_URL_B, ER_EMAIL) 
    			VALUES 
    			(@COMPANY_SEQ, @ORDER_SEQ, @ER_TYPE, @CARD_SEQ, @CARD_CODE, @USERID, @REVIEWS_TITLE, @REVIEWS_URL, @CONTENT, @SCORE, @USER_NAME, @REVIEWS_URL_A, @REVIEWS_URL_B, @EMAIL)
    		
    			SET @ID = SCOPE_IDENTITY()
    		
			INSERT INTO S4_EVENT_REVIEW_STATUS(ERA_ER_IDX) VALUES (@ID)

			--iF @USERID = '' BEGIN 

			--	INSERT INTO S4_EVENT_REVIEW_STATUS(ERA_ER_IDX, ERA_Status, ERA_Comment_Cancel) VALUES (@ID, 2, '회원가입 전환 후 재승인 요청을 클릭해 주세요.')
		
			--END ELSE BEGIN 

			--	INSERT INTO S4_EVENT_REVIEW_STATUS(ERA_ER_IDX) VALUES (@ID)
			--END 
    			
				SET @RESULT = '0'
				SET @RESULT = @@ERROR
				IF (@RESULT <> 0) GOTO PROBLEM
				COMMIT TRAN


				PROBLEM:
				IF (@RESULT <> 0) BEGIN
					ROLLBACK TRAN
				END
			END
		ELSE
			BEGIN
				SET @RESULT = '9'
				--SET @RESULT = '동일한 URL이 존재합니다.'
			END
			
			RETURN @RESULT

END


GO
