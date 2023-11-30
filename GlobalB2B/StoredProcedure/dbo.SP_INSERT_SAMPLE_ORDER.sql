IF OBJECT_ID (N'dbo.SP_INSERT_SAMPLE_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_SAMPLE_ORDER
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
CREATE PROCEDURE [dbo].[SP_INSERT_SAMPLE_ORDER]
	-- Add the parameters for the stored procedure here
	@p_user_id nvarchar(255),
	@p_sample_group_seq int,
	@p_sample_product_seq_list nvarchar(255),
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
	
	DECLARE 
	@t_user_seq int,
	@t_order_seq int,
	@t_order_code nvarchar(255),
	@t_exist_sample_product int;
	
	
	IF(LEN(@p_sample_product_seq_list) = 0)
		SET @p_sample_product_seq_list = NULL;
		
	
	
	--USER 정보 설정
	SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID = @p_user_id);
	
	-- CART_SEQ_LIST : 생성된 CART_SEQ 저장
	DECLARE @t_cart_seq_table table	(	CART_SEQ nvarchar(100)	);
	
	-- PROD_SEQ_LIST 분할을 위한 처리 
	DECLARE @t_prod_seq_table table	(	PROD_SEQ nvarchar(100), QUANTITY nvarchar(100)	);
	
	BEGIN
		DECLARE @paramlist varchar(500),
				@delim char,
				@currentStrIndex int,
				@findStr varchar(100),
				@subStrIndex int,
				@prodSeqValue nvarchar(100),
				@quantityValue nvarchar(100);
				
		SET @paramlist = @p_sample_product_seq_list;
		SET @delim = '|';
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
					
					-- PROD_SEQ 와 QUANTITY 를 분리
					BEGIN
						SET @subStrIndex = CHARINDEX(':', @findStr, 0);
						SET @prodSeqValue = SUBSTRING(@findStr,1,@subStrIndex-1);
						SET @quantityValue = SUBSTRING(@findStr,@subStrIndex + 1,LEN(@findStr) - @subStrIndex);
						
						INSERT INTO 
							@t_prod_seq_table(PROD_SEQ, QUANTITY) 
						VALUES 
							(@prodSeqValue, @quantityValue)
					END
					
					
					SET @currentStrIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex)+1;
				END--END WHILE
				
				IF((SELECT COUNT(*) FROM @t_prod_seq_table) > 0)
				BEGIN
					
					--INSERT INTO @t_prod_seq_table VALUES (SUBSTRING(@paramList,@findIndex+1,LEN(@paramList)-@findIndex));
					
					-- PROD_SEQ 와 QUANTITY 를 분리
					set @findStr = SUBSTRING(@paramList,@findIndex+1,LEN(@paramList)-@findIndex);
					BEGIN
						SET @subStrIndex = CHARINDEX(':', @findStr, 0);
						SET @prodSeqValue = SUBSTRING(@findStr,1,@subStrIndex-1);
						SET @quantityValue = SUBSTRING(@findStr,@subStrIndex + 1,LEN(@findStr) - @subStrIndex);
						
						INSERT INTO 
							@t_prod_seq_table(PROD_SEQ, QUANTITY) 
						VALUES 
							(@prodSeqValue, @quantityValue)
					END
				END 
			END
		ELSE
			BEGIN
				--INSERT INTO @t_prod_seq_table VALUES (@paramList);
				set @findStr = @paramList;
				BEGIN
					SET @subStrIndex = CHARINDEX(':', @findStr, 0);
					SET @prodSeqValue = SUBSTRING(@findStr,1,@subStrIndex-1);
					SET @quantityValue = SUBSTRING(@findStr,@subStrIndex + 1,LEN(@findStr) - @subStrIndex);
					
					INSERT INTO 
						@t_prod_seq_table(PROD_SEQ, QUANTITY) 
					VALUES 
						(@prodSeqValue, @quantityValue)
				END
			END	
    
    END
    
    DELETE FROM @t_prod_seq_table WHERE PROD_SEQ IS NULL;
	-- PROD_SEQ_LIST 분할을 위한 처리 
	
	
	SET @t_exist_sample_product = (SELECT COUNT(*) FROM @t_prod_seq_table);
	
	-- CART 생성
	BEGIN
	
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
		   (NULL
		   ,@t_user_seq
		   ,@p_sample_group_seq
		   ,'111002' --샘플 그룹 카트
		   ,'118002' --주문요청
		   ,1
		   ,0
		   ,0
		   ,GETDATE());
		   
		INSERT INTO @t_cart_seq_table(CART_SEQ) VALUES (CAST(SCOPE_IDENTITY() AS INT));
		
		
		WHILE (SELECT COUNT(*) FROM @t_prod_seq_table) > 0
			BEGIN
			
			DECLARE @t_que_prod_seq int,@t_que_quantity int;
			
			SET @t_que_prod_seq = (SELECT TOP 1 PROD_SEQ FROM @t_prod_seq_table);
			SET @t_que_quantity = (SELECT TOP 1 QUANTITY FROM @t_prod_seq_table);
			
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
			   (NULL
			   ,@t_user_seq
			   ,@t_que_prod_seq
			   ,'111003' --샘플 제품 카트
			   ,'118002' --주문요청
			   ,@t_que_quantity
			   ,0
			   ,0
			   ,GETDATE());
			
			INSERT INTO @t_cart_seq_table(CART_SEQ) VALUES (CAST(SCOPE_IDENTITY() AS INT));
			
			DELETE FROM @t_prod_seq_table WHERE PROD_SEQ = @t_que_prod_seq;
			
			END -- 
	END
	-- CART 생성
	
	-- ORDER 생성
	BEGIN
		DECLARE @t_order_type nvarchar(6);
		
		IF(@t_exist_sample_product > 0)
			SET @t_order_type = '115001';
		ELSE
			SET @t_order_type = '115003'
		
	
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
			   ,CLAIM_EXIST_YORN
			   ,PAYMENT_TYPE_CODE
			   )
		 VALUES
			   (''
			   ,'110002'
			   ,@t_order_type
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
			   ,'N'
			   ,'141001'
			   );
			   
		SET @t_order_seq = CAST(SCOPE_IDENTITY() AS INT);
		SET @t_order_code = 'S' +(SUBSTRING(CONVERT(varchar(30),GETDATE(),112),3,4)+'-'+CONVERT(nvarchar,(@t_order_seq)));
		
		UPDATE ORDER_MST SET ORDER_CODE = @t_order_code WHERE ORDER_SEQ = @t_order_seq;
		
		UPDATE CART_MST
		SET ORDER_SEQ = (@t_order_seq)
		WHERE CART_SEQ IN ( SELECT CART_SEQ FROM @t_cart_seq_table );
		
		SET @r_order_code = @t_order_code;
	END
	-- ORDER 생성
	
END


GO
