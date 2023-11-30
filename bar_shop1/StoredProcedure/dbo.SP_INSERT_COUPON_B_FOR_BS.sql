IF OBJECT_ID (N'dbo.SP_INSERT_COUPON_B_FOR_BS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_COUPON_B_FOR_BS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강찬용
-- Create date: 2021-01-20
-- Description:	COUPON_TYPE_CODE로 쿠폰발급 가능한 프로시저 (바른손스토어 전용)
-- EXEC dbo.[SP_INSERT_COUPON_B_FOR_BS] COUPON_TYPE_CODE, UID, COMPANY_SEQ
-- EXEC dbo.[SP_INSERT_COUPON_B_FOR_BS] 114014, 's4guest', 5006
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_COUPON_B_FOR_BS]
	@COUPON_TYPE_CODE       				AS INT,
	@UID    								AS VARCHAR(50),
	@COMPANY_SEQ       					    AS INT
AS
BEGIN
	
    SET NOCOUNT ON

	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
        ,       @SALES_GUBUN                    AS  VARCHAR(2) 
        ,       @MSG                            AS  VARCHAR(500)
        ,       @END_DATE                       AS  DATETIME

	SELECT @SALES_GUBUN = SALES_GUBUN FROM COMPANY WHERE COMPANY_SEQ = @COMPANY_SEQ

    BEGIN 
	    -- 이미 발급된 쿠폰이 있는 지 확인
	    IF	NOT EXISTS(
		    SELECT		*
		    FROM		S4_MyCoupon			A
		    INNER JOIN	s4_coupon			B ON A.coupon_code= B.coupon_code
		    WHERE		1 = 1
		    AND			A.UID = @UID
		    AND			A.COMPANY_SEQ = @COMPANY_SEQ
		    AND			B.COUPON_TYPE_CODE = @COUPON_TYPE_CODE
	    )
        BEGIN
		    -- 발급안된 쿠폰번호 검색 후, 쿠폰발급
            IF EXISTS(
                SELECT  *
                FROM	s4_coupon
                WHERE	1 = 1
                AND		COUPON_TYPE_CODE = @COUPON_TYPE_CODE
                --AND     end_date > getdate()
                AND		isYN = 'Y'
            )
                BEGIN
					SELECT  TOP(1) @COUPON_CODE =  COUPON_CODE, @END_DATE = END_DATE
					                FROM	s4_coupon
					                WHERE	1 = 1
					                AND		COUPON_TYPE_CODE = @COUPON_TYPE_CODE
					                --AND     end_date > getdate()
					                AND		isYN = 'Y'	 
					IF @COUPON_CODE <> ''
						BEGIN
		                    IF @END_DATE <> ''
		                        INSERT INTO S4_MyCoupon (COUPON_CODE, uid, company_seq, isMyYN, end_Date, reg_date) VALUES (@COUPON_CODE, @UID, @COMPANY_SEQ, 'Y', @END_DATE, getdate())
		                    ELSE
		                        INSERT INTO S4_MyCoupon (COUPON_CODE, uid, company_seq, isMyYN, end_Date, reg_date) VALUES (@COUPON_CODE, @UID, @COMPANY_SEQ, 'Y', null, getdate())
		
		                    
		                    SET @MSG = '쿠폰이 발행되었습니다.'
		                    
		                    UPDATE S4_coupon SET ISYN ='N' where COUPON_CODE = @COUPON_CODE
	                    END
					ELSE
						BEGIN
							SET @MSG = '발행할 수 없는 쿠폰입니다.'
						END
                END
            ELSE
                BEGIN
                    SET @MSG = '발행할 수 없는 쿠폰입니다.'
                END

           

        END
        ELSE
        BEGIN
            SET @MSG = '이미 발급되었습니다.'
        END
    END    

    SELECT @MSG AS RESULT;
END
GO
