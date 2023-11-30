IF OBJECT_ID (N'dbo.bbarunson_OrdPInfo', N'P') IS NOT NULL DROP PROCEDURE dbo.bbarunson_OrdPInfo
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
 작성정보   :   [2007.1.11] 김수경:   
 내용    :      인쇄-배송정보에서 한 주문에 대한 인쇄판 정보 가져오기
   
 수정정보   :   
*/  
CREATE Procedure [dbo].[bbarunson_OrdPInfo]
	@order_seq		INT
as
begin

SELECT A.id,A.card_name,A.card_count,C.card_code,B.preview_type,B.print_date 
FROM CUSTOM_ORDER_CARD_LST A left outer join PREVIEW B on A.id = B.sid,CARD C 
 where B.card_seq = C.card_seq and A.order_seq = @order_seq union all 
SELECT A.id,A.env_name as card_name,A.env_count as card_count,C.card_code,B.preview_type,B.print_date 
FROM CUSTOM_ORDER_ENV_LST A left outer join PREVIEW B on A.id = B.sid,CARD C 
 where B.card_seq = C.card_seq and A.order_seq = @order_seq
end
GO
