IF OBJECT_ID (N'dbo.sp_samsung_daily', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_samsung_daily
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------------------------  
1.Stored Procedure : sp_samsung_daily  
2.관련 Table  : S2_UserInfo, S2_UserInfo_BHands, S2_UserInfo_TheCard, SAMSUNG_DAILY_INFO  
3.내용    : 삼성으로 일일 회원가입 정보 보내는 데이터 생성  
     바른손, 비핸즈(제휴포함), 더카드, 프리미어 일별 회원가입 데이터 -> SAMSUNG_DAILY_INFO 로 중복제거 후 인써트  
     인자값1) 당일 -1일  
4.작성자   : zen  
5.작성일   : 2013.07.01  
6.수정    :  
-----------------------------------------------------------------------------------------------*/  
  
/* 사용 방법-------------------------------------------------------------------------------------  
  
-- 2013-07-01 가입데이터  
exec [dbo].[sp_samsung_daily]  '2013-07-02'  
  
select * from [dbo].[SAMSUNG_DAILY_INFO]  
--truncate table [dbo].[SAMSUNG_DAILY_INFO]  
  
2014 06 09 추가  
조건문에 and b.chk_smembership = 'Y' 추가  
  
2014 07 23 변경  
chk_DM = b.chk_DM, -> chk_DM = 'Y',  
  
2014 08 08 추가  
에프터페이 결제 후 나중에 취소할 경우의 데이터가 안넘어가서 where 조건추가  
convert(varchar(10), aa.discount_in_advance_cancel_date, 120) = convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
  
2014 09 15 변경  
삼성전자 공동멤버십 가입 내 TM 프로세스변경 => 삼성3번째 항목선택값이 SMS/TM/E-MAIL 도 동일하게 설정  
chk_TM = 'Y', chk_DM = 'Y', chk_sms = b.chk_sms 변경  
chk_TM = isnull(b.chk_smembership_per,'N'), chk_DM = isnull(b.chk_smembership_per,'N'), chk_sms = isnull(b.chk_smembership_per,'N')  
chk_aoi = isnull(b.chk_smembership_per,'N')  
-----------------------------------------------------------------------------------------------*/  
CREATE     Procedure [dbo].[sp_samsung_daily]  
  
  
as  
begin  
    
 --2016.07.01수정쿼리  
 --1. 전날회원 삼성멤버십 가입자  
 --2. 일별 중복데이터 없앰  
 --3. 부가정보업뎃 : 예식일이 없이 SAMSUNG_DAILY_INFO에 인서트된 회원들은 다시 삼성전자에 보내기 위한 작업  
  
 insert into dbo.SAMSUNG_DAILY_INFO (ConnInfo)  
 SELECT distinct(ConnInfo)   
 FROM (  
    select bb.UID ,bb.ConnInfo  
    from S2_UserInfo bb  
    where   
    (convert(varchar(10),bb.smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),bb.smembership_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and bb.site_div in ('SB','SS') and bb.chk_smembership = 'Y')  
    Union   
    --비핸즈   
    select bb.UID,bb.ConnInfo  
    from S2_UserInfo_BHands bb  
    where   
    (convert(varchar(10),bb.smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),bb.smembership_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and bb.chk_smembership = 'Y')  
    Union   
    --더카드   
    select bb.UID,bb.ConnInfo  
    from S2_UserInfo_TheCard bb  
    where   
    (convert(varchar(10),bb.smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),bb.smembership_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and bb.chk_smembership = 'Y')  
  ) BB  
 WHERE NOT EXISTS (SELECT 'n' FROM SAMSUNG_DAILY_INFO WHERE ConnInfo = BB.ConnInfo )  
  
  
  
  
 -- 2. CI 값으로 정보 업뎃 ( 정보우선순위 : 비핸즈제휴 -> 프리미어 -> 더카드 -> 비핸즈 -> 바른손 )  
  
  
 -- 비핸즈 제휴 기본정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  uid=b.uid,  
  uname=b.uname,  
  Birthdate = b.Birthdate,  
  Gender = b.Gender,  
  p_gubun = 'H',  
  phone1 = b.phone1,  
  phone2 = b.phone2,  
  phone3 = b.phone3,  
  hand_phone1 = b.hand_phone1,  
  hand_phone2 = b.hand_phone2,  
  hand_phone3 = b.hand_phone3,  
  chk_TM = isnull(b.chk_smembership_per,'N'),  
  zip1 = b.zip1,  
  zip2 = b.zip2,  
  address = b.address,  
  addr_detail = b.addr_detail,  
  c_zip1 = b.zip1,  
  c_zip2 = b.zip2,  
  c_address = b.address,  
  c_addr_detail = b.addr_detail,  
  chk_DM = isnull(b.chk_smembership_per,'N'),  
  chk_sms = isnull(b.chk_smembership_per,'N'),  
  reg_date = b.reg_date,  
  umail = b.umail,  
  chk_mailservice = isnull(b.chk_smembership_per,'N'), --b.chk_mailservice  
  chk_aoi = isnull(b.chk_smembership_per,'N'),  
  chk_tpa = b.chk_smembership_coop,  
  secession = 'N',  
  reg_date_s = GETDATE(),  
  smembership_reg_date = b.smembership_reg_date,  
  smembership_leave_date = b.smembership_leave_date,  
  mod_date = b.mod_date,  
  chk_smembership = b.chk_smembership,  
  site_div = isnull(b.REFERER_SALES_GUBUN,'SB'),  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,
  smembership_period = isnull(b.smembership_period,'R')   
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo_BHands b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and b.isjehu ='Y' and a.chk_DM is null  
 and (convert(varchar(10),b.smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),b.smembership_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and b.chk_smembership = 'Y')  
 and a.smembership_leave_date is null  
   
 -- 비핸즈 제휴 부가정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set   
  site_div = b.isJehu,  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,  
  reg_date_s = GETDATE()  
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo_BHands b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and b.isjehu ='Y' and a.ugubun is null  
 AND a.wedd_year  = ''  
 and b.wedd_year <> ''  
 and a.smembership_leave_date is null  
  
   
   
  
 -- 프리미어 기본정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  uid=b.uid,  
  uname=b.uname,  
  Birthdate = b.Birthdate,  
  Gender = b.Gender,  
  p_gubun = 'H',  
  phone1 = b.phone1,  
  phone2 = b.phone2,  
  phone3 = b.phone3,  
  hand_phone1 = b.hand_phone1,  
  hand_phone2 = b.hand_phone2,  
  hand_phone3 = b.hand_phone3,  
  chk_TM = isnull(b.chk_smembership_per,'N'),  
  zip1 = b.zip1,  
  zip2 = b.zip2,  
  address = b.address,  
  addr_detail = b.addr_detail,  
  c_zip1 = b.zip1,  
  c_zip2 = b.zip2,  
  c_address = b.address,  
  c_addr_detail = b.addr_detail,  
  chk_DM = isnull(b.chk_smembership_per,'N'),  
  chk_sms = isnull(b.chk_smembership_per,'N'),  
  reg_date = b.reg_date,  
  umail = b.umail,  
  chk_mailservice = isnull(b.chk_smembership_per,'N'), --chk_mailservice = b.chk_mailservice  
  chk_aoi = isnull(b.chk_smembership_per,'N'),  
  chk_tpa = b.chk_smembership_coop,  
  secession = 'N',  
  reg_date_s = GETDATE(),  
  smembership_reg_date = b.smembership_reg_date,  
  smembership_leave_date = b.smembership_leave_date,  
  mod_date = b.mod_date,  
  chk_smembership = b.chk_smembership,  
  site_div = isnull(b.REFERER_SALES_GUBUN,'SB'),  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,
  smembership_period = isnull(b.smembership_period,'R')   
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and b.site_div ='SS' and a.chk_DM is null  
 and (convert(varchar(10),b.smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),b.smembership_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and b.chk_smembership = 'Y')  
 and a.smembership_leave_date is null  
   
   
 -- 프리미어 부가정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  site_div = b.site_div,  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,  
  reg_date_s = GETDATE()  
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and b.site_div ='SS' and a.ugubun is null  
 AND a.wedd_year  = ''  
 and b.wedd_year <> ''  
 and a.smembership_leave_date is null  
   
  
 -- 더 카드 기본정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  uid=b.uid,  
  uname=b.uname,  
  Birthdate = b.Birthdate,  
  Gender = b.Gender,  
  p_gubun = 'H',  
  phone1 = b.phone1,  
  phone2 = b.phone2,  
  phone3 = b.phone3,  
  hand_phone1 = b.hand_phone1,  
  hand_phone2 = b.hand_phone2,  
  hand_phone3 = b.hand_phone3,  
  chk_TM = isnull(b.chk_smembership_per,'N'),  
  zip1 = b.zip1,  
  zip2 = b.zip2,  
  address = b.address,  
  addr_detail = b.addr_detail,  
  c_zip1 = b.zip1,  
  c_zip2 = b.zip2,  
  c_address = b.address,  
  c_addr_detail = b.addr_detail,  
  chk_DM = isnull(b.chk_smembership_per,'N'),  
  chk_sms = isnull(b.chk_smembership_per,'N'),  
  reg_date = b.reg_date,  
  umail = b.umail,  
  chk_mailservice = isnull(b.chk_smembership_per,'N'), --chk_mailservice = b.chk_mailservice  
  chk_aoi = isnull(b.chk_smembership_per,'N'),  
  chk_tpa = b.chk_smembership_coop,  
  secession = 'N',  
  reg_date_s = GETDATE(),  
  smembership_reg_date = b.smembership_reg_date,  
  smembership_leave_date = b.smembership_leave_date,  
  mod_date = b.mod_date,  
  chk_smembership = b.chk_smembership,  
  site_div = isnull(b.REFERER_SALES_GUBUN,'SB'),  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,
  smembership_period = isnull(b.smembership_period,'R')   
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo_TheCard b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and a.chk_DM is null  
 and (convert(varchar(10),b.smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),b.smembership_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and b.chk_smembership = 'Y')  
 and a.smembership_leave_date is null  
   
   
 -- 더 카드 부가정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  site_div = b.site_div,  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,  
  reg_date_s = GETDATE()  
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo_TheCard b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and a.ugubun is null  
 AND a.wedd_year  = ''  
 and b.wedd_year <> ''  
 and a.smembership_leave_date is null  
   
   
  
 -- 비핸즈 기본정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  uid=b.uid,  
  uname=b.uname,  
  Birthdate = b.Birthdate,  
  Gender = b.Gender,  
  p_gubun = 'H',  
  phone1 = b.phone1,  
  phone2 = b.phone2,  
  phone3 = b.phone3,  
  hand_phone1 = b.hand_phone1,  
  hand_phone2 = b.hand_phone2,  
  hand_phone3 = b.hand_phone3,  
  chk_TM = isnull(b.chk_smembership_per,'N'),  
  zip1 = b.zip1,  
  zip2 = b.zip2,  
  address = b.address,  
  addr_detail = b.addr_detail,  
  c_zip1 = b.zip1,  
  c_zip2 = b.zip2,  
  c_address = b.address,  
  c_addr_detail = b.addr_detail,  
  chk_DM = isnull(b.chk_smembership_per,'N'),  
  chk_sms = isnull(b.chk_smembership_per,'N'),  
  reg_date = b.reg_date,  
  umail = b.umail,  
  chk_mailservice = isnull(b.chk_smembership_per,'N'), --chk_mailservice = b.chk_mailservice
  chk_aoi = isnull(b.chk_smembership_per,'N'),  
  chk_tpa = b.chk_smembership_coop,  
  secession = 'N',  
  reg_date_s = GETDATE(),  
  smembership_reg_date = b.smembership_reg_date,  
  smembership_leave_date = b.smembership_leave_date,  
  mod_date = b.mod_date,  
  chk_smembership = b.chk_smembership,  
  site_div = isnull(b.REFERER_SALES_GUBUN,'SB'),  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,
  smembership_period = isnull(b.smembership_period,'R')   
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo_BHands b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and b.isjehu ='n' and a.chk_DM is null  
 and (convert(varchar(10),b.smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),b.smembership_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and b.chk_smembership = 'Y')  
 and a.smembership_leave_date is null  
   
   
 -- 비핸즈 부가정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  site_div = b.isJehu,  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,  
  reg_date_s = GETDATE()  
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo_BHands b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and b.isjehu ='n' and a.ugubun is null  
 AND a.wedd_year  = ''  
 and b.wedd_year <> ''  
 and a.smembership_leave_date is null  
   
   
   
  
 -- 바른손 기본업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  uid=b.uid,  
  uname=b.uname,  
  Birthdate = b.Birthdate,  
  Gender = b.Gender,  
  p_gubun = 'H',  
  phone1 = b.phone1,  
  phone2 = b.phone2,  
  phone3 = b.phone3,  
  hand_phone1 = b.hand_phone1,  
  hand_phone2 = b.hand_phone2,  
  hand_phone3 = b.hand_phone3,  
  chk_TM = isnull(b.chk_smembership_per,'N'),  
  zip1 = b.zip1,  
  zip2 = b.zip2,  
  address = b.address,  
  addr_detail = b.addr_detail,  
  c_zip1 = b.zip1,  
  c_zip2 = b.zip2,  
  c_address = b.address,  
  c_addr_detail = b.addr_detail,  
  chk_DM = isnull(b.chk_smembership_per,'N'),  
  chk_sms = isnull(b.chk_smembership_per,'N'),  
  reg_date = b.reg_date,  
  umail = b.umail,  
  chk_mailservice = isnull(b.chk_smembership_per,'N'), --chk_mailservice = b.chk_mailservice  
  chk_aoi = isnull(b.chk_smembership_per,'N'),  
  chk_tpa = b.chk_smembership_coop,  
  secession = 'N',  
  reg_date_s = GETDATE(),  
  smembership_reg_date = b.smembership_reg_date,  
  smembership_leave_date = b.smembership_leave_date,  
  mod_date = b.mod_date,  
  chk_smembership = b.chk_smembership,  
  site_div = isnull(b.REFERER_SALES_GUBUN,'SB'),  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,
  smembership_period = isnull(b.smembership_period,'R')   
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and b.site_div ='SB' and a.chk_DM is null  
 and (convert(varchar(10),b.smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),b.smembership_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and b.chk_smembership = 'Y')  
 and a.smembership_leave_date is null  
   
   
  
 -- 바른손 부가정보업뎃  
 update dbo.SAMSUNG_DAILY_INFO  
 set  
  site_div = b.site_div,  
  ugubun = b.ugubun,  
  wedd_year = b.wedd_year,  
  wedd_month = b.wedd_month,  
  wedd_day = b.wedd_day,  
  wedd_pgubun = b.wedd_pgubun,  
  reg_date_s = GETDATE()  
 from dbo.SAMSUNG_DAILY_INFO a join S2_UserInfo b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_smembership = 'Y' --2014 06 09 추가  
 and b.site_div ='SB' and a.ugubun is null  
 AND a.wedd_year  = ''  
 and b.wedd_year <> ''  
 and a.smembership_leave_date is null  


 -- 삼성 마케팅동의 
 -- 회원 이용약관, 개인정보 수집, 마케팅 정보 수신, 개인정보 제3자 제공

 insert into SAMSUNG_MARKETING_AGREEMENT 
	select uid,'Y','Y','Y','Y','Y', smembership_reg_date from SAMSUNG_DAILY_INFO where  
	(convert(varchar(10),smembership_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),smembership_reg_date,120) < convert(varchar(10),GETDATE(),120) ) 

  
 -------------------------------------------------------------------------------------------------------  
 -- 삼성 선할인 데이터  
 -------------------------------------------------------------------------------------------------------   
    
 INSERT INTO [bar_shop1].[dbo].[SAMSUNG_DAILY_DISCOUNT]  
 (  
 conninfo,  
 chk_smembership,  
 smembership_reg_date,  
 smembership_leave_date,  
 chk_smembership_leave,  
 order_seq,  
 up_order_seq,  
 order_type,  
 sales_Gubun,  
 site_gubun,  
 company_seq,  
 status_seq,  
 order_date,  
 settle_status,  
 settle_date,  
 settle_price,  
 pg_resultinfo,  
 pg_shopid,  
 pg_tid,  
 member_id,  
 order_name,  
 discount_in_advance,  
 discount_in_advance_reg_date,  
 discount_in_advance_cancel_date,  
 reg_date_s,  
 dacom_tid  
   
 )  
  
 select distinct bb.conninfo, bb.chk_smembership, bb.smembership_reg_date, bb.smembership_leave_date, bb.chk_smembership_leave  
 , aa.order_seq, aa.up_order_seq, aa.order_type, aa.sales_gubun, aa.settle_method, aa.company_seq, aa.status_seq  
 , aa.order_date ,aa.settle_status, aa.settle_date, aa.settle_price, aa.pg_resultinfo,aa.pg_shopid, aa.pg_tid  
 , aa.member_id, aa.order_name  
 , aa.discount_in_advance, aa.discount_in_advance_reg_date, aa.discount_in_advance_cancel_date  
 , GETDATE()  
 , dacom_tid  
 from dbo.custom_order aa left join dbo.S2_UserInfo bb on aa.member_id = bb.uid  
 where   
 aa.order_type = '1' -- 청첩장 주문 일때  
 and aa.up_order_seq is null -- 원주문 일때  
 and aa.settle_method = '2' -- 결제 방법이 카드 결제 일때  
 and aa.sales_gubun = 'SB' -- 사이트가 바른손 일때  
 and aa.member_id <> '' -- 바른손회원 일때  
 and aa.discount_in_advance is not null -- 선할인이 결제거나 취소일때  
 and bb.chk_smembership ='Y' -- 삼성멤버쉽 회원 일때  
 and aa.settle_status ='2' -- 결제완료  
 --and pg_shopid ='bhandscas0' -- 피지사 결제아이디가 선할인인것만  
 and (  
  convert(varchar(10), aa.settle_date, 120) = convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
  or   
  convert(varchar(10), aa.discount_in_advance_cancel_date, 120) = convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
  )  
 order by aa.order_seq   
  
END  
  
  
GO
