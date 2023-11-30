IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_SAMPLE_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_SAMPLE_ITEM
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_SAMPLE_ITEM]
	-- Add the parameters for the stored procedure here
	@p_sample_group_seq int,
	@p_prod_seq int,
	@p_sort_rate int = 1000,
	@r_seq int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	/*
	DECLARE @t_max_sort_rate int = 0;
	
	SET @t_max_sort_rate = (SELECT MAX(SORT_RATE) FROM SAMPLE_GROUP_ITEM_MST WHERE SAMPLE_GROUP_SEQ = @p_sample_group_seq);
	
	IF(@t_max_sort_rate IS NULL OR @t_max_sort_rate = )
		SET @t_max_sort_rate = 0;
		
	IF(@t_max_sort_rate != 0)
		SET @t_max_sort_rate = @t_max_sort_rate + 1;
	*/
	

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[SAMPLE_GROUP_ITEM_MST]
           ([SAMPLE_GROUP_SEQ]
           ,[PROD_SEQ]
           ,[REG_DATE]
           ,[SORT_RATE])
     VALUES
           (@p_sample_group_seq
           ,@p_prod_seq
           ,GETDATE()
           ,@p_sort_rate);
END

GO
