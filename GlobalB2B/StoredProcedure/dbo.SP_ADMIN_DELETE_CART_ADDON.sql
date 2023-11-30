IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_CART_ADDON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_CART_ADDON
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_CART_ADDON]
	@p_cart_addon_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM CART_ADDON_MST WHERE CART_ADDON_SEQ = @p_cart_addon_seq;
END

GO
