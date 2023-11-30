IF OBJECT_ID (N'dbo.bbarunson_OrdPInfo0', N'P') IS NOT NULL DROP PROCEDURE dbo.bbarunson_OrdPInfo0
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
 작성정보   :   [2007.1.17] 김수경:   
 내용    :      인쇄-배송정보에서 한 주문에 대한 인쇄판 정보 가져오기
   
 수정정보   :   
*/  
Create  Procedure [dbo].[bbarunson_OrdPInfo0]
	@order_seq		INT
as
begin

SELECT A.id,A.card_name,A.card_count,B.card_code
FROM CUSTOM_ORDER_CARD_LST A inner join CARD B on A.card_seq = B.card_seq
 where A.order_seq = @order_seq union all 
SELECT id,env_name as card_name,env_count as card_count,'' as card_code
FROM CUSTOM_ORDER_ENV_LST  
 where order_seq = @order_seq
end





GO
