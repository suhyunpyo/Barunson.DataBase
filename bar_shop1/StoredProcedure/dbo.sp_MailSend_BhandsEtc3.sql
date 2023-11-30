IF OBJECT_ID (N'dbo.sp_MailSend_BhandsEtc3', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_BhandsEtc3
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




CREATE  Proc [dbo].[sp_MailSend_BhandsEtc3]
as
	Declare @mail_src varchar(5000)
	Declare @mail_str varchar(5000)
	Declare @order_email  varchar(50)
	Declare @order_name  varchar(50)
	Declare @sender_name varchar(50)
	Declare @sender_email varchar(50)
	Declare @email_title varchar(50)


	set @mail_src ='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+
'<html xmlns="http://www.w3.org/1999/xhtml">'+
'<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>샘플신청1</title></head>'+
'<body align="center"><table cellpadding="0" cellspacing="0" border="0" width="666" align="center">'+
'		<tr><td colspan="3"><img src="http://file.barunsoncard.com/ems/SA/new_top_03.jpg" width="666" height="177" border="0" usemap="#Map" /></td></tr>'+
'		<tr><td width="35" valign="top" background="http://file.barunsoncard.com/ems/SA/new_left_bg.jpg"><img src="http://file.barunsoncard.com/ems/SA/new_left_01.jpg" width="35" /></td>'+
'			<td width="575" valign="top"><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td valign="top"><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td valign="middle" align="left" width="206"><br /><table cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-left:8px"><span style="font-size:18px;font-weight:bold;color:#F09;border-bottom:1px solid #666;vertical-align:middle">:::name:::</span> </td><td style="padding-left:5px;"><img src="http://file.barunsoncard.com/ems/SA/txt03_5.gif" alt="님"/></td></tr></table><p style="margin:0;padding:0;"><img src="http://file.barunsoncard.com/ems/SA/new_03_img_01.jpg" width="575" height="180" border="0" usemap="#Map2" /></p>	</td></tr></table></td></tr>'+
'					<tr><td valign="top"><a href="http://www.bhandscard.com/event/event_benefit.asp" target="_blank"><img src="http://file.barunsoncard.com/ems/SA/new_01_img_02.jpg" width="575" height="470" border="0" /></a></td></tr></table></td>'+
'			<td width="56" valign="top" background="http://file.barunsoncard.com/ems/SA/new_right_bg.jpg"><img src="http://file.barunsoncard.com/ems/SA/new_right_01.jpg" width="56" /></td></tr>'+
'		<tr><td colspan="3"><img src="http://file.barunsoncard.com/ems/SA/new_footer_01.jpg" width="666" height="128" border="0" usemap="#Map3" /></td></tr></table>'+
'<map name="Map" id="Map"><area shape="rect" coords="27,22,182,55" href="http://www.bhandscard.com" target="_blank" alt="비핸즈카드" /></map>'+
'<map name="Map2" id="Map2"><area shape="rect" coords="169,94,391,143" href="http://www.bhandscard.com/member/login.asp?frompage=%2Fmypage%2Fwedd%2Forder%5Flist%2Easp" target="_blank" alt="무료10종 샘플 신청" /></map>'+
'<map name="Map3" id="Map3"><area shape="rect" coords="12,58,144,95" href="http://www.bhandscard.com" target="_blank" alt="비핸즈카드" /></map></body></html>'

	
	set @email_title = '초안작업이 완료되었습니다.'


------------------------------------------------------------------------------------------------------------
	-- 바른손카드 구매고객에게 메일 보내기
	set @sender_name = '비핸즈카드'
	set @sender_email = 'mailman@bhands.com'

	DECLARE item_cursor CURSOR

	FOR 		
--	select '김수경' as order_name,'hertalk@naver.com' as order_email
	select distinct order_name,order_email from custom_order where STATUS_SEQ=7 and DATEDIFF(day,src_compose_date,getdate())=1 and company_seq=5006
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @order_name,@order_email

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @mail_str = REPLACE(@mail_src,':::name:::',@order_name)
		exec sp_sendtNeoMail_wedd @sender_name,@sender_email,@order_name,@order_email,@email_title,@mail_str


		FETCH NEXT FROM item_cursor INTO @order_name,@order_email
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

------------------------------------------------------------------------------------------------------------

GO
