IF OBJECT_ID (N'dbo.up_insert_thankcard_order_item', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_thankcard_order_item
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-22
-- Description:	답례장 주문 1단계 정보 저장/수정 
-- up_insert_thankcard_order_item

-- =============================================
CREATE PROCEDURE [dbo].[up_insert_thankcard_order_item]
	
	@order_seq			int,				
	@card_seq			int,				
	@item_type			varchar(1),				
	@item_count			int,
	@item_price			int,
	@item_sale_price	int,
	@addnum_price		int,
	@save_type			varchar(1)
	
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	BEGIN TRAN
		
		/*
		IF @save_type = 'U' BEGIN
			DELETE FROM Custom_Order_Item WHERE order_seq = @order_seq
		END
		*/
		
		INSERT INTO Custom_Order_Item 
		( order_seq, card_seq, item_type, item_count, item_price, item_sale_price, addnum_price ) 
		VALUES 
		( @order_seq, @card_seq, @item_type, @item_count, @item_price, @item_sale_price, @addnum_price )
	
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
