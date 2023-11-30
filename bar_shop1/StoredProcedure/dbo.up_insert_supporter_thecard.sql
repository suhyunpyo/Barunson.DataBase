IF OBJECT_ID (N'dbo.up_insert_supporter_thecard', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_supporter_thecard
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
CREATE PROCEDURE [dbo].[up_insert_supporter_thecard]
	-- Add the parameters for the stored procedure here
	@company_seq		AS		INT,
	@supporters_title			AS		NVARCHAR(150),
	@supporters_url			AS		NVARCHAR(250),
	@supporters_sns_url_1			AS		NVARCHAR(250),
	@supporters_sns_url_2			AS		NVARCHAR(250),
	@comment				AS		NTEXT,
	@userid					AS		NVARCHAR(20),
	@ER_Type				AS		INT,
	@user_name			AS		NVARCHAR(20),
	@inflow_route       AS      NVARCHAR(20),
	@result					AS		INT=0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			
			declare @id	int;
			declare @msg varchar(2000);

			--등록시 초기 문구
			set @msg = '서포터즈에 응모해주셔서 감사합니다 :) 관리자 심사 및 승인 완료 시 개별 연락 드리겠습니다.';
			--select * from S4_Event_Review where er_type = 15
			
			/*리뷰 기본정보 등록*/

    		insert into S4_Event_Review 
			(
				ER_Company_Seq, 
				ER_Order_Seq, 
				ER_Type, 
				ER_Card_Seq, 
				ER_Card_Code, 
				ER_UserId, 
				ER_Review_Title, 
				ER_Review_Url, 
				ER_Review_Url_a, 
				ER_Review_Url_b, 
				ER_Review_Content,
				ER_UserName,
				inflow_route,
				ER_Review_Reply
			) 
    		values 
    		(@company_seq, '9999999', @ER_Type, 0, '', @userid, @supporters_title, @supporters_url, @supporters_sns_url_1, @supporters_sns_url_2, @comment, @user_name, @inflow_route, @msg)
    		
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
