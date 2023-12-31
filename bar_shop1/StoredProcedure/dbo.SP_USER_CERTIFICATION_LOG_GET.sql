USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_USER_CERTIFICATION_LOG_GET]    Script Date: 2023-05-25 오전 10:19:30 ******/
DROP PROCEDURE [dbo].[SP_USER_CERTIFICATION_LOG_GET]
GO
/****** Object:  StoredProcedure [dbo].[SP_USER_CERTIFICATION_LOG_GET]    Script Date: 2023-05-25 오전 10:19:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_USER_CERTIFICATION_LOG_GET
-- Author        : 변미정
-- Create date   : 2023-05-11
-- Description   : 본인인증 정보 조회
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_USER_CERTIFICATION_LOG_GET]          
     @CertID                         VARCHAR(37)                --인증고유 ID (웹에서 db access용으로 사용)        
    
    ,@ErrNum                         INT             OUTPUT
    ,@ErrSev                         INT             OUTPUT
    ,@ErrState                       INT             OUTPUT
    ,@ErrProc                        VARCHAR(50)     OUTPUT
    ,@ErrLine                        INT             OUTPUT
    ,@ErrMsg                         VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON

BEGIN
    BEGIN TRY        

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        SELECT  CERTSEQ
               ,CERTTYPE
               ,CERTID
               ,DUPINFO
               ,CERTDATA        
        FROM    USER_CERTIFICATION_LOG WITH(NOLOCK)
        WHERE   CERTID = @CertID
        AND     REGDATE > DATEADD(day,-1,GETDATE())     --하루가 지나지 않은 건만
        
        SET @ErrNum = 0
        SET @ErrMsg = 'OK'

        RETURN
    
    END TRY
    BEGIN CATCH 

        SET @ErrNum   = ERROR_NUMBER()
		SET @ErrSev   = ERROR_SEVERITY()
		SET @ErrState = ERROR_STATE()
		SET @ErrProc  = ERROR_PROCEDURE()
		SET @ErrLine  = ERROR_LINE()
		SET @ErrMsg   = '인증정보 조회 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO
