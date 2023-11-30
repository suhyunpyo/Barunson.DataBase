IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_COMPANY_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_COMPANY_DETAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_COMPANY_DETAIL]
	-- Add the parameters for the stored procedure here
	@p_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	*
	FROM
	COMPANY_MST WHERE COMPANY_SEQ = @p_seq;
END
GO
