IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_MAIL_MST_BY_UNSENED', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_MAIL_MST_BY_UNSENED
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_MAIL_MST_BY_UNSENED]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	*
	FROM
	MAIL_MST MM
	WHERE MM.SEND_YORN != 'Y'
	AND
	(MM.SCHEDULE_DATE IS NULL OR MM.SCHEDULE_DATE < GETDATE());
END

GO
