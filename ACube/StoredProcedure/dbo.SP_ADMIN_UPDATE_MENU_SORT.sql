IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_MENU_SORT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_MENU_SORT
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_MENU_SORT]
	-- Add the parameters for the stored procedure here
	@p_menu_seq int,
	@p_sort_increase_yorn char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @t_current_sort_num int,@t_current_parent_seq int;
	DECLARE @t_swap_menu_seq int, @t_swap_menu_sort_num int;
	
	SET @t_current_sort_num = (SELECT SORT_NUM FROM ADMIN_MENU_MST WHERE MENU_SEQ = @p_menu_seq);
	SET @t_current_parent_seq = (SELECT PARENT_MENU_SEQ FROM ADMIN_MENU_MST WHERE MENU_SEQ = @p_menu_seq);
	

    -- Insert statements for procedure here
	IF(@p_sort_increase_yorn = 'Y')
	BEGIN
		IF(@t_current_parent_seq IS NOT NULL AND @t_current_parent_seq > 0)
			SET @t_swap_menu_seq = (SELECT TOP 1 MENU_SEQ FROM ADMIN_MENU_MST WHERE PARENT_MENU_SEQ = @t_current_parent_seq AND SORT_NUM > @t_current_sort_num ORDER BY SORT_NUM ASC)
		ELSE
			SET @t_swap_menu_seq = (SELECT TOP 1 MENU_SEQ FROM ADMIN_MENU_MST WHERE PARENT_MENU_SEQ IS NULL AND SORT_NUM > @t_current_sort_num ORDER BY SORT_NUM ASC)
	END
	ELSE
	BEGIN
		IF(@t_current_parent_seq IS NOT NULL AND @t_current_parent_seq > 0)
			SET @t_swap_menu_seq = (SELECT TOP 1 MENU_SEQ FROM ADMIN_MENU_MST WHERE PARENT_MENU_SEQ = @t_current_parent_seq AND SORT_NUM < @t_current_sort_num ORDER BY SORT_NUM DESC)
		ELSE
			SET @t_swap_menu_seq = (SELECT TOP 1 MENU_SEQ FROM ADMIN_MENU_MST WHERE PARENT_MENU_SEQ IS NULL AND SORT_NUM < @t_current_sort_num ORDER BY SORT_NUM DESC)
	END
	
	
	IF(@t_swap_menu_seq IS NOT NULL)
	BEGIN
		SET @t_swap_menu_sort_num = (SELECT SORT_NUM FROM ADMIN_MENU_MST WHERE MENU_SEQ = @t_swap_menu_seq);
		UPDATE ADMIN_MENU_MST SET SORT_NUM = @t_swap_menu_sort_num WHERE MENU_SEQ = @p_menu_seq;
		UPDATE ADMIN_MENU_MST SET SORT_NUM = @t_current_sort_num WHERE MENU_SEQ = @t_swap_menu_seq;
	END
	
	
END


GO
