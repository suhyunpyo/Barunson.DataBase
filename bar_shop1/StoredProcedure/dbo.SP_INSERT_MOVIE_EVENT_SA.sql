IF OBJECT_ID (N'dbo.SP_INSERT_MOVIE_EVENT_SA', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MOVIE_EVENT_SA
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		정혜련
-- Create date: 2018-08-01
-- Description:	비카드 식전영상쿠폰발급(필모션)
-- 원주문/청첩장구매시 발급
-- EXEC dbo.[SP_INSERT_MOVIE_EVENT_SA] 주문번호, 's5guest'
-- 바른손,비핸즈 통합 필요. 천천히....
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_MOVIE_EVENT_SA]
	@ORDER_SEQ       					AS INT,
	@UID								AS VARCHAR(50)
AS
BEGIN
	
	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
        ,		@END_DATE						AS	VARCHAR(50)	= ''
	    ,		@MSG							AS	VARCHAR(150) = ''
	    ,		@SUBJECT						AS	VARCHAR(50) = ''
	    ,		@USERPHONE						AS	VARCHAR(50) = ''
	    ,		@COMPANY_NM						AS	VARCHAR(50) = '비핸즈카드'
	    ,		@SEND_PHONE						AS	VARCHAR(15) = '1644-9713'
	    ,		@COMPANY_SEQ					AS	INT = 5006
        ,       @COUPON_MST_SEQ                 AS  INT = 302
        ,       @ORDER_CNT                      AS  INT
        ,       @SALES_GUBUN                    AS  VARCHAR(2) = 'SA'

    -- 주문내역 확인/발급조건/100매이상
    IF  EXISTS (
        SELECT      *
        FROM        CUSTOM_ORDER
        WHERE       ORDER_SEQ = @ORDER_SEQ
        AND         MEMBER_ID = @UID
        AND         UP_ORDER_SEQ IS NULL
        AND         COMPANY_SEQ = @COMPANY_SEQ
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
