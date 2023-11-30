IF OBJECT_ID (N'dbo.up_delete_event_comment_mobile_N', N'P') IS NOT NULL DROP PROCEDURE dbo.up_delete_event_comment_mobile_N
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김현기
-- Create date: 2016-04-29
-- Description:	이벤트 페이지 덧글 삭제
-- =============================================
CREATE PROCEDURE [dbo].[up_delete_event_comment_mobile_N]
	-- Add the parameters for the stored procedure here
	@idx		int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	DECLARE @result_code INT;
	SET @result_code = 0;

	SET NOCOUNT ON;
	BEGIN TRAN
					
	DELETE FROM S4_Event_Review_NEW WHERE ER_Idx = @idx

	DELETE FROM S4_Event_Review_Status_New WHERE ERA_ER_idx = @idx
	
	
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
