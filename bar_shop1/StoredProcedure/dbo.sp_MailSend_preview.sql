IF OBJECT_ID (N'dbo.sp_MailSend_preview', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_preview
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




CREATE procedure [dbo].[sp_MailSend_preview]
	@otype [char](1)
	,@order_seq [varchar](10)
	,@order_name [varchar](50)
	,@order_email [varchar](100)
as
	DECLARE @mail_url [varchar](100)
	DECLARE @mailSubject [varchar](200)
	DECLARE @mailbody [varchar](1000)
	DECLARE @rhtm [varchar](8000)
	DECLARE @url_str [varchar](100)
	set @mail_url = 'http://shop.barunson.com/mail/mail_img1'
	If @otype = '0'
       		 set @url_str = 'http://www.barunsoncard.com/login/login.asp?frompage=/mypage/main.asp'
    	Else
		if @otype = '1'
			set @url_str = 'http://shop.barunson.com/b2b/login.asp?oseq=' + @order_seq
		else
			set @url_str = 'http://shop.barunson.com/lgeshop/login.asp?oseq=' + @order_seq
  
  	set @mailSubject = '(주)바른손카드입니다. (인쇄디자인 확인요청)'
    
    
    set @mailbody = @order_name + '님 안녕하세요. (주)바른손카드입니다. <br><br>'+char(13)
            + '주문하신 내용을 기준으로 청첩장에 인쇄될 디자인 제작이 완성되었습니다.<BR><BR>'+char(13)
            + '고객님께서는 <a href="' + @url_str + '"><b>인쇄원고확인</b></a> 으로 작업된 인쇄원고를 확인해주세요.<BR><BR>'+char(13)
    
    If @otype = '1' 
        set @mailbody = @mailbody + '인쇄원고 확인은 아래의 [인쇄원고 확인 바로가기]버튼을 클릭하신 후<br>주문번호와 주문자 이름을 기입하시면 됩니다.<br><br>'+char(13)
                     + '주문번호 : <font size=3><b>' + @order_Seq + '</b></font><br>주문자 이름 : <font size=3><b>' + @order_name + '</b></font><br><br>'+char(13)
            
            
    set @mailbody = @mailbody + '작업된 원고 확인을 통해 수정사항이나, 추가할 글귀등이 있다면 <BR>'+char(13)
            + '수정게시판을 통해 글을 남겨주시면 확인 즉시 수정해 드립니다.<BR><BR>'+char(13)
            + '수정내용이 없다면 최종단계인 확인완료 버튼을 눌러주세요.<BR>'+char(13)
            + '고객님의 확인이 없으면, 인쇄가 진행되지 않습니다. <BR><BR>'
            
            
    
    set @rhtm = '<html><head><title>Untitled Document</title>'+char(13)
    +'<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">'+char(13)
    +'<style type="text/css">'+char(13)
    +'<!--'+char(13)
    +'A:link    {color:#767676;text-decoration:none}'+char(13)
    +'A:visited {color:#767676;text-decoration:none}'+char(13)
    +'A:active  {color:#111111;text-decoration:none}'+char(13)
    +'A:hover  {color:#111111;text-decoration:underline}'+char(13)
    
    +'body,td,center,option,pre,blockquote {font-size:9pt;font-family:"돋움";color:#666666;letter-spacing:-0.5px;line-height: 17px;}'+char(13)
    +'textarea { background-color:white;border:1 solid #D6D6D6 ; font-family:돋움;font-color:#767676;line-height:12pt; font-size:9pt;padding-top:5pt; padding-left:7pt;padding-right:5pt}'+char(13)
    +'select { background-color:white;border:1 solid #D6D6D6 ; font-family:돋움; font-size:9pt;font-color:#767676 }'+char(13)
    +'.input01 {background-color:white;border:1 solid #D6D6D6;font-family:"돋움";font-size:9pt;font-color:#767676;color: #333333;}'+char(13)
    +'.big {font-family: "돋움체", "돋움";font-size: 14px;font-weight: bold; letter-spacing:-1.5px;}'+char(13)
    +'.s {font-size: 11px; font-family: "돋움체", "돋움"; letter-spacing:-1.0px}'+char(13)
    +'-->'+char(13)
    +'</style>'+char(13)
    +'</head>'+char(13)
    
    +'<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'+char(13)
    +'<table width="648" border="0" align="center" cellpadding="0" cellspacing="0" background="http://shop.barunson.com/mail/mail_img1/back.gif">'+char(13)
    +'<tr><td><img src="http://shop.barunson.com/mail/mail_img1/top_logo.jpg" width="648" height="69" border="0" usemap="#Map2"></td>'+char(13)
    +'<map name="Map2"><area shape="rect" coords="17,19,156,63" href="http://shop.barunson.com" target="_blank"  onFocus="this.blur();">'+char(13)
    +'</map></tr>'+char(13)
    +'<tr><td><table width="648" border="0" cellspacing="0" cellpadding="0">'+char(13)
    +' <tr><td valign="top"><table width="302" border="0" cellspacing="0" cellpadding="0">'+char(13)
    +'     <tr><td height="30">&nbsp;</td></tr>'
    +'     <tr><td><img src="http://shop.barunson.com/mail/mail_img1/step_02.gif" width="302" height="80"></td></tr>'+char(13)
    +'     <tr><td height="54" align="right"><img src="http://shop.barunson.com/mail/mail_img1/img_05.gif" width="26" height="54"></td></tr>'+char(13)
    +'     <tr><td height="54"><img src="http://shop.barunson.com/mail/mail_img1/bar_02.gif" width="301" height="57"></td></tr></table></td>'+char(13)
    +' <td><table width="347" border="0" cellspacing="0" cellpadding="0">'+char(13)
    +'     <tr><td width="203" height="221" valign="top" background="http://shop.barunson.com/mail/mail_img1/pung_02.gif" class="big" style="padding-left:25;padding-top:76"><font color="#FFFFFF"><!--고객명 --> ' + @order_name + '<!--//고객명 -->님, </font></td>'+char(13)
    +'     <td width="144"><img src="http://shop.barunson.com/mail/mail_img1/img_01.gif" width="144" height="221"></td></tr>'+char(13)
    +'     </table></td></tr>'+char(13)
    +' </table></td></tr>'+char(13)
    +'<tr><td background="http://shop.barunson.com/mail/mail_img1/img_back.gif"><table width="580" border="0" align="center" cellpadding="0" cellspacing="0">'+char(13)
    +' <tr><td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">'+char(13)
    +'     <tr><td height="10"></td></tr>'+char(13)
    +'     <tr><td height="28">'+ @mailbody + '</td></tr>'+char(13)
    +'     <tr><td height="36"><a href="' + @url_str + '"><img src="http://shop.barunson.com/mail/mail_img1/02_btn01.gif" width="140" height="26" border="0"></a></td></tr>'+char(13)
    +'     </table> '
    +' </td></tr></table></td></tr>'+char(13)
    +'<tr><td><img src="http://shop.barunson.com/mail/mail_img1/img_04.gif"></td></tr>'+char(13)
    +'<tr><td height="152"><table width="625" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="D8D8D8">'+char(13)
    +' <tr><td height="108" bgcolor="#FFFFFF"><img src="http://shop.barunson.com/mail/mail_img1/img_06.gif" width="497" height="96"></td></tr></table></td></tr>'+char(13)
    +'<tr><td><img src="http://shop.barunson.com/mail/mail_img1/pu_img05.gif" width="648" height="15"></td></tr>'+char(13)
    +'<tr><td height="22"><!--이청첩장--><table width="100%" border="0" cellspacing="0" cellpadding="0">'+char(13)
    +' <tr><td rowspan="2"><img src="http://shop.barunson.com/mail/mail_img1/pu_02.gif" width="145" height="308"></td><td>'+char(13)
    +'     <table width="100" border="0" cellspacing="0" cellpadding="0">'+char(13)
    +'     <tr><td><img src="http://shop.barunson.com/mail/mail_img1/pu_img02.gif" width="474" height="42"></td></tr>'+char(13)
    +'     <tr><td><img src="http://shop.barunson.com/mail/mail_img1/pu_img03.gif" width="503" height="111" border="0" usemap="#MapMap">'+char(13)
    +'     <map name="MapMap"><area shape="circle" coords="418,55,34" href="http://shop.barunson.com/ewedd/ewedd_main.asp"></map></td></tr>'+char(13)
    +'     <tr><td><table border="0" cellspacing="0" cellpadding="0">'+char(13)
    +'         <tr><td width="105"><table border="0" cellspacing="0" cellpadding="0">'+char(13)
    +'             <tr><td><table border="0" cellpadding="1" cellspacing="1" bgcolor="BABABA">'+char(13)
    +'                 <tr><td bgcolor="#FFFFFF"><a href="http://shop.barunson.com/ewedd/ewedd_main.asp"><img src="http://shop.barunson.com/mail/mail_img1/shine_01.gif" width="90" height="121" border="0"></a></td></tr></table></td></tr>'+char(13)
    +'             <tr><td height="2" bgcolor="E2E2E2"></td></tr></table></td>'+char(13)
    +'         <td width="105"><table border="0" cellspacing="0" cellpadding="0">'+char(13)
    +'             <tr><td><table border="0" cellpadding="1" cellspacing="1" bgcolor="BABABA">'+char(13)
    +'                 <tr><td bgcolor="#FFFFFF"><a href="http://shop.barunson.com/ewedd/ewedd_main.asp"><img src="http://shop.barunson.com/mail/mail_img1/shine_02.gif" width="90" height="121" border="0"></a></td></tr></table></td></tr>'+char(13)
    +'             <tr><td height="2" bgcolor="E2E2E2"></td></tr></table></td>'+char(13)
    +'         <td><table border="0" cellspacing="0" cellpadding="0">'+char(13)
    +'             <tr><td><table border="0" cellpadding="1" cellspacing="1" bgcolor="BABABA">'+char(13)
    +'                 <tr><td bgcolor="#FFFFFF"><a href="http://shop.barunson.com/ewedd/ewedd_main.asp"><img src="http://shop.barunson.com/mail/mail_img1/shine_03.gif" width="90" height="121" border="0"></a></td></tr></table></td></tr>'+char(13)
    +'             <tr><td height="2" bgcolor="E2E2E2"></td></tr></table></td>'+char(13)
    +'         <td><img src="http://shop.barunson.com/mail/mail_img1/pu_02img01.gif" width="176" height="106"></td></tr></table></td></tr></table></td></tr></table><!--//이청첩장-->'+char(13)
    +'</td></tr><tr>'+char(13)
    +'<td>&nbsp;</td></tr>'+char(13)
    +'<tr><td><img src="http://shop.barunson.com/mail/mail_img1/pu_bo.gif" width="648" height="15"></td></tr></table>'+char(13)    
		+'<table cellpadding="0" cellspacing="0" width="648" ALIGN="CENTER"><tr><td><img src="'+@mail_url+'/s_putt02.jpg" width="648" height="90" border="0"></a></table></body></html>' + char(13)
	--exec [114.111.54.153].mail.dbo.usp_tNeoShop_insert @order_seq,@order_name,@order_email,@mailSubject,@rhtm
	
	exec sp_sendtNeoMail_wedd '바른손카드','mailman@bhands.com',@order_name,@order_email,@mailSubject,@rhtm
GO
