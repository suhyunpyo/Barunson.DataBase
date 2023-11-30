IF OBJECT_ID (N'dbo.sp_memplus_daily', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_memplus_daily
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*----------------------------------------------------------------------------------------------  
1.Stored Procedure : sp_memplus_daily  
22.01.11 디디마케팅동의추가 conninfo ,site_div 추가
-----------------------------------------------------------------------------------------------*/  
  
CREATE     Procedure [dbo].[sp_memplus_daily]  
  
as  
 BEGIN  
 
 -------------------------------------------------------------------------------------------------------  
  -- 멤플러스 마케팅 동의 (바른손) 
 -------------------------------------------------------------------------------------------------------  
  insert into dbo.MEMPLUS_DAILY_INFO (file_dt, regdate, uid,type_code1,type_code2,type_code3,type_code4, type_code5, type_code6 , type_code7, type_code8, ConnInfo )  
  select  convert(varchar(10),GETDATE(),120), regdate,UID 
  ,  통신여부, 보험여부, 야쿠르트여부, 건강여부, 교보, 신한생명, 렌탈, 뉴교보생명, ConnInfo
  from  (   
  select     
    max(A.regdate ) regdate        
   , max(A.uid ) uid      
   , max(A.ConnInfo ) ConnInfo   
   , CASE WHEN ISNULL(max(B.seq), 0) = 0 THEN 'N' ELSE 'Y' END AS 마케팅여부  
   ,(select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where marketing_type_code = 119001 and uid = max(a.uid))  AS 통신여부   
   ,'N' AS 보험여부  
   ,'N' AS 야쿠르트여부  
   ,'N' AS 건강여부
   ,'N' AS 교보	
   ,(select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where marketing_type_code = 119006 and uid = max(a.uid))  AS 신한생명 
   ,(select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where marketing_type_code = 119007 and uid = max(a.uid))  AS 렌탈 
   ,(select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where marketing_type_code = 119008 and uid = max(a.uid))  AS 뉴교보생명 
   from (   
      SELECT  uid,  
        CONVERT(varchar(10), reg_date, 112) as regdate,    
         ConnInfo, Birth as Birth
      FROM     dbo.S2_UserInfo_BHands   
   ) A left join S4_Event_Raina B on A.uid = B.uid AND event_div = 'MKevent'   
    WHERE B.reg_date >=  convert(varchar(10),GETDATE()-1,120)   and B.reg_date <  convert(varchar(10),GETDATE(),120)  
    group by  ConnInfo   
     )  tt   
   where tt.마케팅여부 = 'Y' and tt.통신여부= 'Y' and not exists ( select 'Y' FROM S4_Event_Raina WHERE event_div = 'MKevent' and UID = tt.uid and reg_Date < convert(varchar(10),GETDATE()-1,120)  )  


 -------------------------------------------------------------------------------------------------------  
  -- 멤플러스 마케팅 동의 (디얼디어) 
 -------------------------------------------------------------------------------------------------------   
  insert into dbo.MEMPLUS_DAILY_INFO (file_dt, regdate, uid,type_code1,type_code2,type_code3,type_code4, type_code5, type_code6 , type_code7, type_code8, ConnInfo,site_div )    
  SELECT  convert(varchar(10),GETDATE(),120) , CONVERT(varchar(10), agree_Date, 112) as regdate,UID
	 ,  통신여부, 보험여부, 야쿠르트여부, 건강여부, 교보, 신한생명, 렌탈, 뉴교보생명
	,ConnInfo
	,'SD'
	FROM (
	select 
	A.UID  
	,  (select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_UserInfo_Deardeer_Marketing where agreement_type = 'MEMPLUS_COMM' and uid = a.uid) 통신여부
	, 'N' AS 보험여부
	, 'N' 야쿠르트여부
	, 'N' 건강여부
	, 'N' 교보
	, (select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_UserInfo_Deardeer_Marketing where agreement_type = 'MEMPLUS_INSURA' and uid = a.uid) 신한생명
	, 'N' 렌탈
	, 'N' 뉴교보생명
	, ConnInfo
	, agree_Date
	from S2_UserInfo_Deardeer a, S2_UserInfo_Deardeer_Marketing b
	where a.uid = b.uid
	and B.agree_Date >=  convert(varchar(10),GETDATE()-1,120)   and B.agree_Date <  convert(varchar(10),GETDATE(),120) 
	and agreement_type ='MEMPLUS' AND chk_agreement = 'Y'
	and cancel_date is null
	and not exists (select 'Y' from MEMPLUS_DAILY_INFO where file_Dt <= CONVERT(CHAR(10), getdate(), 23) and CONNINFO = a.conninfo)
	) a 


 
 -------------------------------------------------------------------------------------------------------  
  -- 멤플러스 마케팅 동의철회  (바른손)
 -------------------------------------------------------------------------------------------------------  

    insert into MEMPLUS_DAILY_INFO_CANCEL (file_dt, cancel_dt, uid,hphone ) 
	select convert(varchar(10),GETDATE(),120) file_Dt, CONVERT(varchar(10) , delete_date, 112) cancle_Dt , dm.uid
	,isnull((select top 1 HPHONE from VW_USER_INFO where uid = dm.uid  ),'000-0000-0000') hphone
	from SAMSUNG_DELETE_MEMBER dm,  MEMPLUS_DAILY_INFO mp
	where dm.uid = mp.uid
	and dm.delete_date >=  convert(varchar(10),GETDATE()-1,120)   and dm.delete_date <  convert(varchar(10),GETDATE(),120)   
	and dm.DELETE_MARKETING ='Y'

 -------------------------------------------------------------------------------------------------------  
  -- 멤플러스 마케팅 동의철회  (디얼디어)
 -------------------------------------------------------------------------------------------------------  

    insert into MEMPLUS_DAILY_INFO_CANCEL (file_dt, cancel_dt, uid,hphone ) 
	select convert(varchar(10),GETDATE(),120) file_Dt, CONVERT(varchar(10) , cancel_date, 112) cancle_Dt , dm.uid
	,isnull((select top 1 hand_PHONE1 +'-'+ hand_PHONE2 +'-'+hand_PHONE3 from S2_UserInfo_Deardeer where uid = dm.uid  ),'000-0000-0000') hphone
	from S2_UserInfo_Deardeer_Marketing dm,  MEMPLUS_DAILY_INFO mp
	where dm.uid = mp.uid
	and dm.cancel_date >=  convert(varchar(10),GETDATE()-1,120)   and dm.cancel_date <  convert(varchar(10),GETDATE(),120)   
	and dm.agreement_type ='MEMPLUS' AND chk_agreement = 'N'

 END 


GO
