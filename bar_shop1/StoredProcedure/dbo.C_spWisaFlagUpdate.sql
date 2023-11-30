IF OBJECT_ID (N'dbo.C_spWisaFlagUpdate', N'P') IS NOT NULL DROP PROCEDURE dbo.C_spWisaFlagUpdate
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[C_spWisaFlagUpdate]
	@Order_seq  INT
AS      
      
SET NOCOUNT ON      
BEGIN 

	--일반주문건
	UPDATE custom_Order SET WisaFlag = 'N' WHERE order_seq = @Order_seq

	--샘플주문건
	UPDATE CUSTOM_SAMPLE_ORDER SET WisaFlag = 'N' WHERE sample_order_seq = @Order_seq

	--부가상품주문건
	UPDATE CUSTOM_ETC_ORDER SET WisaFlag = 'N' WHERE order_seq = @Order_seq

END 

GO
