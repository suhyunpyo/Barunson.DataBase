IF OBJECT_ID (N'dbo.PROC_COUPON_DETAIL_BARUNSONMALL', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_COUPON_DETAIL_BARUNSONMALL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_COUPON_DETAIL_BARUNSONMALL
-- Author        : 박혜림
-- Create date   : 2023-07-04
-- Description   : 쿠폰 상세(바른손몰)
-- Update History:
-- Comment       : 웹/모바일 공통
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_COUPON_DETAIL_BARUNSONMALL]
       @Coupon_Code            VARCHAR(50)
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

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN

	BEGIN TRY

		----------------------------------------------------------------------------------
		-- 쿠폰 상세 조회
		----------------------------------------------------------------------------------
		SELECT Coupon_Code
		      ,CONVERT(VARCHAR, ISNULL(End_date, '2059-12-31 23:59:59'), 23) AS End_date
		      ,REPLACE(CONVERT(VARCHAR, ISNULL(End_date, '2059-12-31 23:59:59'), 23), '-', '.') AS Convert_End_date
		  FROM s4_coupon WITH(NOLOCK)
		 WHERE coupon_code = @Coupon_Code

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

EXEC bar_shop1.dbo.PROC_COUPON_DETAIL_BARUNSONMALL
     'PLUSSALE5000'
   , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/ 
GO
