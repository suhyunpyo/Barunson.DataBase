IF OBJECT_ID (N'dbo.PROC_STORE_ORDER_SEQ_CHK', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_STORE_ORDER_SEQ_CHK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_STORE_ORDER_SEQ_CHK
-- Author        : 박혜림
-- Create date   : 2021-01-13
-- Description   : 바른손스토어 연동 주문번호 확인
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_STORE_ORDER_SEQ_CHK]
      @Uid      INT		-- 바른손스토어 주문 고유번호
-----------------------------------------------------------------------------------------------------------------     
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

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @Order_Seq INT

SET @Order_Seq = 0

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY	
		----------------------------------------------------------------------------------
		-- Order_Seq  조회
		----------------------------------------------------------------------------------
		SELECT @Order_Seq = Order_Seq
		  FROM bar_shop1.dbo.STORE_BARUNSON_ORDER_MATCHING WITH(NOLOCK)
		 WHERE [Uid] = @Uid

		
		SELECT @Order_Seq

	END TRY


	BEGIN CATCH
		SELECT  @ErrNum   = ERROR_NUMBER()
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

EXEC bar_shop1.dbo.PROC_STORE_ORDER_SEQ_CHK 9248, @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
