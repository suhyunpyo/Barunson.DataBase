IF OBJECT_ID (N'dbo.S2_CardViewChasu', N'V') IS NOT NULL DROP View dbo.S2_CardViewChasu
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE        VIEW [dbo].[S2_CardViewChasu]
AS

select A.*,B.print_group,b.print_sizeH,b.isDigital from (
SELECT   '0' as isS2,card_seq, new_code AS card_code, card_code AS old_code,card_code as erp_code, card_div, 
                card_img_s AS card_image, card_price_customer AS card_price, card_name, 
                card_code_str = CASE 
									WHEN new_code = card_code THEN card_code 
									WHEN new_code <> card_code THEN new_code + '(' + card_code + ')' 
								END	
		,IsInPaper = case	
								when cont_seq > 0 then '1'
								when cont_seq = 0 then '0'
								end		
FROM      Card where card_seq in 
		  (
			SELECT card_seq FROM Custom_order
			WHERE status_Seq = 10 and src_closecopy_date is not null
		  ) or CARD_CATE in ('BE','BI')
UNION ALL

SELECT   '1' as isS2,A.card_Seq,new_code as card_code,Card_Code as old_code,card_erpcode as erp_code, card_div, card_image,  
card_price = CASE WHEN card_div='A01' THEN cardset_price else card_price end,  card_name, 
                card_code_str = CASE WHEN new_code = card_code THEN card_code 
	WHEN new_code <> card_code THEN new_code + '(' + card_code + ')' END
		,IsInPaper = case	
								when inpaper_seq > 0 then '1'
								when inpaper_seq = 0 then '0'
								end		
FROM      S2_Card A left outer join S2_CardDetail B on A.Card_Seq = B.card_seq
) a join card_printinfo b on a.card_code = b.card_code


GO
