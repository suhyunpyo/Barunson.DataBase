IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_FAQ', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_FAQ
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_FAQ]
	-- Add the parameters for the stored procedure here
	@p_seq int,
	@p_title nvarchar(255),
	@p_contents text
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    UPDATE [GlobalB2B].[dbo].[FAQ_MST]
	SET [FAQ_TITLE] = @p_title
		,[FAQ_CONTENTS] = @p_contents
	WHERE FAQ_SEQ = @p_seq;

	
END
GO
