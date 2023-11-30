IF OBJECT_ID (N'dbo.up_select_delivery_info_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_delivery_info_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		김덕중 수정
-- Create date: 2014-12-22
-- Description:	주문상세내역 - 배송정보 
-- TEST : up_select_delivery_info 주문번호
-- =============================================
CREATE PROCEDURE [dbo].[up_select_delivery_info_new]
	
	@order_seq		int,		--주문번호
	@uid			nvarchar(16)	

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;

	SELECT 
		 DI.name
		,DI.zip
		,DI.addr
		,ISNULL(DI.addr_detail, '') AS addr_detail
		,DI.hphone
		,DI.phone
		,ISNULL(DI.delivery_memo, '') AS delivery_memo
		,DI.delivery_info
		,DI.delivery_com
		,DI.delivery_code_num
	FROM CUSTOM_ORDER CO
		LEFT JOIN DELIVERY_INFO DI
		 ON CO.ORDER_SEQ = DI.ORDER_SEQ	
	WHERE CO.order_seq = @order_seq
	AND   CO.member_id = @uid


END
GO
