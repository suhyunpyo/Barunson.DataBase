IF OBJECT_ID (N'dbo.SP_SELECT_USER_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_USER_INFO
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
CREATE PROCEDURE [dbo].[SP_SELECT_USER_INFO]
	-- Add the parameters for the stored procedure here
	@p_user_id nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM USER_MST WHERE USER_ID = @p_user_id;
END
GO
