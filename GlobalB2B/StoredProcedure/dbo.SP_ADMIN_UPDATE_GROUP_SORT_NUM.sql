IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_GROUP_SORT_NUM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_GROUP_SORT_NUM
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_GROUP_SORT_NUM]
	-- Add the parameters for the stored procedure here
	@p_group_code nvarchar(30),
	@p_sort_num int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_swap_group_code nvarchar(30),
    @t_current_group_type_code char(6),
    @t_begin_sort_num int;
    
    
    
    SET @t_begin_sort_num = (SELECT MIN(SORT_NUM) FROM PROD_GROUP WHERE GROUP_CODE = @p_group_code);
    SET @t_current_group_type_code = (SELECT MIN(TYPE_CODE) FROM PROD_GROUP WHERE GROUP_CODE = @p_group_code);
    SET @t_swap_group_code = (SELECT MIN(GROUP_CODE) FROM PROD_GROUP WHERE GROUP_CODE != @p_group_code AND TYPE_CODE = @t_current_group_type_code AND SORT_NUM = @p_sort_num);
    
    
    UPDATE PROD_GROUP
    SET SORT_NUM = @p_sort_num
    WHERE GROUP_CODE = @p_group_code
    
    IF(@t_swap_group_code IS NOT NULL)
		BEGIN
			UPDATE PROD_GROUP
			SET SORT_NUM = @t_begin_sort_num
			WHERE GROUP_CODE = @t_swap_group_code;
		END
		
END
GO
