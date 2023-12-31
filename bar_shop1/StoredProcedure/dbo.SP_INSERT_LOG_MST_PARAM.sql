USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_INSERT_LOG_MST_PARAM]    Script Date: 2023-04-24 오후 3:46:22 ******/
DROP PROCEDURE [dbo].[SP_INSERT_LOG_MST_PARAM]
GO
/****** Object:  StoredProcedure [dbo].[SP_INSERT_LOG_MST_PARAM]    Script Date: 2023-04-24 오후 3:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_INSERT
-- Author        : 변미정
-- Create date   : 2023-04-04
-- Description   : 주문 결제 정보 등록
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_INSERT_LOG_MST_PARAM]   
     @GUID               AS  VARCHAR(40)
    ,@SITE               AS  VARCHAR(50)
    ,@LOCATION           AS  VARCHAR(500)
    ,@SUB_LOCATION       AS  VARCHAR(500)
    ,@LOG_TYPE_NAME      AS  VARCHAR(500)

    ,@MSG                AS  NVARCHAR(MAX)
    ,@USER_ID            AS  VARCHAR(50)

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
        BEGIN TRAN

        INSERT INTO LOG_MST (GUID, SITE, LOCATION, SUB_LOCATION, LOG_TYPE_NAME, MSG, USER_ID)
	    VALUES (@GUID, @SITE, @LOCATION, @SUB_LOCATION, @LOG_TYPE_NAME, @MSG, @USER_ID)

        COMMIT TRAN
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
		SET @ErrMsg   = '로그 등록 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH


END




GO
