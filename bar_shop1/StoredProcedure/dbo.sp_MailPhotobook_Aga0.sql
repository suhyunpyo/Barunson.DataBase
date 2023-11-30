IF OBJECT_ID (N'dbo.sp_MailPhotobook_Aga0', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailPhotobook_Aga0
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE   Proc [dbo].[sp_MailPhotobook_Aga0]
as
	Declare @mail_src varchar(5000)
	Declare @order_email  varchar(50)
	Declare @order_name  varchar(50)
	Declare @email_title varchar(50)

	set @mail_src = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' + 
		'<html><head><title>Untitled Document</title><meta http-equiv="Content-Type" content="text/html; charset=euc-kr"></head>' + 
		'<body><table border="0" align="center" cellpadding="0" cellspacing="0"><tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/cs/info_firstbirth.asp?src=image&kw=000002" target="_blank" onfocus="blur()"><img src="http://www.photopie.co.kr/mail/images/aga_settle_img01.jpg" width="741" height="466" border="0"></a></td></tr>' + 
		'  <tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/cs/info_firstbirth.asp?src=image&kw=000002" target="_blank" onfocus="blur()"><img src="http://www.photopie.co.kr/mail/images/aga_settle_img02.jpg" width="741" height="686" border="0"></a></td></tr></table>' + 
		'<table width="764" border="0" align="center" cellpadding="0" cellspacing="0"><tr><td align="left" valign="top"><a href="http://aga.barunsoncard.com/?src=image&kw=000003" target="_blank" onfocus="blur()"><img src="http://www.photopie.co.kr/mail/images/aga_bottom.gif" width="764" height="87" border="0"></a></td></tr>' + 
		'  <tr><td height="20" align="center"><font size="2">※ 본 메일은 고객님의 수신동의에 한하여 발송되는 메일입니다. </a></td></tr>' + 
		'</table></body></html>'
	
	set @email_title = '[아가 매거진] 돌 잔치 테이블 ''성장앨범''으로 채워보세요.'

------------------------------------------------------------------------------------------------------------
	-- 바른손카드 구매고객에게 메일 보내기

	DECLARE item_cursor CURSOR

	FOR 		
	Select distinct A.order_name,A.order_email from custom_order A inner join agaBarunson_member B on A.member_id = B.uid
	where  B.chk_mailservice='Y' and A.sales_gubun='G' and A.status_seq=15
	 and datediff(day,settle_date,getdate()) = 3
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		exec sp_sendtNeoMail_wedd '바른손카드','no-reply@barunsoncard.com',@order_name,@order_email,@email_title,@mail_src


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------






GO
