IF OBJECT_ID (N'dbo.sp_MailPhotobook_Hon4', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailPhotobook_Hon4
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  Proc [dbo].[sp_MailPhotobook_Hon4]
as
	Declare @mail_src varchar(5000)
	Declare @order_email  varchar(50)
	Declare @order_name  varchar(50)
	Declare @sender_name varchar(50)
	Declare @sender_email varchar(50)
	Declare @email_title varchar(50)
	Declare @email_msg varchar(5000)
	Declare @sales_gubun char(1)

	set @mail_src ='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' +
			'<html><head><title>Untitled Document</title>' +
			'<meta http-equiv="Content-Type" content="text/html; charset=euc-kr"></head>' +
			'<body><table border="0" align="center" cellpadding="0" cellspacing="0">' +
			'  <tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=HNM" target="_blank" onfocus="blur()"><img src="http://file.barunsoncard.com/photobook_img/mail/honeymoon_d_img01.jpg" width="764" height="500" border="0" usemap="#Map"></a></td>' +
			'    <map name="Map"><area shape="rect" coords="24,3,761,431" href="http://www.photopie.co.kr/event/remind_list.asp" target="_blank" onfocus="blur()">' +
			'      <area shape="rect" coords="505,433,748,497" href="http://www.photopie.co.kr/" target="_blank" onfocus="blur()"></map></tr>' +
			'  <tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/event/remind_list.asp" target="_blank" onfocus="blur()"><img src="http://file.barunsoncard.com/photobook_img/mail/honeymoon_d_img02.jpg" width="764" height="595" border="0"></a></td></tr></table>' +
			'	<table width="764" border="0" align="center" cellpadding="0" cellspacing="0">' +
			'  <tr><td align="left" valign="top"><a href=":::site_url:::" target="_blank" onfocus="blur()"><img src="http://file.barunsoncard.com/photobook_img/mail/:::sales_gubun:::_bottom.gif" width="764" height="95" border="0"></a></td></tr>' +
			'  <tr><td height="20" align="center"><font size="2">※ 본 메일은 고객님의 수신동의에 한하여 발송되는 메일입니다. </font></td></tr></table></body></html>'
	
	set @email_title = '[허니문매거진] 동남아로~ 리마인드 허니문 떠나자!! '

------------------------------------------------------------------------------------------------------------
	-- 바른손카드 구매고객에게 메일 보내기
	set @sender_name = '바른손카드'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'W'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join TU_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-34,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-26,getdate()),21)
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
	-- 더카드 구매고객에게 메일 보내기
	set @sender_name = '더카드'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'T'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join the_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-34,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-26,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @email_msg = Replace(@mail_src,':::site_url:::','http://www.thecard.co.kr')
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
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-34,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-26,getdate()),21)
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

	set @sales_gubun = 'S'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join storyLove_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-34,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-26,getdate()),21)
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

------------------------------------------------------------------------------------------------------------
	-- 투유카드 구매고객에게 메일 보내기
	set @sender_name = '투유카드'
	set @sender_email = 'happy@2ucard.co.kr'

	set @sales_gubun = 'U'
	DECLARE item_cursor CURSOR

	FOR 		
	Select A.order_name,A.order_email from custom_order A inner join TU_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun=@sales_gubun and A.status_seq=15 and A.order_type in ('1','6','7','8') 
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-34,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-26,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		set @email_msg = Replace(@mail_src,':::site_url:::','http://www.2ucard.co.kr')
		set @email_msg = Replace(@email_msg,':::sales_gubun:::',@sales_gubun)

		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@email_msg


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------





GO
