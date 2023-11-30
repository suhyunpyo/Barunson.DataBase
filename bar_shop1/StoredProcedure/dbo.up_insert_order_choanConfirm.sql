IF OBJECT_ID (N'dbo.up_insert_order_choanConfirm', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_order_choanConfirm
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-22
-- Description:	초안확인요청  등록
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_order_choanConfirm]
	-- Add the parameters for the stored procedure here
	@order_seq				INT,
	@result_code	int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ARITHABORT ON;

	DECLARE @SALES_GUBUN	AS VARCHAR(100) 
	DECLARE @MSG			AS VARCHAR(4000)    
	DECLARE @TITLE			AS VARCHAR(200)    
	DECLARE @CALL_NUMBER	AS VARCHAR(50)
	DECLARE @HAND_PHONE		AS VARCHAR(100)   	
	DECLARE @MMS_DATE		AS VARCHAR(100)    

	BEGIN TRAN
	
	UPDATE preview SET pstatus=9 WHERE order_seq = @order_seq


	-- 주문상태 변경
	UPDATE custom_order SET src_confirm_date = GETDATE(), src_ap_date=GETDATE(), status_seq=9 WHERE order_seq = @order_seq


	SELECT @SALES_GUBUN = SALES_GUBUN ,@HAND_PHONE = ORDER_HPHONE	FROM CUSTOM_ORDER 	WHERE ORDER_SEQ = @order_seq


	/*
	2019-07-04
	정일순님 요청
	*/

	SET @result_code = @@Error		--에러발생 cnt
	IF (@result_code <> 0) 
		BEGIN
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			COMMIT TRAN
		END 


	RETURN @result_code
END
GO
