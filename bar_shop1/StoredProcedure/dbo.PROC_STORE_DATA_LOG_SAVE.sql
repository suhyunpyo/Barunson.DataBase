IF OBJECT_ID (N'dbo.PROC_STORE_DATA_LOG_SAVE', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_STORE_DATA_LOG_SAVE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_STORE_DATA_LOG_SAVE
-- Author        : 박혜림
-- Create date   : 2021-01-11
-- Description   : 바른손스토어 전송데이터 로그 저장
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_STORE_DATA_LOG_SAVE]
      @Type       VARCHAR(20)	--구분(ORDER:주문완료, PAY:입금완료, CANCEL:주문취소,  PREPARE:제품준비중, DELEVERY:발송완료)
	, @Uid        INT			--바른손스토어 주문 고유번호
	, @Member_ID  VARCHAR(50)	--ID
	, @Status_Seq INT			--주문상태(1:주문발생, 4:결제완료, 3:주문취소, 5:결제취소, 10:제품준비중, 12:발송완료)
	, @Memo       VARCHAR(100)	--메모
	, @RefererURL VARCHAR(200)	--호출한 웹사이트 주소
	, @IP         VARCHAR(20)	--접속 IP
	, @User_Agent VARCHAR(500)	--접속 브라우저/단말기 정보
	, @Auto_Yn    VARCHAR(1)	--자동여부(Y:자동, N:수동)
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

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			----------------------------------------------------------------------------------
			-- 주문데이터 로그 저장
			----------------------------------------------------------------------------------
			INSERT INTO bar_shop1.dbo.STORE_ORDER_DATE_SEND_LOG
					( [Type]
					, [Uid]
					, Member_ID	
					, Status_Seq	
					, Memo
					, RefererURL		
					, [IP]
					, User_Agent
					, Auto_Yn
					, Reg_Date
					)
			VALUES
					( @Type
					, @Uid		
					, @Member_ID		
					, @Status_Seq		
					, @Memo	
					, @RefererURL		
					, @IP
					, @User_Agent
					, @Auto_Yn
					, GETDATE()
				)
			
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

EXEC bar_shop1.dbo.PROC_STORE_DATA_LOG_SAVE 'ORDER', 9213, 'phrim8611', 1, '', 'https://www.barunsonstore.com/', '123.1234.1234', 'N', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
