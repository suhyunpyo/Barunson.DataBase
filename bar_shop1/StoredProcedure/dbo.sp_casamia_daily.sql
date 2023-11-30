IF OBJECT_ID (N'dbo.sp_casamia_daily', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_casamia_daily
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------------------------  
1.Stored Procedure : sp_casamia_daily  
2.관련 Table  : S2_UserInfo, S2_UserInfo_BHands, S2_UserInfo_TheCard, CASAMIA_DAILY_INFO  
3.내용    :까사미아 일일 회원가입 정보 보내는 데이터 생성  
     바른손, 비핸즈(제휴포함), 더카드, 프리미어 일별 회원가입 데이터 -> CASAMIA_DAILY_INFO 로 중복제거 후 인서트  
     인자값1) 당일 -1일  

-- exec [dbo].[sp_casamia_daily]
-----------------------------------------------------------------------------------------------*/  
CREATE Procedure [dbo].[sp_casamia_daily]  
  
as  
begin  
  
 -- 1. 전일 까사미아 마케팅동의 일별회원 데이터 CI 값으로 중복제거 후 CASAMIA_DAILY_INFO 인서트 
  

 insert into dbo.CASAMIA_DAILY_INFO (
 uid, uname, ConnInfo, gender, birth_div, Birth_date, phone ,hand_phone ,zipcode,address,addr_detail,umail,wedding_day,barun_reg_site ,barun_reg_Date ,create_date	
 )
	select 
		uid ,uname,ConnInfo,replace(replace(Gender,'0','F'),'1','M') gender
		,birth_div ,replace(birth,'-','') birth_Dt
		,phone1+'-'+phone2+'-'+phone3
		,hand_phone1+'-'+hand_phone2+'-'+hand_phone3
		,zip1+zip2 as zipcode
		,address
		,addr_detail
		,umail
		,(select top 1 wedding_day from vw_user_info where uid = m.uid) 
		,REFERER_SALES_GUBUN
		,INTERGRATION_DATE 
		,GETDATE()
	from s2_userinfo m 
	where 1 = 1
	and site_div ='SB'
	and (convert(varchar(10),casamiaship_reg_Date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
    and convert(varchar(10),casamiaship_reg_Date,120) < convert(varchar(10),GETDATE(),120)  and chk_casamiamembership = 'Y' ) 
    and m.casamiaship_leave_date is null  
	and NOT EXISTS (SELECT 'n' FROM CASAMIA_DAILY_INFO WHERE ConnInfo = m.ConnInfo )  
	
END  
  
  
GO
