USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_STATUS_GET]    Script Date: 2023-04-24 오후 3:46:22 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_STATUS_GET]
GO
/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_STATUS_GET]    Script Date: 2023-04-24 오후 3:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_STATUS_INFO_GET
-- Author        : 변미정
-- Create date   : 2023-04-05
-- Description   : 주문 결제 상태 조회
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_STATUS_GET]     
     @order_seq                      INT                        --주문번호     
    ,@order_type                     VARCHAR(2)      = NULL     --주문타입 (W:청첩장 WS:초특급청첩장 S:샘플 그외:부가상품)
    ,@card_div                       VARCHAR(5)      = NULL     --카드구분 (A01:카드 A02:내지 A03:인사말카드 .... C08:답례품...)
    
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
        IF ISNULL(@order_seq,0) = 0 OR ISNULL(@order_type,'') = '' BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        -------------------------------------------------------
        -- 주문정보 조회
        -------------------------------------------------------     
        --청첩장
        IF @order_type = 'W' BEGIN 

           SELECT ISNULL(STATUS_SEQ, 0) AS STATUS_SEQ 
                 ,ISNULL(SETTLE_STATUS, 0) AS SETTLE_STATUS 
                 ,ISNULL(SETTLE_METHOD, 0) AS SETTLE_METHOD 
                 ,ISNULL(SETTLE_PRICE, 0) AS SETTLE_PRICE 
                 ,ISNULL(PG_SHOPID, '') AS PG_SHOPID 
                 ,ISNULL(DACOM_TID, '') AS DACOM_TID 
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
           SELECT ISNULL(STATUS_SEQ, 0) AS STATUS_SEQ 
                 ,CASE STATUS_SEQ WHEN 4 THEN 2 ELSE STATUS_SEQ END AS SETTLE_STATUS
                 ,ISNULL(SETTLE_METHOD, 0) AS SETTLE_METHOD 
                 ,ISNULL(SETTLE_PRICE, 0) AS SETTLE_PRICE 
                 ,ISNULL(PG_SHOPID, '') AS PG_SHOPID 
                 ,ISNULL(DACOM_TID, '') AS DACOM_TID 
            FROM    CUSTOM_ETC_ORDER 
            WHERE   ORDER_SEQ = @order_seq  
            IF @@ROWCOUNT <> 1 BEGIN                
                SET @ErrNum = 2304
                SET @ErrMsg = '주문정보가 없습니다.'                     
                RETURN
            END

        END
        --샘플주문
        ELSE IF @order_type = 'S' BEGIN
            SELECT ISNULL(STATUS_SEQ, 0) AS STATUS_SEQ 
                 ,CASE STATUS_SEQ WHEN 4 THEN 2 ELSE STATUS_SEQ END AS SETTLE_STATUS
                 ,ISNULL(SETTLE_METHOD, 0) AS SETTLE_METHOD 
                 ,ISNULL(SETTLE_PRICE, 0) AS SETTLE_PRICE 
                 ,ISNULL(PG_MERTID, '') AS PG_SHOPID 
                 ,ISNULL(DACOM_TID, '') AS DACOM_TID 
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
