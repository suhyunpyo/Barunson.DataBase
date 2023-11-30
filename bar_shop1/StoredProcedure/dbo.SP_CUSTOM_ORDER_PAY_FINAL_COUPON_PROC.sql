USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC]    Script Date: 2023-07-05 오전 11:40:57 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC]    Script Date: 2023-07-05 오전 11:40:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC
-- Author        : 변미정
-- Create date   : 2023-06-29
-- Description   : 주문 결제 완료시 쿠폰 지급 처리
-- Update History: 
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC]     
     @order_seq                      INT                        --주문번호     
    ,@sales_gubun                    VARCHAR(2)      = NULL     --B:제휴,H:프페 제휴, SA:비핸즈, SS:프페,SB: 바른손, ST:더카드,D:대리점 , P:아웃바운드, Q:지역대리점
    ,@company_seq                    INT             = NULL     --
    ,@order_category                 VARCHAR(1)      = NULL     --주문 구분 ("W":청첩장 "S":샘플 "E":부가상품,답례품) 
    ,@order_type                     VARCHAR(2)      = NULL     --주문타입 
    
    ,@member_id                      VARCHAR(50)     = NULL     --회원/비회원 아이디 
    ,@uid                            VARCHAR(50)     = NULL     --회원아이디 

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
        DECLARE @up_order_seq               INT = 0
        DECLARE @order_count                INT = 0        
        DECLARE @thank_coupon               VARCHAR(50) = ''    --감사장 할인 쿠폰 번호
        DECLARE @evt_video_coupon_mst_seq   INT         = 0     --식전영상쿠폰
        DECLARE @thk_video_coupon_mst_seq   INT         = 0     --감사영상쿠폰
        DECLARE @card_seq                   INT
        DECLARE @coupon_seq                 VARCHAR(50)
        DECLARE @addition_couponseq         VARCHAR(50)
        DECLARE @org_order_type             VARCHAR(2) 

        DECLARE @is_member                   BIT         = 0     --1:회원 0:비회원 주문
        DECLARE @is_org_order                BIT         = 0     --1:원주문 0:추가주문

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@order_seq,0) = 0  OR ISNULL(@sales_gubun,'') = '' OR ISNULL(@member_id,'') = '' BEGIN    
            SET @ErrNum = 3001
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        --회원여부 
        IF ISNULL(@uid,'') <> '' BEGIN
            SET @is_member = 1
        END        
        
         --청첩장인경우
        IF @order_category = 'W' BEGIN

            --주문정보 조회
            SELECT @up_order_seq   = UP_ORDER_SEQ
                  ,@order_count    = ORDER_COUNT
                  ,@card_seq       = CARD_SEQ
                  ,@coupon_seq     = ISNULL(COUPONSEQ,'')
                  ,@addition_couponseq = ISNULL(ADDITION_COUPONSEQ,'')
                  ,@org_order_type = order_type
            FROM   CUSTOM_ORDER WITH(NOLOCK)
            WHERE  ORDER_SEQ = @order_seq
            IF @@ROWCOUNT <> 1 BEGIN
                SET @ErrNum = 3003
                SET @ErrMsg = '청첩장 주문정보가 없습니다.'            
                RETURN
            END

            --원주문 여부 
            IF ISNULL(@up_order_seq,0) = 0 BEGIN
                SET @is_org_order = 1
            END

            ------------------------------------------------------------------
            -- 감사장할인/식전영상/감사영상 쿠폰 정보 SET
            ------------------------------------------------------------------
            --바른손카드 
            IF @sales_gubun = 'SB'  BEGIN                              
                SET @thank_coupon = 'C600-1862-412D-AA73'
                SET @evt_video_coupon_mst_seq = 301
                SET @thk_video_coupon_mst_seq = 627
            END
            --프리미어페이퍼 
            ELSE IF @sales_gubun = 'SS'  BEGIN           
                SET @thank_coupon = '5E3F-86BA-4EAE-B723'
                SET @evt_video_coupon_mst_seq = 291
                SET @thk_video_coupon_mst_seq = 292
            END 
            --바른손몰
            ELSE IF @sales_gubun IN ('SA','B')  BEGIN           
                SET @thank_coupon = 'BHS15THK0101'
            END                       
            
            ------------------------------------------------------------------
            -- 쿠폰사용 처리및 감사장할인/감사영상/식전영상 쿠폰 등 발급 처리
            ------------------------------------------------------------------
            --바른몰인 경우 지급방식 다름
            IF @sales_gubun IN ('SA','B')  BEGIN  
                
                --원주문인경우만 
                IF @is_org_order = 1 BEGIN
                     -- 35108 // BH5009(35097) 스티커 // (카운팅사은품)   
                    IF @card_seq = 35097  BEGIN
                        IF NOT EXISTS(SELECT ID 
                                      FROM   CUSTOM_ORDER_ITEM WITH(NOLOCK)
                                      WHERE  ORDER_SEQ = @order_seq
                                      AND    CARD_SEQ  = 35108
                                      AND    ITEM_TYPE = 'H') BEGIN
                            INSERT INTO CUSTOM_ORDER_ITEM(ORDER_SEQ,CARD_SEQ,ITEM_TYPE,ITEM_PRICE,ITEM_SALE_PRICE,ITEM_COUNT) 
                                                   VALUES(@order_seq,35108,'H',0,0,10)
                        END
                    END
                    -- 35107 // BH5005,5006 스티커 // (카운팅사은품)  
                    ELSE IF @card_seq IN (35203, 35202)  BEGIN
                        IF NOT EXISTS(SELECT ID 
                                      FROM   CUSTOM_ORDER_ITEM WITH(NOLOCK)
                                      WHERE  ORDER_SEQ = @order_seq
                                      AND    CARD_SEQ  = 35107
                                      AND    ITEM_TYPE = 'H') BEGIN
                            INSERT INTO CUSTOM_ORDER_ITEM(ORDER_SEQ,CARD_SEQ,ITEM_TYPE,ITEM_PRICE,ITEM_SALE_PRICE,ITEM_COUNT) 
                                                   VALUES(@order_seq,35107,'H',0,0,10)
                        END
                    END                
                    ELSE IF @card_seq IN (35382, 35385, 35386) AND @order_type <> 'WS' BEGIN --초특급이 아닌경우만
                        IF NOT EXISTS(SELECT ID 
                                      FROM   CUSTOM_ORDER_ITEM WITH(NOLOCK)
                                      WHERE  ORDER_SEQ = @order_seq
                                      AND    CARD_SEQ  = 35387
                                      AND    ITEM_TYPE = 'H') BEGIN
                            INSERT INTO CUSTOM_ORDER_ITEM(ORDER_SEQ, CARD_SEQ, ITEM_TYPE, ITEM_COUNT, ITEM_PRICE
                                                         ,ITEM_SALE_PRICE, DISCOUNT_RATE, MEMO1, ADDNUM_PRICE, REG_DATE) 
                                                   values(@order_seq, 35387, 'H', 50, 0
                                                         , 0, NULL, NULL, 0, GETDATE())
                        END
                    END                    
                END             
                

                --쿠폰 사용 처리
                IF @coupon_seq <> '' BEGIN
              
                    UPDATE S4_COUPON 
                    SET    ISYN='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @coupon_seq 
                    AND    ISRECYCLE   ='0' 
                    AND    ([UID] = @member_id OR [UID]='' OR [UID] IS NULL)

                     --제일모직 제휴할인
                    IF @company_seq = 6802 BEGIN
                        UPDATE S4_COUPON 
                        SET   ISYN = 'N' 
                        WHERE COMPANY_SEQ = @company_seq 
                        AND   COUPON_CODE = @coupon_seq 
                        AND   ISRECYCLE   ='N' 
                        AND   ([UID] = @member_id OR [UID]='' OR [UID] IS NULL)

                        UPDATE S4_MYCOUPON 
                        SET    ISMYYN = 'N' 
                        WHERE  COMPANY_SEQ = @company_seq 
                        AND    COUPON_CODE = @coupon_seq  
                        AND    [UID]       = @member_id
                    END

                    -- 바른손몰 > 제휴쿠폰은 다회 사용 가능
                    IF @coupon_seq NOT IN ('BARUNSONAMLL5R_JEHU', 'BARUNSONAMLL10R_JEHU', 'BARUNSONAMLL15R_JEHU', 'BARUNSONAMLL17R_JEHU', 'BARUNSONAMLL25R_JEHU') BEGIN
                        UPDATE S4_MYCOUPON 
                        SET   ISMYYN ='N' 
                        WHERE COUPON_CODE = @coupon_seq
                        AND   ISMYYN      = 'Y' 
                        AND   [UID]       = @member_id
                    END

                     --리본웨딩 쿠폰 사용 처리
                    IF SUBSTRING(@coupon_seq,2,4) = 'MRIB' BEGIN
                        UPDATE S4_MYCOUPON 
                        SET   ISMYYN ='N' 
                        WHERE COUPON_CODE = @coupon_seq
                        AND   ISMYYN      = 'Y' 
                        AND   [UID]       = @member_id
                    END
                END

                --중복쿠폰 사용처리
                IF @addition_couponseq <> '' BEGIN
                    
                    UPDATE S4_MYCOUPON 
                    SET    ISMYYN='N' 
                    WHERE  COMPANY_SEQ IN (@company_seq,5006 ) 
                    AND    COUPON_CODE = @addition_couponseq
                    AND    [UID]       = @member_id 
                END            
                          
                --회원/원주문인 경우
                IF @is_org_order = 1 AND @is_member = 1 BEGIN                   

                    --감사장 할인 쿠폰 발행
                    IF NOT EXISTS(SELECT ID 
                                    FROM S4_MYCOUPON WITH(NOLOCK)
                                    WHERE [UID]= @uid
                                    AND   COMPANY_SEQ = 5006
                                    AND   COUPON_CODE = @thank_coupon) BEGIN
                       
                        INSERT INTO S4_MYCOUPON([UID],COUPON_CODE,COMPANY_SEQ,END_DATE) 
                                        VALUES(@uid, @thank_coupon, 5006 , DATEADD(MONTH, 2, GETDATE())) 
                    END 

                    --식전영상/감사영상 쿠폰 발급
                    EXEC SP_INSERT_MOVIE_EVENT_JEHU_V2 @uid                         
                    EXEC SP_INSERT_THK_MOVIE_EVENT_JEHU @uid 
                END
                
            END
            --바른손 카드, 프리미어페이퍼
            ELSE  BEGIN       
            
                --쿠폰 사용 처리
                IF @coupon_seq <> '' BEGIN
                    UPDATE S4_COUPON 
                    SET    ISYN='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @coupon_seq 
                    AND    ISRECYCLE   ='0' 
                    AND    ([UID] = @member_id OR [UID]='' OR [UID] IS NULL)

                    UPDATE S4_MYCOUPON 
                    SET    ISMYYN ='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @coupon_seq                 
                    AND    [UID] = @member_id 
                END

                --중복쿠폰 사용처리
                IF @addition_couponseq <> '' BEGIN
                    UPDATE S4_COUPON 
                    SET    ISYN='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @addition_couponseq 
                    AND    ISRECYCLE   ='0' 
                    AND    ([UID] = @member_id OR [UID]='' OR [UID] IS NULL)

                    UPDATE S4_MYCOUPON 
                    SET    ISMYYN ='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @addition_couponseq                 
                    AND    [UID] = @member_id 
                END 

                --회원/원주문인 경우
                IF @is_org_order = 1 AND @is_member = 1 BEGIN    
                    --감사장 할인 쿠폰 발행 
                    EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @company_seq, @sales_gubun, @uid, @thank_coupon                               
                    
                    --식전영상/감사영상 쿠폰발급                     
                    EXEC SP_INSERT_COUPON_MST_SEQ @evt_video_coupon_mst_seq, @uid, @company_seq   
                    EXEC SP_INSERT_COUPON_MST_SEQ @thk_video_coupon_mst_seq, @uid, @company_seq                    
                END
            END

            ------------------------------------------------------------------
            --가입혜택 이벤트 사은품 증정 (바른손카드만)
            ------------------------------------------------------------------
            IF ISNULL(@uid,'')<>'' AND @sales_gubun ='SB' BEGIN
                EXEC SP_INSERT_EVT_REGIST_GIFT @order_seq, @company_seq
            END

            ------------------------------------------------------------------
            -- 사은품 증정
            ------------------------------------------------------------------            
            EXEC SP_INSERT_FREE_GIFT @order_seq
            
        END        
        ELSE IF @order_category = 'S' BEGIN
            
            IF @sales_gubun IN ('SB','SS')  BEGIN                                             

                EXEC SP_INSERT_SAMPLE_FREE_GIFT @order_seq,@company_seq            
            END 
            --바른손몰
            ELSE IF @sales_gubun IN ('SA','B')  BEGIN           
                EXEC SP_INSERT_SAMPLE_FREE_GIFT @order_seq,5006
            END 
            
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
		SET @ErrMsg   = '쿠폰 발급 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END

GO


