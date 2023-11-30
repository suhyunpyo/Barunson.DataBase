IF OBJECT_ID (N'dbo.SP_SELECT_UPLOAD_FILE_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_UPLOAD_FILE_DETAIL
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
CREATE PROCEDURE [dbo].[SP_SELECT_UPLOAD_FILE_DETAIL]
	-- Add the parameters for the stored procedure here
	@p_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT * FROM UPLOAD_FILE_MST WHERE FILE_SEQ = @p_seq;
END


GO
