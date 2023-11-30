IF OBJECT_ID (N'dbo.SP_SELECT_ADDITIONAL_PRICE_LIST_BY_FOREIGN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_ADDITIONAL_PRICE_LIST_BY_FOREIGN
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
CREATE PROCEDURE [dbo].[SP_SELECT_ADDITIONAL_PRICE_LIST_BY_FOREIGN]
	-- Add the parameters for the stored procedure here
	@p_price_type char(6),
	@p_foreign_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM ADDITIONAL_PRICE_MST WHERE ADD_PRICE_TYPE_CODE = @p_price_type AND FOREIGN_SEQ = @p_foreign_seq;
END

GO
