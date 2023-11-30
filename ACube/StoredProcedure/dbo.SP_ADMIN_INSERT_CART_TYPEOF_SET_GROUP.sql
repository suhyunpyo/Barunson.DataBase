IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_CART_TYPEOF_SET_GROUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_CART_TYPEOF_SET_GROUP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_CART_TYPEOF_SET_GROUP]
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
	DECLARE @t_cart_seq int,
    @t_order_code nvarchar(255),
    @t_cart_code_keyword nvarchar(255),
    @t_optional_ref_type_code nchar(6);
    
	SET @t_cart_code_keyword = 'CR';
	IF(@p_cart_type_code = '201001')
		BEGIN
			--SET GROUP 요청의 경우
			SET @t_cart_code_keyword = 'CS'
			SET @t_optional_ref_type_code = '302003';
		END
	ELSE
		BEGIN
			-- RETAIL 요청의 경우
			SET @t_cart_code_keyword = 'CR'
			SET @t_optional_ref_type_code = '302002';
		END
		
    
    
    
    
	IF(@p_cart_code IS NULL)
		SET @p_cart_code = '';

    -- Insert statements for procedure here
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
		SET @p_cart_code = @t_order_code + '-' + @t_cart_code_keyword + CONVERT(nvarchar, @t_cart_seq);
		
		UPDATE CART_MST 
		SET CART_CODE = @p_cart_code 
		WHERE CART_SEQ = @t_cart_seq;
	END
	
	
	-- 세트 상품을 기준으로 Cart Item 구성
	BEGIN
	
		DECLARE @t_ref_prod_seq int,
		@t_ref_prod_type_code nchar(6),
		@t_ref_type_code nchar(6),
		@t_cart_item_quantity int,
		@t_cart_item_export_quantity int;
	
		DECLARE TEMP_CURSOR  CURSOR FOR 	
			SELECT 
			PM.PROD_SEQ,
			PM.PROD_TYPE_CODE,
			REF.REF_TYPE_CODE
			FROM PROD_SET_GROUP_REF_MST REF
			LEFT JOIN PROD_MST PM ON REF.PROD_SEQ = PM.PROD_SEQ
			WHERE 
			REF.PROD_SET_GROUP_SEQ = @p_seq
			AND 
			(
				REF.REF_TYPE_CODE = '302001'
				OR
				REF.REF_TYPE_CODE = @t_optional_ref_type_code
			);
			
		OPEN TEMP_CURSOR;
		
		FETCH NEXT FROM TEMP_CURSOR INTO @t_ref_prod_seq, @t_ref_prod_type_code, @t_ref_type_code;
		
		WHILE(@@FETCH_STATUS=0)
		BEGIN
		
		/*
			-- 주문 수량 설정
			SET @t_cart_item_quantity = (
				CASE @t_ref_prod_type_code 
				--Password
				WHEN '101006' THEN 1
				--Labour
				WHEN '101007' THEN 1
				--Fee
				WHEN '101009' THEN 1
				ELSE @p_quantity END
			)
		*/
		
			--CART ITEM INSERT 처리
			EXECUTE [ACube].[dbo].[SP_ADMIN_INSERT_CART_ITEM] 
				@t_cart_seq
				,@t_ref_prod_seq
				,@p_quantity;
		
			FETCH NEXT FROM TEMP_CURSOR INTO @t_ref_prod_seq, @t_ref_prod_type_code, @t_ref_type_code;	
		END
		CLOSE TEMP_CURSOR;
		DEALLOCATE TEMP_CURSOR;
	END
	


	--W1101P 주문시 수량 강제 조정 (글로벌 박은현대리 요청-20170525)
	--Retail Product(201002)
	IF EXISTS (select * from CART_MST where CART_SEQ = @t_cart_seq AND CART_TYPE_CODE = 201002 AND PROD_SEQ = 485 )
	BEGIN 
		
	--2579	AID001
	--2581	AP002
	--2698	LABOUR
	--2762	W1101p

		UPDATE CART_ITEM_MST 
		SET QUANTITY = ROUND(QUANTITY / 6, 0)
			, EXPORT_QUANTITY = ROUND(EXPORT_QUANTITY / 6, 0)
		WHERE CART_SEQ = @t_cart_seq  AND  PROD_SEQ = 2581 

		UPDATE CART_ITEM_MST 
		SET EXPORT_QUANTITY = CASE WHEN QUANTITY < 12 THEN 1 ELSE ROUND(QUANTITY / 12, 0) END
		WHERE CART_SEQ = @t_cart_seq  AND  PROD_SEQ = 2579 
	 
	 END


	
END

GO
