USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_VACCOUNT_WEBHOOK_LOG_INSERT]    Script Date: 2023-04-24 오후 3:46:22 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_VACCOUNT_WEBHOOK_LOG_INSERT]
GO
/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_VACCOUNT_WEBHOOK_LOG_INSERT]    Script Date: 2023-04-24 오후 3:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_VACCOUNT_WEBHOOK_LOG_INSERT
-- Author        : 변미정
-- Create date   : 2023-04-07
-- Description   : 가상계좌 WEBHOOK 로그등록
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_VACCOUNT_WEBHOOK_LOG_INSERT]         

 @toss_secret                    VARCHAR(50)                --거래 검증키
,@toss_orderid                   VARCHAR(50)                --주문번호 (각 주문테이블의 pg_tid)
,@toss_status                    VARCHAR(50)                --toss 거래 상태값
,@toss_trankey                   VARCHAR(50)                --toss 거래키
,@toss_created_date              DATETIME                   --webhook 생성일(입금일시)

,@barun_msg                      VARCHAR(200) = NULL        --내부 처리 결과 메세지

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
           

           INSERT INTO TOSS_VACCOUNT_LOG (TOSS_SECRET, TOSS_ORDERID, TOSS_STATUS, TOSS_TRANKEY, TOSS_CREATED_DATE
                                         ,BARUN_MSG )
                                  VALUES (@toss_secret, @toss_orderid, @toss_status, @toss_trankey, @toss_created_date
                                         ,@barun_msg)

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
		SET @ErrMsg   = '가상계좌 로그 등록 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO
