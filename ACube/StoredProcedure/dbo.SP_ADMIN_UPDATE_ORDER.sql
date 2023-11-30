IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_ORDER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_seq int,
	@p_request_status_type_code nchar(6),
	@p_order_status_type_code nchar(6),
	@p_memo ntext
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [ACube].[dbo].[ORDER_MST]
	SET [REQUEST_STATUS_TYPE_CODE] = @p_request_status_type_code
      ,[ORDER_STATUS_TYPE_CODE] = @p_order_status_type_code
      ,[MEMO] = @p_memo
	WHERE 
	ORDER_SEQ = @p_order_seq;
	
END

GO
