IF OBJECT_ID (N'dbo.up_select_thankcard_order_item_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thankcard_order_item_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-24
-- Description:	답례장 주문 1단계 카드 & 봉투 주문 item 정보 
-- TEST : up_select_thankcard_order_item_info 1970860
-- =============================================
CREATE PROCEDURE [dbo].[up_select_thankcard_order_item_info]
	
	@order_seq	int	
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;

	-- rs1 (카드 정보) --
	SELECT   card_seq
			,item_type
			,item_count
			,item_price
			,item_sale_price 
	FROM Custom_Order_Item 
	WHERE order_seq = @order_seq
	  AND item_type = 'C'

	--신규 답례봉투 (봉투없음 [S2_CardDetail].[Env_Seq] = 11111)_20170614
	DECLARE @Env_Seq INT, @Card_Seq INT, @Item_Count INT

	SELECT @Card_Seq = card_seq
		, @Item_Count = item_count 
	FROM Custom_Order_Item 
	WHERE order_seq = @order_seq 
		AND item_type = 'C'

	SET @Env_Seq = (SELECT TOP 1 Env_Seq FROM S2_CardDetail WHERE Card_Seq = @Card_Seq)
	
	IF @Env_Seq = 11111
		BEGIN
			--봉투없음
			SELECT @Env_Seq AS card_seq
					,'E' AS item_type
					,@Item_Count AS item_count
					,0 AS item_price
					,0 AS item_sale_price 
		END
	ELSE
		BEGIN
			--그외	
			-- rs2 (봉투 정보) --
			SELECT   card_seq
					,item_type
					,item_count
					,item_price
					,item_sale_price 
			FROM Custom_Order_Item 
			WHERE order_seq = @order_seq
			  AND item_type = 'E'

		END
END
GO
