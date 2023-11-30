IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_SAMPLE_GROUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_SAMPLE_GROUP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_SAMPLE_GROUP]
	-- Add the parameters for the stored procedure here
	@p_sample_group_seq int,
	@p_title nvarchar(255),
	@p_description ntext
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE SAMPLE_GROUP_MST
	SET 
		TITLE = @p_title, 
		DESCRIPTION = @p_description
	WHERE
		SAMPLE_GROUP_SEQ = @p_sample_group_seq
	
END


GO
