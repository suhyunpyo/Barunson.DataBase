IF OBJECT_ID (N'dbo.up_insert_to_cart', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_to_cart
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-05
-- Description:	장바구니에 상품 추가
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_to_cart]
		
	@uid			NVARCHAR(16),
	@card_seq		INT,
	@company_seq	INT,	
	@session_id		VARCHAR(10),
	@quantity		INT,
	@discRate		INT,
	@unitPrice		INT,
	@result_code	INT = 0 OUTPUT,
	@result_cnt		INT = 0 OUTPUT
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	DECLARE @ResultCount INT
	
	SELECT @ResultCount = COUNT(CART_SEQ)
	FROM S4_Cart
	WHERE CART_OWNER_ID = @uid
	  AND CARD_SEQ = @card_seq
	
	
	IF @ResultCount > 0		--이미 장바구니에 상품이 존재하는 경우
		
		BEGIN
			SET @result_cnt = 0	
			SET @result_code = 0
			--GOTO PROBLEM
		END
	
	ELSE
		
		BEGIN
		
			INSERT INTO S4_Cart 
			( cart_owner_id, card_seq, company_seq, owner_session_id, card_num, unit_price, discount_rate, reg_date ) 
			VALUES 
			( @uid, @card_seq, @company_seq, @session_id, @quantity, @unitPrice, @discRate, GETDATE() )	
			
			SET @result_cnt = @@ROWCOUNT	--변경된 rowcount
			SET @result_code = @@Error		--에러발생 cnt
			--IF (@result_code <> 0) GOTO PROBLEM
		
		END
		
	/*
	PROBLEM:
	IF (@result_code <> 0) BEGIN
		ROLLBACK TRAN
	END
	*/
	
	RETURN @result_code
	RETURN @result_cnt
	
END


--  select * from S4_Cart
--  delete from S4_Cart

GO
