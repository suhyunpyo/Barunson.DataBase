IF OBJECT_ID (N'dbo.SP_INSERT_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_ORDER
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
CREATE PROCEDURE [dbo].[SP_INSERT_ORDER]
	-- Add the parameters for the stored procedure here
	@p_user_id nvarchar(255),
	@p_cart_seq_list nvarchar(255),
	@p_first_name nvarchar(255),
	@p_last_name nvarchar(255),
	@p_email nvarchar(255),
	@p_tel1 nvarchar(20),
	@p_tel2 nvarchar(20),
	@p_tel3 nvarchar(20),
	@p_tel4 nvarchar(255),
	@p_addr1 nvarchar(255),
	@p_addr2 nvarchar(255),
	@p_zipcode nvarchar(255),
	@p_city nvarchar(255),
	@p_state nvarchar(255),
	@p_country nvarchar(255),
	@p_special_instruction ntext,
	@r_order_code nvarchar(255) output
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @t_max_order_seq int,
	@t_user_seq int,
	@t_order_seq int,
	@t_order_code nvarchar(255),
	@t_order_status_type nvarchar(255)
	
	SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID = @p_user_id);
	SET @t_max_order_seq = (SELECT MAX(ORDER_SEQ) FROM ORDER_MST);
	
	IF(@t_max_order_seq IS NULL)
		SET @t_max_order_seq = 0;		
	
	DECLARE @t_cart_seq_table table
    (
		CART_SEQ nvarchar(100)
    )
    
    -- CART SEQ 분리
    BEGIN
    
		DECLARE @paramlist varchar(500),
				@delim char,
				@currentStrIndex int,
				@findStr varchar(100)
				
		SET @paramlist = @p_cart_seq_list;
		SET @delim = ',';
		SET @currentStrIndex = 0;
		SET @findStr = '';
		

		IF(CHARINDEX(@delim,@paramList) > 0)
			BEGIN
				WHILE CHARINDEX(@delim,@paramlist,@currentStrIndex) > 0
				BEGIN
					DECLARE @findIndex int = CHARINDEX(@delim,@paramlist,@currentStrIndex);	
					SET @findIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex);
					-- 찾은 문자열 저장
					SET @findStr = SUBSTRING(@paramlist,@currentStrIndex,@findIndex-@currentStrIndex);
					INSERT INTO @t_cart_seq_table VALUES (@findStr);
					SET @currentStrIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex)+1;
				END--END WHILE
				
				IF((SELECT COUNT(*) FROM @t_cart_seq_table)>0)
				BEGIN
					INSERT INTO @t_cart_seq_table VALUES (SUBSTRING(@paramList,@findIndex+1,LEN(@paramList)-@findIndex));
				END 
			END
		ELSE
			BEGIN
				INSERT INTO @t_cart_seq_table VALUES (@paramList);
			END	
    
    END
    
    DELETE FROM @t_cart_seq_table WHERE CART_SEQ IS NULL;
	
	
	
	
	SET @t_order_status_type = '119001';
	SET @t_order_code = 'G'+(SUBSTRING(CONVERT(varchar(30),GETDATE(),112),3,4)+'-'+CONVERT(nvarchar,(@t_max_order_seq+1)));
	
	INSERT INTO [GlobalB2B].[dbo].[ORDER_MST]
           ([ORDER_CODE]
           ,[ORDER_TYPE_CODE]
           ,ORDER_STATUS_TYPE_CODE
           ,[ORDER_DATE]
           ,[USER_SEQ]
           ,[FIRST_NAME]
           ,[LAST_NAME]
           ,[EMAIL]
           ,[TEL_1]
           ,[TEL_2]
           ,[TEL_3]
           ,[TEL_4]
           ,[SHIPPING_ADDR_1]
           ,[SHIPPING_ADDR_2]
           ,[SHIPPING_CITY]
           ,[SHIPPING_STATE]
           ,[SHIPPING_ZIPCODE]
           ,[SHIPPING_COUNTRY]
           ,SPECIAL_INSTRUCTION
           ,PAYMENT_TYPE_CODE
           )
     VALUES
           (@t_order_code
           ,'110001'
           ,@t_order_status_type
           ,GETDATE()
           ,@t_user_seq
           ,@p_first_name
           ,@p_last_name
           ,@p_email
           ,@p_tel1
           ,@p_tel2
           ,@p_tel3
           ,@p_tel4
           ,@p_addr1
           ,@p_addr2
           ,@p_city
           ,@p_state
           ,@p_zipcode
           ,@p_country
           ,@p_special_instruction
           ,'141001'
           );
           
    SET @t_order_seq = CAST(SCOPE_IDENTITY() AS INT);
	SET @t_order_code = 'G' +(SUBSTRING(CONVERT(varchar(30),GETDATE(),112),3,4)+'-'+CONVERT(nvarchar,(@t_order_seq)));
	
	UPDATE ORDER_MST SET ORDER_CODE = @t_order_code WHERE ORDER_SEQ = @t_order_seq;
    
    UPDATE CART_MST
    SET ORDER_SEQ = @t_order_seq,
    CART_STATE_CODE = '118002'
    FROM CART_MST CM
    LEFT JOIN @t_cart_seq_table T_CM ON CM.CART_SEQ = T_CM.CART_SEQ
    WHERE
    CM.USER_SEQ = @t_user_seq AND CM.CART_STATE_CODE = '118001' AND T_CM.CART_SEQ IS NOT NULL
    	
	SET @r_order_code = @t_order_code;
END


GO
