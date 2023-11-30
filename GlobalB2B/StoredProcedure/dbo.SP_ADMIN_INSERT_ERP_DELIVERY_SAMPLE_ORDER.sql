IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_ERP_DELIVERY_SAMPLE_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_ERP_DELIVERY_SAMPLE_ORDER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_ERP_DELIVERY_SAMPLE_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	/*
	글로벌 샘플주문 ERP INSERT SP 입니다.
	From. 이상민 과장(sangmin.lee@bhandscard.com)
    -- Insert statements for procedure here
    
    --ERP IP : 114.111.54.142 
	--ERP DB : XERP
	 
	-- [C_spGlobalSample_INSERT]
	-- @ORDER_GUBUN CHAR(4) -- 구분: 'HEAD', 'ITEM'  
	--, @GLOBAL_SITE NVARCHAR(2) --해외구분
	--, @ORDER_CODE NVARCHAR(255) --주문번호
	--, @ORDER_DATE CHAR(8)  --주문일자
	--, @ORDER_DESCR NVARCHAR(255) --비고
	--, @PROD_CODE NVARCHAR(30)  --품목코드
	--, @PROD_QTY INT     --주문수량
	--, @PROD_AMNT NUMERIC(28,8)  --주문금액
	--, @SAMPLE_GROUP_TITLE NVARCHAR(255)  --샘플그룹
	 
	--[C_spGlobalSample_DELETE]
	-- @GLOBAL_SITE NVARCHAR(2) --해외구분
	--, @ORDER_CODE NVARCHAR(255) --주문번호
	 
	SELECT * FROM C_GlobalSampleHeader
	SELECT * FROM C_GlobalSampleItem

	--INSERT SP 실행시
	--HEAD
	EXEC [C_spGlobalSample_INSERT] 'HEAD', 'US', 'TEST01', '20150316', '테스트주문', '', 0, 0, ''
	--ITEM
	EXEC [C_spGlobalSample_INSERT] 'ITEM', 'US', 'TEST01', '20150316', '테스트주문', 'BE004', 1, 3000, '샘플킷001'

	--DELETE SP 실행시
	EXEC [C_spGlobalSample_DELETE] 'US', 'TEST01'
	*/
    
    DECLARE @t_result_table table (OK_CHECK nvarchar(255), ERROR_MSG nvarchar(255));
    
    
    DECLARE     
    @t_order_site_key NVARCHAR(2),
    @t_order_code nvarchar(255),
    @t_order_date_datetime Datetime,--YYYYMMDD
    @t_order_date_str char(8),
    @t_description nvarchar(255),
    @t_prod_code nvarchar(30),
    @t_prod_quantity int,
    @t_prod_price NUMERIC(28,8),   
    @t_sample_group_title nvarchar(255);
    
    SET @t_order_site_key = 'GB';
    SET @t_order_code = (SELECT ORDER_CODE FROM ORDER_MST WHERE ORDER_SEQ = @p_order_seq)
    SET @t_order_date_datetime = (SELECT ORDER_DATE FROM ORDER_MST WHERE ORDER_SEQ = @p_order_seq);
    SET @t_order_date_str = CAST(YEAR(@t_order_date_datetime) AS NVARCHAR) 
							+ RIGHT('00'+CAST(MONTH(@t_order_date_datetime) AS NVARCHAR), 2) 
							+ RIGHT('00'+CAST(DAY(@t_order_date_datetime) AS NVARCHAR), 2);
    SET @t_description = 'Test Data - This is ERP Delevery Infomation Insert Test';  
    
    
    --사전 입력 정보 삭제
    BEGIN
		EXEC [dbo].[SP_ADMIN_DELETE_ERP_DELIVERY_SAMPLE_ORDER]
				@p_order_seq = @p_order_seq
    END
    
	--HEAD 정보 입력
	BEGIN
		/*
		SELECT 'HEAD' AS ORDER_GUBUN, 
			@t_order_site_key AS GLOBAL_SITE,  
			@t_order_code AS ORDER_CODE, 
			@t_order_date_str AS ORDER_DATE, 
			@t_description AS ORDER_DESCR, 
			'' AS PROD_CODE, 
			1 AS PROD_QTY, 
			0 AS PROD_AMNT, 
			'' AS SAMPLE_GROUP_TITLE;
		*/
		
		EXECUTE [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[C_spGlobalSample_INSERT] 
			'HEAD', 
			@t_order_site_key,
			@t_order_code,
			@t_order_date_str,
			@t_description,
			'',
			1,
			0,
			''
	END
	
	-- Sample Group Info Insert
	BEGIN
		
		DECLARE sample_group_item_cursor CURSOR FOR		
			SELECT 
			PM.PROD_CODE AS PROD_CODE,
			CM.QUANTITY AS PROD_QTY,
			CM.PRICE AS PROD_AMNT,
			SGM.TITLE AS SAMPLE_GROUP_TITLE
			FROM ORDER_MST OM
			LEFT JOIN CART_MST CM ON OM.ORDER_SEQ = CM.ORDER_SEQ
			LEFT JOIN SAMPLE_GROUP_MST SGM ON SGM.SAMPLE_GROUP_SEQ = CM.PROD_SEQ
			LEFT JOIN SAMPLE_GROUP_ITEM_MST SGIM ON SGM.SAMPLE_GROUP_SEQ = SGIM.SAMPLE_GROUP_SEQ
			LEFT JOIN PROD_MST PM ON SGIM.PROD_SEQ = PM.PROD_SEQ
			WHERE OM.ORDER_SEQ = @p_order_seq
			AND CM.CART_TYPE_CODE = '111002'
			
		OPEN sample_group_item_cursor;
		
		FETCH NEXT FROM sample_group_item_cursor INTO @t_prod_code, @t_prod_quantity, @t_prod_price, @t_sample_group_title;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			/*
			SELECT @t_prod_code,@t_prod_quantity, @t_prod_price, @t_sample_group_title;
			*/
			
			--INSERT INTO @t_result_table
			EXECUTE [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[C_spGlobalSample_INSERT] 
				'ITEM', 
				@t_order_site_key,
				@t_order_code,
				@t_order_date_str,
				@t_description,
				@t_prod_code,
				@t_prod_quantity,
				@t_prod_price,
				@t_sample_group_title
			FETCH NEXT FROM sample_group_item_cursor INTO @t_prod_code, @t_prod_quantity, @t_prod_price, @t_sample_group_title;
		END
		
		CLOSE sample_group_item_cursor;
		DEALLOCATE sample_group_item_cursor;

		
	END
	
	-- Additional Sample Item Info Insert
	BEGIN
		
		DECLARE additional_sample_item_cursor CURSOR FOR		
			SELECT 
			PM.PROD_CODE AS PROD_CODE,
			CM.QUANTITY AS PROD_QTY,
			CM.PRICE AS PROD_AMNT,
			'' AS SAMPLE_GROUP_TITLE
			FROM ORDER_MST OM
			LEFT JOIN CART_MST CM ON OM.ORDER_SEQ = CM.ORDER_SEQ
			LEFT JOIN PROD_MST PM ON CM.PROD_SEQ = PM.PROD_SEQ
			WHERE OM.ORDER_SEQ = @p_order_seq
			AND CM.CART_TYPE_CODE = '111003';
			
		OPEN additional_sample_item_cursor;
		
		FETCH NEXT FROM additional_sample_item_cursor INTO @t_prod_code, @t_prod_quantity, @t_prod_price, @t_sample_group_title;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			/*
			SELECT @t_prod_code,@t_prod_quantity, @t_prod_price, @t_sample_group_title;
			*/
			
			--INSERT INTO @t_result_table
			EXECUTE [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[C_spGlobalSample_INSERT] 
				'ITEM', 
				@t_order_site_key,
				@t_order_code,
				@t_order_date_str,
				@t_description,
				@t_prod_code,
				@t_prod_quantity,
				@t_prod_price,
				@t_sample_group_title
			FETCH NEXT FROM additional_sample_item_cursor INTO @t_prod_code, @t_prod_quantity, @t_prod_price, @t_sample_group_title;
		END
		
		CLOSE additional_sample_item_cursor;
		DEALLOCATE additional_sample_item_cursor;
		
		
	END
	
	/*
	BEGIN
		-- 제품별 주문 수량값 구하기
		SELECT
		TT.PROD_SEQ,
		SUM(TT.QUANTITY)
		FROM 
		(
			SELECT
			*
			FROM
			(
				SELECT 
				PM.PROD_SEQ, 
				SUM(CM.QUANTITY) AS QUANTITY
				FROM ORDER_MST OM
				LEFT JOIN CART_MST CM ON CM.ORDER_SEQ = OM.ORDER_SEQ
				LEFT JOIN SAMPLE_GROUP_MST SGM ON CM.PROD_SEQ = SGM.SAMPLE_GROUP_SEQ
				LEFT JOIN SAMPLE_GROUP_ITEM_MST SGIM ON SGM.SAMPLE_GROUP_SEQ = SGIM.SAMPLE_GROUP_SEQ
				LEFT JOIN PROD_MST PM ON PM.PROD_SEQ = SGIM.PROD_SEQ
				WHERE OM.ORDER_SEQ = @p_order_seq AND CM.CART_TYPE_CODE = '111002'
				GROUP BY PM.PROD_SEQ
			) AS GL
			UNION ALL
			(
				SELECT 
				PM.PROD_SEQ, SUM(CM.QUANTITY) AS QUANTITY
				FROM ORDER_MST OM
				LEFT JOIN CART_MST CM ON CM.ORDER_SEQ = OM.ORDER_SEQ
				LEFT JOIN PROD_MST PM ON CM.PROD_SEQ = PM.PROD_SEQ
				WHERE OM.ORDER_SEQ = @p_order_seq AND CM.CART_TYPE_CODE = '111003'
				GROUP BY PM.PROD_SEQ
			)
		) AS TT 
		GROUP BY TT.PROD_SEQ 
		ORDER BY TT.PROD_SEQ
	END
	
	*/
	
	
	UPDATE ORDER_MST	SET ERP_INSERT_YORN = 'Y'	WHERE ORDER_SEQ = @p_order_seq;
	
END


GO
