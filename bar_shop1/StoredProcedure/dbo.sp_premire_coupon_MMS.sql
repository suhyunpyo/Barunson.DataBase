IF OBJECT_ID (N'dbo.sp_premire_coupon_MMS', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_premire_coupon_MMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------------------------
1.STORED PROCEDURE	: SP_PREMIRE_COUPON_MMS
2.관련 TABLE		: INVTMNG.MMS_MSG
3.내용				: 프리미어 쿠폰 이벤트 MMS 발송
4.작성자			: ZEN
5.작성일			: 2014.11.21
6.수정				:
-----------------------------------------------------------------------------------------------*/

/* 사용 방법-------------------------------------------------------------------------------------

INSERT INTO S4_COUPON 
(COUPON_CODE, COMPANY_SEQ, UID, DISCOUNT_TYPE, DISCOUNT_VALUE, LIMIT_PRICE, COUPON_DESC, ISWEDDINGCOUPON, ISJEHU)
VALUES
('PBHR20KF64778', 5003, 'SSHNAD', 'R', 20, 100,'프리미어페이퍼 SPECIAL SALE 20% 쿠폰', 'Y', 'N')

[SP_PREMIRE_COUPON_MMS] '01023578510','PREMIRE','2015-03-13','PBHR20KF64778'

[SP_PREMIRE_COUPON_MMS] '01020862730','PREMIER150507','2015-06-11','PBHR15VEAFGTY'

SELECT * FROM INVTMNG.MMS_MSG

-----------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[sp_premire_coupon_MMS]
@PHONE VARCHAR(15),
@COMPANY  VARCHAR(100),
@ENDDATE  VARCHAR(15), 
@COUPON_NO VARCHAR(50)
AS

	/* 20201123 추가 START */
	DECLARE	@ERRNUM INT,
			@ERRSEV INT, 
			@ERRSTATE INT, 
			@ERRPROC VARCHAR(50), 
			@ERRLINE INT, 
			@ERRMSG VARCHAR(2000),
			@SITE_TYPE AS VARCHAR(4)

	/* 20201123 추가 END */
     
	DECLARE @SMS_MSG VARCHAR(MAX) = ''

	IF @COMPANY ='PREMIRE' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] 바른손카드 VIP 고객만의 특권!' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG + 'SUPER 2WEEKS! 주문제품 추가 20% 할인쿠폰' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '- 사용기간 : ' + @ENDDATE + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '- 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10)  + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 

--		INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
--		VALUES(
--		'[프리미어페이퍼]',@PHONE,'16448796','0',GETDATE(),
--		'
		
--[프리미어페이퍼] 바른손카드 VIP 고객만의 특권!
--SUPER 2WEEKS! 주문제품 추가 20% 할인쿠폰
--- 사용기간 : ' + @ENDDATE + '
--- 쿠폰번호 : ' + @COUPON_NO + '

--<<쿠폰 사용 방법>>
--초안컨펌 후 -> 결제시 쿠폰번호 입력

--http://www.premierpaper.co.kr/



--		','0'
--		)
		
	END ELSE IF @COMPANY = 'PREMIREJEHU' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] 바른손카드 VIP 고객만의 특권!' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG + 'SUPER 2WEEKS! 주문제품 추가 20% 할인쿠폰' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '- 사용기간 : ' + @ENDDATE + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '- 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10)  + CHAR(10) 

