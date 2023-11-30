IF OBJECT_ID (N'dbo.SP_INSERT_ORDER_PAYMENT_REQUEST_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_ORDER_PAYMENT_REQUEST_INFO
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
CREATE PROCEDURE [dbo].[SP_INSERT_ORDER_PAYMENT_REQUEST_INFO]
	-- Add the parameters for the stored procedure here
	@p_order_seq int,
	@p_mid nvarchar(50),
	@p_merchant_key nvarchar(50),
	@p_time_stamp nvarchar(50),
	@p_web_order_number nvarchar(50),
	@p_good_name nvarchar(255),
	@p_currency nvarchar(20),
	@p_price int,
	@p_buyer_name nvarchar(255),
	@p_buyer_tel nvarchar(255),
	@p_buyer_email nvarchar(255),
	@p_req_type nvarchar(20),
	@p_return_url nvarchar(255),
	@p_hash_data nvarchar(255),
	@r_result int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [GlobalB2B].[dbo].[ORDER_PAYMENT_REQUEST_MST]
           ([ORDER_SEQ]
           ,[MID]
           ,[MERCHANT_KEY]
           ,[TIME_STAMP]
           ,[WEB_ORDER_NUMBER]
           ,[GOOD_NAME]
           ,[CURRENCY]
           ,[PRICE]
           ,[BUYER_NAME]
           ,[BUYER_TEL]
           ,[BUYER_EMAIL]
           ,[REQ_TYPE]
           ,[RETURN_URL]
           ,[HASH_DATA]
           ,[REG_DATE])
     VALUES
           (@p_order_seq
           ,@p_mid
           ,@p_merchant_key
           ,@p_time_stamp
           ,@p_web_order_number
           ,@p_good_name
           ,@p_currency
           ,@p_price
           ,@p_buyer_name
           ,@p_buyer_tel
           ,@p_buyer_email
           ,@p_req_type
           ,@p_return_url
           ,@p_hash_data
           ,GETDATE());
           
	SET @r_result = SCOPE_IDENTITY();
END

GO
