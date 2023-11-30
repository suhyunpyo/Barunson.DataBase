IF OBJECT_ID (N'dbo.SP_UPDATE_PERSONAL_PAYMENT_ORDER_CANCLE_REQUEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_PERSONAL_PAYMENT_ORDER_CANCLE_REQUEST
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
CREATE PROCEDURE [dbo].[SP_UPDATE_PERSONAL_PAYMENT_ORDER_CANCLE_REQUEST]
	-- Add the parameters for the stored procedure here
	@p_seq int,
	@p_title nvarchar(255),
	@p_content ntext
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE ORDER_MST
	SET ORDER_STATUS_TYPE_CODE = '161002',
	REQUEST_CANCLE_DATE = GETDATE(),
	REQUEST_CANCLE_TITLE = @p_title,
	REQUEST_CANCLE_CONTENT = @p_content
	WHERE ORDER_SEQ = @p_seq
END


GO
