IF OBJECT_ID (N'dbo.proc_DelCustomOrder', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_DelCustomOrder
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


create  Procedure [dbo].[proc_DelCustomOrder]
@oid int
as
begin


/*
update custom_order set src_CloseCopy_date  = null	
	, src_compose_date = null
	, src_confirm_date = null
	, src_printW_date = null
where order_seq = '주문번호'
*/

delete from [dbo].[DELIVERY_INFO_DELCODE] where order_seq = @oid
delete from [dbo].[DELIVERY_INFO_DETAIL] where order_seq = @oid
delete from [dbo].[DELIVERY_INFO] where order_seq = @oid

delete from [dbo].[custom_order_item] where order_seq = @oid

delete from [dbo].[custom_order_plist] where order_seq = @oid
delete from  [dbo].[custom_order_weddinfo] where order_seq = @oid
delete from  [dbo].[preview] where order_seq = @oid
delete from  [dbo].[preview_notice] where order_seq = @oid
delete from  [dbo].[preview_opinion] where preview_seq in (select preview_seq from [dbo].[preview] where order_seq = @oid)

delete from [dbo].[custom_order_history] where order_seq = @oid
delete from [dbo].[custom_order_admin_ment] where order_seq = @oid

delete from [dbo].[custom_order_cprice] where order_seq = @oid
delete from [dbo].[CUSTOM_ORDER_COPY] where order_seq = @oid
delete from [dbo].[CUSTOM_ORDER_COPY_DETAIL] where order_seq = @oid

delete from [dbo].[CUSTOM_ORDER_COUPON] where order_seq = @oid


END

GO
