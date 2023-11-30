IF OBJECT_ID (N'dbo.up_select_delivery_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_delivery_info
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
CREATE PROCEDURE [dbo].[up_select_delivery_info]
	
	@order_seq		int		--주문번호

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;


	SELECT   name
			,zip
			,addr
			,ISNULL(addr_detail, '') AS addr_detail
			,hphone
			,phone
			,ISNULL(delivery_memo, '') AS delivery_memo
			,delivery_info
			,delivery_com
			,delivery_code_num
			,ID
	FROM DELIVERY_INFO
	WHERE order_seq = @order_seq


END
GO
