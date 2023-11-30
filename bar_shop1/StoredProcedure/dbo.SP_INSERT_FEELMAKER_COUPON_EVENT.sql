IF OBJECT_ID (N'dbo.SP_INSERT_FEELMAKER_COUPON_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_FEELMAKER_COUPON_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2018-01-31
-- Description:	바른손카드 식전영상쿠폰발급(필모션)
-- 원주문/100매이상 구입시 발급
-- EXEC dbo.[SP_INSERT_MOVIE_EVENT_SB] 주문번호, 's5guest'

-- 2020.09.01 
-- 식전영상 외 감사영상이 추가되면서 COUPON_MST_SEQ 추가된 버전으로 다시 만듬
-- SP_INSERT_FEELMAKER_COUPON_EVENT로 새로만듬
-- 바른손 식전영상 : 301
-- EXEC dbo.[SP_INSERT_FEELMAKER_COUPON_EVENT] 3024032, 's4guest' , 'SB',301
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_FEELMAKER_COUPON_EVENT]
	@ORDER_SEQ       					AS INT,
	@UID								AS VARCHAR(50),
	@SALES_GUBUN						AS VARCHAR(2),
	@COUPON_MST_SEQ						AS INT
AS
BEGIN
	
	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
		,		@SEND_PHONE						AS	VARCHAR(15)
	    ,		@NO_REC_BRAND					AS	VARCHAR(20) = ''
	    ,		@COMPANY_SEQ					AS	INT		

   IF @SALES_GUBUN = 'SB'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손카드'      
     SET @SEND_PHONE  = '1644-0708' 
     SET @COMPANY_SEQ  = 5001      
    END  
  
   ELSE IF @SALES_GUBUN = 'SA'  
    BEGIN  
     SET @NO_REC_BRAND = '비핸즈카드'      
     SET @SEND_PHONE  = '1644-9713'
     SET @COMPANY_SEQ  = 5006  
    END  
  
  
   ELSE IF @SALES_GUBUN = 'ST'  
    BEGIN  
     SET @NO_REC_BRAND = '더카드'       
     SET @SEND_PHONE  = '1644-7998'
     SET @COMPANY_SEQ  = 5007 
    END  

   ELSE IF @SALES_GUBUN = 'B'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손몰'      
     SET @SEND_PHONE  = '1644-7413' 
     SET @COMPANY_SEQ  = 5000 
    END  
 
   ELSE IF @SALES_GUBUN = 'SS' 
    BEGIN  
     SET @NO_REC_BRAND = '프리미어페이퍼'      
     SET @SEND_PHONE  = '1644-8796'
     SET @COMPANY_SEQ  = 5003
    END  

	
    -- 주문내역 확인/발급조건/100매이상
    IF  EXISTS (
        SELECT      *
        FROM        CUSTOM_ORDER
        WHERE       ORDER_SEQ = @ORDER_SEQ
        AND         MEMBER_ID = @UID
        AND         UP_ORDER_SEQ IS NULL
        AND         COMPANY_SEQ = @COMPANY_SEQ
        AND         ORDER_COUNT >= 100
        AND         SETTLE_STATUS = 2
        AND         ORDER_TYPE IN (1,6,7) 
        AND         STATUS_SEQ <> -1   
    )
    BEGIN
	    -- 이미 발급된 쿠폰이 있는 지 확인
	    IF	NOT EXISTS(
		    SELECT		*
		    FROM		COUPON_DETAIL			CD
		    INNER JOIN	COUPON_ISSUE			CI	ON CD.COUPON_DETAIL_SEQ= CI.COUPON_DETAIL_SEQ
		    WHERE		1 = 1
		    AND			CI.UID = @UID
		    AND			CI.COMPANY_SEQ = @COMPANY_SEQ
		    AND			CD.COUPON_MST_SEQ = @COUPON_MST_SEQ
	    )

        BEGIN
		    -- 발급안된 쿠폰번호 검색 후, 쿠폰발급
		    SELECT	TOP(1) @COUPON_CODE =  COUPON_CODE
		    FROM	COUPON_DETAIL
		    WHERE	1 = 1
		    AND		COUPON_MST_SEQ = @COUPON_MST_SEQ
		    AND		DOWNLOAD_ACTIVE_YN = 'Y'

            EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @UID, @COUPON_CODE
            UPDATE COUPON_DETAIL SET DOWNLOAD_ACTIVE_YN = 'N' WHERE COUPON_CODE = @COUPON_CODE 
        END
    END
END
GO
