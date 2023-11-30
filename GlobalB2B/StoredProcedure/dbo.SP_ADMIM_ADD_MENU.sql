IF OBJECT_ID (N'dbo.SP_ADMIM_ADD_MENU', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIM_ADD_MENU
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
CREATE PROCEDURE [dbo].[SP_ADMIM_ADD_MENU]
	@p_menu_name nvarchar(255),
	@p_parent_menu_seq int,
	@p_link_url nvarchar(255),
	@p_link_target nvarchar(255)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @t_parent_count int=0,@t_depth int,@t_sort_num int;
	
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

    INSERT INTO [GlobalB2B].[dbo].[ADMIN_MENU_MST]
           ([MENU_TITLE]
           ,[PARENT_MENU_SEQ]
           ,[DEPTH]
           ,[SORT_NUM]
           ,[LINK_URL]
           ,[LINK_TARGET]
           ,[REG_DATE])
     VALUES
           (@p_menu_name
           ,@p_parent_menu_seq
           ,@t_depth
           ,@t_sort_num
           ,@p_link_url
           ,@p_link_target
           ,GETDATE());


END
GO
