IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ADMIN_NOTIFY_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ADMIN_NOTIFY_DETAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ADMIN_NOTIFY_DETAIL]
	-- Add the parameters for the stored procedure here
	@p_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
    ANM.*
    ,AUM.ADMIN_USER_NAME
	,AUM.ADMIN_USER_ID
    FROM ADMIN_NOTIFY_MST ANM
    LEFT JOIN ADMIN_USER_MST AUM ON ANM.ADMIN_USER_SEQ = AUM.ADMIN_USER_SEQ
    WHERE ANM.NOTIFY_SEQ = @p_seq;
END
GO
