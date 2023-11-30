IF OBJECT_ID (N'dbo.SP_BHANDS_ORDER_LAYER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BHANDS_ORDER_LAYER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- 300매(첫주문) + 100매(추가)  = 186,000원
-- 400매(첫주문)=137,700원
-- 약 56,000원 절약
		
-- BH8007 100매추가... (최소구매 200매)
-- BH8015 100매 할인 7% 


 --EXEC [SP_BHANDS_ORDER_LAYER] 5006, 35086, 100, 200, 300
-- =============================================
CREATE PROCEDURE [dbo].[SP_BHANDS_ORDER_LAYER] 
	@COMPANY_SEQ	INT,
	@CARD_SEQ		INT,
	@ORDER_NUM1		INT,
	@ORDER_NUM2		INT,
	@ORDER_NUM3		INT
AS
BEGIN	

	DECLARE @SALE_PRICE1 AS VARCHAR(10)
	DECLARE @SALE_PRICE2 AS VARCHAR(10)
	DECLARE @SALE_PRICE3 AS VARCHAR(10)


  SELECT 
	   @SALE_PRICE1 = isnull(replace( convert(money , (Round(B.cardset_price * ((100 - B.Discount_Rate1) / 100) , 0)) * @ORDER_NUM1), '.00', '' ) ,0) 
	 , @SALE_PRICE2 = isnull(replace(convert(money , (Round(B.cardset_price * ((100 - B.Discount_Rate2) / 100) , 0)) * @ORDER_NUM2), '.00', '' ) ,0)  
	 , @SALE_PRICE3 = isnull(replace(convert(money , (Round(B.cardset_price * ((100 - B.Discount_Rate3) / 100) , 0)) * @ORDER_NUM3), '.00', '' ) ,0) 

	FROM 
  (
  SELECT A.cardset_price
  ,(SELECT Discount_Rate FROM S2_CARDDISCOUNT WHERE CARDDISCOUNT_SEQ = B.CARDDISCOUNT_SEQ AND MinCount = @ORDER_NUM1) Discount_Rate1
  ,(SELECT Discount_Rate FROM S2_CARDDISCOUNT WHERE CARDDISCOUNT_SEQ = B.CARDDISCOUNT_SEQ AND MinCount = @ORDER_NUM2) Discount_Rate2
  ,(SELECT Discount_Rate FROM S2_CARDDISCOUNT WHERE CARDDISCOUNT_SEQ = B.CARDDISCOUNT_SEQ AND MinCount = @ORDER_NUM3) Discount_Rate3  
 FROM S2_CARD A JOIN S2_CARDSALESSITE B ON A.CARD_SEQ = B.CARD_SEQ
 AND B.COMPANY_SEQ = @COMPANY_SEQ
 AND A.CARD_SEQ= @CARD_SEQ
 ) B


 SELECT  @SALE_PRICE1 as sale_price1
		, @SALE_PRICE2 as sale_price2 
		, @SALE_PRICE3 as sale_price3
		, @order_num2 as order_num2
		, @order_num3 as order_num3

	
END
GO
