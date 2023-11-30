IF OBJECT_ID (N'dbo.up_insert_commont_url', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_commont_url
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
CREATE PROCEDURE [dbo].[up_insert_commont_url]
	@userid				nvarchar(20),	
	@user_name			nvarchar(20),	
	@order_seq			int,	
	@comment_title			nvarchar(150),
	@comment_URL			nvarchar(250),
	@score				int,
	@result				INT=0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRAN
			
			declare @exist_cnt int;
			declare @exist_cnt2 int;

			begin
				SELECT @exist_cnt = COUNT(*) FROM s2_event_UserComment_url WHERE c_url = @comment_URL AND c_uid = @userid
			End

			If @exist_cnt = 0
				begin
 				   /*이벤트 이용후기 URL 등록*/
    				insert into s2_event_UserComment_url (c_uid, c_uname, c_order_seq, c_regDate, c_title, c_url, c_score, c_status) 
    				values 
    				(@userid, @user_name, @order_seq, getdate(), @comment_title, @comment_URL, @score, 0)
				
				begin
					select @exist_cnt2 = COUNT(*) FROM Evt_three_six_nine_board where b_uid = @userid and evt_num = '3'
				End
				
				If @exist_cnt2 = 0
				
				begin
 				
				/*이벤트 등록*/
    				insert into Evt_three_six_nine_board (b_uid ,evt_num ,evt_regDate ) values  (@userid, '3', getdate())
				
				end

					set @result = '0'
					COMMIT TRAN

				End
			else
				begin
					set @result = '9'
				end

			return @result

END
GO
