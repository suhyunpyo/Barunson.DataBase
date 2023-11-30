IF OBJECT_ID (N'dbo.sp_MailSend_sample_confirm', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_sample_confirm
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  procedure [dbo].[sp_MailSend_sample_confirm]
as
DECLARE @order_seq int
DECLARE @order_name [varchar](50)
DECLARE @order_email [varchar](100)
DECLARE @ADDR [varchar](8000)
DECLARE @subject [varchar](200)
DECLARE tbl_cursor CURSOR FOR
SELECT sample_order_Seq,member_name,member_email
from dbo.custom_sample_order where status_seq=12 and datediff(day,delivery_Date,getdate()) =3
OPEN tbl_cursor
	FETCH NEXT FROM tbl_cursor INTO @order_seq, @order_name, @order_email
WHILE (@@FETCH_STATUS = 0)
begin
	FETCH NEXT FROM tbl_cursor INTO @order_seq, @order_name, @order_email
	-- 테스트를 위해 임시적으로 걸어놓음
	--set @order_email = 'ksk@barunson.com'
	set @subject = @order_name+'고객님,샘플주문상품을 안전하게 받으셨나요?'
	set @ADDR = '<html><head><title>더카드 시스템 메일1</title></head>' + char(13)
	+'<body>' + char(13)
	+'  <table width="768" cellpadding="0" cellspacing="0">' + char(13)
	+'	<tr><td valign="top" colspan="3"><img src="http://www.thecard.co.kr/mail/sample//mail3_thecardimg1.jpg" border="0" usemap="#map_001"/></td></tr>' + char(13)
	+'	<tr><td valign="top" rowspan="3"><img src="http://www.thecard.co.kr/mail/sample//mail3_left1.jpg"/></td>' + char(13)
	+'		<td valign="top" align="center" height="20" width="722"><b><font size="2" face="돋움" color="#af7819">' + @order_name + '</font><font size="2" face="돋움" color="#272525"> 고객님!!</font></b></td>' + char(13)
	+'		<td valign="top" rowspan="3"><img src="http://www.thecard.co.kr/mail/sample//mail3_right1.jpg"/></td></tr>' + char(13)
	+'	<tr><td valign="top" align="center"><img src="http://www.thecard.co.kr/mail/sample//mail3_thecardimg2.jpg" border="0"/></td></tr>' + char(13)
	+'	<tr><td valign="top" align="center" style="line-height:16px;height:51px;">' + char(13)
	+'		<font style="font-size:11px;" face="돋움" color="#929292"> 샘플을 아직 받지 못하셨거나, 불편사항 있으시면<font style="font-size:11px;" face="돋움" color="#af7819">고객센터(1644-0708)</font> 로 연락 부탁드립니다. <br/>' + char(13)
	+'		즉시 처리해 드리겠습니다.</font></td></tr>' + char(13)
	+'	<tr><td valign="top" align="center" colspan="3"><a href="http://www.thecard.co.kr/info/event.asp" target="new1"><img src="http://www.thecard.co.kr/mail/sample//mail3_thecardimg3.jpg" border="0" border="0"/></a></td></tr>' + char(13)
	+'	<tr><td valign="top" colspan="3"><img src="http://www.thecard.co.kr/mail/sample//main_thecardimg4.jpg"/></td></tr>' + char(13)
	+'</table> ' + char(13)
	+' <map name="map_001"><area shape="rect" coords="8,7,124,53" href="http://www.thecard.co.kr/" target="_blank" alt="thecard"></map> ' + char(13)
	+' </body></html>' + char(13)
	--exec [114.111.54.153].mail.card_admin.usp_tNeoS2_insert @order_seq, @order_name,@order_email,@subject,@ADDR
	exec sp_sendtNeoMail_wedd '더카드','mailman@bhands.com',@order_name,@order_email,@subject,@ADDR
end 
CLOSE tbl_cursor
DEALLOCATE tbl_cursor


GO
