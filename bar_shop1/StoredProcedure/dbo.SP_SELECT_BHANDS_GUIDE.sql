IF OBJECT_ID (N'dbo.SP_SELECT_BHANDS_GUIDE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_BHANDS_GUIDE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_BHANDS_GUIDE 36613

*/

CREATE PROCEDURE [dbo].[SP_SELECT_BHANDS_GUIDE]
	@CARD_SEQ		AS INT

AS

BEGIN
	
	DECLARE @SAMPLE_CNT AS INT;
	DECLARE @ORDER_CNT AS INT;
	DECLARE @UP_ORDER_RATE AS INT;
	DECLARE @OVER_ORDER_RATE AS INT;
	DECLARE @ENV_PRICE_RATE AS INT;
	DECLARE @ENV_NAME AS VARCHAR(40);


	--배송완료 기준 샘플신청수 
	SELECT @SAMPLE_CNT = COUNT(A.SAMPLE_ORDER_SEQ)  
	FROM CUSTOM_SAMPLE_ORDER A JOIN CUSTOM_SAMPLE_ORDER_ITEM B ON A.SAMPLE_ORDER_SEQ = B.SAMPLE_ORDER_SEQ 
	AND A.STATUS_SEQ = 12 
	AND B.CARD_SEQ = @CARD_SEQ 


	-- 배송기준(결제완료) 총주문건수 / 추가주문건수 / 원주문300매이상주문건수 / 고급봉투
	SELECT	@ORDER_CNT = B.ORDER_CNT
		, @UP_ORDER_RATE = ( CASE WHEN UP_ORDER_RATE >= 100 THEN 100 ELSE UP_ORDER_RATE END )
		, @OVER_ORDER_RATE = OVER_ORDER_RATE 	 
		--, @ENV_PRICE_RATE = ( CASE WHEN ENV_PRICE_RATE >= 100 THEN 100 ELSE ENV_PRICE_RATE END )
		,@ENV_PRICE_RATE = ''
	FROM (	
		SELECT	ORDER_CNT
			, FLOOR (UP_ORDER_CNT / CONVERT(float,ORDER_CNT) * 100 ) + 20 AS UP_ORDER_RATE
			, FLOOR (OVER_ORDER_CNT / CONVERT(float,ORDER_CNT) * 100 ) AS OVER_ORDER_RATE 	 
		FROM 
			(
			SELECT 
				SUM(CASE WHEN ORDER_GB = 'A' THEN 1 ELSE 0 END) ORDER_CNT   
				, SUM(CASE WHEN ORDER_GB = 'B' THEN 1 ELSE 0 END) UP_ORDER_CNT  
				, SUM(OVER_CNT) OVER_ORDER_CNT    
			FROM (  
				SELECT ( CASE WHEN UP_ORDER_SEQ > 0 THEN 'B' ELSE  'A' END ) ORDER_GB     
					, ( CASE WHEN ORDER_COUNT >= 300 AND UP_ORDER_SEQ IS NULL THEN 1 ELSE  0 END ) OVER_CNT     
				FROM CUSTOM_ORDER C 
				WHERE STATUS_SEQ = 15 AND SETTLE_STATUS = 2 AND CARD_SEQ = @CARD_SEQ ) A 
			) A
	)B 


	
	
--	IF @ENV_PRICE_RATE > 30 
--
--		BEGIN
--				SELECT TOP 1 @ENV_NAME = C.CARD_NAME 
--				 FROM ( 
--				 SELECT B.CARD_SEQ, COUNT(B.ORDER_SEQ) CNT 
--				 FROM CUSTOM_ORDER A, CUSTOM_ORDER_ITEM B  
--				 WHERE A.ORDER_SEQ = B.ORDER_SEQ 
--				 AND  STATUS_SEQ = 15 AND SETTLE_STATUS = 2 AND A.CARD_SEQ = @CARD_SEQ AND ITEM_TYPE ='E' AND ITEM_SALE_PRICE > 0 
--				 AND B.CARD_SEQ IN (36625,36629,36623,36626,36633,36632,36634)
--				 GROUP BY B.CARD_SEQ  
--				 ) A , S2_CARD C 
--				 WHERE A.CARD_SEQ = C.CARD_SEQ 
--				 ORDER BY CNT DESC 
--					
--		END


	SELECT @SAMPLE_CNT AS SAMPLE_CNT , @ORDER_CNT AS ORDER_CNT, @UP_ORDER_RATE AS UP_ORDER_RATE 
		, @OVER_ORDER_RATE AS OVER_ORDER_RATE , @ENV_PRICE_RATE AS ENV_PRICE_RATE , @ENV_NAME AS ENV_NAME 

END
GO
