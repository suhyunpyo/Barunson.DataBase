IF OBJECT_ID (N'dbo.up_select_thankcard_item_type', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thankcard_item_type
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-08
-- Description:	답례장 주문 item type
-- TEST : up_select_thankcard_item_type 1781764
-- =============================================
CREATE PROCEDURE [dbo].[up_select_thankcard_item_type]
	
	@order_seq		int

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;


	--DECLARE @order_seq int=1781764--(2)

	SELECT  ISNULL(MAX(CASE item_type WHEN 'A' THEN card_seq END), 0) AS order_acc_seq
		   ,ISNULL(MAX(CASE item_type WHEN 'E' THEN card_seq END), 0) AS order_env_seq
		   ,ISNULL(MAX(CASE item_type WHEN 'D' THEN card_seq END), 0) AS order_lining_seq
	FROM Custom_Order_Item
	WHERE order_seq = @order_seq
	  AND item_type IN ('E', 'A', 'D')
	  

END
GO
