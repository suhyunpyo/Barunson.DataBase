IF OBJECT_ID (N'dbo.PROC_EVENT_APPLY_CHK', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_EVENT_APPLY_CHK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_EVENT_APPLY_CHK
-- Author        : 박혜림
-- Create date   : 2022-05-18
-- Description   : 이벤트 응모여부 체크
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_EVENT_APPLY_CHK]
      @EVENT_GUBUN  VARCHAR(30)	-- 이벤트 구분
	, @MEMBER_ID    VARCHAR(50)	-- 아이디
	, @SALES_GUBUN  VARCHAR(10)	-- 사이트 구분
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
DECLARE @EVENT_CNT INT
      , @APPLY_YN  VARCHAR(1)

SET @APPLY_YN = 'N'

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY	
		----------------------------------------------------------------------------------
		-- 이벤트 응모여부 체크(사이트 구분 안함)
		----------------------------------------------------------------------------------
		SELECT @EVENT_CNT = COUNT(*)
		  FROM bar_shop1.dbo.EVENT_ENTER_MEMBER WITH(NOLOCK)
		 WHERE EVENT_GUBUN = @EVENT_GUBUN
		   AND MEMBER_ID   = @MEMBER_ID
		
		----------------------------------------------------------------------------------
		-- 이벤트 응모한 경우
		----------------------------------------------------------------------------------
		IF @EVENT_CNT > 0
		BEGIN
			SET @APPLY_YN = 'Y'
		END

		SELECT @APPLY_YN AS APPLY_YN


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

EXEC bar_shop1.dbo.PROC_EVENT_APPLY_CHK 'fairtradekorea', 's4guest', 'SB', '', '', '', '', '', ''

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
