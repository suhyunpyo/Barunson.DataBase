IF OBJECT_ID (N'dbo.PROC_EVENT_APPLY', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_EVENT_APPLY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_EVENT_APPLY
-- Author        : 박혜림
-- Create date   : 2022-05-18
-- Description   : 이벤트 응모
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_EVENT_APPLY]
      @EVENT_GUBUN  VARCHAR(30)	-- 이벤트 구분
	, @MEMBER_ID    VARCHAR(50)	-- 아이디
	, @SALES_GUBUN  VARCHAR(10)	-- 사이트 구분
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
DECLARE @EVENT_SEQ INT

SET @EVENT_SEQ = 0 

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			INSERT INTO bar_shop1.dbo.EVENT_ENTER_MEMBER
					    ( EVENT_GUBUN		
						, MEMBER_ID		
						, SALES_GUBUN
						)
				 VALUES ( @EVENT_GUBUN
						, @MEMBER_ID
						, @SALES_GUBUN
						)

			----------------------------------------------------------------------------------
			-- 응모여부 확인(사이트 구분 안함)
			----------------------------------------------------------------------------------
			SELECT @EVENT_SEQ = SEQ
			  FROM bar_shop1.dbo.EVENT_ENTER_MEMBER WITH(NOLOCK)
			 WHERE EVENT_GUBUN = @EVENT_GUBUN
		       AND MEMBER_ID   = @MEMBER_ID

			SELECT @EVENT_SEQ
			
		COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		 BEGIN
		     ROLLBACK TRAN
        END	

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

EXEC bar_shop1.dbo.PROC_EVENT_APPLY
	   'fairtradekorea'				
	 , 'gpflawkd2'						
     , 'SB'
	 , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
