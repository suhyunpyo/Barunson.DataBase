IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_ERP_DELIVERY_SAMPLE_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_ERP_DELIVERY_SAMPLE_ORDER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_ERP_DELIVERY_SAMPLE_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @t_order_site_key NVARCHAR(2),
	@t_order_code nvarchar(255);

    SET @t_order_site_key = 'GB';
    SET @t_order_code = (SELECT ORDER_CODE FROM ORDER_MST WHERE ORDER_SEQ = @p_order_seq);
    
    /*
    SELECT @t_order_site_key as GLOBAL_SITE
		, @t_order_code as ORDER_CODE
	*/	
	
	EXECUTE [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[C_spGlobalSample_DELETE] 
		@t_order_site_key,
		@t_order_code
	
	UPDATE ORDER_MST	SET ERP_INSERT_YORN = 'N'	WHERE ORDER_SEQ = @p_order_seq;
	
END

GO
