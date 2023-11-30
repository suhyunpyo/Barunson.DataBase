IF OBJECT_ID (N'dbo.sp_shakr_coupon_MMS', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_shakr_coupon_MMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*----------------------------------------------------------------------------------------------
1.Stored Procedure	: sp_shakr_coupon_MMS
2.관련 Table		: invtmng.MMS_MSG
3.내용				: 쉐이커 쿠폰 MMS 발송
4.작성자			: zen
5.작성일			: 2014.09.26
6.수정				:
-----------------------------------------------------------------------------------------------*/

/* 사용 방법-------------------------------------------------------------------------------------

[sp_shakr_coupon_MMS] '01027237442','bhands','BHAND-SQVST-SS2S8','30000'
[sp_shakr_coupon_MMS] '01027237442','bhands','BHAND-SQVST-SS2S8','50000'
[sp_shakr_coupon_MMS] '01027237442','bhands','BHAND-SQVST-SS2S8','60000'

[sp_shakr_coupon_MMS] '01027237442','barunson','BHAND-SM9SE-P8FSY','b'

select * from invtmng.MMS_MSG

[sp_shakr_coupon_MMS] '01067640922','bhands','BHAND-SQVST-SS2S8','60000'  -- 차재원

-----------------------------------------------------------------------------------------------*/


CREATE     Procedure [dbo].[sp_shakr_coupon_MMS]

@phone varchar(15),
@company  varchar(15), -- bhands, barunson
@coupon_no varchar(50),
@type  varchar(15)

as


declare @uname varchar(50)

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)
	  , @msg varchar(2000)


if @type ='30000'
	begin

	set @uname = '포토슬라이드'

	end
else if @type ='50000'
	begin

	set @uname = '우리결혼해요'

	end
else if @type ='60000'
	begin

	set @uname = '러브스토리'

	end

set @phone = 'AA^'+@phone

if @company ='bhands'
	BEGIN
	    set @msg = '
[비핸즈카드]웨딩 식전영상 쿠폰 구매완료
상품명 : ' + @uname + '
쿠폰번호 : ' + @coupon_no + '

쿠폰 사용 방법
www.shakr.com 접속 -> 개인영상 테마별
분류 -> 웨딩 -> ' + @uname + ' ->
영상제작 -> 쿠폰번호 입력 -> 완료

쿠폰사용안내
비핸즈카드: ☎ 1644-9713

영상제작 및 기술지원
쉐이커 미디어: ☎ 1899-0389
'
		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '[비핸즈카드]', @msg, '', '16449713', 1, @phone, 0, '', 0, 'SA', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

	END
ELSE IF @company = 'barunson'
	BEGIN
	    set @msg = '
[바른손카드]웨딩 식전영상 쿠폰 구매완료
상품명 : ' + @uname + '
쿠폰번호 : ' + @coupon_no + '

쿠폰 사용 방법
www.shakr.com 접속 -> 개인영상 테마별
분류 -> 웨딩 -> ' + @uname + ' ->
영상제작 -> 쿠폰번호 입력 -> 완료

쿠폰사용안내
바른손카드: ☎ 1644-0708

영상제작 및 기술지원
쉐이커 미디어: ☎ 1899-0389
'

		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '[바른손카드]', @msg, '', '16440708', 1, @phone, 0, '', 0, 'SB', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT
		
	END
ELSE
	select 4


GO
