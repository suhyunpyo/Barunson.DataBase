IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_ADDITIONAL_PRICE_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_ADDITIONAL_PRICE_INFO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_ADDITIONAL_PRICE_INFO]
	-- Add the parameters for the stored procedure here
	@p_add_seq int,
	@p_type_code char(6),
	@p_label nvarchar(255),
	@p_price float
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE ADDITIONAL_PRICE_MST 
	SET ADD_PRICE_TYPE_CODE = @p_type_code,
	LABEL = @p_label,
	PRICE = @p_price,
	ABS_PRICE = ABS(@p_price)
	WHERE ADD_PRICE_SEQ = @p_add_seq
END
GO
