IF OBJECT_ID (N'dbo.up_insert_thankcard_order_option', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_thankcard_order_option
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조창연
-- Create date: 2015-01-25
-- Description:	답례장 주문 2단계 정보 저장 (부가옵션상품)
-- up_insert_thankcard_order_option
-- update history: 2020-12-18 (박혜림) - 스티커 수량 저장시, 카드수량 -> 봉투수량으로 저장되도록 수정 
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_thankcard_order_option]	
	@order_seq            INT,
	@order_num            INT,
	@sticker_seq          INT,
	@sticker_unit_price   INT,
	@sticker_total_price  INT,
	@moneyEnv_seq         INT,
	@moneyEnv_unit_price  INT,
	@moneyEnv_num         INT,
	@moneyEnv_total_price INT,
	@isInpaper            VARCHAR(1),
	@isInpaper_price      INT,
	@isHandmade           VARCHAR(1),
	@isHandmade_price     INT,
	@isEnvInsert          VARCHAR(1),
	@isEnvInsert_price    INT,
	@isEmbo	              VARCHAR(1),
	@isEmbo_price         INT,
	@sticker_num          INT	
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	
	BEGIN TRAN
		
		DECLARE @jebon_price int
		SET @jebon_price = @isInpaper_price + @isHandmade_price 
		
		DELETE FROM Custom_Order_Item 
		WHERE item_type IN ('S')
		  AND order_seq = @order_seq
		
		-- 스티커 --
		IF @sticker_seq <> '0'--신규 답례봉투 (봉투없음 [S2_CardDetail].[Env_Seq] = 11111)_20170614
			BEGIN
				INSERT INTO Custom_Order_Item (order_seq, card_seq, item_type, item_count, item_price, item_sale_price) 
				VALUES (@order_seq, @sticker_seq, 'S', @sticker_num, @sticker_unit_price, @sticker_total_price)
			END
			 
		-- 주문 총 금액 수정 --
		UPDATE Custom_Order SET last_total_price = last_total_price + @sticker_total_price + @moneyEnv_total_price + @jebon_price + @isEnvInsert_price + @isEmbo_price,
			embo_price = @isEmbo_price, sticker_price = @sticker_total_price, jebon_price = @jebon_price, envInsert_price = @isEnvInsert_price, moneyenv_price = @moneyEnv_total_price,
			ishandmade = @ishandmade, isEmbo = @isEmbo, isEnvInsert = @isEnvInsert, isinpaper = @isinpaper
		WHERE order_seq = @order_seq
		
		
	--SET @result_cnt = @@ROWCOUNT	-- 변경된 rowcount
	--SET @result_code = @@Error	-- 에러발생 cnt
	
	IF (@@Error <> 0) GOTO PROBLEM
	COMMIT TRAN

	PROBLEM:
	IF (@@Error <> 0) BEGIN
		ROLLBACK TRAN
	END
	
END
GO
