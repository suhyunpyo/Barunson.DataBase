IF OBJECT_ID (N'dbo.SP_SAMPLEBOOK_STATUS_UPDATE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SAMPLEBOOK_STATUS_UPDATE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SAMPLEBOOK_STATUS_UPDATE]
	@OrderSeq INT
	, @StatusSeq INT

AS
BEGIN


	
	--해당 주문건에 포함된 품목이 모두 회수완료되면 custom_etc_order.status_seq 회수완료 처리.
	IF @StatusSeq = 15
	BEGIN 
			IF NOT EXISTS (
				SELECT SampleBook_id, SampleBook_Status
				FROM CUSTOM_ETC_ORDER_ITEM 
				WHERE order_Seq = @OrderSeq
					AND ISNULL(SampleBook_Status, 0) < @StatusSeq
			) 
			BEGIN 
				UPDATE custom_etc_order 
				SET status_seq = @StatusSeq
					, Return_Complete_Date = GETDATE() 
				WHERE order_Seq = @OrderSeq
			END
	END 

	
	--해당 주문건에 포함된 품목이 모두 입고완료되면 custom_etc_order.status_seq 입고완료 처리.
	IF @StatusSeq = 16
	BEGIN 
			IF NOT EXISTS (
				SELECT SampleBook_id, SampleBook_Status
				FROM CUSTOM_ETC_ORDER_ITEM 
				WHERE order_Seq = @OrderSeq
					AND ISNULL(SampleBook_Status, 0) < @StatusSeq
			) 
			BEGIN 
				UPDATE custom_etc_order 
				SET status_seq = @StatusSeq
					, Stock_Date = GETDATE() 
				WHERE order_Seq = @OrderSeq
			END
	END 


--Delivery_Status 
--etc_status_seq	0	주문중
--etc_status_seq	1	주문완료
--etc_status_seq	3	주문취소
--etc_status_seq	4	결제완료
--etc_status_seq	5	결제취소
--etc_status_seq	10	제품준비중
--etc_status_seq	12	발송완료

--etc_status_seq	13	회수신청
--etc_status_seq	14	회수진행
--etc_status_seq	15	회수완료
--etc_status_seq	16	입고완료



END


GO