--		INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
--		VALUES(
--		'[프리미어페이퍼]',@PHONE,'16448796','0',GETDATE(),
--		'
--[프리미어페이퍼] 바른손카드 VIP 고객만의 특권!
--SUPER 2WEEKS! 주문제품 추가 20% 할인쿠폰
--- 사용기간 : ' + @ENDDATE + '
--- 쿠폰번호 : ' + @COUPON_NO + '

--<<쿠폰 사용 방법>>
--초안컨펌 후 -> 결제시 쿠폰번호 입력



--		','0'
--		)
		
	END ELSE IF @COMPANY = 'PREMIER150507' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] 결혼을 축하드립니다♡' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG + '무더운 여름예식, 시원함을 선사합니다! ' + CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '▶ 15% 할인쿠폰 + 제본 서비스 제공! ' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '▶ 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '▶ 유효기간: ~' +  @ENDDATE + '까지' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10)  + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 

		--INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
		--		VALUES(
		--		'[프리미어페이퍼]',@PHONE,'16448796','0',GETDATE(),
		--		'
		--[프리미어페이퍼] 결혼을 축하드립니다♡
		--무더운 여름예식, 시원함을 선사합니다! 

		--▶ 15% 할인쿠폰 + 제본 서비스 제공!
		--▶ 쿠폰번호: ' + @COUPON_NO + '
		--▶ 유효기간: ~' + @ENDDATE + '까지

		--<<쿠폰 사용 방법>>
		--초안컨펌 후 -> 결제시 쿠폰번호 입력
		--http://www.premierpaper.co.kr/', 
		--		'0'
		--        )
	
	END ELSE IF @COMPANY = 'PREMIERSUPER1WEEK' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] SUPER WEEK 20% SALE!' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '- 사용기간 : ' + @ENDDATE + + '까지' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '- 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 

		--INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
		--		VALUES(
		--		'[프리미어페이퍼]',@PHONE,'16448796','0',GETDATE(),
		--		'

		--[프리미어페이퍼] SUPER WEEK 20% SALE! 
		--- 사용기간: ~' + @ENDDATE + '까지
		--- 쿠폰번호: ' + @COUPON_NO + '
		--<<쿠폰 사용 방법>>
		--초안컨펌 후 -> 결제시 쿠폰번호 입력HTTP://WWW.PREMIERPAPER.CO.KR/
		--		', '0'
		--		)

	END ELSE IF @COMPANY = 'PREMIERSURPRISE10' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼]' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG + '더할 나위 없는 10일의 찬스! ' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG + '★SURPRISE 20% SALE★' + CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '- 사용기간 : ' + @ENDDATE + '까지' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '- 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 


	--	INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
	--	VALUES(
	--	'[프리미어페이퍼]',@PHONE,'16448796','0',GETDATE(),
	--	'

	--[프리미어페이퍼] 
	--더할 나위 없는 10일의 찬스! 
	--★SURPRISE 20% SALE★
 
	--- 사용기간: ~' + @ENDDATE + '까지
	--- 쿠폰번호: ' + @COUPON_NO + '
	--<<쿠폰 사용 방법>>
	--초안컨펌 후 -> 결제시 쿠폰번호 입력
	--HTTP://WWW.PREMIERPAPER.CO.KR/
	--	', '0'
	--	)
    END ELSE IF @COMPANY = 'PREMIERSERVICE08' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼]' + CHAR(10)
		SET @SMS_MSG = @SMS_MSG + '품질의 차이를 선택하신 프리미어 고객님에게 드리는 10,000원 할인쿠폰!' + CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '- 사용기간 : ' + @ENDDATE + '까지' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '- 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 

	--	INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
	--		VALUES(
	--		'[프리미어페이퍼]고객님에게 드리는 10,000원 할인쿠폰',@PHONE,'16448796','0',GETDATE(),
	--		'
	--		[프리미어페이퍼]
	--품질의 차이를 선택하신 프리미어 고객님에게 드리는 10,000원 할인쿠폰!
 
	--- 사용기간: ~' + @ENDDATE + '까지
	--- 쿠폰번호: ' + @COUPON_NO + '
	--<<쿠폰 사용 방법>>
	--초안컨펌 후 -> 결제시 쿠폰번호 입력
	--http://www.premierpaper.co.kr/
	--        ', '0'
	--        )
    END ELSE IF @COMPANY = 'WEEKLYPICK' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] WEEKLY PICK 20% SALE!'+ CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '- 사용기간 : ' + @ENDDATE + '까지' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '- 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 

