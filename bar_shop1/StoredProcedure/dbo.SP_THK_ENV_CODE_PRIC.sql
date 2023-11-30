IF OBJECT_ID (N'dbo.SP_THK_ENV_CODE_PRIC', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_THK_ENV_CODE_PRIC
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		정혜련
-- Create date: 2020-12-14
-- Description:	가로형한지봉투_인쇄

-- 30980	BE046	가로형한지봉투
-- 38134	BE046_P	가로형한지봉투_인쇄


-- EXEC 쿠폰타입, 회원아이디, 사이트코드
-- EXEC SP_THK_ENV_CODE_PRIC 3075890

-- =============================================

CREATE PROCEDURE [dbo].[SP_THK_ENV_CODE_PRIC]
	@ORDER_SEQ		AS INT
AS
BEGIN
	
	DECLARE		@P_PRINT_COUNT		AS	INT = 0
	DECLARE		@FLOW			AS	INT = 0 
	DECLARE		@ITEM_CNT		AS	INT = 0
	DECLARE		@ITEM_P_CNT		AS	INT = 0
	
	DECLARE		@ENV_SEQ		AS INT 
	DECLARE		@ENV_P_SEQ		AS INT 
	DECLARE		@P_ID			AS INT 
	DECLARE		@SUM_PRINT_P	AS INT
	DECLARE		@SUM_PRINT		AS INT
	DECLARE		@item_env_cnt	AS INT 
		

	IF EXISTS ( 
		SELECT  TOP 1 ORDER_SEQ  
		FROM CUSTOM_ORDER_ITEM 
		WHERE ORDER_SEQ = @ORDER_SEQ 
		AND CARD_SEQ IN ( SELECT CARD_SEQ FROM S2_CARD WHERE CARD_CODE IN ('BE046','BE046_P','BE047'))
	)  
	BEGIN                     
		SET @FLOW = 1  
	END  
	ELSE  
	BEGIN                     
		SET @FLOW = 0
	END 


	IF @FLOW = 1 
	BEGIN

	SELECT @ENV_SEQ = CARD_SEQ FROM S2_CARD WHERE CARD_CODE ='BE046' 

	SELECT @ENV_P_SEQ = CARD_SEQ FROM S2_CARD WHERE CARD_CODE ='BE046_P' 

	-- PLIST에 BE046_P 있는지 확인  
 	select  @p_id = isnull(
		(SELECT	 ID
			FROM	CUSTOM_ORDER_PLIST COP
			WHERE	ORDER_SEQ = @ORDER_SEQ
			AND	PRINT_TYPE='E'
			AND	PRINT_COUNT > 0
			AND	isNotPrint = '4'
		),0) 
				  


	-- 있다면
	IF @p_id > 0
	
	BEGIN
		UPDATE CUSTOM_ORDER_PLIST SET title = '감사인쇄봉투' , isNotPrint = '1' , CARD_SEQ= @ENV_P_SEQ where order_Seq = @ORDER_SEQ and id = @p_id
	END 
		 
	--select @item_env_cnt = count(*) from custom_order_item where order_seq =  @ORDER_SEQ and card_seq = @ENV_SEQ and item_count > 0 

	--IF @item_env_cnt > 1  -- 1개이상인경우는 SP에서 삭제해준다.
	--BEGIN
	--	DELETE FROM custom_order_item WHERE order_seq = @order_seq and ID = (SELECT TOP 1 id FROM custom_order_item where ORDER_SEQ = @ORDER_SEQ AND card_seq = @ENV_SEQ and item_count > 0 )
	--END


	-- CUSTOM_ORDER_PIST 확인	
	SELECT 
	@SUM_PRINT_P = sum(isnull((CASE  WHEN TITLE ='감사인쇄봉투' THEN  PRINT_COUNT END ),0))   -- 감사인쇄봉투
	, @SUM_PRINT = sum(isnull((CASE  WHEN TITLE <> '감사인쇄봉투' THEN  PRINT_COUNT END ),0)) -- 그외봉투
	FROM CUSTOM_ORDER_PLIST 
	WHERE order_Seq = @ORDER_SEQ 
	AND PRINT_TYPE ='E' 
		
	-- custom_order_item 확인해야함  BE046_P		
	SELECT @ITEM_P_CNT = ISNULL((SELECT ITEM_COUNT FROM CUSTOM_ORDER_ITEM WHERE ORDER_SEQ = @ORDER_SEQ AND ITEM_TYPE = 'E' AND CARD_SEQ =  @ENV_P_SEQ),0) 
								 
	IF @ITEM_P_CNT = 0 

		BEGIN 
			PRINT @ENV_P_SEQ
			PRINT @SUM_PRINT_P
		
			INSERT INTO CUSTOM_ORDER_ITEM (ORDER_SEQ, CARD_SEQ, ITEM_TYPE, ITEM_COUNT, ITEM_PRICE) VALUES (@ORDER_SEQ, 	@ENV_P_SEQ,  'E',	@SUM_PRINT_P,0  )	
		END 

		-- 감사인쇄봉투
		UPDATE CUSTOM_ORDER_ITEM SET ITEM_COUNT = @SUM_PRINT_P WHERE ORDER_SEQ = @ORDER_SEQ AND ITEM_TYPE = 'E' AND CARD_SEQ = @ENV_P_SEQ
		-- 일반봉투
		UPDATE CUSTOM_ORDER_ITEM SET ITEM_COUNT = @SUM_PRINT WHERE ORDER_SEQ = @ORDER_SEQ AND ITEM_TYPE = 'E' AND CARD_SEQ <> @ENV_P_SEQ
	
	END

	-- CUSTOM_ORDER_ITEM 확인
	select @item_env_cnt = count(*) from custom_order_item where order_seq =  @ORDER_SEQ and card_seq IN ( @ENV_SEQ, @ENV_P_SEQ )  and item_count = 0 AND ITEM_TYPE ='E'
	
	IF @item_env_cnt > 0  -- 1개이상인경우는 SP에서 삭제해준다.
	BEGIN
		DELETE FROM custom_order_item WHERE order_seq = @order_seq AND card_seq IN ( @ENV_SEQ, @ENV_P_SEQ ) and item_count = 0 AND ITEM_TYPE ='E'
	END	

END
GO
