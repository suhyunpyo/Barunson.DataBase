IF OBJECT_ID (N'dbo.sp_joinmember_MMS', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_joinmember_MMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*----------------------------------------------------------------------------------------------
1.Stored Procedure	: sp_joinmember_MMS
2.관련 Table		: invtmng.MMS_MSG
3.내용				: 회원가입 MMS 발송
						- barunson , bhands , premier , thecard
4.작성자			: zen
5.작성일			: 2013.07.05
6.수정				:
-----------------------------------------------------------------------------------------------*/

/* 사용 방법-------------------------------------------------------------------------------------

01073810423
exec [dbo].[sp_joinmember_MMS] '0167237442','bhands'
exec [dbo].[sp_joinmember_MMS] '01073810423','barunson'
exec [dbo].[sp_joinmember_MMS] '01073810423','thecard'
exec [dbo].[sp_joinmember_MMS] '0167237442','premier'

-- select * from invtmng.MMS_MSG

exec [dbo].[sp_joinmember_MMS] '01067640922','premier'

-----------------------------------------------------------------------------------------------*/


CREATE     Procedure [dbo].[sp_joinmember_MMS]

@phone varchar(50),
@type  varchar(15)

as

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)
	  , @msg VARCHAR(2000)

set @phone = 'AA^'+@phone

if @type ='bhands'
	BEGIN
	    set @msg = '
		업계1위 바른손tkld카드의 더 큰 이름, 비핸즈카드에 가입하여 주셔서 감사합니다.
		1970년 최초로 시작해 2013년 최고를 지켜온 비핸즈카드! 

		모방할 수 없는 품질과 가치로 고객님의 특별한 청첩장을 제작하여 드리겠습니다. 

		[이벤트]
		세계1위 삼성전자와 비핸즈카드가 함께 드리는 비핸즈회원만의 특별한 혜택도 함께하세요!		 

		- 삼성디지털프라자 혼수전문점에서 300만원 이상 구매 시
		디지털프라자 혼수전문점 기본혜택 + 리턴페이 7% + 샘소나이트 여행가방		 

		- 삼성디지털프라자 혼수전문점에서 300만원 이상 구매 시
		디지털프라자 혼수전문점 기본혜택 + 리턴페이 7% + 에코네츄얼 세라믹 홈세트 20pcs 
		
		이벤트자세히 - http://www.bhandscard.com/event/event_affiliated.asp

		Have a nice day!

		'

		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '[비핸즈카드 회원가입 완료 메시지]', @msg, '', '16449713', 1, @phone, 0, '', 0, 'SA', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT


	END
ELSE IF @type = 'barunson'
	BEGIN

	    set @msg ='
		The Original Since 1970!
		44년 전통의 업계1위! 바른손카드의 회원가입을 축하합니다.		 

		1970년 최초로 시작해 2013년 최고를 지켜온 바른손카드! 		 

		세상에서 가장 아름다운 여행 결혼, 그 시작에는 늘 바른손카드가 있습니다.		 

		[이벤트]
		세계1위 삼성전자와 바른손카드가 함께 드리는 바른손회원만의 특별한 혜택도 함께하세요!		 

		- 삼성디지털프라자 혼수전문점에서 300만원 이상 구매 시
		디지털프라자 혼수전문점 기본혜택 + 리턴페이 7% + 샘소나이트 여행가방		 

		- 삼성디지털프라자 혼수전문점에서 300만원 이상 구매 시
		디지털프라자 혼수전문점 기본혜택 + 리턴페이 7% + 에코네츄얼 세라믹 홈세트 20pcs		
		
		이벤트자세히 - http://www.barunsoncard.com/event/event_affiliated.asp

		Have a nice day!
		'

		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '[바른손카드 회원가입 완료 메시지]', @msg, '', '16440708', 1, @phone, 0, '', 0, 'SB', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

		
	END
ELSE IF @type = 'thecard'
	BEGIN
		set @msg = '
		NO.1 대한민국 청첩장 더카드!
		비핸즈카드에서 운영하는 대한민국 NO.1 청첩장쇼핑몰 더카드 회원가입을 축하합니다.		 

		비핸즈카드의 운영노하우와 다양한 청첩장 브랜드로 고객님께 어울리는 맞춤형 청첩장을
		제작하여 드리겠습니다.		 

		[이벤트]
		세계1위 삼성전자와 더카드가 함께 드리는 더카드회원만의 특별한 혜택도 함께하세요!		 

		- 삼성디지털프라자 혼수전문점에서 300만원 이상 구매 시
		디지털프라자 혼수전문점 기본혜택 + 리턴페이 7% + 샘소나이트 여행가방		 

		- 삼성디지털프라자 혼수전문점에서 300만원 이상 구매 시
		디지털프라자 혼수전문점 기본혜택 + 리턴페이 7% + 에코네츄얼 세라믹 홈세트 20pcs		
		
		이벤트자세히 - http://www.thecard.co.kr/event/event_affiliated.asp 

		고객님의 새로운 출발을 응원합니다!
		'

		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '[더카드 회원가입 완료 메시지]', @msg, '', '16447998', 1, @phone, 0, '', 0, 'ST', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

	
	END
ELSE IF @type = 'premier'
	BEGIN 
		set @msg = '
		가치있는 선택, 프리미어페이퍼에 가입하여 주셔서 감사합니다.
		1970년 최초로 시작해 2013년 최고를 지켜온 프리미어페이퍼! 

		프리미어페이퍼는 업계1위 44년 전통의 바른손카드에서 운영합니다.
		모방할 수 없는 품질과 가치로 고객님의 특별한 청첩장을 제작하여 드리겠습니다. 

		[이벤트]
		세계1위 삼성전자와 프리미어페이퍼가 함께 드리는 프리미어페이퍼회원만의 특별한 혜택도 함께하세요! 

		- 삼성디지털프라자 혼수전문점에서 300만원 이상 구매 시
		디지털프라자 혼수전문점 기본혜택 + 리턴페이 7% + 샘소나이트 여행가방 

		- 삼성디지털프라자 혼수전문점에서 300만원 이상 구매 시
		디지털프라자 혼수전문점 기본혜택 + 리턴페이 7% + 에코네츄얼 세라믹 홈세트 20pcs 

		Have a nice day!

		'

		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '[프리미어페이퍼 회원가입 완료 메시지]', @msg, '', '16448796', 1, @phone, 0, '', 0, 'SS', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

	
	END
ELSE

	select 4



GO
