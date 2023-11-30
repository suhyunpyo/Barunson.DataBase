IF OBJECT_ID (N'dbo.up_Update_Custom_Order_Group_For_Settle_TheCard', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Update_Custom_Order_Group_For_Settle_TheCard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		박동혁
-- Create date: 2015-06-08
-- Description:	더카드 무통장입금 결제 결과 처리
--
/*
	exec up_Update_Custom_Order_Group_For_Settle_TheCard 'IT1022122', 119000

	UPDATE custom_order_group SET settle_date = '2015-07-14 09:15:35' WHERE order_g_seq = 1022122
	UPDATE custom_order SET settle_date = '2015-07-14 09:15:35' WHERE order_g_seq = 1022122
	UPDATE custom_etc_order SET settle_date = '2015-07-14 09:15:35' WHERE order_g_seq = 1022122
*/
-- =============================================
CREATE PROCEDURE [dbo].[up_Update_Custom_Order_Group_For_Settle_TheCard]
(  
	  @LGD_OID VARCHAR(50)
	, @LGD_AMOUNT INT
)  
AS
BEGIN
	
	BEGIN TRAN;
	
		UPDATE Custom_Order_Group
		SET Settle_Status = 2
			, Settle_Date = GETDATE()
			, SRC_AP_Date = GETDATE()
			, Settle_Price = @LGD_AMOUNT
		WHERE PG_TID = @LGD_OID;

		DECLARE @Order_G_Seq INT;

		IF (LEFT(@LGD_OID, 2) = 'IS')
			BEGIN

				SELECT @Order_G_Seq = Order_G_Seq
				FROM Custom_Sample_Order WITH(NOLOCK) 
				WHERE PG_TID = @LGD_OID;

			END
		ELSE
			BEGIN

				SELECT @Order_G_Seq = Order_G_Seq
				FROM Custom_Order_Group WITH(NOLOCK) 
				WHERE PG_TID = @LGD_OID;

			END

		IF ISNULL(@Order_G_Seq, '') <> ''
			BEGIN

				UPDATE Custom_Sample_Order 
				SET Status_Seq = 4
					, Settle_Date = GETDATE() 
					, Settle_Price = @LGD_AMOUNT 
				WHERE Order_G_Seq = @Order_G_Seq;

				UPDATE Custom_ETC_Order 
				SET Status_Seq = 4
					, Settle_Date = GETDATE()
					, Settle_Price = @LGD_AMOUNT 
				WHERE Order_G_Seq = @Order_G_Seq;

				UPDATE Custom_Order
				SET Settle_Status = 2
					, Settle_Date = GETDATE()
					, SRC_AP_Date = GETDATE()
					, Settle_Price = Last_Total_Price 
					--, Settle_Price = CASE 
					--					WHEN (Last_Total_Price + Reduce_Price) < 0 THEN 0 
					--					ELSE (Last_total_price + Reduce_Price)
					--				 END
				WHERE Order_G_Seq =  @Order_G_Seq;

			END
		ELSE
			BEGIN

				PRINT 'PG 결제 정보 업데이트 중 오류 발생 - @Order_G_Seq 값이 없음';
				ROLLBACK TRAN;			

			END



	IF @@ERROR <> 0
		BEGIN

			PRINT 'PG 결제 정보 업데이트 중 오류 발생!';
			ROLLBACK TRAN;

		END
	ELSE
		BEGIN

			COMMIT TRAN;

		END

END

GO
