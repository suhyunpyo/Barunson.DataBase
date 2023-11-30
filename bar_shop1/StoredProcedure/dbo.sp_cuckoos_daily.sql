IF OBJECT_ID (N'dbo.sp_cuckoos_daily', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_cuckoos_daily
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------------------------  
내용 : 쿠쿠홈시스 일일 회원가입 정보 보내는 데이터 생성  
작성일 : 2021.08.24   

 사용 방법 
exec [dbo].[sp_cuckoos_daily] 
-----------------------------------------------------------------------------------------------*/  
CREATE Procedure [dbo].[sp_cuckoos_daily]  
  
as  
begin  
  
 -- 1. 바른손, 비핸즈(제휴포함), 더카드, 프리미어 일별회원 데이터를 CI 값으로 중복제거 후 CUCKOOS_DAILY_INFO 인서트    
 -- 2. 부가정보업데이트 
  
 insert into dbo.CUCKOOS_DAILY_INFO (ConnInfo)  
 SELECT distinct(ConnInfo)   
 FROM (  
    select bb.UID ,bb.ConnInfo  
    from S2_UserInfo bb  
    where   
    (convert(varchar(10),bb.cuckoosship_reg_Date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),bb.cuckoosship_reg_Date,120) < convert(varchar(10),GETDATE(),120)  
    and bb.site_div = 'SB' and bb.chk_cuckoosmembership = 'Y')  
  ) BB  
 WHERE NOT EXISTS (SELECT 'N' FROM CUCKOOS_DAILY_INFO WHERE ConnInfo = BB.ConnInfo )  
  
-- 2. CI 값으로 정보 업뎃 ( vw_user_info : 바른손 : SB )  
  
 update dbo.CUCKOOS_DAILY_INFO  
 set  
  file_dt = convert(varchar(10),GETDATE(),120),
  uid=b.uid,  
  uname=b.uname,   
  phone = b.phone1+'-'+b.phone2+'-'+b.phone3,  
  hand_phone = b.hand_phone1+'-'+b.hand_phone2+'-'+b.hand_phone3,  
  umail = b.umail, 
  zipcode = b.zip1+b.zip2,  
  address = b.address,  
  wedding_day = b.wedd_year+'-'+b.wedd_month+'-'+b.wedd_day,
  barun_reg_Date = b.intergration_date,  
  barun_reg_site = b.referer_sales_gubun,  
  cuckos_reg_date = b.cuckoosship_reg_Date
 from dbo.CUCKOOS_DAILY_INFO a join s2_userinfo b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_cuckoosmembership = 'Y'  
 and b.site_div ='SB'  
 and (convert(varchar(10),b.cuckoosship_reg_Date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
 and convert(varchar(10),b.cuckoosship_reg_Date,120) < convert(varchar(10),GETDATE(),120)  
 and b.chk_cuckoosmembership = 'Y')  


 -------------------------------------------------------------------------------------------------------  
  -- 마케팅 동의철회  
 -------------------------------------------------------------------------------------------------------  

    insert into CUCKOOS_DAILY_INFO_CANCEL (file_dt, cancel_dt, uid,hand_phone ) 
	select convert(varchar(10),GETDATE(),120) file_Dt, CONVERT(varchar(10) , delete_date, 112) cancle_Dt , dm.uid
	,isnull((select top 1 HPHONE from VW_USER_INFO where uid = dm.uid  ),'000-0000-0000') hphone
	from SAMSUNG_DELETE_MEMBER dm,  CUCKOOS_DAILY_INFO mp
	where dm.uid = mp.uid
	and dm.delete_date >=  convert(varchar(10),GETDATE()-1,120)   and dm.delete_date <  convert(varchar(10),GETDATE(),120)   
	and dm.DELETE_MARKETING ='Y'


 -------------------------------------------------------------------------------------------------------  
  -- 렌탈상담  
 -------------------------------------------------------------------------------------------------------
	UPDATE CUCKOOS_INBOUND SET file_dt = convert(varchar(10),GETDATE(),120)
	WHERE reg_date >=  convert(varchar(10),GETDATE()-1,120)   and reg_date < convert(varchar(10),GETDATE(),120)
	and file_dt = '' 
END  
GO
