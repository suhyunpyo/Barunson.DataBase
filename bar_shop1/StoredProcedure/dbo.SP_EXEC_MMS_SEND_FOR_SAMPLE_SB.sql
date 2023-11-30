IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_FOR_SAMPLE_SB', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_FOR_SAMPLE_SB
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
2020-08-27 정혜련  

1. LMS 발송 대상 필터링 내용
- 1차 필터링 : 바른손카드 샘플 주문 + LMS 수신 허용
- 2차 필터링 : 회원가입 시, 예식장 '호텔' 설정 or 바른손카드 샘플 선택 중, 소비자가 1,200원 이상 2종 이상 선택
- 3차 필터링 : LMS 발송일 기준 예식일 6개월 이후 or 예식일 1개월 전 고객 제외
청첩장 구매 고객 제외

2. LMS 자동 발송 요청 일정
- 샘플 발송일 기준, +4일 이후 LMS 자동 발송 요청
- LMS 발송 시작 일자 11월 6일 금요일 오전 11시 요청
(조건 부합 고객은 발송 시작 일자에 일괄 LMS 발송 요청 예정)


EXEC SP_EXEC_MMS_SEND_FOR_SAMPLE_SB
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_FOR_SAMPLE_SB]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @Today_Dt AS VARCHAR(8)  
 
    SET @TIME = ' 14:00:00'
 
  
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_sample CURSOR FAST_FORWARD  
 FOR  

 select CONVERT(VARCHAR(10), getdate(), 120) + @TIME AS SEND_DATE, sales_gubun, hphone
 from (
		select  c.sales_gubun  , m.hphone, c.sample_order_seq , m.WEDDING_HALL 
		,isnull((SELECT TOP  1 'Y' FROM CUSTOM_ORDER WHERE member_id = uid AND status_Seq > 0 AND status_seq NOT IN ('3','5') AND order_type IN ('1','6','7') ),'N') AS orderYN 
		,( select  count(ci.card_seq) from CUSTOM_SAMPLE_ORDER_ITEM ci, s2_Card s where ci.card_seq = s.card_seq and sample_order_seq = c.sample_order_seq and cardSet_price >= 1200 ) cardCnt
		from CUSTOM_SAMPLE_ORDER c, vw_user_info m
		where c.member_id = m.uid
			AND M.site_div ='SB'
			AND m.chk_sms ='Y'
			and LEN(m.HPHONE) > 12 
			and m.WEDDING_DAY < convert(char(10),dateadd(month,6,getdate()),23)
			and m.WEDDING_DAY > convert(char(10),dateadd(month,1,getdate()),23)
			and c.sales_gubun ='SB'
			and c.DELIVERY_DATE >= CONVERT(CHAR(10), GETDATE() - 5, 23)
			and c.DELIVERY_DATE < CONVERT(CHAR(10), GETDATE() - 4 , 23)  
	) a WHERE orderYN = 'N'
		and ( WEDDING_HALL ='H' OR  cardCnt >= 2 ) 

 OPEN cur_AutoInsert_For_sample  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @U_ID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @MMS_PHONE VARCHAR(50)  
 DECLARE @ETC_INFO VARCHAR(50)  

 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  
  
 FETCH NEXT FROM cur_AutoInsert_For_sample INTO @MMS_DATE, @SERVICE,  @PHONE_NUM
  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  

		IF @SERVICE = 'SB'  
		BEGIN  
			SET @NO_REC_BRAND = '바른손카드'      
			SET @MMS_PHONE  = '1644-0708'  
		END  

		SET @MMS_SUBJECT = '[광고] 바른손카드 고객을 위한 프리미엄 청첩장 제안'

		SET @MMS_MSG = '[광고] 바른손카드 고객을 위한
		프리미엄 청첩장 제안-

		하나뿐인 우리의 결혼식,
		주인공이 되는 특별한 날인만큼
		기억에 남을 아름다운 웨딩을 꿈꾼다면!

		셀럽들의 특별한 날을 함께한
		프리미어페이퍼 청첩장으로
		당신의 한 번 뿐인 웨딩을 빛내보세요!

		▶ 셀럽이 선택한 청첩장 보러가기
		https://m.premierpaper.co.kr/mobile/product/c_choice_lms.asp
 
		[수신거부] '+ @NO_REC_BRAND+' 고객센터
		 '+ @MMS_PHONE + '로 수신거부 문자 전송'

		SET @MMS_DATE = REPLACE(REPLACE(REPLACE(@MMS_DATE, '-', ''), ':', ''), ' ', '')
		SET @PHONE_NUM = 'AA^' + @PHONE_NUM

		----------------------------------------------------------------------------------
		-- KT
		----------------------------------------------------------------------------------
		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 1, @MMS_SUBJECT, @MMS_MSG, @MMS_DATE, @MMS_PHONE, 1, @PHONE_NUM, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
		
		----------------------------------------------------------------------------------
		-- LG 데이콤(구버전)
		---------------------------------------------------------------------------------- 
		--INSERT INTO invtmng.MMS_MSG(subject, phone, callback, status, reqdate, msg, TYPE)  
		--VALUES (  @MMS_SUBJECT  
		--	, @PHONE_NUM  
		--	, @MMS_PHONE  
		--	, '0'  
		--	, @MMS_DATE  
		--	, @MMS_MSG  
		--	, '0' 
		--)  

		FETCH NEXT FROM cur_AutoInsert_For_sample INTO  @MMS_DATE, @SERVICE,  @PHONE_NUM
	END  
  
	CLOSE cur_AutoInsert_For_sample  
	DEALLOCATE cur_AutoInsert_For_sample  
END
GO
