IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_SAMPLE_GROUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_SAMPLE_GROUP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_SAMPLE_GROUP]
	-- Add the parameters for the stored procedure here
	@p_title nvarchar(255),
	@p_description ntext,
	@r_seq int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [GlobalB2B].[dbo].[SAMPLE_GROUP_MST]
           ([TITLE]
           ,[DESCRIPTION]
           ,[USE_YORN]
           ,[REG_DATE]
           ,[SORT_RATE])
     VALUES
           (@p_title
           ,@p_description
           ,'Y'
           ,GETDATE()
           ,0)

	SET @r_seq = CAST(SCOPE_IDENTITY() AS INT);
    -- Insert statements for procedure here
	
END

GO
