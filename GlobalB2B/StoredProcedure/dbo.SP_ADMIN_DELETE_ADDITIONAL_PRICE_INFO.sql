IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_ADDITIONAL_PRICE_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_ADDITIONAL_PRICE_INFO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_ADDITIONAL_PRICE_INFO]
	-- Add the parameters for the stored procedure here
	@p_add_price_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM ADDITIONAL_PRICE_MST WHERE ADD_PRICE_SEQ = @p_add_price_seq;
END
GO
