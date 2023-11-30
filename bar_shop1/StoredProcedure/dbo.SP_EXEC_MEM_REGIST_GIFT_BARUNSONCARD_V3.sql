USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_V3]    Script Date: 2023-05-08 오전 10:41:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*     
	회원 가입시 쿠폰 확인하여 발행 하는 프로시져
*/     
      
ALTER  PROCEDURE [dbo].[SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_V3]      
 	@COMPANY_SEQ AS INT      
,   @UID AS VARCHAR(50)      
,   @GIFT_CARD_SEQ AS INT = 0      
AS      
BEGIN      
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

	DECLARE @sales_gubun varchar(10) = '', @dt smalldatetime, @COUPON_CODE VARCHAR(50);
	
	Set @dt = GETDATE();
	-- Sales Gubun
	IF (@COMPANY_SEQ = 5001)		--바른손
		SET @sales_gubun = 'SB';	
	ELSE IF (@COMPANY_SEQ = 5003)	--프페
		SET @sales_gubun = 'SS';
	ELSE IF (@COMPANY_SEQ = 5006)	--비헨즈 <- 관리페이지에서 등록 가능하여 유지
		SET @sales_gubun = 'SA';

	--//제3자 마케팅 동의 여부?  
	declare @mkt_chk_flg char(10) = 'N' 
	declare @lg_chk_flg char(10) = 'N'
	declare @cuc_chk_flg char(10) = 'N'
  
	select top 1 @mkt_chk_flg = mkt_chk_flag , @lg_chk_flg = chk_lgmembership
   	from 	S2_UserInfo   
 	where 	[uid] = @UID            

	--// DownloadKindEtcCode 130005 제3자 이용약관 동의, 자동 발급
	If @mkt_chk_flg  = 'Y' and @lg_chk_flg = 'Y' and @COMPANY_SEQ in (5001,5003,5006)
	  begin
		DECLARE Coupon_CURSOR  CURSOR FOR 
			select c.COUPON_CODE from COUPON_MST as a
				inner join COUPON_APPLY_SITE as b on a.COUPON_MST_SEQ = b.COUPON_MST_SEQ 
				Inner Join COUPON_DETAIL as c on a.COUPON_MST_SEQ = c.COUPON_MST_SEQ
			Where	a.STATUS_ACTIVE_YN = 'Y' 
			and		a.DOWNLOAD_KIND_ETC_CODE = '130005' --제3자 이용약관 동의
			And		a.DOWNLOAD_KIND = 'E'
			and		b.COMPANY_SEQ = @COMPANY_SEQ 
			and		c.DOWNLOAD_ACTIVE_YN = 'Y'
			And	(
					(a.COUPON_ISSUE_START_DATE <= @dt and a.COUPON_ISSUE_END_DATE > @dt) Or
					a.COUPON_ISSUE_START_DATE is null
				)	
		OPEN Coupon_CURSOR;
		
		FETCH NEXT FROM Coupon_CURSOR INTO @COUPON_CODE;
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ,  @sales_gubun, @UID, @COUPON_CODE;
			FETCH NEXT FROM Coupon_CURSOR INTO @COUPON_CODE;
		End
		CLOSE Coupon_CURSOR;
		DEALLOCATE Coupon_CURSOR;
	  End
   	ELSE IF @mkt_chk_flg  = 'Y' and @lg_chk_flg = 'Y' and @COMPANY_SEQ != 5001 --// 바른손몰
	  BEGIN

		if not exists (select * from s4_mycoupon where uid =@uid and coupon_code ='BARUNWELCOME10_NEW')
			begin
				insert into s4_mycoupon (coupon_code, company_seq, uid, end_date)
				values ('BARUNWELCOME10_NEW', 5006, @UID, DATEADD(MM, 2, getdate()))
			end

		if not exists (select * from s4_mycoupon where uid = @uid and coupon_code ='BHS15THK0101' ) 
			begin
				insert into s4_mycoupon (coupon_code, company_seq, uid, end_date)
				values ('BHS15THK0101', 5006, @UID, DATEADD(MM, 3, getdate()))
			end 
	  END
	
	--// DownloadKindEtcCode 130007 회원가입, 동의 여부 상관없이
	If @COMPANY_SEQ in (5001,5003,5006)
	  begin
		DECLARE Coupon_CURSOR_1  CURSOR FOR 
			select c.COUPON_CODE from COUPON_MST as a
				inner join COUPON_APPLY_SITE as b on a.COUPON_MST_SEQ = b.COUPON_MST_SEQ 
				Inner Join COUPON_DETAIL as c on a.COUPON_MST_SEQ = c.COUPON_MST_SEQ
			Where	a.STATUS_ACTIVE_YN = 'Y' 
			and		a.DOWNLOAD_KIND_ETC_CODE = '130007' --회원가입
			And		a.DOWNLOAD_KIND = 'E'
			and		b.COMPANY_SEQ = @COMPANY_SEQ 
			and		c.DOWNLOAD_ACTIVE_YN = 'Y'
			And	(
					(a.COUPON_ISSUE_START_DATE <= @dt and a.COUPON_ISSUE_END_DATE > @dt) Or
					a.COUPON_ISSUE_START_DATE is null
				)	
		OPEN Coupon_CURSOR_1;
		
		FETCH NEXT FROM Coupon_CURSOR_1 INTO @COUPON_CODE;
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ,  @sales_gubun, @UID, @COUPON_CODE;
			FETCH NEXT FROM Coupon_CURSOR_1 INTO @COUPON_CODE;
		End
		CLOSE Coupon_CURSOR_1;
		DEALLOCATE Coupon_CURSOR_1;
	  End

END 