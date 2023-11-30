IF OBJECT_ID (N'dbo.get_order_amount', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_order_amount', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_order_amount', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_order_amount', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_order_amount', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.get_order_amount
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		조창연
-- Create date: 2014-12-19
-- Description:	주문결제 리스트 상품종류/주문수량 STRING 반환
-- =============================================
CREATE FUNCTION [dbo].[get_order_amount]
(
	@order_seq int,
	@kind varchar(3)	
)

RETURNS 
	varchar(200)
AS  
BEGIN 
 	
 	--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	--SET NOCOUNT ON;	
	
	
	DECLARE @retStr VARCHAR(200)	
	
	IF @kind = 'E'	-- 부가상품 / 플러스쇼핑
	
		BEGIN
		
			SELECT @retStr = CONVERT(varchar, COUNT(order_seq)) + '개'
			FROM Custom_Etc_Order_Item
			WHERE order_seq = @order_seq
			
		END
	
	ELSE IF @kind = 'S'				-- 샘플
		
		BEGIN
		
			SELECT @retStr = ' 외 ' + CONVERT(varchar, COUNT(sample_order_seq) - 1) + '종'
			FROM Custom_Sample_Order_Item
			WHERE sample_order_seq = @order_seq
		
		END 		
	
	ELSE 	-- 청첩장 / 답례장
	
		BEGIN
		
			SELECT @retStr   
					= ISNULL(MAX(CASE card_div WHEN 'A01' THEN strItem END), '') 
			+ '|' + ISNULL(MAX(CASE card_div WHEN 'A02' THEN strItem END), '') 
			+ '|' + ISNULL(MAX(CASE card_div WHEN 'A03' THEN strItem END), '') 
			+ '|' + ISNULL(MAX(CASE card_div WHEN 'A04' THEN strItem END), '') 
			+ '|' + ISNULL(MAX(CASE card_div WHEN 'A05' THEN strItem END), '') 
			+ '|' + ISNULL(MAX(CASE card_div WHEN 'B01' THEN strItem END), '') 
			+ '|' + ISNULL(MAX(CASE card_div WHEN 'B02' THEN strItem END), '')
			FROM
			(
				SELECT S.card_div, ISNULL(I.strItem, '') AS strItem
				FROM
				(
					SELECT 'A01' AS card_div
					UNION ALL
					SELECT 'A02' AS card_div
					UNION ALL
					SELECT 'A03' AS card_div
					UNION ALL
					SELECT 'A04' AS card_div
					UNION ALL
					SELECT 'A05' AS card_div
					UNION ALL
					SELECT 'B01' AS card_div
					UNION ALL
					SELECT 'B02' AS card_div
				) S 
				LEFT OUTER JOIN 
				(
					SELECT C.card_div, MC.code_value + ';' + CONVERT(varchar, I.item_count) AS strItem
					FROM S2_Card C 
					INNER JOIN Custom_Order_Item I ON C.Card_Seq = I.card_seq AND I.order_seq = @order_seq
					INNER JOIN Manage_Code MC ON C.card_div = MC.code AND MC.code_type = 'card_div'
				) I ON S.card_div = I.Card_Div
			) AS Result
			
		END
	
	RETURN @retStr
	

END



GO
