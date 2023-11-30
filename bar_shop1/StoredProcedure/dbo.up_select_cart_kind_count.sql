IF OBJECT_ID (N'dbo.up_select_cart_kind_count', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_cart_kind_count
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-02
-- Description:	쇼핑캐스트 - 장바구니 상품별 갯수 산출
-- TEST : up_select_cart_kind_count 5007, 'palaoh'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_cart_kind_count]
	
	@company_seq	int,
	@uid			nvarchar(16)	

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;


	--DECLARE @uid varchar(16)='palaoh'
	--DECLARE @company_seq int=5007
	
	
	/*
	청첩장 : A01(1,6,7)
	답례장 : A01(2)
	부가상품 : C08 제외한 C로 시작
	플러스쇼핑(답례품) : C08
	*/
	
	-- 상품별 COUNT --
	
	SELECT SUM(col1) AS 'A', SUM(col2) AS 'B', SUM(col3) AS 'C', SUM(col4) AS 'D' 
	FROM
	(
		SELECT   COUNT(CASE kind WHEN 'A' THEN 'A' END) AS col1
				,COUNT(CASE kind WHEN 'B' THEN 'B' END) AS col2
				,COUNT(CASE kind WHEN 'C' THEN 'C' END) AS col3
				,COUNT(CASE kind WHEN 'D' THEN 'D' END) AS col4
		FROM
		(
			SELECT 
					CASE CardKind_Seq WHEN 1 THEN 'A'
									  WHEN 6 THEN 'A'
									  WHEN 7 THEN 'A'
									  WHEN 2 THEN 'B'
					END AS kind
			FROM
			(
				SELECT   C.card_seq
						,MIN(O.CardKind_Seq) AS CardKind_Seq
				FROM S4_CART C
				INNER JOIN S2_CardKind O ON C.card_seq = O.card_seq
				WHERE C.cart_owner_id = @uid 
				  AND C.company_seq = @company_seq	  
				GROUP BY C.card_seq
			) A
			  
			UNION ALL  

			SELECT   
					CASE O.Card_div WHEN 'C08' THEN 'C'
									ELSE 'D'
					END AS kind
			FROM S4_CART C
			INNER JOIN S2_Card O ON C.card_seq = O.card_seq
			WHERE C.cart_owner_id = @uid 
			  AND C.company_seq = @company_seq
			  AND O.Card_Div LIKE 'C%'
		) Result
		GROUP BY kind
	) A
	
	
	
	
	-- 상품별 TOP 1 --
		-- 청첩장 --
	SELECT	TOP 1 C.card_seq, S.card_code, 'A' AS kind		    
	FROM S4_CART C
	INNER JOIN S2_CardKind O ON C.card_seq = O.card_seq
	INNER JOIN S2_Card S ON C.card_seq = S.card_seq
	WHERE C.cart_owner_id = @uid 
	  AND C.company_seq = @company_seq
	  AND O.CardKind_Seq IN (1, 6, 7)
	
	UNION ALL
		-- 답례장 --
	SELECT	TOP 1 C.card_seq, S.card_code, 'B' AS kind		    
	FROM S4_CART C
	INNER JOIN S2_CardKind O ON C.card_seq = O.card_seq
	INNER JOIN S2_Card S ON C.card_seq = S.card_seq
	WHERE C.cart_owner_id = @uid 
	  AND C.company_seq = @company_seq
	  AND O.CardKind_Seq = 2
	
	UNION ALL
		-- 플러스쇼핑 --
	SELECT  TOP 1 C.card_seq, O.card_code, 'C' AS kind
	FROM S4_CART C
	INNER JOIN S2_Card O ON C.card_seq = O.card_seq
	WHERE C.cart_owner_id = @uid 
	  AND C.company_seq = @company_seq
	  AND O.Card_Div = 'C08'
	
	UNION ALL
		-- 부가상품
	SELECT  TOP 1 C.card_seq, O.card_code, 'D' AS kind
	FROM S4_CART C
	INNER JOIN S2_Card O ON C.card_seq = O.card_seq
	WHERE C.cart_owner_id = @uid 
	  AND C.company_seq = @company_seq
	  AND O.Card_Div LIKE 'C%'
	  AND O.Card_Div <> 'C08'
	  
	ORDER BY kind
	
	
END
GO
