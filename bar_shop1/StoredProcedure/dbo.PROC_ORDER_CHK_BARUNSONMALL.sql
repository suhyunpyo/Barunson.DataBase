IF OBJECT_ID (N'dbo.PROC_ORDER_CHK_BARUNSONMALL', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_ORDER_CHK_BARUNSONMALL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_ORDER_CHK_BARUNSONMALL
-- Author        : 박혜림
-- Create date   : 2022-01-11
-- Description   : 바른손몰 > 주문여부 체크
-- Update History:
-- Comment       : 웹/모바일 공통
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_ORDER_CHK_BARUNSONMALL]
	   @Company_Login_ID   VARCHAR(20)
	 , @UID                VARCHAR(50)
	-----------------------------------------------------------------------------
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
DECLARE @Sample_Order_Cnt INT
      , @Card_Order_Cnt   INT
	  , @OrderYN          CHAR(1)

SET @Sample_Order_Cnt = 0
SET @Card_Order_Cnt = 0
SET @OrderYN = 'N'

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN

	BEGIN TRY

		----------------------------------------------------------------------------------
		-- 샘플 주문 체크
		----------------------------------------------------------------------------------
		SELECT @Sample_Order_Cnt = COUNT(sample_order_seq)
		  FROM CUSTOM_SAMPLE_ORDER
		 WHERE member_id = @UID
		   AND status_seq >= 4
		   AND company_seq IN ( SELECT company_seq
		                          FROM COMPANY
								 WHERE Login_ID = @Company_Login_ID
								   AND SALES_GUBUN IN ('B','C','H')
								   AND [STATUS] = 'S2')

		----------------------------------------------------------------------------------
		-- 청첩장/감사장 주문 체크
		----------------------------------------------------------------------------------
		SELECT @Card_Order_Cnt = COUNT(order_seq)
		  FROM CUSTOM_ORDER
		 WHERE member_id = @UID
		   AND status_seq >= 0
		   AND company_seq IN ( SELECT company_seq
		                          FROM COMPANY
								 WHERE Login_ID = @Company_Login_ID
								   AND SALES_GUBUN IN ('B','C','H')
								   AND [STATUS] = 'S2')


		IF @Sample_Order_Cnt > 0 OR @Card_Order_Cnt > 0
		BEGIN
			SET @OrderYN = 'Y'
		END


		SELECT @OrderYN AS OrderYN


	END TRY

	BEGIN CATCH

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

EXEC bar_shop1.dbo.PROC_ORDER_CHK_BARUNSONMALL
    'arina'
   , 's4guest'
   , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/ 
GO
