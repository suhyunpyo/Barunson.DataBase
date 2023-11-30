IF OBJECT_ID (N'dbo.sp_ModOrderID', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ModOrderID
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- 주문번호 변경 처리 쿼리
-----------------------------------------------------------------
CREATE    procedure [dbo].[sp_ModOrderID]
@new_order_seq int,
@order_seq int
as
begin
--- 청첩장
update custom_order_admin_ment set order_seq = @new_order_seq where order_Seq = @order_seq
update custom_order_plist set order_seq = @new_order_seq where order_Seq = @order_seq
update custom_order_weddInfo set order_seq = @new_order_seq where order_Seq = @order_seq
update delivery_info set order_seq = @new_order_seq where order_Seq = @order_seq
update delivery_info_detail set order_seq = @new_order_seq where order_Seq = @order_seq
update custom_order_item set order_seq = @new_order_seq where order_Seq = @order_seq
update cshopadm.preview_opinion set order_seq = @new_order_seq where order_Seq = @order_seq
update custom_order_cprice set order_seq = @new_order_seq where order_Seq = @order_seq
update custom_order_chasu set order_seq = @new_order_seq where order_Seq = @order_seq
update custom_order set weddinfo_id = @new_order_seq,pg_tid=cast(@new_order_seq as varchar(50)) where order_Seq = @order_seq

update custom_order set order_seq = @new_order_seq where order_seq = @order_seq

end
GO
