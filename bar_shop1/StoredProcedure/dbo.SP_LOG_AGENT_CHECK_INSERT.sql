USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_LOG_AGENT_CHECK_INSERT]    Script Date: 2023-04-24 오후 3:46:22 ******/
DROP PROCEDURE [dbo].[SP_LOG_AGENT_CHECK_INSERT]
GO
/****** Object:  StoredProcedure [dbo].[SP_LOG_AGENT_CHECK_INSERT]    Script Date: 2023-04-24 오후 3:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_LOG_AGENT_CHECK_INSERT
-- Author        : 변미정
-- Create date   : 2023-04-11
-- Description   : Browser Agent정보 등록
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_LOG_AGENT_CHECK_INSERT]          
    @log_agent                      NVARCHAR(400)   = NULL     
    ,@uid                            NVARCHAR(400)   = NULL     
    ,@sales_gubun                    NVARCHAR(10)    = NULL         

    ,@ErrNum                         INT             OUTPUT
    ,@ErrSev                         INT             OUTPUT
    ,@ErrState                       INT             OUTPUT
    ,@ErrProc                        VARCHAR(50)     OUTPUT
    ,@ErrLine                        INT             OUTPUT
    ,@ErrMsg                         VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

BEGIN
    BEGIN TRY        


        -------------------------------------------------------
        -- 트랜잭션 시작
        -------------------------------------------------------     
        BEGIN TRAN 
                     
      
        INSERT INTO LOG_AGENT_CHECK ( LOG_AGENT, [UID], SALES_GUBUN, REG_DATE)
                            VALUES (  @log_agent, @uid, @sales_gubun, GETDATE())
 

        COMMIT TRAN

        SET @ErrNum = 0
        SET @ErrMsg = 'OK'
        RETURN
    
    END TRY
    BEGIN CATCH
        IF ( XACT_STATE() ) <> 0  BEGIN            
            ROLLBACK TRAN
         END

        SET @ErrNum   = ERROR_NUMBER()
		SET @ErrSev   = ERROR_SEVERITY()
		SET @ErrState = ERROR_STATE()
		SET @ErrProc  = ERROR_PROCEDURE()
		SET @ErrLine  = ERROR_LINE()
		SET @ErrMsg   = 'Agent 값 등록 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO
