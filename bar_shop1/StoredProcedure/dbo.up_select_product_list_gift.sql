IF OBJECT_ID (N'dbo.up_select_product_list_gift', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_product_list_gift
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
	작성정보   : 김덕중
	관련페이지 : product > product_list_gift.asp
	내용	   : 상품리스트 가져오기
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_product_list_gift]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@brand AS nvarchar(20),		-- 고유브랜드
	@isExtra int,				-- 상단노출여부 (1:상단노출)
	@imagesize_H  int,				-- 이미지 크기(높이)			
	@imagesize_W  int				-- 이미지 크기(넓이)			
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- total count
	select COUNT(a.card_seq) From s2_cardsalessite a with(nolock)
	join s2_card b  with(nolock) on a.card_seq=b.card_seq 
	join s2_carddetailEtc c with(nolock) on a.card_seq=c.card_seq 
	join s2_cardimage d with(nolock) on a.card_seq=d.card_seq 
	Where a.company_seq=@company_seq and a.isdisplay='1' and d.cardimage_wsize=@imagesize_W and d.cardimage_hsize=@imagesize_H 
	and 
	(
	case LEN(@brand)
	when 1 then LEFT(C.card_category,1)
	ELSE C.card_category
	end
	) = @brand

	and d.Company_Seq=@company_seq 
	and
			(
				CASE @isExtra
				WHEN '1' THEN	IsExtra
				ELSE IsDisplay
				END
			) = '1'
			
			
			

	select 
	a.card_seq, a.company_seq, a.isbest, a.isnew, a.IsExtra,
	b.card_code, b.card_name, b.card_price, b.regdate, 
	d.cardimage_filename 
	From s2_cardsalessite a with(nolock)
	join s2_card b  with(nolock) on a.card_seq=b.card_seq 
	join s2_carddetailEtc c with(nolock) on a.card_seq=c.card_seq 
	join s2_cardimage d with(nolock) on a.card_seq=d.card_seq 
	Where a.company_seq=@company_seq and a.isdisplay='1' and d.cardimage_wsize=@imagesize_W and d.cardimage_hsize=@imagesize_H
	and 
	(
	case LEN(@brand)
	when 1 then LEFT(C.card_category,1)
	ELSE C.card_category
	end
	) = @brand

	and d.Company_Seq=@company_seq 
	and
			(
				CASE @isExtra
				WHEN '1' THEN	IsExtra
				ELSE IsDisplay
				END
			) = '1'
	Order By card_name
END
GO
