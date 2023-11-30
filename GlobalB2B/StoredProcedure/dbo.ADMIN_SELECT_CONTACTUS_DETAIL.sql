IF OBJECT_ID (N'dbo.ADMIN_SELECT_CONTACTUS_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.ADMIN_SELECT_CONTACTUS_DETAIL
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
CREATE PROCEDURE [dbo].[ADMIN_SELECT_CONTACTUS_DETAIL]
	@p_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	*
	FROM
	CONTACT_US_MSG_MST 
	WHERE CONTACT_SEQ = @p_seq;
END
GO
