IF OBJECT_ID (N'dbo.SP_INSERT_LOTTEDUTY_COUPON_LMS_2019', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_LOTTEDUTY_COUPON_LMS_2019
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2019-01-23
-- Description:	바비더프몰 롯데면세점 쿠폰발급 LMS

-- =============================================
CREATE PROCEDURE [dbo].[SP_INSERT_LOTTEDUTY_COUPON_LMS_2019]
	@COUPON_MST_SEQ       					AS INT,
	@UID    								AS VARCHAR(50),
	@COUPON_CODE       					    AS VARCHAR(50)
AS
BEGIN
	
    SET NOCOUNT ON

	/****** 20201123 표수현 추가 START ****/
	DECLARE	@ErrNum   INT, 
			@ErrSev   INT,
			@ErrState INT,
			@ErrProc  VARCHAR(50),
			@ErrLine  INT,
			@ErrMsg   VARCHAR(2000),
			@SITE_TYPE AS VARCHAR(4)
	  
    SET @SITE_TYPE = CASE WHEN @COUPON_MST_SEQ = 5001 THEN 'SB'
						  WHEN @COUPON_MST_SEQ = 5003 THEN 'SS'
						  WHEN @COUPON_MST_SEQ = 5006 THEN 'SA'
					ELSE 'B'
					END
	/****** 20201123 표수현 추가 END ****/

    DECLARE @MMS_MSG	AS	VARCHAR(1000)
	,   @SUBJECT	AS	VARCHAR(50) = '롯데인터넷면세점 이벤트 안내'
	,   @USERPHONE	AS	VARCHAR(50) = ''
	,   @COMPANY_NM	AS	VARCHAR(50) = ''
	,   @SEND_PHONE	AS	VARCHAR(15) = ''

    IF @COUPON_MST_SEQ = 213
    BEGIN
        SET @COMPANY_NM = '바른손카드'
        SET @SEND_PHONE = '1644-0708'
    END
    ELSE IF @COUPON_MST_SEQ = 214
    BEGIN
        SET @COMPANY_NM = '비핸즈카드'
        SET @SEND_PHONE = '1644-9713'
    END
    ELSE IF @COUPON_MST_SEQ = 215
    BEGIN
        SET @COMPANY_NM = '더카드'
        SET @SEND_PHONE = '1644-7998'
    END
    ELSE IF @COUPON_MST_SEQ = 216
    BEGIN
        SET @COMPANY_NM = '프리미어페이퍼'
        SET @SEND_PHONE = '1644-8796'
    END
    ELSE IF @COUPON_MST_SEQ = 217
    BEGIN
        SET @COMPANY_NM = '바른손몰'
        SET @SEND_PHONE = '1644-7413'
    END

	SET @MMS_MSG = '이벤트 1. '+@COMPANY_NM+' 추가 적립금 
$3 증정 이벤트에 참여하셨습니다. 

- 쿠폰 교환번호 :  '+ @COUPON_CODE+ '
- 쿠폰혜택 : 롯데인터넷면세점 적립금 $3 지급
- 교환기간 : ~ 2019. 12. 31 
- 적립금 사용기간 : 발급일로부터 60일

[쿠폰 교환방법] 
이벤트 페이지 (http://kor.lottedfs.com/kr/event/eventDetail?evtDispNo=1016877) 접속
쿠폰 교환번호 입력  

[유의사항]
- 본 이벤트는 PC와 모바일에서 동시 진행되며 
  1인 1회 참여가능합니다.
- 다운받은 적립금은 마이롯데에서 확인 가능합니다. 
- 일부 브랜드 및 특정 상품은 브랜드 정책에 따라 적립금이
   적용되지 않습니다. 
- 기타 자세한 내용은 해당 이벤트 페이지를 참고하세요. 

[고객문의]
롯데면세점 고객센터 1688-3000'+ char(13) + char(10)
	
    SET @SUBJECT = '['+@COMPANY_NM+']'+@SUBJECT

	SELECT	@USERPHONE      =   HAND_PHONE1 + HAND_PHONE2 + HAND_PHONE3
	FROM	S2_USERINFO
	WHERE	UID = @UID

	
  /* 2020-11-23 KT 문자 서비스 작업 변경 */
  SET @USERPHONE = '^' + @USERPHONE
       EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MMS_MSG, '', @SEND_PHONE, 1, @USERPHONE, 0, '', 0, @SITE_TYPE, '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

	--INSERT INTO invtmng.MMS_MSG(SUBJECT, PHONE, CALLBACK, STATUS, REQDATE, MSG, TYPE,etc4) VALUES
	--(@SUBJECT, @USERPHONE, @SEND_PHONE, '0', GETDATE(), @MMS_MSG, '0', 1)


END

GO
