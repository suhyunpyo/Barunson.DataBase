IF OBJECT_ID (N'dbo.SP_SELECT_ORDER_PAYMENT_REQUEST_BY_REQUEST_DATA', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_ORDER_PAYMENT_REQUEST_BY_REQUEST_DATA
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
CREATE PROCEDURE [dbo].[SP_SELECT_ORDER_PAYMENT_REQUEST_BY_REQUEST_DATA]
	-- Add the parameters for the stored procedure here
	@p_timestamp nvarchar(255),
	@p_order_number nvarchar(255),
	@p_good_name nvarchar(255),
	@r_result int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    SET @r_result = (  
						SELECT 
						TOP 1
						PAYMENT_REQUEST_SEQ
						FROM ORDER_PAYMENT_REQUEST_MST 
						WHERE TIME_STAMP = @p_timestamp
						AND WEB_ORDER_NUMBER = @p_order_number
						AND GOOD_NAME = @p_good_name
						ORDER BY PAYMENT_REQUEST_SEQ DESC
					);
END

GO
