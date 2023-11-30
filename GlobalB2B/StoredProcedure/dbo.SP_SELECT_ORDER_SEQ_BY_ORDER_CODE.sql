IF OBJECT_ID (N'dbo.SP_SELECT_ORDER_SEQ_BY_ORDER_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_ORDER_SEQ_BY_ORDER_CODE
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
CREATE PROCEDURE [dbo].[SP_SELECT_ORDER_SEQ_BY_ORDER_CODE]
	-- Add the parameters for the stored procedure here
	@p_user_id nvarchar(255),
	@p_order_number nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	OM.ORDER_SEQ
	FROM ORDER_MST OM
	LEFT JOIN USER_MST UM ON UM.USER_SEQ = OM.USER_SEQ
	WHERE UM.USER_ID = @p_user_id
	AND
	OM.ORDER_CODE LIKE '%' + @p_order_number
END

GO
