IF OBJECT_ID (N'dbo.SP_INSERT_PERSONAL_PAYMENT_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_PERSONAL_PAYMENT_ORDER
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
CREATE PROCEDURE [dbo].[SP_INSERT_PERSONAL_PAYMENT_ORDER]
	-- Add the parameters for the stored procedure here
	@p_user_seq int,
	@p_price float,
	@p_admin_seq int,
	@p_description ntext,
	@r_order_code nvarchar(255) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_max_order_seq int,
	@t_order_seq int,
	@t_order_code nvarchar(255),
	@t_order_status_type nvarchar(255)
	
	SET @t_max_order_seq = (SELECT MAX(ORDER_SEQ) FROM ORDER_MST);
	
    IF(@t_max_order_seq IS NULL)
		SET @t_max_order_seq = 0;		
		
	SET @t_order_status_type = '161001';
	SET @t_order_code = 'P'+(SUBSTRING(CONVERT(varchar(30),GETDATE(),112),3,4)+'-'+CONVERT(nvarchar,(@t_max_order_seq+1)));
	
	INSERT INTO [GlobalB2B].[dbo].[ORDER_MST]
           ([ORDER_CODE]
           ,[ORDER_TYPE_CODE]
           ,ORDER_STATUS_TYPE_CODE
           ,[ORDER_DATE]
           ,[USER_SEQ]
           ,PAYMENT_TYPE_CODE
           ,PAYMENT_STATUS_CODE
           ,DESCRIPTION
           ,CLAIM_EXIST_YORN
           ,ADMIN_USER_SEQ
           )
     VALUES
           (@t_order_code
           ,'110003'
           ,@t_order_status_type
           ,GETDATE()
           ,@p_user_seq
           ,'141002'
           ,'145001'
           ,@p_description
           ,'N'
           ,@p_admin_seq
           );
           
    SET @t_order_seq = CAST(SCOPE_IDENTITY() AS INT);
	SET @t_order_code = 'P' +(SUBSTRING(CONVERT(varchar(30),GETDATE(),112),3,4)+'-'+CONVERT(nvarchar,(@t_order_seq)));
	
	
	UPDATE ORDER_MST SET ORDER_CODE = @t_order_code WHERE ORDER_SEQ = @t_order_seq;
	
	
	INSERT INTO [GlobalB2B].[dbo].[CART_MST]
           ([ORDER_SEQ]
           ,[USER_SEQ]
           ,[PROD_SEQ]
           ,[CART_TYPE_CODE]
           ,[CART_STATE_CODE]
           ,[QUANTITY]
           ,[PRICE]
           ,[UNIT_PRICE]
           ,[REG_DATE])
     VALUES
           (@t_order_seq
           ,@p_user_seq
           ,0
           ,'111004'
           ,'118002'
           ,1
           ,@p_price
           ,@p_price
           ,GETDATE());
           
    SET @r_order_code = @t_order_code;
    
END

GO
