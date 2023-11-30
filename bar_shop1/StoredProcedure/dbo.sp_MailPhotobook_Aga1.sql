IF OBJECT_ID (N'dbo.sp_MailPhotobook_Aga1', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailPhotobook_Aga1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




CREATE   Proc [dbo].[sp_MailPhotobook_Aga1]
as
	Declare @mail_src varchar(5000)
	Declare @order_email  varchar(50)
	Declare @order_name  varchar(50)
	Declare @sender_name varchar(50)
	Declare @sender_email varchar(50)
	Declare @email_title varchar(50)


	set @mail_src = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'+
		'<html><head><title>Untitled Document</title><meta http-equiv="Content-Type" content="text/html; charset=euc-kr"></head>'+
		'<body><table border="0" align="center" cellpadding="0" cellspacing="0"><tr><td align="left" valign="top"><a href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=BAB&src=image&kw=000004" target="_blank" onfocus="blur()"><img src="http://www.photopie.co.kr/mail/images/aga_a_img01.jpg" width="764" height="521" border="0"></a></td></tr>'+
		'  <tr><td align="left" valign="top"><img src="http://www.photopie.co.kr/mail/images/aga_a_img02.jpg" width="764" height="475" border="0" usemap="#Map"></td>'+
		'	<map name="Map"><area shape="poly" coords="471,419,481,337,747,333,749,15,39,18,50,407" href="http://www.photopie.co.kr/display/prod_list.asp?prod_cate=BAB&src=image&kw=000004" target="_blank" onfocus="blur()">'+
		'  <area shape="rect" coords="489,350,716,420" href="http://www.photopie.co.kr/" target="_blank" onfocus="blur()"></map>  </tr></table>'+
		'<table width="764" border="0" align="center" cellpadding="0" cellspacing="0"><tr><td align="left" valign="top"><a href="http://aga.barunsoncard.com/?src=image&kw=000005" target="_blank" onfocus="blur()"><img src="http://www.photopie.co.kr/mail/images/aga_bottom.gif" width="764" height="87" border="0"></a></td></tr>'+
		'  <tr><td height="20" align="center"><font size="2">※ 본 메일은 고객님의 수신동의에 한하여 발송되는 메일입니다. </a></td></tr>'+
		'</table></body></html>'

	
	set @email_title = '[아가 매거진] 우리아가 첫 번째 생일을 축하해♡'


------------------------------------------------------------------------------------------------------------
	-- 바른손카드 구매고객에게 메일 보내기
	set @sender_name = '바른손카드'
	set @sender_email = 'no-reply@barunsoncard.com'

	DECLARE item_cursor CURSOR

	FOR 		
--	select '김수경' as order_name,'hertalk@naver.com' as order_email
	Select A.order_name,A.order_email from custom_order A inner join agaBarunson_member B on A.member_id = B.uid,custom_order_weddinfo C 
	where  A.weddinfo_id = C.order_seq and B.chk_mailservice='Y' and A.sales_gubun='G' and A.status_seq=15 and A.order_type in ('3','9','10')
	and C.wedd_date>=convert(varchar(10),dateadd(dd,-10,getdate()),21) and C.wedd_date<convert(varchar(10),dateadd(dd,-17,getdate()),21)
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@mail_src


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------








GO
