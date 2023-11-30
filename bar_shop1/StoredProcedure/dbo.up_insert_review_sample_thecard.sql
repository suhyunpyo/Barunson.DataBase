IF OBJECT_ID (N'dbo.up_insert_review_sample_thecard', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_review_sample_thecard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[up_insert_review_sample_thecard]
	-- Add the parameters for the stored procedure here
	@company_seq		AS		INT,
	@order_seq				AS		INT,
	@card_seq				AS		INT,
	@card_code			AS		NVARCHAR(20),
	@reviews_title			AS		NVARCHAR(150),
	@reviews_URL			AS		NVARCHAR(250),
	@reviews_URL_a			AS		NVARCHAR(250),
	@reviews_URL_b			AS		NVARCHAR(250),
	@score					AS		INT,
	@content				AS		NTEXT,
	@userid					AS		NVARCHAR(20),
	@ER_Type				AS		INT,
	@user_name			AS		NVARCHAR(20),
	@star_rating1			AS		INT,
	@star_rating2			AS		INT,
	@star_rating3			AS		INT,
	@star_rating4			AS		INT,
	@inflow_route		    AS		NVARCHAR(20),
	@result					AS		INT=0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			
			declare @id	int;
			declare @strTemp nvarchar(20);
			
			/*리뷰 기본정보 등록*/

    		insert into S4_Event_Review 
			(
			ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Card_Seq, ER_Card_Code, ER_UserId, ER_Review_Title, ER_Review_Url, ER_Review_Content, ER_Review_Star, ER_UserName
           ,ER_Review_Price
           ,ER_Review_Design
           ,ER_Review_Quality
           ,ER_Review_Satisfaction
		   ,ER_Review_Url_a
		   ,ER_Review_Url_b 
		   ,inflow_route
			) 
    		values 
    		(@company_seq, @order_seq, @ER_Type, @card_seq, @card_code, @userid, @reviews_title, @reviews_URL, @content, @score, @user_name,@star_rating1,@star_rating2,@star_rating3,@star_rating4, @reviews_URL_a, @reviews_URL_b, @inflow_route)
    		
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
