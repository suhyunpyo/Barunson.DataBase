IF OBJECT_ID (N'dbo.SP_INSERT_LOTTEDUTY_COUPON_LMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_LOTTEDUTY_COUPON_LMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		정혜련
-- Create date: 2018-04-02
-- Description:	바른손카드 롯데면세점 쿠폰발급 LMS

-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_LOTTEDUTY_COUPON_LMS]
	@COUPON_MST_SEQ       					AS INT,
	@UID    								AS VARCHAR(50),
	@COUPON_CODE       					    AS VARCHAR(50)
AS
BEGIN
	
    SET NOCOUNT ON

    DECLARE @MMS_MSG	AS	VARCHAR(1000)
	,   @SUBJECT	AS	VARCHAR(50) = '[바른손카드] 롯데인터넷면세점 이벤트 안내'
	,   @USERPHONE	AS	VARCHAR(50) = ''
	,   @COMPANY_NM	AS	VARCHAR(50) = '바른손카드'
	,   @SEND_PHONE	AS	VARCHAR(15) = '1644-0708'

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)


	IF @COUPON_MST_SEQ = 132

	begin
	SET @MMS_MSG = '이벤트 1. 바른손카드 추가 적립금 
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
	END 

	ELSE IF @COUPON_MST_SEQ = 133
	begin
	SET @MMS_MSG = '이벤트 2. 바른손카드 샘플신청고객으로
플래티늄 즉시 등업 이벤트에 참여하셨습니다. 

- 쿠폰 교환번호 :  '+ @COUPON_CODE+ '
- 쿠폰혜택 : 롯데인터넷면세점 플래티늄 등급 혜택 
- 교환기간 : ~ 2018. 12. 31 
- 혜택기간 : 등업일로부터 1년

[쿠폰 교환방법] 
이벤트 페이지 (https://goo.gl/yQ9LtY) 접속
쿠폰 교환번호 입력  

[유의사항]
- 본 이벤트는 PC와 모바일에서 동시 진행되며 
  1인 1회 참여가능합니다.
- 일부 브랜드 및 특정 상품은 브랜드 정책에 따라 적립금이
  및 할인율 적용이 되지 않습니다.
-기타 자세한 내용은 해당 이벤트 페이지를 참고하세요.  

[고객문의]
롯데면세점 고객센터 1688-3000'+ char(13) + char(10)
	END 
	ELSE IF @COUPON_MST_SEQ = 134
	begin
	SET @MMS_MSG = '이벤트 3. 바른손카드 청첩장구매고객으로
플래티늄+ 즉시 등업 이벤트에 참여하셨습니다. 

- 쿠폰 교환번호 :  '+ @COUPON_CODE+ '
- 쿠폰혜택 : 롯데인터넷면세점 플래티늄 등급 혜택 
- 교환기간 : ~ 2018. 12. 31 
- 혜택기간 : 등업일로부터 1년

[쿠폰 교환방법] 
이벤트 페이지 (https://goo.gl/6cYBhL) 접속
쿠폰 교환번호 입력  

[유의사항]
- 본 이벤트는 PC와 모바일에서 동시 진행되며 
  1인 1회 참여가능합니다.
- 일부 브랜드 및 특정 상품은 브랜드 정책에 따라 적립금이
  및 할인율 적용이 되지 않습니다.
-기타 자세한 내용은 해당 이벤트 페이지를 참고하세요.  

[고객문의]
롯데면세점 고객센터 1688-3000
'+ char(13) + char(10)
	END 

	SELECT	@USERPHONE      = UNAME + '^'+  HAND_PHONE1 + HAND_PHONE2 + HAND_PHONE3
	FROM	S2_UserInfo_TheCard
	WHERE	UID = @UID


	EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND @UID, 0, @SUBJECT, @MMS_MSG, '', @SEND_PHONE, 1, @USERPHONE, 0, '', 0, 'SB', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT



END
GO
