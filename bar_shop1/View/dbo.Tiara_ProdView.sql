IF OBJECT_ID (N'dbo.Tiara_ProdView', N'V') IS NOT NULL DROP View dbo.Tiara_ProdView
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE      VIEW [dbo].[Tiara_ProdView]  
AS  
  
select A.CARD_SEQ,CARD_CODE,CARD_Name,A.COMPANY,is100,is200,is300,issbaesong,CARD_IMG_MS,ISHAVE,isSelfEdit,ISSAMPLE,ReInputDate,sales_ranking,bestRangking
,isTrendy,isRomantic,isTie,isElegant,isGold,isStylish,isRibon,isButterFly,isHeart,isWinitial,isPress,isPearl,isYu,isSweet,isFlower,isHologram,card_shape,cont_seq
,BEST_YES_OR_NO,NEW_YES_OR_NO,recomend_yes_or_no,online_yes_or_no,display_yes_or_no
,card_price_customer,disrate400 ,card_price_customer as card_sale_price,a.regist_date
from card A inner join card_discount B on A.card_seq = B.card_price and A.disrate_type='I' 
where A.card_Group=3 and card_cate='I1'  and A.card_kind = B.card_kind
union all
select A.CARD_SEQ,CARD_CODE,CARD_Name,A.COMPANY,is100,is200,is300,issbaesong,CARD_IMG_MS,ISHAVE,isSelfEdit,ISSAMPLE,ReInputDate,sales_ranking,bestRangking
,isTrendy,isRomantic,isTie,isElegant,isGold,isStylish,isRibon,isButterFly,isHeart,isWinitial,isPress,isPearl,isYu,isSweet,isFlower,isHologram,card_shape,cont_seq
,BEST_YES_OR_NO,NEW_YES_OR_NO,recomend_yes_or_no,online_yes_or_no,display_yes_or_no
,card_price_customer,disrate400 ,card_price_customer as card_sale_price,a.regist_date
from card A inner join CARD_DISCOUNT B on A.card_price_customer = B.card_price
where A.card_Group=3 and card_cate='I1'  and A.disrate_type='P' and A.company = B.company and A.card_kind = B.card_kind








GO
