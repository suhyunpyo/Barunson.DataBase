IF OBJECT_ID (N'dbo.sp_MailSend_test', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_test
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE procedure [dbo].[sp_MailSend_test]
as
	DECLARE @order_seq1 int
	DECLARE @order_seq2 int
	DECLARE @order_name [varchar](50)
	DECLARE @member_id [varchar](20)
	DECLARE @order_email [varchar](100)
	DECLARE @card_seq [varchar](20)
	DECLARE @card_code [varchar](20)
	DECLARE @img_s [varchar](50)
	DECLARE @mail_url [varchar](100)
DECLARE @subject [varchar](200)
	set @mail_url = 'http://shop.barunson.com/mail/mail_img1'
	set @subject = '(주)바른손카드입니다.(배송확인)'
	set @order_seq1 = 23858
	set @order_name = '권동찬'
	set @order_email = 'ksk@barunson.com'
	set @card_code = '2022'
	set @member_id = 'chanie76'
	set @card_seq = '1095'
	set @img_s = '2022_s.jpg'
	DECLARE @ADDR [varchar](8000)
	
	set @ADDR = '<html><head><title>Untitled Document</title>'+char(13)
	+'<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">' + char(13)
	+'<link rel="stylesheet" href="http://shop.barunson.com/inc/style.css" type="text/css">' + char(13)
	+'</head>' + char(13)
	+'<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0"><form name="ans" method="post" action="http://shop.barunson.com/wedd/display/ans_save_tmp.asp">' + char(13)
	+'<input type="hidden" name="order_seq" value="'+cast(@order_seq1 as varchar(20))+'">'+ char(13)
	+'<table width="648" border="0" align="center" cellpadding="0" cellspacing="0" background="'+@mail_url+'/back.gif">' + char(13)
	+'<tr><td><a href="http://shop.barunson.com"><img src="'+@mail_url+'/top_logo.jpg" width="648"  border="0"></a></td></tr>' + char(13)
		+'	<tr><td align="center"><a href="http://shop-test1.barunson.com/wedd/event/after_event.asp?order_seq='+cast(@order_seq1 as varchar(20))+'"><img src="http://shop-test1.barunson.com/wedd/event/img/new_event1.jpg" border="0"></a></td></tr>' + char(13)
	+'		<tr><td align="right"><a href="http://shop-test1.barunson.com/wedd/event/after_event.asp?order_seq='+cast(@order_seq1 as varchar(20))+'"><img src="http://shop-test1.barunson.com/wedd/event/img/new_event_detail1.jpg" border="0"></a>&nbsp;&nbsp;&nbsp;</td></tr>' + char(13)
	+'<tr><td><a href="http://shop.barunson.com"><img src="'+@mail_url+'/s_top1.jpg" width="648"  border="0"></a></td></tr>' + char(13)
	+'<tr><td background="'+@mail_url+'/img_back.gif">' + char(13)
	+'	<table width="580" border="0" align="center" cellpadding="0" cellspacing="0">' + char(13)
	+'	<tr><td height="39" colspan="2"><img src="'+@mail_url+'/04_txt01.gif"></td></tr>' + char(13)
	+'	<tr><td width="408" height="25"><strong>1</strong>. 고객님께서 주문하신 제품이 <strong>제대로 도착</strong> 되었나요? </td>' + char(13)
	+'	<td width="172"><table border="0" cellpadding="0" cellspacing="0" >' + char(13)
	+'		<tr><td width="60" class="s"> <input type="radio" name="isReceive" value="1" checked>	Yes</td>' + char(13)
	+'		<td class="s"><input type="radio" name="isReceive" value="0"> No </td></tr></table>' + char(13)
	+'	</td></tr>' + char(13)
	+'	<tr><td colspan="2"><img src="'+@mail_url+'/line.gif" width="562" height="1"></td></tr>' + char(13)
	+'	<tr valign="bottom"><td height="25" colspan="2"><strong>2</strong>. 바른손 청첩장 샵을 <strong>어떻게</strong> ' + char(13)
	+'	알고 <strong>방문</strong>하셨나요? (복수 가능)</td></tr>' + char(13)
	+'	<tr><td height="22" colspan="2">' + char(13)
	+'		<table width="550" border="0" align="center">' + char(13)
	+'		<tr><td class="s"><input type="checkbox" name="ans1" value="1"> 포탈 사이트에서 "청첩장" 키워드로 검색해서</td></tr>' + char(13)
	+'		<tr><td class="s"><input type="checkbox" name="ans1" value="2"> 주소창에 "바른손카드"나 "www.barunson.com"을 치고</td></tr> ' + char(13)
	+'		<tr><td class="s"><input type="checkbox" name="ans1" value="3"> 평소에 잘 알고 있는 사이트라서</td></tr>' + char(13)
	+'		<tr><td class="s"><input type="checkbox" name="ans1" value="4">기타 <input name="ans1_str" type="text" class="input01" size="30" maxlength="50">(직접 적어주세요)</td></tr>' + char(13)
	+'		</table></td>' + char(13)
	+'	</tr>' + char(13)
	+ '	<tr><td colspan="2"><img src="'+@mail_url+'/line.gif" width="562" height="1"></td></tr>' + char(13)
	+'	<tr valign="bottom"><td height="25" colspan="2"><strong>3</strong>. 고객님께서 바른손 청첩장 샵에서 <strong>구매하신 이유</strong>는 무엇인가요? (복수 가능)</td></tr>' + char(13)
	+'	<tr><td height="22" colspan="2">' + char(13)
	+'		<table width="550" border="0" align="center">' + char(13)
	+'		<tr><td class="s"> <input type="checkbox" name="ans2" value="1">	가격이 저렴하다.</td></tr>' + char(13)
	+'		<tr><td class="s"> <input type="checkbox" name="ans2" value="2"> 본사가 직영으로 운영하는 사이트라 신뢰가 갔다.</td></tr>' + char(13)
	+'		<tr><td class="s"> <input type="checkbox" name="ans2" value="3"> 주변으로부터의 소개로</td></tr>' + char(13)
	+'		<tr><td class="s"> <input type="checkbox" name="ans2" value="4">기타 <input name="ans2_str" type="text" class="input01" size="30">(직접 적어주세요)</td>' + char(13)
	+'		</tr></table></td></tr>' + char(13)
	+'	<tr><td colspan="2"><img src="'+@mail_url+'/line.gif" width="562" height="1"></td></tr>' + char(13)
	+'	<tr valign="bottom"><td height="25" colspan="2"><strong>4</strong>. 보다 나은 서비스를 위해 만약, 바른손카드에 하시고 싶은 <strong>의견을 적어 주세요.</strong></td></tr>' + char(13)
	+'	<tr><td height="25" colspan="2"><span class="s"><strong> </strong></span> ' + char(13)
	+'		<table width="550" border="0" align="center" cellpadding="0" cellspacing="0">' + char(13)
	+'		<tr><td  style="padding-top:2;padding-bottom:10"> <textarea name="service_ment" cols="30" rows="6" class="input01" style="width:540"></textarea></td></tr>' + char(13)
	+'		</table></td></tr>' + char(13)
	+'	<tr><td colspan="2"><img src="'+@mail_url+'/line.gif" width="562" height="1"></td></tr>' + char(13)
	+'	<tr valign="bottom"><td height="25" colspan="2"><strong>5</strong>. 주문하신 <font color="#FFFFFF"></font><font color="#479A32"><strong>'+@card_code+' 카드</strong></font><font color="#FFFFFF"><!--//카드명-->' + char(13)
	+'	</font>에 대해서 평가 부탁드립니다. <span class="s">(사이트내 이용후기에 <strong>자동 등록</strong>)</span></td></tr>' + char(13)
	+'	<tr><td height="25" colspan="2"><input type=hidden name="title" value="'+@card_code+' 카드에 대한 이용후기">' + char(13)
	+'		<table width="550" border="0" align="center">' + char(13)
	+'		<tr><td ><table width="100%"><tr><td width="20%" align=center><img src="http://shopfile.barunson.com/prod_img/'+@img_s+'" width=90></td>' + char(13)
	+'		<td><input type="radio" name="SCORE" value="1"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif">&nbsp;&nbsp;&nbsp;<input type="radio" name="SCORE" value="2"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif">&nbsp;&nbsp;&nbsp;<input type="radio" name="SCORE" value="3"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif">&nbsp;&nbsp;&nbsp;<input type="radio" name="SCORE" value="4"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif">&nbsp;&nbsp;<input type="radio" name="SCORE" value="5" checked><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif"><img src="http://shop.barunson.com/wedd/invitation_img/pop_heart.gif">' + char(13)
	+'		<br><textarea name="card_comment" cols="60" rows="6" class="input01"></textarea></td></tr></table></td></tr>' + char(13)
	+'		</table></td></tr>' + char(13)
	+'<tr><td><br><div align=center><input type=image src="http://shop.barunson.com/mail/mail_img1/btn_04.gif" width="112" height="26" border="0"></td></tr></form></table></td></tr>' + char(13)
	+'<tr><td><img src="'+@mail_url+'/img_04.gif"></td></tr>' + char(13)
	+'<tr><td>&nbsp;</td></tr>' + char(13)
	+'<tr><td height="22"><a href="http://shop.barunson.com/ewedd/ewedd_main.asp"  onFocus="this.blur()"><img src="'+@mail_url+'/s_putt01.jpg" width="648" height="348" border="0" ></a></td></tr>' + char(13)
	+'<tr><td><img src="'+@mail_url+'/s_putt02.jpg" width="648" height="90" border="0"></a></table></body></html>' + char(13)
print @ADDR
	exec [114.111.54.153].mail.dbo.usp_tNeoShop_insert @order_seq1,@order_name,@order_email,@subject,@ADDR

GO
