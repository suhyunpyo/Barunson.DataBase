IF OBJECT_ID (N'dbo.up_delete_thankcard_order_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_delete_thankcard_order_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-25
-- Description:	답례장 주문 1단계 정보 수정 시에 기존 data 일괄 삭제 
-- up_delete_thankcard_order_info

-- =============================================
CREATE PROCEDURE [dbo].[up_delete_thankcard_order_info]
	
	@order_seq int,
	@target varchar(1)

AS
BEGIN


	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
		
	IF @target = 'I'	
		BEGIN
			DELETE FROM Custom_Order_Item WHERE order_seq = @order_seq
		END
	
	ELSE
		
		BEGIN
			DELETE FROM Custom_Order_Plist WHERE order_seq = @order_seq
		END


END
GO
