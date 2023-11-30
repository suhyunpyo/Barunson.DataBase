IF OBJECT_ID (N'dbo.SP_UPDATE_FAQ_VIEW_COUNT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_FAQ_VIEW_COUNT
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
CREATE PROCEDURE [dbo].[SP_UPDATE_FAQ_VIEW_COUNT]
	@p_faq_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE FAQ_MST 
	SET VIEW_COUNT = VIEW_COUNT + 1
	WHERE FAQ_SEQ = @p_faq_seq;
END
GO
