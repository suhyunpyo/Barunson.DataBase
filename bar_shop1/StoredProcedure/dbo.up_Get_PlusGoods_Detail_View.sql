IF OBJECT_ID (N'dbo.up_Get_PlusGoods_Detail_View', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Get_PlusGoods_Detail_View
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-16
-- Description:	플러스쇼핑제품 상세 정보
-- =============================================
CREATE PROCEDURE [dbo].[up_Get_PlusGoods_Detail_View]
	-- Add the parameters for the stored procedure here
	-- 제품 상세 정보 --
	@card_seq INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	
	SELECT 
		 A.cardbrand			--0
		,A.card_div				--1
		,A.card_code			--2
		,A.card_name			--3
		,ISNULL(A.cardset_price, 0)	cardset_price	--4	
		,ISNULL(A.card_price, 0) card_price			--5
		,ISNULL(B.card_sale_price, 0) card_sale_price	--6
		,B.composition			--7
		,B.summary				--8
		,B.origin				--9
		,ISNULL(B.min_onum, 1) min_onum				--10
		,B.option_str1			--11
		,B.option_str2			--12
		,B.option_str3			--13	
		,B.option_str4			--14	
		,B.option_str5			--15	
		,B.card_content			--16	
		,ISNULL(B.isDisplay, 0) isDisplay		--17	
		,B.card_category			--18	
		,ISNULL(B.delivery_price,0)	delivery_price		--19
		,ISNULL(B.brand_story,'') brand_story 				--20
		,ISNULL(B.delivery_policy,'') delivery_policy			--21
		,ISNULL(B.refund_policy,'') refund_policy			--22
		,ISNULL(B.free_delivery_price,0)	free_delivery_price		--19
	FROM 
		s2_card A
		INNER JOIN s2_carddetailEtc B ON A.card_seq = B.card_seq 
	WHERE 
		A.card_seq = @card_seq 
END
GO
