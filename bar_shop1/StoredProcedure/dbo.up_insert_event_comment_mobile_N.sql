IF OBJECT_ID (N'dbo.up_insert_event_comment_mobile_N', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_event_comment_mobile_N
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김현기
-- Create date: 2016-04-29
-- Description:	모바일 이벤트 페이지 덧글 등록
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_event_comment_mobile_N]
	-- Add the parameters for the stored procedure here
	@mode			CHAR(1),	
	@idx		int,
	@company_seq		int,
	@type				int,
	@card_seq			int,
	@userid				nvarchar(20),
	@reviews_title		nvarchar(150),
	@reviews_URL		nvarchar(250),
	@reviews_content	ntext,
	@user_name			nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRAN
	
	DECLARE @result_code INT
	SET @result_code = 0	

	---- 등록인 경우
	IF @mode = 'I'
	BEGIN
			
		/*덧글  기본정보 등록*/
		INSERT INTO S4_Event_Review_NEW 
				(ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Card_Seq, ER_Card_Code, ER_UserId, ER_Review_Title, ER_Review_Url, ER_Review_Content, ER_UserName) 
			VALUES 
				(@company_seq, 0, @type, @card_seq, @card_seq, @userid, @reviews_title, @reviews_URL, @reviews_content, @user_name)
    		
		set @idx = SCOPE_IDENTITY()
    		
		INSERT INTO S4_Event_Review_Status_New(ERA_ER_idx) values (@idx)
	END
	
	-- 수정인 경우
	ELSE
	BEGIN
		UPDATE S4_Event_Review_NEW
			SET	
				 ER_Review_Title =  @reviews_title
				,ER_Review_Content =  @reviews_content
			WHERE ER_Idx = @idx
	END	
	
	SET @result_code = @@Error		--에러발생 cnt
	IF (@result_code <> 0) 
		BEGIN
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			COMMIT TRAN
		END 

	select @result_code

END
GO
