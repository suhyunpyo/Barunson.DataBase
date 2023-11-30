IF OBJECT_ID (N'dbo.up_select_env_charge_option', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_env_charge_option
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-30
-- Description:	마이페이지 주문상세내역 봉투 유료옵션 정보
-- TEST : up_select_env_charge_option 1970755
-- =============================================
CREATE PROCEDURE [dbo].[up_select_env_charge_option]
	
	@order_seq		int	

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	

	SELECT   A.id				--0
			,A.item_type		--1	
			,B.card_div			--2
			,B.card_code		--3
			,B.card_price		--4
			,A.item_sale_price	--5
			,A.item_count		--6
			,A.addnum_price		--7
			,B.card_image		--8
			,B.card_name		--9			
	FROM Custom_Order_Item A 
	INNER JOIN S2_Card B ON A.card_seq = B.card_seq 
	WHERE order_seq = @order_seq 
	  AND B.card_div LIKE 'B%'
	  AND A.item_sale_price >= 0	  
  
  
END

GO
