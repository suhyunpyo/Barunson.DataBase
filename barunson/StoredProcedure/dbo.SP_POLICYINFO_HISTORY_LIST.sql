USE [barunson]
GO

/****** Object:  StoredProcedure [dbo].[SP_POLICYINFO_HISTORY_LIST]    Script Date: 2023-08-23 오전 10:11:16 ******/
DROP PROCEDURE [dbo].[SP_POLICYINFO_HISTORY_LIST]
GO

/****** Object:  StoredProcedure [dbo].[SP_POLICYINFO_HISTORY_LIST]    Script Date: 2023-08-23 오전 10:11:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********************************************************
-- SP Name       : SP_POLICYINFO_HISTORY_LIST
-- Author        : 변미정
-- Create date   : 2023-08-21
-- Description   : 약관 정보 출력 (최신약관)
-- Update History:
-- Comment       : bar_shop1과 SP명 및 파라메터 동일하게 유지 (통합회원에서 사용)
**********************************************************/
CREATE PROCEDURE [dbo].[SP_POLICYINFO_HISTORY_LIST]      
     @SalesGubun                     VARCHAR(2) = NULL  
    ,@CompanySeq                     INT        = NULL
    ,@PolicyDiv                      VARCHAR(1)    
    
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
        
        DECLARE @CurrDate VARCHAR(10)

        SET @CurrDate = CONVERT(VARCHAR(10),GETDATE(),121)
        
        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF  ISNULL(@PolicyDiv,'') = '' BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        
        -------------------------------------------------------
        -- 이전 약관 리스트 출력
        -------------------------------------------------------     
        SELECT Seq
              ,StartDate
              ,EndDate
              ,Title
        FROM   dbo.TB_PolicyInfo WITH(NOLOCK)
        WHERE  PolicyDiv  = @PolicyDiv
        AND    EndDate < @CurrDate
        ORDER BY Seq DESC
              
    
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
		SET @ErrMsg   = 'Policy History 정보 조회 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO


