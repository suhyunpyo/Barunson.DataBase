IF OBJECT_ID (N'dbo.Up_Select_Orderinfo_ForOrderCountChange', N'P') IS NOT NULL DROP PROCEDURE dbo.Up_Select_Orderinfo_ForOrderCountChange
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-08-03
-- Description:	프론트, 수량변경을 위한, 기존 데이터 조회

-- EXEC Up_Select_Orderinfo_ForOrderCountChange 2191441
-- =============================================
CREATE proc [dbo].[Up_Select_Orderinfo_ForOrderCountChange]

	@order_seq as int

as

	
set nocount on;

declare @up_order_seq int


-- 기본정보
select order_seq,up_order_seq,order_type,order_add_type,order_count,order_name,order_price
     ,order_total_price,last_total_price,option_price,A.card_seq
	 ,A.isinpaper,A.ishandmade,A.isColorPrint,A.isSpecial,jebon_price,embo_price
	 ,guestbook_price,A.isEmbo,envInsert_price,A.isColorInpaper,A.isEnvInsert,A.isLiningJaebon
	 ,fticket_price,sticker_price,mini_price,last_total_price
	 ,A.card_seq, ISNULL(A.print_color,'') as print_color
	 ,B.card_code,B.cardset_price
	 ,case when ISNULL(A.print_color,'') = '' then B.card_image
		   else B.card_code + '/130_' + print_color + '.jpg' end as card_image
	 ,C.isEmbo as card_embo
	 ,C.isEmboColor as card_embocolor,C.isInpaper as card_inpaper,C.isEnvInsert as card_envInsert
	 ,C.ishandmade as card_handmade,C.isJaebon as card_jaebon,D.env_seq
	 ,Env_GroupSeq,Acc1_seq,Acc1_GroupSeq,D.Lining_seq,D.Lining_Groupseq
	 ,isnull(Unit_Count, 50) as Unit_Count
	 ,isnull(Minimum_Count, 100) as Minimum_Count
	 ,inpaper_seq,greetingcard_seq
	 , case when inpaper_seq > 0 then 'I'
	        when greetingcard_seq > 0 then 'G'
			else ''
			end as cont_type
	 ,isDigitalColor,DigitalColor
	 ,C.isEnvSpecial, isnull(C.isLiningJaebon, '0') as liningJaebonType
from custom_order A
inner join S2_Card B 
on A.card_seq = B.card_Seq
inner join S2_CardOption C
on B.Card_Seq = C.Card_Seq
inner join S2_CardDetail D
on B.Card_Seq = D.Card_Seq
where A.order_seq = @order_seq


--추가 주문 정보
select @up_order_seq = up_order_seq 
from custom_order 
where order_seq = @order_seq

select order_count
from custom_order 
where order_seq = @up_order_seq

--주문 항목 정보
select count(*) as cnt
from custom_order_item A 
inner join S2_Card B 
on A.card_seq = B.card_seq
where order_Seq = @order_seq and left(B.card_div,1) in ('A','B') 

select A.card_seq,B.card_div,B.card_code
	,B.card_image,B.card_price
	,A.item_count,A.item_sale_price
	,A.item_type
	,B.card_div,B.cardset_price,addnum_price 
from custom_order_item A 
inner join S2_Card B 
on A.card_seq = B.card_seq
where order_Seq = @order_seq and left(B.card_div,1) in ('A','B') 
order by B.card_div

GO
