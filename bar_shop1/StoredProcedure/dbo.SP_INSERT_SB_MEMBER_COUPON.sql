IF OBJECT_ID (N'dbo.SP_INSERT_SB_MEMBER_COUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_SB_MEMBER_COUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2018-08-10
-- Description:	바른손카드 고객 전용 쿠폰 (비핸즈/프리미어)
-- EXEC dbo.[SP_INSERT_SB_MEMBER_COUPON] COMPANY_SEQ, UNAME, UPHONE
-- =============================================
CREATE PROCEDURE [dbo].[SP_INSERT_SB_MEMBER_COUPON]
	@SALES_GUBUN           					AS VARCHAR(2),
	@UNAME    								AS VARCHAR(50),
	@UPHONE                                 AS VARCHAR(50)
AS
BEGIN
	
    SET NOCOUNT ON

	
	/****** 20201123 표수현 추가 START ****/
	DECLARE	@ErrNum   INT          
		  , @ErrSev   INT          
		  , @ErrState INT          
		  , @ErrProc  VARCHAR(50)  
		  , @ErrLine  INT          
		  , @ErrMsg   VARCHAR(2000)
	/****** 20201123 표수현 추가 END ****/

	DECLARE @COUPON_CODE AS	VARCHAR(50) = '',
			@MSG AS  VARCHAR(500),       
			@RESULT AS VARCHAR(100),
			@MMS_MSG AS	VARCHAR(500),
			@SUBJECT AS	VARCHAR(50) = '',
			@COMPANY_NM AS	VARCHAR(50),
			@SEND_PHONE AS  VARCHAR(15),
			@COMMENT1 AS  VARCHAR(200),
			@COMMENT2 AS  VARCHAR(200),
			@DUP AS  VARCHAR(4) = ''

    -- 재신청인지 확인
    IF  EXISTS (
                SELECT  *
                FROM    EVENT_SMS_COUPON
                WHERE   1 = 1
                AND     SALES_GUBUN = @SALES_GUBUN
                AND     NAME = @UNAME
                AND     HPHONE = @UPHONE 
				) 
	BEGIN
		SET @RESULT = '이미 발급받으셨습니다.'
	END

    -- 신규신청
    ELSE BEGIN

        -- 비핸즈카드
        IF @SALES_GUBUN = 'SA' BEGIN
            SET @COUPON_CODE = '19DC-3FAD-4C26-9EC7'
            SET @COMPANY_NM = '비핸즈카드'
            SET @SEND_PHONE = '1644-9713'
            SET @COMMENT1 = '▶ 쿠폰사용 방법 '+CHAR(10) + 
                            + '① '+@COMPANY_NM+' 로그인' + CHAR(10) + '(https://bit.ly/2AKB8b2) '+ CHAR(10) 
                            +   '② 마이페이지 > 쿠폰관리 '+CHAR(10) 
                            +   '③ 쿠폰코드 등록 후 사용 가능' + CHAR(10)
            SET @COMMENT2 = '※ 거품 뺀 Good Price 청첩장'+CHAR(10)+'▼ '+@COMPANY_NM+'  자세히보기' + CHAR(10) + 'https://bit.ly/2nj3Rdw' + CHAR(10)
            SET @DUP = '중복'
        END

        -- 프리미어페이퍼
        ELSE IF @SALES_GUBUN = 'SS' BEGIN
            SET @COUPON_CODE = '69E4-C4F4-45E3-8037'
            SET @COMPANY_NM = '프리미어페이퍼'
            SET @SEND_PHONE = '1644-8796'
            SET @COMMENT1 = '▶ 쿠폰사용 방법 '+CHAR(10) + '① '+@COMPANY_NM+' 접속'+CHAR(10)+'(https://bit.ly/2OUgNU3) ' + CHAR(10) 
							+ '② 청첩장 주문 / 결제하기' + CHAR(10) 
                            + '③ 할인쿠폰 등록란에 쿠폰코드 입력 후 사용'+ CHAR(10) 
            SET @COMMENT2 = '※ 연예인이 선택한 프리미엄청첩장'+CHAR(10)+'▼ '+@COMPANY_NM+' 자세히보기 ' + CHAR(10) +'  https://bit.ly/2OUgNU3' + CHAR(10)
        END

        -- 데이터조합
        SET @SUBJECT = '[' + @COMPANY_NM + '] 쿠폰이 발급되었습니다.'
        SET @MMS_MSG = '['+@COMPANY_NM+'] 바른손카드에서 방문 해 주신 감사한 고객님께 '+@COMPANY_NM+''+@DUP+'할인 쿠폰이 발급 되었습니다.' + CHAR(10) + CHAR(10)
						+ '##'+@DUP+'할인쿠폰 ##' + CHAR(10) + CHAR(10)
						+ '▶ 쿠폰번호 ' +CHAR(10) + @COUPON_CODE + CHAR(10)
						+ @COMMENT1 + CHAR(10)
						+ '▶ 사용기한' +CHAR(10) + '쿠폰번호 발행 후 30일 내 '+ CHAR(10) + CHAR(10)
						+ @COMMENT2

        -- 문자발송
		
		/* 2020-11-23 KT 문자 서비스 작업 변경 */
		SET @UPHONE = '^' + @UPHONE
		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '',@MMS_MSG, '',@SEND_PHONE, 1, @UPHONE, 0, '', 0, @SALES_GUBUN, '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

		--INSERT INTO invtmng.MMS_MSG(SUBJECT, PHONE, CALLBACK, STATUS, REQDATE, MSG, TYPE) VALUES
		--(@SUBJECT, @UPHONE, @SEND_PHONE, '0', GETDATE(), @MMS_MSG, '0')

        -- 데이터저장
        INSERT INTO EVENT_SMS_COUPON(SALES_GUBUN, NAME, HPHONE, CREATED_TMSTMP) VALUES
        (@SALES_GUBUN, @UNAME, @UPHONE, GETDATE());

        SET @RESULT = '입력하신 휴대번호로 쿠폰이 발급 되었습니다. 문자를 확인 해주세요.';
    END

    SELECT @RESULT AS RESULT;
END

GO
