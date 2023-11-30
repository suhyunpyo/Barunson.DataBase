IF OBJECT_ID (N'dbo.SP_INSERT_KYOBO_COUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_KYOBO_COUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		정혜련
-- Create date: 2019-07-01
-- Description:	교보 이벤트 쿠폰 발급
-- EXEC dbo.[SP_INSERT_KYOBO_COUPON] COUPON_MST_SEQ, UID
-- EXEC dbo.[SP_INSERT_KYOBO_COUPON] 134, 's4guest'
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_KYOBO_COUPON]
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
		,		@MSG_CODE						AS VARCHAR(4)	= '9999'


	select @SALES_GUBUN = sales_gubun from company where company_seq = @COMPANY_SEQ


    -- 발급조건 확인
    IF ( @COUPON_MST_SEQ = 461 OR @COUPON_MST_SEQ = 462 OR @COUPON_MST_SEQ = 463 OR @COUPON_MST_SEQ = 464 OR @COUPON_MST_SEQ = 465 OR @COUPON_MST_SEQ = 551)  
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

			-- 몰은 COMPANY_SEQ : 5000
			BEGIN
				INSERT @TABLE_TEMP EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @UID, @COUPON_CODE
			END 

						
			SET @MSG = (SELECT RESULT_MESSAGE FROM @TABLE_TEMP)
			SET @MSG_CODE = (SELECT RESULT_CODE FROM @TABLE_TEMP)    
			
			-- 바른손몰
			IF ( @COMPANY_SEQ = 5000 ) 		    
			BEGIN
			    INSERT INTO S4_MYCOUPON (COUPON_CODE, UID, COMPANY_SEQ , isMyYN) VALUES ('EVTKYOBO5000', @UID, 5006 , 'Y')		   	  			
			END

            -- 프리미어페이퍼
        END

        ELSE
        BEGIN
            SET @MSG = '이미 다운로드 되었습니다.'
        END
    END      
    ELSE
    BEGIN 
        SET @MSG = '발급 조건에 부합하지 않습니다.'
    END

    SELECT @MSG AS MSG, CASE WHEN @MSG_CODE = '0000' THEN 'ok' ELSE 'fail' END  AS result;
END
GO
