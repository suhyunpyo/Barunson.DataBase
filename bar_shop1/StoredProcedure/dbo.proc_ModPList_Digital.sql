IF OBJECT_ID (N'dbo.proc_ModPList_Digital', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_ModPList_Digital
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : proc_ModPList_Digital
-- Author        : 박혜림
-- Create date   : 2022-07-27
-- Description   : 디지털카드 인쇄판 수량변경
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[proc_ModPList_Digital]
      @TYPE         CHAR(1)		-- 구분(M:수정, D:삭제)
	, @PID          BIGINT
	, @ORDER_SEQ    INT
	, @PCOUNT       INT
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
DECLARE @TITLE VARCHAR(50)
      , @TITLE_FRONT VARCHAR(50)

SET @TITLE = ''
SET @TITLE_FRONT = ''

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			SELECT @TITLE = title
			  FROM bar_shop1.dbo.custom_order_plist
			 WHERE order_seq = @ORDER_SEQ
			   AND id = @PID


			IF @TITLE = '카드기본인쇄'
				SET @TITLE_FRONT = @TITLE + ' 겉면'
			ELSE IF @TITLE = '카드내지인쇄'
				SET @TITLE_FRONT = @TITLE + ' 뒷면'
			ELSE
				SET @TITLE_FRONT = @TITLE + ' 겉면'
			

			IF @TYPE = 'M'
			BEGIN

				UPDATE bar_shop1.dbo.custom_order_plist
				   SET print_count = @PCOUNT
				 WHERE order_seq = @ORDER_SEQ
				   AND id = @PID

				UPDATE bar_shop1.dbo.custom_order_plist
				   SET print_count = @PCOUNT
				 WHERE order_seq = @ORDER_SEQ
				   AND title = @TITLE_FRONT

			END
			ELSE
			BEGIN

				DELETE FROM bar_shop1.dbo.custom_order_plist
				 WHERE order_seq = @ORDER_SEQ
				   AND id = @PID 

				DELETE FROM bar_shop1.dbo.custom_order_plist
				 WHERE order_seq = @ORDER_SEQ
				   AND title = @TITLE_FRONT

			END
			
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

EXEC bar_shop1.dbo.proc_ModPList_Digital
       'M'
	 , 11982079
	 , 4172896
	 , 100
	 , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