--		INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
--		VALUES(
--		'[프리미어페이퍼] WEEKLY PICK 20% SALE!',@PHONE,'16448796','0',GETDATE(),
--		'[프리미어페이퍼] WEEKLY PICK 20% SALE!
 
--- 사용기간: ~' + @ENDDATE + '까지
--- 쿠폰번호: ' + @COUPON_NO + '
--<<쿠폰 사용 방법>>
--초안컨펌 후 -> 결제시 쿠폰번호 입력
--http://www.premierpaper.co.kr/
--        ', '0'
--        )
    END ELSE IF @COMPANY = 'EVENT1541' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] 스타가 선택한 청첩장! 시크릿 5만원 할인쿠폰! '+ CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '- 사용기간 : ' + @ENDDATE + '까지' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '- 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 

		--INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
		--		VALUES(
		--		'[프리미어페이퍼] 스타가 선택한 청첩장! 시크릿 5만원 할인쿠폰!', @PHONE, '16448796', '0', GETDATE(),
		--		'[프리미어페이퍼] 스타가 선택한 청첩장! 시크릿 5만원 할인쿠폰!  
 
		--- 사용기간: ' + @ENDDATE + '까지
		--- 쿠폰번호: ' + @COUPON_NO + '

		--<<쿠폰 사용 방법>>
		--초안컨펌 후 -> 결제시 쿠폰번호 입력
		--HTTP://WWW.PREMIERPAPER.CO.KR/
		--		', '0'
		--)
	END ELSE IF @COMPANY = '2015NOV11' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] 11월11일 PREMIUM DAY 11% 할인 쿠폰'+ CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '- 사용기간 : ' + @ENDDATE + '까지' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '- 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 


		--INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
		--VALUES(
		--'[프리미어페이퍼] 11월11일 PREMIUM DAY 11% 할인 쿠폰', @PHONE, '16448796', '0', GETDATE(),
		--'[프리미어페이퍼] 11월11일 PREMIUM DAY 11% 할인 쿠폰  
 
		--- 사용기간: ' + @ENDDATE + '까지
		--- 쿠폰번호: ' + @COUPON_NO + '

		--	<<쿠폰 사용 방법>>
		--	초안컨펌 후 -> 결제시 쿠폰번호 입력
		--	HTTP://WWW.PREMIERPAPER.CO.KR/
		--			', '0'
		--	)
	END ELSE IF @COMPANY = 'SUMMER201610' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] ★MY SUMMER WEDDING 10% 할인쿠폰'+ CHAR(10)
		SET @SMS_MSG = @SMS_MSG + '일생의 단 한번, 당신의 가장 빛나는 여름을 축하 드립니다!'+ CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '▶ 10%할인쿠폰 : ' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '▶ 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '▶ 유효기간 : ' +  @ENDDATE + '까지'+ CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10) + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '고객센터: 1644-8796' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 

		--INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
		--VALUES(
		--'[프리미어페이퍼] ★MY SUMMER WEDDING 10% 할인쿠폰', @PHONE, '16448796', '0', GETDATE(),
		--'[프리미어페이퍼] ★MY SUMMER WEDDING 10% 할인쿠폰
		--일생의 단 한번, 당신의 가장 빛나는 여름을 축하 드립니다!

		--▶ 10%할인쿠폰
		--▶ 쿠폰번호: ' + @COUPON_NO + '
		--▶ 유효기간: ' + @ENDDATE + '까지
		--▶ 쿠폰 사용 방법
		--	초안컨펌 후, 결제시 쿠폰번호 입력
			
		--고객센터: 1644-8796
		--HTTP://WWW.PREMIERPAPER.CO.KR/
		--			', '0'
		--	)
	END ELSE IF @COMPANY = 'SUMMER201615' BEGIN

		SET @SMS_MSG = @SMS_MSG + '[프리미어페이퍼] ★MY SUMMER WEDDING 15% 할인쿠폰'+ CHAR(10)
		SET @SMS_MSG = @SMS_MSG + '일생의 단 한번, 당신의 가장 빛나는 여름을 축하 드립니다!'+ CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '▶ 15%할인쿠폰 : ' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '▶ 쿠폰번호 : ' +  @COUPON_NO + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '▶ 유효기간 : ' +  @ENDDATE + '까지'+ CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '<<쿠폰 사용 방법>>' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG +  '초안컨펌 후 -> 결제시 쿠폰번호 입력' + CHAR(10) + CHAR(10)
		SET @SMS_MSG = @SMS_MSG +  '고객센터: 1644-8796' + CHAR(10) 
		SET @SMS_MSG = @SMS_MSG + 'http://www.premierpaper.co.kr/' + CHAR(10)  + CHAR(10) 

		--INSERT INTO INVTMNG.MMS_MSG(SUBJECT,PHONE,CALLBACK,STATUS,REQDATE,MSG,TYPE) 
		--VALUES(
		--'[프리미어페이퍼] ★MY SUMMER WEDDING 15% 할인쿠폰', @PHONE, '16448796', '0', GETDATE(),
		--'[프리미어페이퍼] ★MY SUMMER WEDDING 15% 할인쿠폰
		--일생의 단 한번, 당신의 가장 빛나는 여름을 축하 드립니다!

		--▶ 15%할인쿠폰
		--▶ 쿠폰번호: ' + @COUPON_NO + '
		--▶ 유효기간: ' + @ENDDATE + '까지
		--▶ 쿠폰 사용 방법
		--	초안컨펌 후, 결제시 쿠폰번호 입력
			
		--고객센터: 1644-8796
		--HTTP://WWW.PREMIERPAPER.CO.KR/
		--			', '0'
		--	)
	END ELSE  BEGIN 
			SELECT 4
	END

	SET @PHONE = '^' + @PHONE
	--20201123 표수현 KT 발송 --
	EXEC BAR_SHOP1.DBO.PROC_SMS_MMS_SEND '', 0, '', @SMS_MSG, '', '16448796', 1, @PHONE, 0, '', 0, @COMPANY, '', '', '', '', @ERRNUM OUTPUT, @ERRSEV OUTPUT, @ERRSTATE OUTPUT, @ERRPROC OUTPUT, @ERRLINE OUTPUT, @ERRMSG OUTPUT
  
GO
