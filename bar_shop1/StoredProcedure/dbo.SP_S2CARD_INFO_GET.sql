USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_S2CARD_INFO_GET]    Script Date: 2023-11-13 오전 8:38:19 ******/
DROP PROCEDURE [dbo].[SP_S2CARD_INFO_GET]
GO

/****** Object:  StoredProcedure [dbo].[SP_S2CARD_INFO_GET]    Script Date: 2023-11-13 오전 8:38:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********************************************************
-- SP Name       : SP_S2CARD_INFO_GET
-- Author        : 변미정
-- Create date   : 2023-11-02
-- Description   : 초과 지급 수량(서비스수량) 등 조회. (약도카드 스티커 등)
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_S2CARD_INFO_GET]     
     @card_seq                       INT                        --카드번호     
    
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
        IF ISNULL(@card_seq,0) = 0  BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        -------------------------------------------------------
        -- 초과 지급 수량, 카드내지 인쇄여부,컬럼 추가필요시 아래쪽으로 추가해라
        -------------------------------------------------------     
        SELECT ISNULL(OVERQTY,0) AS OVERQTY
              ,ISNULL(FPRINT_YORN,'N') AS FPRINT_YORN
        FROM S2_CARD WITH(NOLOCK)
        WHERE CARD_SEQ = @card_seq
        IF @@ROWCOUNT <> 1 BEGIN
            SET @ErrNum = 2301
            SET @ErrMsg = '카드가 존재하지 않습니다.'
            RETURN  
        END

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
		SET @ErrMsg   = '초과 지급 수량조회 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO


