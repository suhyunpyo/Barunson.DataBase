IF OBJECT_ID (N'dbo.up_insert_review_cnt', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_review_cnt
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
CREATE PROCEDURE [dbo].[up_insert_review_cnt]
	-- Add the parameters for the stored procedure here
	@ER_Idx				int,
	@userid				nvarchar(20),
	@result				INT=0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @current_write	int
	set @current_write = 0	--1일전에 추천건 방지
	

			set @result = 0
			set @current_write = (select DATEDIFF(DD, ERS_Regdate, GETDATE()) from S4_Event_Review_Sub with(nolock) where ERS_ER_Idx=@ER_Idx and ERS_UserId=@userid )
			
			if @current_write is null	--해당글에 추천건이 없으면 1
				begin
					set @current_write = 1
				end
			
			if @current_write > 0	-- 하루지났으면 insert실행
			
				begin
					/*추천 기본정보 등록*/
					update S4_Event_Review set ER_Recom_Cnt = ER_Recom_Cnt+1 where ER_Idx=@ER_Idx
					
    				insert into S4_Event_Review_Sub (ERS_ER_Idx, ERS_UserId) values (@ER_Idx, @userid)
					
					set @result = 1		
					
				end 
			
			return @result
			

END
GO
