IF OBJECT_ID (N'dbo.SP_INSERT_ORDER_PAYMENT_RESULT_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_ORDER_PAYMENT_RESULT_INFO
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
CREATE PROCEDURE [dbo].[SP_INSERT_ORDER_PAYMENT_RESULT_INFO]
	-- Add the parameters for the stored procedure here
	@p_success_yorn nchar(1),
	@p_result_code nvarchar(10) = NULL,
	@p_result_message nvarchar(255) = NULL,
	@p_order_seq int = NULL,
	@p_mid nvarchar(50) = NULL,
	@p_tid nvarchar(255) = NULL,
	@p_paymethod nvarchar(50) = NULL,
	@p_web_order_number nvarchar(50) = NULL,
	@p_good_name nvarchar(255) = NULL,
	@p_currency nvarchar(20) = NULL,
	@p_price int = NULL,
	@p_auth_date_str nvarchar(50) = NULL,
	@p_auth_time_str nvarchar(50) = NULL,
	@p_auth_date datetime = NULL,
	@p_notetext nvarchar(255) = NULL,
	@p_ship_to_name nvarchar(255) = NULL,
	@p_ship_to_street nvarchar(255) = NULL,
	@p_ship_to_street2 nvarchar(255) = NULL,
	@p_ship_to_city nvarchar(255) = NULL,
	@p_ship_to_state nvarchar(255) = NULL,
	@p_ship_to_zip nvarchar(255) = NULL,
	@p_ship_to_country_code nvarchar(255) = NULL,
	@p_ship_to_phone_num nvarchar(255) = NULL,
	@p_ship_to_country_name nvarchar(255) = NULL,
	@p_result_all_post_data ntext = NULL,
	@r_result int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [GlobalB2B].[dbo].[ORDER_PAYMENT_RESULT_MST]
           ([PAYMENT_RESULT_SUCCESS_YORN]
           ,[RESULT_CODE]
           ,[RESULT_MESSAGE]
           ,[ORDER_SEQ]
           ,[MID]
           ,[TID]
           ,[PAYMETHOD]
           ,[WEB_ORDER_NUMBER]
           ,[GOOD_NAME]
           ,[CURRENCY]
           ,[PRICE]
           ,[AUTH_DATE_STR]
           ,[AUTH_TIME_STR]
           ,[AUTH_DATE]
           ,[NOTETEXT]
           ,[SHIP_TO_NAME]
           ,[SHIP_TO_STREET]
           ,[SHIP_TO_STREET2]
           ,[SHIP_TO_CITY]
           ,[SHIP_TO_STATE]
           ,[SHIP_TO_ZIP]
           ,[SHIP_TO_COUNTRY_CODE]
           ,[SHIP_TO_PHONE_NUM]
           ,[SHIP_TO_COUNTRY_NAME]
           ,[RESULT_ALL_POST_DATA]
           ,[REG_DATE])
     VALUES
           (@p_success_yorn
           ,@p_result_code
           ,@p_result_message
           ,@p_order_seq
           ,@p_mid
           ,@p_tid
           ,@p_paymethod
           ,@p_web_order_number
           ,@p_good_name
           ,@p_currency
           ,@p_price
           ,@p_auth_date_str
           ,@p_auth_time_str
           ,@p_auth_date
           ,@p_notetext
           ,@p_ship_to_name
           ,@p_ship_to_street
           ,@p_ship_to_street2
           ,@p_ship_to_city
           ,@p_ship_to_state
           ,@p_ship_to_zip
           ,@p_ship_to_country_code
           ,@p_ship_to_phone_num
           ,@p_ship_to_country_name
           ,@p_result_all_post_data
           ,GETDATE());
           
	SET @r_result = SCOPE_IDENTITY();
          
    /**
    * RESULT Data 들을 기준으로, Request 정보를 찾는다.
    **/ 
    DECLARE @t_tid nvarchar(255);
	DECLARE @t_mid nvarchar(255);
	DECLARE @t_timestamp nvarchar(255);

	SET @t_mid = @p_mid;
	SET @t_tid = @p_tid;
	DECLARE @t_indexOf int;

	SET @t_indexOf = (SELECT CHARINDEX(@t_mid, @t_tid));
	IF(@t_indexOf > 0)
	BEGIN
		SET @t_indexOf = @t_indexOf + LEN(@t_mid);
		IF(LEN(@t_tid) > (@t_indexOf + 14))
		BEGIN
			SET @t_timestamp = (SELECT SUBSTRING(@t_tid,@t_indexOf,14));
			
			DECLARE @r_request_seq int;
	
			EXECUTE [GlobalB2B].[dbo].[SP_SELECT_ORDER_PAYMENT_REQUEST_BY_REQUEST_DATA] 
			   @t_timestamp
			  ,@p_web_order_number
			  ,@p_good_name
			  ,@r_request_seq OUTPUT;
			
			IF(@r_result > 0)
			BEGIN
				UPDATE ORDER_PAYMENT_RESULT_MST
				SET PAYMENT_REQUEST_SEQ = @r_request_seq
				WHERE 
				PAYMENT_RESULT_SEQ = @r_result;
			END
			
		END
	END
	
	
	

END

GO
