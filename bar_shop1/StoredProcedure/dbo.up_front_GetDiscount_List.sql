IF OBJECT_ID (N'dbo.up_front_GetDiscount_List', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_GetDiscount_List
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   : [2003:07:22    12:35]  JJH: 
	관련페이지 : wedd_det.asp
	내용	   : 상품의 판매수량별 할인정보
	
	수정정보   : 
*/
CREATE Procedure  [dbo].[up_front_GetDiscount_List]
	@CARD_CATEGORY_SEQ		varchar(10)
,	@CARD_PRICE_CUSTOMER	money
as
	SET NOCOUNT ON
-- 할인율
CREATE TABLE #TEMP_RATE
(
	CARD_COUNT		INT		-- 판매수량
,	DISCOUNT_RATE		FLOAT		-- 할인율
,	SELL_PRICE		INT		-- 할인가
)
	DECLARE	@TEMP_COUNT		INT
			,@CARD_COUNT		INT
			,@DISCOUNT_RATE	FLOAT
			,@SELL_PRICE		INT
	SET @TEMP_COUNT = 2
	WHILE ( @TEMP_COUNT <= 9)
	BEGIN
		SET @DISCOUNT_RATE = NULL
		SET @CARD_COUNT = @TEMP_COUNT * 50
		SET @SELL_PRICE = 0
		
		 SELECT TOP 1 @DISCOUNT_RATE = DISCOUNT_RATE FROM dbo.DISCOUNT_POLICY  
					WHERE  	CARD_CATEGORY_SEQ=@CARD_CATEGORY_SEQ  
					AND 	MIN_PRICE <=  @CARD_PRICE_CUSTOMER
					AND	MAX_PRICE >= @CARD_PRICE_CUSTOMER
					AND	MIN_COUNT<= 	@CARD_COUNT
					AND 	MAX_COUNT>=	@CARD_COUNT
		IF ( ISNULL(@DISCOUNT_RATE,0) = 0)	-- 시중가를 산출한것이 NULL 이거나 0이면 상위 카테고리를 이용해서 한번더 검색한다
							-- TABLE 구조가 합리적으로 되어 있지않아서 JOIN 문장이 복잡해진다.
		BEGIN
			DECLARE	 @CATEGORY_UPPER_CODE	INT
	
			SELECT @CATEGORY_UPPER_CODE = CC.CATEGORY_UPPER_CODE FROM dbo.card_category CC	WHERE CC.CARD_CATEGORY_SEQ= @CARD_CATEGORY_SEQ
	
			-- 상위 코드가 있다면 상위코드값을 이용해서 다시 할인율을 구해본다
			IF (ISNULL(@CATEGORY_UPPER_CODE,0) != 0)	
				BEGIN
					SELECT TOP 1 @DISCOUNT_RATE = DISCOUNT_RATE FROM dbo.DISCOUNT_POLICY  
						WHERE  	CARD_CATEGORY_SEQ=@CATEGORY_UPPER_CODE  
						AND 	MIN_PRICE <=  @CARD_PRICE_CUSTOMER
						AND	MAX_PRICE >= @CARD_PRICE_CUSTOMER
						AND	MIN_COUNT<= 	@CARD_COUNT
						AND 	MAX_COUNT>=	@CARD_COUNT
				END
		END
	
	
			IF ( @DISCOUNT_RATE !=0)
			BEGIN
				SET @SELL_PRICE = @CARD_PRICE_CUSTOMER*((100-@DISCOUNT_RATE)/100)
			END
		--  수량별 임시테이블생성
			INSERT INTO #TEMP_RATE(CARD_COUNT,DISCOUNT_RATE,SELL_PRICE) VALUES(ISNULL(@CARD_COUNT,0),@DISCOUNT_RATE,@SELL_PRICE)
			
			SET @TEMP_COUNT = @TEMP_COUNT + 1		
	END
-- 계산된 값을 가져온다
		SELECT CARD_COUNT
			,isnull(DISCOUNT_RATE,0) as DISCOUNT_RATE
			,isnull(SELL_PRICE ,0) as SELL_PRICE
		FROM #TEMP_RATE

GO