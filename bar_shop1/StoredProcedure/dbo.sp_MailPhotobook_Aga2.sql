IF OBJECT_ID (N'dbo.sp_MailPhotobook_Aga2', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailPhotobook_Aga2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE   Proc [dbo].[sp_MailPhotobook_Aga2]
as
	Declare @mail_src varchar(5000)
	Declare @order_email  varchar(50)
	Declare @order_name  varchar(50)
	Declare @email_title varchar(50)


	set @mail_src = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' + 
		'<html><head><title>Untitled Document</title><meta http-equiv="Content-Type" content="text/html; charset=euc-kr"></head>' + 
		'<body><table border="0" align="center" cellpadding="0" cellspacing="0"><tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=BAB&src=image&kw=000006" target="_blank" onFocus="blur()"><img src="http://www.photopie.co.kr/mail/images/aga_b_img01.jpg" width="764" height="252" border="0"></a></td></tr>' + 
		'  <tr><td align="left" valign="top"><img src="http://www.photopie.co.kr/mail/images/aga_b_img02.jpg" width="764" height="662" border="0" usemap="#Map"></td>' + 
		'	<map name="Map"><area shape="rect" coords="95,48,256,307" href="http://www.photopie.co.kr/display/prod_det.asp?prod_code=BABB06H_026&src=image&kw=000012" target="_blank" onfocus="blur()">' + 
		'  <area shape="rect" coords="313,70,483,305" href="http://www.photopie.co.kr/display/prod_det.asp?prod_code=BABA03H_015&src=image&kw=000013" target="_blank" onfocus="blur()">' + 
		'  <area shape="rect" coords="543,64,714,305" href="http://www.photopie.co.kr/display/prod_det.asp?prod_code=BABB03H_021&src=image&kw=000014" target="_blank" onfocus="blur()">' + 
		'  <area shape="rect" coords="81,361,257,595" href="http://www.photopie.co.kr/display/prod_det.asp?prod_code=BABA03H_020&src=image&kw=000015" target="_blank" onfocus="blur()">' + 
		'  <area shape="rect" coords="308,361,474,592" href="http://www.photopie.co.kr/display/prod_det.asp?prod_code=BABB03H_025&src=image&kw=000016" target="_blank" onfocus="blur()">' + 
		'  <area shape="rect" coords="485,409,618,494" href="http://www.photopie.co.kr/" target="_blank" onfocus="blur()"></map></tr>' + 
		'  <tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=BAB&src=image&kw=000006" target="_blank" onfocus="blur()"><img src="http://www.photopie.co.kr/mail/images/aga_b_img03.jpg" width="764" height="247" border="0" usemap="#Map2"></a></td></tr></table>' + 
		'<table width="764" border="0" align="center" cellpadding="0" cellspacing="0"><tr><td align="left" valign="top"><a href="http://aga.barunsoncard.com/?src=image&kw=000007" target="_blank" onfocus="blur()"><img src="http://www.photopie.co.kr/mail/images/aga_bottom.gif" width="764" height="87" border="0"></a></td></tr>' + 
		'  <tr><td height="20" align="center"><font size="2">※ 본 메일은 고객님의 수신동의에 한하여 발송되는 메일입니다. </a></td></tr></table></body></html>'
	
	set @email_title = '[아가 매거진] 똑 소리 나는 엄마되는 법!!'


------------------------------------------------------------------------------------------------------------
	-- 바른손카드 구매고객에게 메일 보내기

	DECLARE item_cursor CURSOR

	FOR 		
--	select '김수경' as order_name,'hertalk@naver.com' as order_email
	Select distinct A.order_name,A.order_email from custom_order A inner join agaBarunson_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun='G' and A.status_seq=15
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-17,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-25,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		exec sp_sendtNeoMail_wedd  '바른손카드','no-reply@barunsoncard.com',@order_name,@order_email,@email_title,@mail_src


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------








GO
