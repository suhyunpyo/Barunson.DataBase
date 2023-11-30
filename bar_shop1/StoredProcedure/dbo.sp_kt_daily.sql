IF OBJECT_ID (N'dbo.sp_kt_daily', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_kt_daily
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------------------------  
1.Stored Procedure : sp_kt_daily  
2.관련 Table  : s2_userinfo,kt_DAILY_INFO  
3.내용    :kt 일일 회원가입 정보 보내는 데이터 생성  

-- exec [dbo].[sp_kt_daily]
-----------------------------------------------------------------------------------------------*/  
CREATE Procedure [dbo].[sp_kt_daily]  
  
as  
begin  
  
 -- 1. 전일 까사미아 마케팅동의 일별회원 데이터 CI 값으로 중복제거 후 kt_DAILY_INFO 인서트 
  

 insert into dbo.KT_DAILY_INFO (
 uid, uname, ConnInfo, Birth_date, phone ,hand_phone ,zipcode,address,addr_detail,umail,wedding_day,gender ,barun_reg_Date ,KTmembership_reg_Date, create_Date	
 )
	select 
		uid ,uname,ConnInfo
		,birth
		,phone1+phone2+phone3
		,hand_phone1+hand_phone2+hand_phone3
		,zip1+zip2 as zipcode
		,address
		, addr_detail
		,umail
		,replace((select top 1 wedding_day from vw_user_info where uid = m.uid),'-','') wedding_day 
		,gender
		,INTERGRATION_DATE 
		,KTmembership_reg_Date
		,GETDATE()
	from s2_userinfo m 
	where 1 = 1
	and site_div ='SB'
	and (convert(varchar(10),KTmembership_reg_Date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),KTmembership_reg_Date,120) < convert(varchar(10),GETDATE(),120)  and chk_ktmembership = 'Y' ) 
    and m.ktmembership_leave_date is null  
	and NOT EXISTS (SELECT 'n' FROM kt_DAILY_INFO WHERE ConnInfo = m.ConnInfo )  


 -------------------------------------------------------------------------------------------------------  
  -- 마케팅 동의철회
 -------------------------------------------------------------------------------------------------------  

     insert into KT_DAILY_INFO_CANCEL (cancel_dt, uid, UNAME,hand_phone, create_Date ) 
		select CONVERT(varchar(10) , delete_date, 112) cancle_Dt , dm.uid, dm.uname 
		,isnull((select top 1 HPHONE from VW_USER_INFO where uid = dm.uid  ),'000-0000-0000') hand_phone
		,GETDATE()
		from SAMSUNG_DELETE_MEMBER dm,  KT_DAILY_INFO mp
		where dm.uid = mp.uid
		and dm.delete_date >=  convert(varchar(10),GETDATE()-1,120)   and dm.delete_date <  convert(varchar(10),GETDATE(),120)   
		and dm.DELETE_MARKETING ='Y'


		
END  
  
  
GO
