IF OBJECT_ID (N'dbo.up_insert_review2', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_review2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- up_insert_review2 5003, 2007499, 0, 0000, '제목', 'reviews_URL', 'reviews_URL2', 5, 'sample', 'phs4125', 10,'박형승','reviews_URL_a','reviews_URL_b' 
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_review2]
	-- Add the parameters for the stored procedure here
	@company_seq		int,
	@order_seq			int,
	@card_seq			int,
	@card_code			nvarchar(20),
	@reviews_title		nvarchar(150),
	@reviews_URL		nvarchar(250),
    @reviews_URL2		nvarchar(250),
	@score				int,
	@content			ntext,
	@userid				nvarchar(20),
	@ER_Type			int,
	@user_name			nvarchar(20),
	@reviews_URL_a		nvarchar(250),
	@reviews_URL_b		nvarchar(250),	
	
	@result				INT=0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRAN
			
			declare @id	int;
			
			/*리뷰 기본정보 등록*/
    		insert into S4_Event_Review (ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Card_Seq, ER_Card_Code, ER_UserId, ER_Review_Title, ER_Review_Url, ER_Review_Url2, ER_Review_Content, ER_Review_Star, ER_UserName, ER_Review_Url_a, ER_Review_Url_b) 
    		values 
    		(@company_seq, @order_seq, @ER_Type, @card_seq, @card_code, @userid, @reviews_title, @reviews_URL, @reviews_URL2, @content, @score, @user_name, @reviews_URL_a, @reviews_URL_b)
    		
    		set @id = SCOPE_IDENTITY()
    		
    		insert into S4_Event_Review_Status(ERA_ER_idx) values (@id)
		
			set @result = '0'
			set @result = @@Error
			IF (@result <> 0) GOTO PROBLEM
			COMMIT TRAN


			PROBLEM:
			IF (@result <> 0) BEGIN
				ROLLBACK TRAN
			END
			
			return @result

END
GO
