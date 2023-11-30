IF OBJECT_ID (N'dbo.PROC_STORE_ORDER_MOD', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_STORE_ORDER_MOD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_STORE_ORDER_MOD
-- Author        : 박혜림
-- Create date   : 2021-01-14
-- Description   : 바른손스토어 주문정보 업데이트
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_STORE_ORDER_MOD]
      @Type          VARCHAR(20)	-- 구분(PAY:입금완료, CANCEL:주문취소, PREPARE:제품준비중, DELIVERY:발송완료)
	, @Order_Seq     INT			-- 주문번호
	, @Status_Seq    INT			-- 주문상태(주문취소:3, 결제취소/환불:5, 제품준비중:10, 발송완료:12)
	, @Delivery_Com  VARCHAR(2)		-- 택배사(대한통운:CJ, 우체국:PO, 한진:HJ, 로젠:LG, 롯데:LT, 퀵:QC, 경동택배/기타:공백)
	, @Delivery_Code VARCHAR(50)	-- 송장번호
-----------------------------------------------------------------------------------------------------------------------      
    , @ErrNum   INT           OUTPUT
    , @ErrSev   INT           OUTPUT
    , @ErrState INT           OUTPUT
    , @ErrProc  VARCHAR(50)   OUTPUT
    , @ErrLine  INT           OUTPUT
    , @ErrMsg   VARCHAR(2000) OUTPUT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

-----------------------------------------------------------------------------------------------------------------------
-- Declare Block
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			----------------------------------------------------------------------------------
			-- 주문취소
			----------------------------------------------------------------------------------
			IF @Type = 'CANCEL'
			BEGIN
				UPDATE bar_shop1.dbo.CUSTOM_ETC_ORDER
				   SET status_seq = @Status_Seq
				     , settle_Cancel_Date = GETDATE()
					 , prepare_date  = NULL
				 WHERE order_seq = @Order_Seq
			END

			----------------------------------------------------------------------------------
			-- 환불(적용안함)
			----------------------------------------------------------------------------------
			--IF @Type = 'REFUND'
			--BEGIN
			--	UPDATE bar_shop1.dbo.CUSTOM_ETC_ORDER
			--	   SET status_seq = @Status_Seq
			--	     , settle_Cancel_Date = GETDATE()
			--	 WHERE order_seq = @Order_Seq
			--END

			----------------------------------------------------------------------------------
			-- 입금확인
			----------------------------------------------------------------------------------
			IF @Type = 'PAY'
			BEGIN
				UPDATE bar_shop1.dbo.CUSTOM_ETC_ORDER
				   SET status_seq = @Status_Seq
				     , settle_date = GETDATE()
				 WHERE order_seq = @Order_Seq
			END

			----------------------------------------------------------------------------------
			-- 제품준비중
			----------------------------------------------------------------------------------
			IF @Type = 'PREPARE'
			BEGIN
				UPDATE bar_shop1.dbo.CUSTOM_ETC_ORDER
				   SET status_seq = @Status_Seq
				     , prepare_date = GETDATE()
				 WHERE order_seq = @Order_Seq
			END

			----------------------------------------------------------------------------------
			-- 발송완료
			----------------------------------------------------------------------------------
			IF @Type = 'DELIVERY'
			BEGIN
				UPDATE bar_shop1.dbo.CUSTOM_ETC_ORDER
				   SET status_seq = @Status_Seq
				     , delivery_com = @Delivery_Com
					 , delivery_code = @Delivery_Code
				     , delivery_date = GETDATE()
				 WHERE order_seq = @Order_Seq
			END

			----------------------------------------------------------------------------------
			-- 매칭 테이블 최근 매칭일 업데이트
			----------------------------------------------------------------------------------
			UPDATE bar_shop1.dbo.STORE_BARUNSON_ORDER_MATCHING
			   SET Last_Matching_Date = GETDATE()
			 WHERE Order_Seq = @Order_Seq

			
		COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		BEGIN
			ROLLBACK TRAN
        END	

		SELECT @ErrNum   = ERROR_NUMBER()
		     , @ErrSev   = ERROR_SEVERITY()
			 , @ErrState = ERROR_STATE()
			 , @ErrProc  = ERROR_PROCEDURE()
			 , @ErrLine  = ERROR_LINE()
			 , @ErrMsg   = ERROR_MESSAGE();

	END CATCH

END

-- Execute Sample
/*

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)

EXEC bar_shop1.dbo.PROC_STORE_ORDER_MOD
       'CANCEL'
	 , 3202958
	 , 5
	 , ''
	 , ''
	 , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
