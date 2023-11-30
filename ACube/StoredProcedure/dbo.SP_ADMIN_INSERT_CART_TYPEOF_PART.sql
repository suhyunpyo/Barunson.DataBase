IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_CART_TYPEOF_PART', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_CART_TYPEOF_PART
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_CART_TYPEOF_PART]
	-- Add the parameters for the stored procedure here
	@p_order_seq int,
	@p_cart_code nvarchar(255),
	@p_seq int,
	@p_cart_type_code nchar(6),
	@p_quantity int,
	@p_request_shipping_date datetime,
	@r_result int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    DECLARE @t_cart_seq int,
    @t_order_code nvarchar(255),
    @t_exist_addon int;
    
    IF(@p_cart_code IS NULL)
		SET @p_cart_code = '';
	
	INSERT INTO [ACube].[dbo].[CART_MST]
           ([CART_CODE]
           ,[ORDER_SEQ]
           ,[CART_TYPE_CODE]
           ,[PROD_SEQ]
           ,[QUANTITY]
           ,[REQUEST_SHIPPING_DATE]
           ,[REG_DATE]
           ,[UPDATE_DATE])
     VALUES
           (@p_cart_code
           ,@p_order_seq
           ,@p_cart_type_code
           ,@p_seq
           ,@p_quantity
           ,@p_request_shipping_date
           ,GETDATE()
           ,NULL);
           
	SET @t_cart_seq = SCOPE_IDENTITY();
	
	SET @r_result = @t_cart_seq;
	
	
	--Cart Code 없이 전달된 주문에 대한 CartCode Build 처리
	IF(@p_cart_code = '')
	BEGIN
		SET @t_order_code = (SELECT ORDER_CODE FROM ORDER_MST WHERE ORDER_SEQ = @p_order_seq);
		SET @p_cart_code = @t_order_code + '-CP' + 	CONVERT(nvarchar, @t_cart_seq);
		
		UPDATE CART_MST 
		SET CART_CODE = @p_cart_code 
		WHERE CART_SEQ = @t_cart_seq;
	END
	
	SET @t_exist_addon = (SELECT COUNT(*) FROM PROD_ADDON_MST WHERE PROD_SEQ = @p_seq);
	
	--연결 제품이 존재하는 경우 추가적으로 Cart 에 Insert 로직 처리 
	IF(@t_exist_addon > 0)
	BEGIN
		
		DECLARE @t_addon_prod_seq int,
		@t_addon_prod_type_code nchar(6);
		
		DECLARE TEMP_CURSOR CURSOR FOR 	
			SELECT 
			PAM.ADDON_PROD_SEQ,
			ADDON_PM.PROD_TYPE_CODE
			FROM PROD_ADDON_MST PAM 
			LEFT JOIN PROD_MST ADDON_PM ON PAM.ADDON_PROD_SEQ = ADDON_PM.PROD_SEQ
			WHERE PAM.PROD_SEQ = @p_seq;
			
		OPEN TEMP_CURSOR;
		
		FETCH NEXT FROM TEMP_CURSOR INTO @t_addon_prod_seq , @t_addon_prod_type_code;
		
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			DECLARE @t_result int;
			EXECUTE [ACube].[dbo].[SP_ADMIN_INSERT_CART_TYPEOF_PART] 
			   @p_order_seq
			  ,''
			  ,@t_addon_prod_seq
			  ,@p_cart_type_code
			  ,@p_quantity
			  ,@p_request_shipping_date
			  ,@t_result OUTPUT;
			FETCH NEXT FROM TEMP_CURSOR INTO @t_addon_prod_seq , @t_addon_prod_type_code;	
		END
		
		CLOSE TEMP_CURSOR;
		DEALLOCATE TEMP_CURSOR;
	END
	
END

GO
