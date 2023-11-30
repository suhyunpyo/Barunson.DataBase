IF OBJECT_ID (N'dbo.SP_THECARD_EVENT_WIFI', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_THECARD_EVENT_WIFI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2018-05-18
-- Description:	더카드 와이파이 도시락 이벤트
-- EXEC dbo.[SP_THECARD_EVENT_WIFI] COUPON_MST_SEQ, UID
-- EXEC dbo.[SP_THECARD_EVENT_WIFI] 171, 's4guest'
-- thecard.co.kr/event/event_2018wifidosirak.asp
-- =============================================

CREATE PROCEDURE [dbo].[SP_THECARD_EVENT_WIFI]
	@COUPON_MST_SEQ       					AS INT,
	@UID    								AS VARCHAR(50)
AS
BEGIN
	
    SET NOCOUNT ON

	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
        ,       @SALES_GUBUN                    AS  VARCHAR(2) = 'ST'
        ,       @COUPON_DOWN_YN                 AS  VARCHAR(1) = 'N'
        ,       @MSG                            AS  VARCHAR(500)
        ,       @COMPANY_SEQ                    AS  INT = 5007


    -- 300장 이상 구매고객
    IF  EXISTS (
                SELECT      *
                FROM        CUSTOM_ORDER
                WHERE       1 = 1
                AND         MEMBER_ID = @UID
                AND         UP_ORDER_SEQ IS NULL
                AND         COMPANY_SEQ = @COMPANY_SEQ
                AND         SETTLE_STATUS = 2
                AND         STATUS_SEQ NOT IN (3,5)
                AND         ORDER_TYPE IN (1,6,7)
                AND         ORDER_COUNT >= 300
    )
    BEGIN
        SET @COUPON_DOWN_YN = 'Y'
    END
    
    IF @COUPON_DOWN_YN = 'Y' 
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
		    SELECT  TOP(1) @COUPON_CODE =  COUPON_CODE
		    FROM	COUPON_DETAIL
		    WHERE	1 = 1
		    AND		COUPON_MST_SEQ = @COUPON_MST_SEQ
		    AND		DOWNLOAD_ACTIVE_YN = 'Y'

            DECLARE @TABLE_TEMP TABLE (
                                        RESULT_CODE VARCHAR(4)
                                    ,   RESULT_MESSAGE VARCHAR(100))

			INSERT @TABLE_TEMP EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @UID, @COUPON_CODE
						
			SET @MSG = '쿠폰이 발급되었습니다. 마이페이지>보관함에서 확인해주세요'
            UPDATE COUPON_DETAIL SET DOWNLOAD_ACTIVE_YN = 'N' WHERE COUPON_CODE = @COUPON_CODE 
        END
        ELSE
        BEGIN
            SET @MSG = '이미 발급되었습니다.'
        END
    END      
    ELSE
    BEGIN 
        SET @MSG = '발급 조건에 부합하지 않습니다.'
    END

    SELECT @MSG AS RESULT;
END
GO
