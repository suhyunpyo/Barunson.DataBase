IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_BANNER_SORT_TO_UP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_BANNER_SORT_TO_UP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_BANNER_SORT_TO_UP]
	@p_banner_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @t_current_sort int,
	@t_current_banner_type char(6),
	@t_swap_sort_num int,
	@t_swap_banner_seq int
	
	SET @t_current_sort = (SELECT SORT_NUM FROM BANNER_MST WHERE BANNER_SEQ = @p_banner_seq);
	
	SET @t_current_banner_type = (SELECT BANNER_TYPE_CODE FROM BANNER_MST WHERE BANNER_SEQ = @p_banner_seq);
	
	SET @t_swap_sort_num = (SELECT MAX(SORT_NUM) FROM BANNER_MST WHERE BANNER_TYPE_CODE = @t_current_banner_type AND SORT_NUM < @t_current_sort);
	
	IF(@t_swap_sort_num IS NOT NULL)
		BEGIN
			SET @t_swap_banner_seq = (SELECT BANNER_SEQ FROM BANNER_MST WHERE BANNER_TYPE_CODE = @t_current_banner_type AND SORT_NUM = @t_swap_sort_num);
		END
		
	IF(@t_swap_banner_seq IS NOT NULL)
		BEGIN
			UPDATE BANNER_MST SET SORT_NUM = @t_current_sort WHERE BANNER_SEQ = @t_swap_banner_seq;
			UPDATE BANNER_MST SET SORT_NUM = @t_swap_sort_num WHERE BANNER_SEQ = @p_banner_seq;
		END
	
END
GO
