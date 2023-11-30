IF OBJECT_ID (N'dbo.SP_INSERT_COUPON_MST_SEQ', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_COUPON_MST_SEQ
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2019-02-11
-- Description:	MST_SEQ로 쿠폰발급 가능한 프로시저
-- EXEC dbo.[SP_INSERT_COUPON_MST_SEQ] COUPON_MST_SEQ, UID
-- EXEC dbo.[SP_INSERT_COUPON_MST_SEQ] 134, 's4guest'
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_COUPON_MST_SEQ]
	@COUPON_MST_SEQ       					AS INT,
	@UID    								AS VARCHAR(50),
	@COMPANY_SEQ       					    AS INT
AS
BEGIN
	
    SET NOCOUNT ON

	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
        ,       @ORDER_CNT                      AS  INT
        ,       @SALES_GUBUN                    AS  VARCHAR(2) 
        ,       @MSG                            AS  VARCHAR(500)

	SELECT @SALES_GUBUN = SALES_GUBUN FROM COMPANY WHERE COMPANY_SEQ = @COMPANY_SEQ

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
           
			SET @MSG = (SELECT RESULT_MESSAGE FROM @TABLE_TEMP)
            UPDATE COUPON_DETAIL SET DOWNLOAD_ACTIVE_YN = 'N' WHERE COUPON_CODE = @COUPON_CODE 

        END
        ELSE
        BEGIN
            SET @MSG = '이미 발급되었습니다.'
        END
    END    

    SELECT @MSG AS RESULT;
END
GO
