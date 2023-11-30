IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_MENU', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_MENU
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_MENU]
	@p_menu_seq int,
	@p_menu_title nvarchar(255),
	@p_parent_menu_seq int,
	@p_link_url nvarchar(255),
	@p_link_target nvarchar(255),
	@p_display_yorn nchar(1)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @t_parent_count int=0,@t_depth int,@t_sort_num int;
	DECLARE @t_current_depth int, @t_current_parent_menu_seq int, @t_current_sort_num int;
	
	SET @t_current_depth = (SELECT DEPTH FROM ADMIN_MENU_MST WHERE MENU_SEQ = @p_menu_seq);
	SET @t_current_parent_menu_seq = (SELECT PARENT_MENU_SEQ FROM ADMIN_MENU_MST WHERE MENU_SEQ = @p_menu_seq);
	SET @t_current_sort_num = (SELECT SORT_NUM FROM ADMIN_MENU_MST WHERE MENU_SEQ = @p_menu_seq);
	
	
	IF(@t_current_parent_menu_seq != @p_parent_menu_seq)
		BEGIN
			IF(@p_parent_menu_seq != '' AND @p_parent_menu_seq IS NOT NULL AND @p_parent_menu_seq > 0)
				SET @t_parent_count = (SELECT COUNT(*) FROM ADMIN_MENU_MST WHERE MENU_SEQ = @p_parent_menu_seq);

			IF(@t_parent_count < 1)
				BEGIN
				SET @t_depth = 0
				SET @p_parent_menu_seq = NULL;
				END
			ELSE
				SET @t_depth = 1;
				
				
			IF(@t_depth > 0)
				SET @t_sort_num = (SELECT MAX(SORT_NUM) FROM ADMIN_MENU_MST WHERE PARENT_MENU_SEQ = @p_parent_menu_seq);
			ELSE
				SET @t_sort_num = (SELECT MAX(SORT_NUM) FROM ADMIN_MENU_MST WHERE DEPTH = 0);
			
			IF(@t_sort_num IS NULL)
				SET @t_sort_num = 0;
			ELSE 
				SET @t_sort_num	 = @t_sort_num + 1;
		END
	ELSE
		BEGIN
			SET @t_depth = @t_current_depth;
			SET @t_sort_num = @t_current_sort_num;
		END
	
	
		
	UPDATE [dbo].[ADMIN_MENU_MST]
	   SET [MENU_TITLE] = @p_menu_title
		  ,[PARENT_MENU_SEQ] = @p_parent_menu_seq
		  ,[DEPTH] = @t_depth
		  ,[SORT_NUM] = @t_sort_num
		  ,[LINK_URL] = @p_link_url
		  ,[LINK_TARGET] = @p_link_target
		  ,MENU_DISPLAY_YORN = @p_display_yorn
	 WHERE MENU_SEQ = @p_menu_seq
	
END


GO
