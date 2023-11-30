IF OBJECT_ID (N'dbo.SP_SELECT_WISH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_WISH
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
CREATE PROCEDURE [dbo].[SP_SELECT_WISH]
	-- Add the parameters for the stored procedure here
	@p_cart_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT
	CM.*,
	PM.PROD_CODE,
	PM.PROD_TITLE,
	PM.PROD_TITLE,
	PM.MIN_ORDER
	FROM CART_MST CM
	LEFT JOIN PROD_MST PM ON CM.PROD_SEQ = PM.PROD_SEQ
	WHERE CM.CART_SEQ = @p_cart_seq;
	
END
GO
