IF OBJECT_ID (N'dbo.up_select_charge_option', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_charge_option
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-24
-- Description:	마이페이지 주문상세내역 - 유료옵션 또는 수량추가 가져오기
-- TEST : up_select_charge_option 1970887
-- =============================================
CREATE PROCEDURE [dbo].[up_select_charge_option]
	
	@order_seq		int	

AS
BEGIN

	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	

	SELECT   A.id
			,A.item_type
			,ISNULL(A.memo1, '') AS memo
			,B.card_div
			,B.card_code
			,B.card_price
			,A.item_sale_price
			,A.item_count
			,A.addnum_price
			,B.card_image
			,ISNULL(MC.code_value, '') AS item_name
	FROM Custom_Order_Item A 
	INNER JOIN S2_card B ON A.card_seq = B.card_seq
	INNER JOIN Manage_Code MC ON B.card_div = MC.code 
	WHERE order_seq = @order_seq   
	  AND (B.card_div LIKE 'A%' OR B.card_div LIKE 'B%')
	  AND MC.code_type = 'card_div'
	ORDER BY B.card_div


	SELECT   A.id
			,A.item_type
			,ISNULL(A.memo1, '') AS memo
			,B.card_div
			,B.card_code
			,A.item_sale_price
			,A.item_count
			,B.card_image
			,ISNULL(MC.code_value, '') AS item_name
			--,B.card_name
	FROM Custom_Order_Item A 
	INNER JOIN S2_card B ON a.card_seq = B.card_seq
	INNER JOIN Manage_Code MC ON B.card_div = MC.code 
	WHERE order_seq = @order_seq 
	  AND B.card_div LIKE 'C%'
	  AND MC.code_type = 'card_div'
	ORDER BY A.id, A.item_type, B.card_div



END
GO
