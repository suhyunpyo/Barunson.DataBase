IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_FAQ', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_FAQ
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_FAQ]
	-- Add the parameters for the stored procedure here
	@p_title nvarchar(255),
	@p_contents text
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[FAQ_MST]
           ([FAQ_TITLE]
           ,[FAQ_CONTENTS]
           ,[VIEW_COUNT]
           ,[REG_DATE])
     VALUES
           (@p_title
           ,@p_contents
           ,0
           ,GETDATE());

END

GO
