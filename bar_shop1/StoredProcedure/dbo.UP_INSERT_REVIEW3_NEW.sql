IF OBJECT_ID (N'dbo.UP_INSERT_REVIEW3_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_INSERT_REVIEW3_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************    
작성자  : 표수현    
  
작성일  : 2020-10-15    
  
DESCRIPTION :   
  
EXEC UP_INSERT_REVIEW3_NEW 5476, 1811969, 37164, 'BH9221','샘플후기2222','http://www.test.com', null, null,'4','&nbsp; 아 좋네 &lt;p&gt;&nbsp; &lt;p&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_20200429115625.jpg">www.barunsonmall.com/mypage/review/file/bin4849_20200429115625.jpg</a>" title="bin4849_20200429115625.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_20200429115647.jpg">www.barunsonmall.com/mypage/review/file/bin4849_20200429115647.jpg</a>" title="bin4849_20200429115647.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;/p&gt;&nbsp; &lt;p&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_2020042911574.jpg">www.barunsonmall.com/mypage/review/file/bin4849_2020042911574.jpg</a>" title="bin4849_2020042911574.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_20200429115713.jpg">www.barunsonmall.com/mypage/review/file/bin4849_20200429115713.jpg</a>" title="bin4849_20200429115713.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_20200429115719.jpg">www.barunsonmall.com/mypage/review/file/bin4849_20200429115719.jpg</a>" title="bin4849_20200429115719.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;br&gt;&lt;/p&gt;&nbsp;&nbsp;','s4guest','0','시스템테스트',null, null ,'1'

 EXEC UP_INSERT_REVIEW3_NEW 5476, 1811969, 37164, 'BH9221','후기에여','http://www.test.com44', null, null,'5','&nbsp; 아 좋네 &lt;p&gt;&nbsp; &lt;p&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_20200429115625.jpg">www.barunsonmall.com/mypage/review/file/bin4849_20200429115625.jpg</a>" title="bin4849_20200429115625.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_20200429115647.jpg">www.barunsonmall.com/mypage/review/file/bin4849_20200429115647.jpg</a>" title="bin4849_20200429115647.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;/p&gt;&nbsp; &lt;p&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_2020042911574.jpg">www.barunsonmall.com/mypage/review/file/bin4849_2020042911574.jpg</a>" title="bin4849_2020042911574.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_20200429115713.jpg">www.barunsonmall.com/mypage/review/file/bin4849_20200429115713.jpg</a>" title="bin4849_20200429115713.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;img src="https://<a href="http://www.barunsonmall.com/mypage/review/file/bin4849_20200429115719.jpg">www.barunsonmall.com/mypage/review/file/bin4849_20200429115719.jpg</a>" title="bin4849_20200429115719.jpg" style="max-width:800px;heigth:auto;"&gt;&lt;br style="clear:both;"&gt;&lt;br&gt;&lt;/p&gt;&nbsp;&nbsp;','s4guest','0','시스템테스트',null, null ,'1'
********************************************************************    
  
  	SELECT @EXIST_CNT = COUNT(*) FROM S4_EVENT_REVIEW WHERE ER_REVIEW_URL = @REVIEWS_URL AND ER_COMPANY_SEQ = @COMPANY_SEQ
			 select  top 100 *  from S4_EVENT_REVIEW 
			 
			 where er_username = '표수현' ER_REVIEW_TITLE = '샘플 후기입니다'

			 update S4_EVENT_REVIEW
			 set er_view = 1
			where er_username = '표수현'


수정일   작업자  DESCRIPTION    
  
********************************************************************/ 
CREATE PROCEDURE [dbo].[UP_INSERT_REVIEW3_NEW]
	@COMPANY_SEQ		INT,
	@ORDER_SEQ			INT,
	@CARD_SEQ			INT,
	@CARD_CODE			NVARCHAR(20),
	@REVIEWS_TITLE		NVARCHAR(150),
	@REVIEWS_URL		NVARCHAR(250),
    @REVIEWS_URL2		NVARCHAR(250),
	@REVIEWS_URL3		NVARCHAR(250),
	@SCORE				INT,
	@CONTENT			NTEXT,
	@USERID				NVARCHAR(20),
	@ER_TYPE			INT,
	@USER_NAME			NVARCHAR(20),
	@REVIEWS_URL_A		NVARCHAR(250),
	@REVIEWS_URL_B		NVARCHAR(250),	
	@TEXTGUBUN			NVARCHAR(40),
	@DEVICETYPE			NVARCHAR(40) = NULL,				
	@RESULT				INT=0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM
	-- INTERFERING WITH SELECT STATEMENTS.
	SET NOCOUNT ON;
	--BEGIN TRAN
			
			DECLARE @ID	INT;
			DECLARE @EXIST_CNT INT;

			IF @USERID = 's4guest' BEGIN 
				SET @USER_NAME = '표수현'
			END

			IF @COMPANY_SEQ = '5001' OR @COMPANY_SEQ = '5007'
				BEGIN
					SELECT @EXIST_CNT = COUNT(*) FROM S4_EVENT_REVIEW WHERE ER_REVIEW_URL = @REVIEWS_URL AND ER_COMPANY_SEQ = @COMPANY_SEQ
				END
			ELSE
				BEGIN
					SELECT @EXIST_CNT = COUNT(*) FROM S4_EVENT_REVIEW WHERE ER_REVIEW_URL = @REVIEWS_URL AND ER_COMPANY_SEQ = @COMPANY_SEQ
				END

			IF @EXIST_CNT = 0
				BEGIN
					/*리뷰 기본정보 등록*/
    				INSERT INTO S4_EVENT_REVIEW (ER_COMPANY_SEQ, ER_ORDER_SEQ, ER_TYPE, ER_ISPHOTO, ER_CARD_SEQ, ER_CARD_CODE, 
												 ER_USERID, ER_REVIEW_TITLE, ER_REVIEW_URL, ER_REVIEW_URL2, ER_REVIEW_URL3, ER_Comment, --ER_REVIEW_CONTENT
												 ER_REVIEW_STAR, ER_USERNAME, ER_REVIEW_URL_A, ER_REVIEW_URL_B, INFLOW_ROUTE) 
    				VALUES (@COMPANY_SEQ, @ORDER_SEQ, @ER_TYPE, @TEXTGUBUN, @CARD_SEQ, @CARD_CODE, @USERID, @REVIEWS_TITLE, @REVIEWS_URL, @REVIEWS_URL2, @REVIEWS_URL3, 
							@CONTENT, @SCORE, @USER_NAME, @REVIEWS_URL_A, @REVIEWS_URL_B,@DEVICETYPE)
    		
    				SET @ID = SCOPE_IDENTITY()
    		
    				INSERT INTO S4_EVENT_REVIEW_STATUS(ERA_ER_IDX) VALUES (@ID)
		
					--SET @RESULT = '0'
					--SET @RESULT = @@ERROR
					--IF (@RESULT <> 0) GOTO PROBLEM
					--COMMIT TRAN


					--PROBLEM:
					--IF (@RESULT <> 0) BEGIN
					--	ROLLBACK TRAN
					--END
				END
			ELSE
				BEGIN
					SET @RESULT = '9'
					--SET @RESULT = '동일한 URL이 존재합니다.'
				END

			select @RESULT
			RETURN @RESULT

END

GO
