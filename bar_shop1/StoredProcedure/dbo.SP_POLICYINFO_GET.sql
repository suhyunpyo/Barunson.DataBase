USE [bar_shop1]
GO

DROP PROCEDURE [dbo].[SP_POLICYINFO_GET]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********************************************************
-- SP Name       : SP_POLICYINFO_GET
-- Author        : 변미정
-- Create date   : 2023-08-01
-- Description   : 약관 정보 출력 (최신약관)
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_POLICYINFO_GET]      
     @SalesGubun                     VARCHAR(2)   
    ,@CompanySeq                     INT
    ,@PolicyDiv                      VARCHAR(1)               --P : 개인정보 처리방침    
    ,@Seq                            INT            = NULL
    
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
        IF  ISNULL(@SalesGubun,'') = ''OR  ISNULL(@CompanySeq,0) = 0 OR ISNULL(@PolicyDiv,'') = '' BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        IF ISNULL(@Seq,0) = 0 BEGIN
            -------------------------------------------------------
            -- 현재 적용중인 Policy Seq 추출
            -------------------------------------------------------     
            SELECT TOP 1 @Seq = Seq
            FROM   dbo.PolicyInfo WITH(NOLOCK)
            WHERE  SalesGubun = @SalesGubun
            AND    CompanySeq = @CompanySeq
            AND    PolicyDiv  = @PolicyDiv
            AND    @CurrDate BETWEEN StartDate And EndDate
            ORDER BY Seq DESC

            --존재하지 않는 경우 최신항목 출력
            IF @@ROWCOUNT = 0 BEGIN 
                SELECT TOP 1  @Seq = Seq           
                FROM   dbo.PolicyInfo WITH(NOLOCK)    
                WHERE  SalesGubun = @SalesGubun
                AND    CompanySeq = @CompanySeq
                AND    PolicyDiv  = @PolicyDiv
                AND    @CurrDate BETWEEN StartDate And EndDate
                ORDER BY Seq DESC 
            END
        END

        --에러처리
        IF  ISNULL(@Seq,0) = 0 BEGIN    
            SET @ErrNum = 2305
            SET @ErrMsg = '약관 정보가 없습니다.'            
            RETURN
        END

        --------------------------
        --약관 출력
        --------------------------            
        SELECT Title,                      
               Contents           
        FROM   dbo.PolicyInfo WITH(NOLOCK)    
        WHERE  Seq = @Seq
    
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
		SET @ErrMsg   = 'Policy 정보 조회 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO


