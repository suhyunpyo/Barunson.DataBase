IF OBJECT_ID (N'dbo.SP_UPDATE_ADDITIONAL_PRICE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_ADDITIONAL_PRICE
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
CREATE PROCEDURE [dbo].[SP_UPDATE_ADDITIONAL_PRICE]
	-- Add the parameters for the stored procedure here
	@p_add_price_seq int,
	@p_add_price_type char(6),
	@p_memo nvarchar(255),
	@p_price numeric(18,2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE ADDITIONAL_PRICE_MST
	SET 
	ADD_PRICE_TYPE_CODE = @p_add_price_type,
	LABEL = @p_memo,
	PRICE = @p_price
	WHERE ADD_PRICE_SEQ = @p_add_price_seq;
END
GO
