IF OBJECT_ID (N'dbo.sp_myomee_daily', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_myomee_daily
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------------------------  
관련 Table  S2_UserInfo, S2_UserInfo_BHands, S2_UserInfo_TheCard, MYOMEE_DAILY_INFO  

내용 : 롯데(묘미) 일일 회원가입 정보 보내는 데이터 생성  
	 바른손, 비핸즈(제휴포함), 더카드, 프리미어 일별 회원가입 데이터 -> MYOMEE_DAILY_INFO 로 중복제거 후 인써트  
	 인자값1) 당일 -1일  
작성일 : 2018.02.21   

 사용 방법 
exec [dbo].[sp_myomee_daily] 

-----------------------------------------------------------------------------------------------*/  
CREATE Procedure [dbo].[sp_myomee_daily]  
  
as  
begin  
  
 -- 1. 바른손, 비핸즈(제휴포함), 더카드, 프리미어 일별회원 데이터를 CI 값으로 중복제거 후 MYOMEE_DAILY_INFO 인서트    
 -- 2. 부가정보업데이트 
  
 insert into dbo.MYOMEE_DAILY_INFO (ConnInfo)  
 SELECT distinct(ConnInfo)   
 FROM (  
    select bb.UID ,bb.ConnInfo  
    from S2_UserInfo bb  
    where   
    (convert(varchar(10),bb.myomee_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),bb.myomee_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and bb.site_div in ('SB','SS') and bb.chk_myomee = 'Y')  
    Union      
    select bb.UID,bb.ConnInfo  
    from S2_UserInfo_BHands bb  
    where   
    (convert(varchar(10),bb.myomee_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),bb.myomee_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and bb.chk_myomee = 'Y')  
    Union   
    select bb.UID,bb.ConnInfo  
    from S2_UserInfo_TheCard bb  
    where   
    (convert(varchar(10),bb.myomee_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),bb.myomee_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and bb.chk_myomee = 'Y')  
  ) BB  
 WHERE NOT EXISTS (SELECT 'N' FROM MYOMEE_DAILY_INFO WHERE ConnInfo = BB.ConnInfo )  
  
-- 2. CI 값으로 정보 업뎃 ( vw_user_info : 바른손 : SB )  
  
 update dbo.MYOMEE_DAILY_INFO  
 set  
  uid=b.uid,  
  uname=b.uname,  
  Birth_date = b.Birth_date,   
  phone = b.phone,  
  hand_phone = b.hphone,  
  zipcode = replace(b.zipcode,'-',''),   
  address = b.address,  
  addr_detail = b.addr_detail,  
  umail = b.umail,  
  wedding_day = b.wedding_day,
  barun_reg_Date = b.intergration_date,  
  wedd_pgubun = b.wedding_hall,
  create_date = getdate()
 from dbo.MYOMEE_DAILY_INFO a join VW_USER_INFO b  
 on a.ConnInfo=b.ConnInfo   
 and b.chk_myomee = 'Y'  
 and b.site_div ='SB'  
 and (convert(varchar(10),b.myomee_reg_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),b.myomee_reg_date,120) < convert(varchar(10),GETDATE(),120)  
    and b.chk_myomee = 'Y')  

END  
  
GO
