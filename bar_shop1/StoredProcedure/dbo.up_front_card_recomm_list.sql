IF OBJECT_ID (N'dbo.up_front_card_recomm_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_card_recomm_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:23    11:58]  JJH: 
	관련페이지 : wedd_det.asp
	내용	   : 해당카테고리에서 많이판매된상품 별 추천
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_front_card_recomm_list]
	@CARD_CATEGORY_SEQ		varchar(10)
,	@CARD_SEQ			int
as
	DECLARE	@ROW_COUNT	int	-- 선택된 상품 수량 (5개 미만일경우 5개로 맞춰준다)
	
	SELECT TOP 5 CD.CARD_SEQ , CD.CARD_IMG_S , RECOM.SELL_COUNT  , CD.CARD_CODE FROM 
 		dbo.card CD , 
		( SELECT TOP 6 CD2.CARD_SEQ , SUM(1) AS SELL_COUNT FROM dbo.card CD2 ,  dbo.custom_order_master COM  WHERE 	CD2.CARD_CATEGORY_SEQ = @CARD_CATEGORY_SEQ
							AND		COM.CARD_SEQ		= CD2.CARD_SEQ
							GROUP BY  CD2.CARD_SEQ 
							ORDER BY SUM(1) DESC
	) RECOM
	WHERE CD.CARD_SEQ = RECOM.CARD_SEQ
	AND	CD.CARD_SEQ != @CARD_SEQ
	AND      CD.DISPLAY_YES_OR_NO =1

GO
