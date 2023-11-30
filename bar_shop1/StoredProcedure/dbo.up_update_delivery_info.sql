IF OBJECT_ID (N'dbo.up_update_delivery_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_update_delivery_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-22
-- Description:	주문상세내역 - 배송정보 변경
-- =============================================
CREATE PROCEDURE [dbo].[up_update_delivery_info]
	
	@order_seq		int,		--주문번호
	@order_name		varchar(20),
	@zip			varchar(6),
	@addr			varchar(50),
	@addr_detail	varchar(50),
	@phone			varchar(13),
	@hphone			varchar(13),
	@delivery_info	varchar(50)
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;


	UPDATE DELIVERY_INFO SET
		 name = @order_name
		,zip = @zip
		,addr = @addr
		,addr_detail = @addr_detail
		,phone = @phone
		,hphone = @hphone
		,delivery_info = @delivery_info
	WHERE order_seq = @order_seq
	
	
END
GO
