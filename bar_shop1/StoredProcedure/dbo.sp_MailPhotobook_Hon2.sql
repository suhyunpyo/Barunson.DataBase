IF OBJECT_ID (N'dbo.sp_MailPhotobook_Hon2', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailPhotobook_Hon2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     Proc [dbo].[sp_MailPhotobook_Hon2]
as
	Declare @mail_src varchar(5000)
	Declare @order_email  varchar(50)
	Declare @order_name  varchar(50)
	Declare @sender_name varchar(50)
	Declare @sender_email varchar(50)
	Declare @email_title varchar(50)
	Declare @email_msg varchar(5000)
	Declare @sales_gubun varchar(2)

	set @mail_src = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><title>Untitled Document</title><meta http-equiv="Content-Type" content="text/html; charset=euc-kr"></head>' +
			'<body><table border="0" align="center" cellpadding="0" cellspacing="0">' +
			'  <tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=HNM" target="_blank" onfocus="blur()"><img src="http://file.barunsoncard.com/photobook_img/mail/honeymoon_b_img01.jpg" width="764" height="524" border="0"></a></td></tr>' +
			'  <tr><td align="left" valign="top"><img src="http://file.barunsoncard.com/photobook_img/mail/honeymoon_b_img02.jpg" width="764" height="497" border="0" usemap="#Map"></td>' +
			'    <map name="Map"><area shape="poly" coords="20,1,558,1,556,75,760,74,761,493,21,494" href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=HNM&src=image&kw=00000D" target="_blank" onfocus="blur()">' +
			'      <area shape="rect" coords="564,2,747,70" href="http://www.photopie.co.kr/?src=image&kw=000017" target="_blank" onfocus="blur()"></map></tr>' +
			'  <tr><td align="left" valign="top"><img src="http://file.barunsoncard.com/photobook_img/mail/honeymoon_b_img03.jpg" width="764" height="429" border="0" usemap="#Map2"></td>' +
			'    <map name="Map2"><area shape="poly" coords="761,96,461,79,204,40,193,78,22,75,22,4,761,2" href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=HNM&src=image&kw=00000D" target="_blank" onfocus="blur()">' +
			'      <area shape="poly" coords="139,217,150,384,484,365,699,265,716,120,521,95,206,47,175,199" href="http://www.photopie.co.kr/display/pop_SkinView.asp?skin_nm=HNMA03&w=920&h=490" target="_blank" onfocus="blur()"></map></tr></table>' +
			'<table width="764" border="0" align="center" cellpadding="0" cellspacing="0">' +
			'  <tr><td align="left" valign="top"><a href=":::site_url:::" target="_blank" onfocus="blur()"><img src="http://file.barunsoncard.com/photobook_img/mail/:::sales_gubun:::_bottom.gif" width="764" height="95" border="0"></a></td></tr>' +
			'  <tr><td height="20" align="center"><font size="2">※ 본 메일은 고객님의 수신동의에 한하여 발송되는 메일입니다. </font></td></tr>' +
			'</table></body></html>'

	
	set @email_title = '[허니문매거진] 우리 둘 만이 기억하는, 허니문 북!!'

------------------------------------------------------------------------------------------------------------
	-- 바른손카드 구매고객에게 메일 보내기
	set @sender_name = '바른손카드'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'SB'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join tUserInfo B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and order_type in ('1','6','7','8')
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-26,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-19,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @email_msg = Replace(@mail_src,':::site_url:::','http://www.barunsoncard.com')
		set @email_msg = Replace(@email_msg,':::sales_gubun:::',@sales_gubun)

		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@email_msg


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------
	-- 위시메이드 구매고객에게 메일 보내기
	set @sender_name = '위시메이드'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'SW'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join the_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-26,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-19,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @email_msg = Replace(@mail_src,':::site_url:::','http://www.wishmade.co.kr')
		set @email_msg = Replace(@email_msg,':::sales_gubun:::',@sales_gubun)

		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@email_msg


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
	-- 해피카드 구매고객에게 메일 보내기
	set @sender_name = '해피카드'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'SH'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join the_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-26,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-19,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @email_msg = Replace(@mail_src,':::site_url:::','http://www.happycard.co.kr')
		set @email_msg = Replace(@email_msg,':::sales_gubun:::',@sales_gubun)

		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@email_msg


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
	-- W페이퍼 구매고객에게 메일 보내기
	set @sender_name = 'W페이퍼'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'SP'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join the_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-26,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-19,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @email_msg = Replace(@mail_src,':::site_url:::','http://www.wpaper.co.kr')
		set @email_msg = Replace(@email_msg,':::sales_gubun:::',@sales_gubun)

		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@email_msg


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
	-- 티아라카드 구매고객에게 메일 보내기
	set @sender_name = '티아라카드'
	set @sender_email = 'no-reply@tiaracard.com'

	set @sales_gubun = 'A'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join tiara_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-26,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-19,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @email_msg = Replace(@mail_src,':::site_url:::','http://www.tiaracard.co.kr')
		set @email_msg = Replace(@email_msg,':::sales_gubun:::',@sales_gubun)

		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@email_msg


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------
	-- 스토리오브러브 구매고객에게 메일 보내기
	set @sender_name = '스토리오브러브'
	set @sender_email = 'happy@storyoflove.co.kr'

	set @sales_gubun = 'SS'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join storyLove_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-26,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-19,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @email_msg = Replace(@mail_src,':::site_url:::','http://www.storyoflove.co.kr')
		set @email_msg = Replace(@email_msg,':::sales_gubun:::',@sales_gubun)

		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@email_msg


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------




GO
