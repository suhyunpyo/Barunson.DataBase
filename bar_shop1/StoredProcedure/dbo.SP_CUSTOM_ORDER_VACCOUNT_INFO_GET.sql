USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_VACCOUNT_INFO_GET]    Script Date: 2023-04-24 오후 3:46:22 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_VACCOUNT_INFO_GET]
GO
/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_VACCOUNT_INFO_GET]    Script Date: 2023-04-24 오후 3:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : [SP_CUSTOM_ORDER_VACCOUNT_INFO_GET
-- Author        : 변미정
-- Create date   : 2023-04-07
-- Description   : 가상계좌 발급 조회
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_VACCOUNT_INFO_GET]          
     @toss_secret                    VARCHAR(50)                --거래 검증키
    ,@toss_orderid                   VARCHAR(50)                --주문번호 (각 주문테이블의 pg_tid)    
    
    ,@ErrNum                         INT             OUTPUT
    ,@ErrSev                         INT             OUTPUT
    ,@ErrState                       INT             OUTPUT
    ,@ErrProc                        VARCHAR(50)     OUTPUT
    ,@ErrLine                        INT             OUTPUT
    ,@ErrMsg                         VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON

BEGIN
       
    DECLARE  @order_seq             INT                       
    DECLARE  @order_type            VARCHAR(2)      = NULL    
    DECLARE  @status                TINYINT         = NULL
    DECLARE  @status_seq            TINYINT         = NULL    
    DECLARE  @settle_status         TINYINT         = NULL    

    BEGIN TRY        

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@toss_secret,'') = '' OR ISNULL(@toss_orderid,'') = '' BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        -------------------------------------------------------
        -- 주문정보 조회
        -------------------------------------------------------     
        SELECT  @order_type = ORDER_TYPE
               ,@order_seq  = ORDER_SEQ
               ,@status     = [STATUS]             
        FROM    TOSS_VACCOUNT 
        WHERE   toss_orderid = @toss_orderid
        AND     toss_secret  = @toss_secret
        IF @@ROWCOUNT <> 1 BEGIN
            SET @ErrNum = 2302
            SET @ErrMsg = '가상계좌 발급정보가 존재하지 않습니다.'            
            RETURN
        END

        --청첩장
        IF @order_type = 'W' BEGIN 

           SELECT 'W' AS ORDER_TYPE
                 ,ORDER_SEQ
                 ,ISNULL(STATUS_SEQ, 0) AS STATUS_SEQ 
                 ,CASE WHEN ISNULL(SETTLE_STATUS, 0) = 2 THEN 2 ELSE 1 END  AS SETTLE_FLAG  --1:결제전또는 취소상태 2:결제완료상태
                 ,ISNULL(SETTLE_METHOD, 0) AS SETTLE_METHOD 
                 ,ISNULL(SETTLE_PRICE, 0) AS SETTLE_PRICE 
                 ,ISNULL(PG_SHOPID, '') AS PG_SHOPID 
                 ,ISNULL(DACOM_TID, '') AS DACOM_TID 
                 ,ISNULL(COMPANY_SEQ, 0) AS COMPANY_SEQ  
            FROM   CUSTOM_ORDER 
            WHERE  ORDER_SEQ = @order_seq  
            IF @@ROWCOUNT <> 1 BEGIN                
                SET @ErrNum = 2302
                SET @ErrMsg = '주문정보가 없습니다.'                     
                RETURN                                
            END
        END
        --답례품/부가상품
        ELSE IF @order_type = 'E' BEGIN           
           SELECT 'E' AS ORDER_TYPE
                  ,ORDER_SEQ
                  ,ISNULL(STATUS_SEQ, 0) AS STATUS_SEQ 
                  ,CASE WHEN ISNULL(STATUS_SEQ,0) IN (0,1,2,3,5) THEN 1 ELSE 2 END AS SETTLE_FLAG  --1:결제전또는 취소상태 2:결제완료상태
                  ,ISNULL(SETTLE_METHOD, 0) AS SETTLE_METHOD 
                  ,ISNULL(SETTLE_PRICE, 0) AS SETTLE_PRICE 
                  ,ISNULL(PG_SHOPID, '') AS PG_SHOPID 
                  ,ISNULL(DACOM_TID, '') AS DACOM_TID 
                  ,ISNULL(COMPANY_SEQ, 0) AS COMPANY_SEQ  
            FROM   CUSTOM_ETC_ORDER 
            WHERE  ORDER_SEQ = @order_seq  
            IF @@ROWCOUNT <> 1 BEGIN                
                SET @ErrNum = 2304
                SET @ErrMsg = '주문정보가 없습니다.'                     
                RETURN
            END

        END
        --샘플주문
        ELSE IF @order_type = 'S' BEGIN
            SELECT  'S' AS ORDER_TYPE
                    ,SAMPLE_ORDER_SEQ AS ORDER_SEQ
                    ,ISNULL(STATUS_SEQ, 0) AS STATUS_SEQ 
                    ,CASE WHEN ISNULL(STATUS_SEQ,0) IN (0,1,2,3,5) THEN 1 ELSE 2 END AS SETTLE_FLAG   --1:결제전또는 취소상태 2:결제완료상태
                    ,ISNULL(SETTLE_METHOD, 0) AS SETTLE_METHOD 
                    ,ISNULL(SETTLE_PRICE, 0) AS SETTLE_PRICE 
                    ,ISNULL(PG_MERTID, '') AS PG_SHOPID 
                    ,ISNULL(DACOM_TID, '') AS DACOM_TID 
                    ,ISNULL(COMPANY_SEQ, 0) AS COMPANY_SEQ  
            FROM  CUSTOM_SAMPLE_ORDER 
            WHERE SAMPLE_ORDER_SEQ = @order_seq  
            IF @@ROWCOUNT <> 1 BEGIN                
                SET @ErrNum = 2306
                SET @ErrMsg = '주문정보가 없습니다.'                     
                RETURN
            END        
        END
         ELSE BEGIN            
            SET @ErrNum = 2308
            SET @ErrMsg = '상품 구분 오류'                       
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
		SET @ErrMsg   = '결제 정보 조회 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO
