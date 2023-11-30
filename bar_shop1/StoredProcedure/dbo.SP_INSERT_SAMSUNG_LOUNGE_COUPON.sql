IF OBJECT_ID (N'dbo.SP_INSERT_SAMSUNG_LOUNGE_COUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_SAMSUNG_LOUNGE_COUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		정혜련
-- Create date: 2019-08-30
-- Description:	삼성 인천라운지 쿠폰발급
-- EXEC dbo.[SP_INSERT_LOTTEDUTY_COUPON] COUPON_MST_SEQ, UID
-- EXEC dbo.[SP_INSERT_LOTTEDUTY_COUPON] 134, 's4guest'
-- 바른손 : 520
-- 비핸즈 : 521
-- 더카드 : 519
-- 프리미어페이퍼: 523
-- 몰 : 522
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_SAMSUNG_LOUNGE_COUPON]
	@UID    								AS VARCHAR(50),
	@COMPANY_SEQ       					    AS INT
AS
BEGIN
	
    SET NOCOUNT ON

	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
        ,       @SALES_GUBUN                    AS  VARCHAR(2) 
        ,       @COUPON_DOWN_YN                 AS  VARCHAR(1) = 'N'
        ,       @MSG                            AS  VARCHAR(500)
        ,       @COUPON_MST_SEQ					AS  INT

	
	-- 쿠폰 MST_SEQ 
	select @SALES_GUBUN = sales_gubun from company where company_seq = @COMPANY_SEQ

	if @SALES_GUBUN = 'SB' -- 바른손
		BEGIN
			SET @COUPON_MST_SEQ = 520
		END
	ELSE IF @SALES_GUBUN = 'SA' -- 비핸즈
		BEGIN
			SET @COUPON_MST_SEQ = 521
		END
	ELSE IF @SALES_GUBUN = 'ST' -- 더카드
		BEGIN
			SET @COUPON_MST_SEQ = 519
		END
	ELSE IF @SALES_GUBUN = 'SS' -- 프리미어페이퍼
		BEGIN
			SET @COUPON_MST_SEQ = 523
		END
	ELSE
		BEGIN
			SET @SALES_GUBUN = 'B'
			SET @COUPON_MST_SEQ = 522
		END



    SET @COUPON_DOWN_YN = 'N'
   
    
    IF ( @COUPON_MST_SEQ = 519 OR @COUPON_MST_SEQ = 520 OR @COUPON_MST_SEQ = 521 OR @COUPON_MST_SEQ = 522 OR @COUPON_MST_SEQ = 523)
	BEGIN
		-- 삼성고객
		IF  EXISTS (
                    SELECT UID
					FROM S2_USERINFO_BHANDS 
					WHERE UID = @UID 
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

   
					-- 바른손몰
					IF ( @COUPON_MST_SEQ = 522) 		    
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
