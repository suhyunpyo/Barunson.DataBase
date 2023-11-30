IF OBJECT_ID (N'dbo.SP_INSERT_LOTTEDUTY_COUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_LOTTEDUTY_COUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2018-01-31
-- Description:	바른손카드 롯데면세점 쿠폰발급
-- EXEC dbo.[SP_INSERT_LOTTEDUTY_COUPON] COUPON_MST_SEQ, UID
-- EXEC dbo.[SP_INSERT_LOTTEDUTY_COUPON] 134, 's4guest'
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_LOTTEDUTY_COUPON]
	@COUPON_MST_SEQ       					AS INT,
	@UID    								AS VARCHAR(50),
	@COMPANY_SEQ       					    AS INT
AS
BEGIN
	
    SET NOCOUNT ON

	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
        ,       @ORDER_CNT                      AS  INT
        ,       @SALES_GUBUN                    AS  VARCHAR(2) 
        ,       @COUPON_DOWN_YN                 AS  VARCHAR(1) = 'N'
        ,       @MSG                            AS  VARCHAR(500)


	select @SALES_GUBUN = sales_gubun from company where company_seq = @COMPANY_SEQ


    -- 발급조건 확인
    IF ( @COUPON_MST_SEQ = 213 OR @COUPON_MST_SEQ = 214 OR @COUPON_MST_SEQ = 217 OR @COUPON_MST_SEQ = 216 OR @COUPON_MST_SEQ = 215)  
    
    BEGIN
            SET @COUPON_DOWN_YN = 'Y'
    END
    
    ELSE IF ( @COUPON_MST_SEQ = 133 OR @COUPON_MST_SEQ = 136 OR @COUPON_MST_SEQ = 143 OR @COUPON_MST_SEQ = 146 OR @COUPON_MST_SEQ = 139) 
    BEGIN
        -- 샘플신청 고객
        IF  EXISTS (
                    SELECT  *
                    FROM    CUSTOM_SAMPLE_ORDER
                    WHERE   1 = 1
                    AND     COMPANY_SEQ = @COMPANY_SEQ
                    AND     MEMBER_ID = @UID
                    AND     STATUS_SEQ IN (4, 10, 12)
        )
        BEGIN
            SET @COUPON_DOWN_YN = 'Y'
        END
    END
    
    ELSE IF ( @COUPON_MST_SEQ = 134 OR @COUPON_MST_SEQ = 137 OR @COUPON_MST_SEQ = 144 OR @COUPON_MST_SEQ = 147 OR @COUPON_MST_SEQ = 140)
    BEGIN
        -- 구매고객
        IF  EXISTS (
                    SELECT      *
                    FROM        CUSTOM_ORDER
                    WHERE       1 = 1
                    AND         MEMBER_ID = @UID
                    AND         UP_ORDER_SEQ IS NULL
                    AND         COMPANY_SEQ = @COMPANY_SEQ
                    AND         SETTLE_STATUS IN (1,2)
                    AND         STATUS_SEQ <> -1
                    AND         ORDER_TYPE IN (1,6,7)
        )
        BEGIN
            SET @COUPON_DOWN_YN = 'Y'
        END
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

		    IF ( @COMPANY_SEQ = 5006 OR @COMPANY_SEQ = 5003 OR @COMPANY_SEQ = 5007 OR @COMPANY_SEQ = 5001)
				BEGIN
					INSERT @TABLE_TEMP EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @UID, @COUPON_CODE
				END 
			ELSE
				BEGIN
					INSERT @TABLE_TEMP EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE 5000, @SALES_GUBUN, @UID, @COUPON_CODE
				END 
						
			SET @MSG = (SELECT RESULT_MESSAGE FROM @TABLE_TEMP)
            UPDATE COUPON_DETAIL SET DOWNLOAD_ACTIVE_YN = 'N' WHERE COUPON_CODE = @COUPON_CODE 

			EXEC SP_INSERT_LOTTEDUTY_COUPON_LMS_2019 @COUPON_MST_SEQ, @UID, @COUPON_CODE	

			    
			-- 바른손몰
			IF ( @COUPON_MST_SEQ = 217 OR @COUPON_MST_SEQ = 143 OR @COUPON_MST_SEQ = 144 ) 		    
			BEGIN
			    UPDATE S4_COUPON SET isYN = 'N' WHERE coupon_code = @COUPON_CODE
			    INSERT INTO S4_MYCOUPON (COUPON_CODE, UID, COMPANY_SEQ , isMyYN) VALUES (@COUPON_CODE, @UID, 5006 , 'Y')		   	  			
			END

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
