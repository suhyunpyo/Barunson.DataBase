IF OBJECT_ID (N'dbo.sp_MailPhotobook_Hon0', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailPhotobook_Hon0
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE    Proc [dbo].[sp_MailPhotobook_Hon0]
as
	Declare @mail_src varchar(5000)
	Declare @order_email  varchar(50)
	Declare @order_name  varchar(50)
	Declare @sender_name varchar(50)
	Declare @sender_email varchar(50)
	Declare @email_title varchar(50)
	Declare @email_msg varchar(5000)
	Declare @sales_gubun varchar(2)

	set @mail_src = '<html><head><title>Untitled Document</title><meta http-equiv="Content-Type" content="text/html; charset=euc-kr"></head> ' +
		'<body><table border="0" align="center" cellpadding="0" cellspacing="0"> ' +
		'  <tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=WDD&src=image&kw=000008" target="_blank" onfocus="blur()"><img src="http://file.barunsoncard.com/photobook_img/mail/settle_img01.jpg" width="741" height="441" border="0"></a></td></tr> ' +
		'  <tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/cs/info_wddalbum.asp?src=image&kw=00000C" target="_blank" onfocus="blur()"><img src="http://file.barunsoncard.com/photobook_img/mail/settle_img02.jpg" width="741" height="576" border="0"></a></td></tr></table> ' +
		'	<table width="764" border="0" align="center" cellpadding="0" cellspacing="0"> ' +
		'  <tr><td align="left" valign="top"><a href=":::site_url:::" target="_blank" onfocus="blur()"><img src="http://file.barunsoncard.com/photobook_img/mail/:::sales_gubun:::_bottom.gif" width="764" height="95" border="0"></a></td></tr> ' +
		' <tr><td height="20" align="center"><font size="2">※ 본 메일은 고객님의 수신동의에 한하여 발송되는 메일입니다. </font></td></tr></table></body></html>'
	
	set @email_title = '[웨딩 매거진] 청첩장으로 디자인 된 나만의 웨딩앨범'

------------------------------------------------------------------------------------------------------------
	-- 바른손카드 구매고객에게 메일 보내기
	set @sender_name = '바른손카드'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'SB'
	DECLARE item_cursor CURSOR

	FOR 		
	Select order_name,order_email from custom_order A inner join tUserInfo B on A.member_id = B.uid and B.chk_mailservice='Y' 
	where A.sales_gubun=@sales_gubun and datediff(day,settle_date,getdate()) = 1 and order_type in ('1','6','7','8')
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
	--위시메이드 구매고객에게 메일 보내기
	set @sender_name = '위시메이드'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'SW'
	DECLARE item_cursor CURSOR

	FOR 		
	Select order_name,order_email from custom_order A inner join the_member B on A.member_id = B.uid and B.chk_mailservice='Y' 
	where A.sales_gubun=@sales_gubun and datediff(day,settle_date,getdate()) = 1 and order_type in ('1','6','7','8')
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
	--해피카드 구매고객에게 메일 보내기
	set @sender_name = '해피카드'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'SH'
	DECLARE item_cursor CURSOR

	FOR 		
	Select order_name,order_email from custom_order A inner join the_member B on A.member_id = B.uid and B.chk_mailservice='Y' 
	where A.sales_gubun=@sales_gubun and datediff(day,settle_date,getdate()) = 1 and order_type in ('1','6','7','8')
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
	--W페이퍼 구매고객에게 메일 보내기
	set @sender_name = 'W페이퍼'
	set @sender_email = 'no-reply@barunsoncard.com'

	set @sales_gubun = 'SP'
	DECLARE item_cursor CURSOR

	FOR 		
	Select order_name,order_email from custom_order A inner join the_member B on A.member_id = B.uid and B.chk_mailservice='Y' 
	where A.sales_gubun=@sales_gubun and datediff(day,settle_date,getdate()) = 1 and order_type in ('1','6','7','8')
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
	Select order_name,order_email from custom_order A inner join tiara_member B on A.member_id = B.uid and B.chk_mailservice='Y' 
	where A.sales_gubun=@sales_gubun and datediff(day,settle_date,getdate()) = 1 and order_type in ('1','6','7','8')
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
	Select  order_name,order_email from custom_order A inner join storyLove_member B on A.member_id = B.uid and B.chk_mailservice='Y' 
	where A.sales_gubun=@sales_gubun and datediff(day,settle_date,getdate()) = 1 and order_type in ('1','6','7','8')
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
