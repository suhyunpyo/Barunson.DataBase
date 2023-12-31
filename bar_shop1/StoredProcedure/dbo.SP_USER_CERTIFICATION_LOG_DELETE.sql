USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_USER_CERTIFICATION_LOG_DELETE]    Script Date: 2023-05-25 오전 10:19:30 ******/
DROP PROCEDURE [dbo].[SP_USER_CERTIFICATION_LOG_DELETE]
GO
/****** Object:  StoredProcedure [dbo].[SP_USER_CERTIFICATION_LOG_DELETE]    Script Date: 2023-05-25 오전 10:19:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_USER_CERTIFICATION_LOG_DELETE
-- Author        : 변미정
-- Create date   : 2023-05-11
-- Description   : 본인인증 정보 삭제
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_USER_CERTIFICATION_LOG_DELETE]          
     @CertID                         VARCHAR(37)                --인증고유 ID (웹에서 db access용으로 사용)        
    
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
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF  ISNULL(@CertID,'') = '' BEGIN    
            SET @ErrNum = 2422
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END       

        -------------------------------------------------------
        -- 트랜잭션 시작
        -------------------------------------------------------     
        BEGIN TRAN                          

        BEGIN TRY
            DELETE FROM USER_CERTIFICATION_LOG 
            WHERE CERTID = @CertID
            IF @@ROWCOUNT <> 1 BEGIN
                ROLLBACK TRAN
                SET @ErrNum = 2434
                SET @ErrMsg = '인증정보 삭제 실패 ' 
                RETURN
            END

        END TRY
        BEGIN CATCH
            ROLLBACK TRAN
            SET @ErrNum = 2436
            SET @ErrMsg = '인증정보 삭제 실패 ' + ERROR_MESSAGE()                        
            RETURN
        END CATCH
        
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
		SET @ErrMsg   = '인증정보 삭제 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO
