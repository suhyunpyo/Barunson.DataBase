IF OBJECT_ID (N'dbo.up_select_mypage_coupon_cart', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_mypage_coupon_cart
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-11-19
-- Description:	마이페이지 쿠폰 갯수 / 장바구니 갯수
-- TEST : up_select_mypage_coupon_cart 5007, 'palaoh'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_mypage_coupon_cart]
	
	@company_seq	int,				-- 회사고유코드	
	@uid			nvarchar(20)		-- 사용자 ID	
	
AS
BEGIN
	
	
	SELECT MAX(CASE kind WHEN 1 THEN cnt END) AS coupon_cnt, MAX(CASE kind WHEN 2 THEN cnt END) AS cart_cnt
	FROM
	(
		SELECT	COUNT(*) AS cnt
			,		1 AS kind 
		FROM	COUPON_ISSUE 
		WHERE	UID =  @uid 
		AND		COMPANY_SEQ = 5007 
		AND		ACTIVE_YN = 'Y'

		UNION ALL
		
		SELECT COUNT(*) AS cnt, 2 AS kind 
		FROM S4_CART 
		WHERE cart_owner_id = @uid 
		  AND company_seq = @company_seq
	) Result 
	--ORDER BY kind  
	
	
END
GO
