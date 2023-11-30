IF OBJECT_ID (N'dbo.up_select_shoppingcast_count', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_shoppingcast_count
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-02
-- Description:	쇼핑캐스트 종류별 갯수 산출 
-- TEST : up_select_shoppingcast_count 5007, 'palaoh'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_shoppingcast_count]
	
	@company_seq	int,				-- 회사고유코드	
	@uid			nvarchar(20)		-- 사용자 ID	
	
AS
BEGIN
	
	
	SELECT   MAX(CASE kind WHEN 1 THEN cnt END) AS coupon_cnt
			,MAX(CASE kind WHEN 2 THEN cnt END) AS cart_cnt
			,MAX(CASE kind WHEN 3 THEN cnt END) AS zzim_cnt
			,MAX(CASE kind WHEN 4 THEN cnt END) AS sample_cnt
	FROM
	(
		-- 쿠폰 --
		SELECT	COUNT(*) AS cnt
			,		1 AS kind 
		FROM	COUPON_ISSUE 
		WHERE	UID =  @uid 
		AND		COMPANY_SEQ = 5007 
		AND		ACTIVE_YN = 'Y'
		  
		UNION ALL
		
		-- 장바구니 --
		SELECT COUNT(*) AS cnt, 2 AS kind 
		FROM S4_CART 
		WHERE cart_owner_id = @uid 
		  AND company_seq = @company_seq
		  
		UNION ALL
		
		-- 찜 --
		SELECT  COUNT(*) AS cnt, 3 AS kind
		FROM S2_WishCard WC
		INNER JOIN S2_Card SC ON WC.card_seq = SC.Card_Seq
		INNER JOIN (
						SELECT card_seq, MIN(CardKind_Seq) AS cardkind_seq
						FROM S2_CardKind
						GROUP BY card_seq
					) SCK ON WC.card_seq = SCK.Card_Seq
		INNER JOIN S2_CardSalesSite C ON WC.Card_Seq = C.Card_Seq
		INNER JOIN S2_CardDiscount D ON C.CardDiscount_Seq = D.CardDiscount_Seq
		WHERE 1 = 1
		  AND WC.uid = @uid	  
		  AND D.MinCount <= 400 
		  AND D.MaxCount >= 400
		  AND C.Company_Seq = @Company_Seq
		  
	
		UNION ALL
		
		-- 샘플 --
		SELECT  COUNT(*) AS cnt, 4 AS kind 
		FROM S2_SampleBasket A 
		INNER JOIN S2_CardSalesSite B ON A.card_Seq = B.card_Seq 
		INNER JOIN S2_Card C ON A.card_seq = C.card_seq 
		INNER JOIN S2_cardOption D ON A.card_Seq = D.card_seq
		INNER JOIN (
						SELECT card_seq, MIN(CardKind_Seq) AS cardkind_seq
						FROM S2_CardKind
						GROUP BY card_seq
					) SCK ON A.card_seq = SCK.Card_Seq 
		WHERE A.uid = @uid 	  
		  AND B.Company_Seq = @company_seq
		  AND B.isDisplay = 1 
		  AND D.isSample = 1 		
		  
	) Result 
	
	
END
GO
