USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_USER_CERTIFICATION_LOG_INSERT]    Script Date: 2023-05-25 오전 10:19:30 ******/
DROP PROCEDURE [dbo].[SP_USER_CERTIFICATION_LOG_INSERT]
GO
/****** Object:  StoredProcedure [dbo].[SP_USER_CERTIFICATION_LOG_INSERT]    Script Date: 2023-05-25 오전 10:19:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_USER_CERTIFICATION_LOG_INSERT
-- Author        : 변미정
-- Create date   : 2023-05-11
-- Description   : 본인인증 정보 등록
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_USER_CERTIFICATION_LOG_INSERT]          
     @CertType                       VARCHAR(10)                --인증방식 구분 ( CPClient:통합인증, IPIN:아이핀, NONE : 그외 전달용으로 사용시)
    ,@DupInfo                        VARCHAR(64)     = NULL     --개인고유번호
    ,@CertData                       VARCHAR(2048)   = NULL     --암호화된 인증결과 정보(Json형식), @CertType='NONE'인 경우 전달하지 않는다
    
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
        
        DECLARE @CertID        VARCHAR(37)                --인증고유 ID (웹에서 db access용으로 사용)    

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@DupInfo,'') = ''  BEGIN    
            SET @ErrNum = 2422
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END       

        IF @CertType IN ('CPCLIENT','IPIN')  BEGIN
            IF ISNULL(@CertData,'') = ''  BEGIN    
            SET @ErrNum = 2424
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END  
        END

        -------------------------------------------------------
        -- 트랜잭션 시작
        -------------------------------------------------------     
        BEGIN TRAN                   

        SET @CertID = NEWID() --GUID 값으로 셋팅

        BEGIN TRY
            INSERT INTO USER_CERTIFICATION_LOG (CERTTYPE, CERTID, DUPINFO, CERTDATA)
                                        VALUES (@CertType, @CertID, @DupInfo, @CertData)     
        END TRY
        BEGIN CATCH
            ROLLBACK TRAN
            SET @ErrNum = 2436
            SET @ErrMsg = '인증정보 등록 실패 ' + ERROR_MESSAGE()                        
            RETURN
        END CATCH
        
        COMMIT TRAN



        SET @ErrNum = 0
        SET @ErrMsg = 'OK'

        --CertID 출력
        SELECT @CertID AS CertID

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
		SET @ErrMsg   = '인증정보 등록 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO
