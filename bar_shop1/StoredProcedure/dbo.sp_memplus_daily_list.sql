IF OBJECT_ID (N'dbo.sp_memplus_daily_list', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_memplus_daily_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*----------------------------------------------------------------------------------------------  
1.Stored Procedure : sp_memplus_daily_list  
2.작성일   : 2016.04.27 // 119001 : 통신 / 119002 : 보험 / 119005 : 교보생명   
			코드확인table : common_code class_code= 119 
			
exec [sp_memplus_daily_list] '2021-06-13', '2021-06-16','1'		 
-----------------------------------------------------------------------------------------------*/  
  
CREATE Procedure [dbo].[sp_memplus_daily_list]  
  
	@s_dt nvarchar(20),  
	@e_dt nvarchar(20),
	@type  varchar(1) 
AS
BEGIN

	SET NOCOUNT ON

	IF @type = '1'
		BEGIN

		   select  tt.*  
		 , ( CASE WHEN 통신여부 = 'Y' THEN CASE WHEN 마케팅동의 = 0 THEN 1 WHEN 마케팅동의 = 1 AND 가입구분 = 'S' THEN 3 WHEN 마케팅동의 = 1 AND 가입구분 IS NULL THEN 2 END   END ) AS 참여영역구분 
		 from  ( 
			select   max(A.uname) uname  , max(a.BDAY) BDAY   , max(A.PHONE) PHONE  , max(A.HPHONE) HPHONE  , max(A.ZIPCODE) ZIPCODE   , max(A.address ) address   , max(A.addr_detail) addr_detail  
			, ISNULL(max(a.settle_agree_date),max(A.regdate ) ) as regdate  , ISNULL(max(a.settle_reg_time),max(A.reg_time ) ) as reg_time  , max(A.umail) umail   
			, max(A.ConnInfo ) ConnInfo  , max(A.uid ) uid  
			, '디얼디어' AS SITE_DIV_NAME  
			, max(A.Birth) Birth    , max(A.wedd_year) wedd_year   , max( A.wedd_month) wedd_month  , max(A.wedd_day) wedd_day   , CASE WHEN ISNULL(max(B.seq), 0) = 0 THEN 'N' ELSE 'Y' END AS 마케팅여부  
			, (select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_UserInfo_Deardeer_Marketing where agreement_type = 'MEMPLUS_COMM' and uid = max(a.uid))  AS 통신여부  
			, 'N' AS 보험여부  , 'N' AS 건강여부  , 'N' AS 교보  , '0' AS  마케팅동의  
			, ( select gubun FROM EVENT_MARKETING_AGREEMENT WHERE  UID = max(A.uid)) 가입구분  
			, (select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_UserInfo_Deardeer_Marketing where agreement_type = 'MEMPLUS_INSURA' and uid = max(a.uid))  AS 신한생명  
			,  'N' AS  렌탈  
			,  'N' AS 뉴교보생명  
			from (     SELECT  uid, uname, SUBSTRING(birth+Gender,3,7) BDAY, phone1 + '-' + phone2 + '-' + phone3 AS PHONE,       hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE
			, zip1 + '-' + zip2 AS ZIPCODE, address, addr_detail
			,       CONVERT(varchar(10), reg_date, 112) as regdate 		,SUBSTRING((convert(varchar(10),reg_date,24)),1,2) + SUBSTRING((convert(varchar(10),reg_date,24)),4,2) + SUBSTRING((convert(varchar(10),reg_date,24)),7,2) reg_time
			,        umail, ConnInfo, replace(birth,'-','') as Birth, GETDATE() as nowDate, wedd_year, wedd_month, wedd_day       
			,'SD' site_div 	
			,(select convert(varchar(10),max(agree_date),112) from S2_UserInfo_Deardeer_Marketing where uid = m.uid and agreement_type ='MEMPLUS' ) as settle_agree_date 	
			,(select SUBSTRING((convert(varchar(10),max(reg_date),24)),1,2) + SUBSTRING((convert(varchar(10),max(reg_date),24)),4,2) + SUBSTRING((convert(varchar(10),max(reg_date),24)),7,2) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = m.uid) as settle_reg_time     
			FROM dbo.S2_UserInfo_Deardeer m  ) A 
			left join S2_UserInfo_Deardeer_Marketing B on A.uid = B.uid    
			WHERE B.agree_date >=  @s_dt  and B.agree_date <  @e_dt   
			group by  ConnInfo    )  tt  
			where tt.마케팅여부 = 'Y' and exists ( select 'Y' FROM MEMPLUS_DAILY_INFO WHERE site_div = 'SD' and UID = tt.uid and FILE_dT = @e_dt) 
	
			union ALL
	
			select  tt.*  
		 , ( CASE WHEN 통신여부 = 'Y' THEN CASE WHEN 마케팅동의 = 0 THEN 1 WHEN 마케팅동의 = 1 AND 가입구분 = 'S' THEN 3 WHEN 마케팅동의 = 1 AND 가입구분 IS NULL THEN 2 END   END ) AS 참여영역구분 
		 from  ( 
			select   max(A.uname) uname  , max(a.BDAY) BDAY   , max(A.PHONE) PHONE  , max(A.HPHONE) HPHONE  , max(A.ZIPCODE) ZIPCODE   , max(A.address ) address   , max(A.addr_detail) addr_detail  
			, ISNULL(max(a.settle_agree_date),max(A.regdate ) ) as regdate  , ISNULL(max(a.settle_reg_time),max(A.reg_time ) ) as reg_time  , max(A.umail) umail   
			, max(A.ConnInfo ) ConnInfo  , max(A.uid ) uid  
			,(case max(A.site_div)  when 'SA' THEN '비핸즈'  when 'SB' then '바른손'  when 'ST' THEN '더카드'  when 'SS' then '프리미어페이퍼'  when 'SD' then '디얼디어'  ELSE  '바른손몰' end ) SITE_DIV_NAME 
			, max(A.Birth) Birth    , max(A.wedd_year) wedd_year   , max( A.wedd_month) wedd_month  , max(A.wedd_day) wedd_day   , CASE WHEN ISNULL(max(B.seq), 0) = 0 THEN 'N' ELSE 'Y' END AS 마케팅여부  
			,(select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where marketing_type_code = 119001 and uid = max(a.uid))  AS 통신여부  
			, 'N' AS 보험여부  , 'N' AS 건강여부  , 'N' AS 교보  , ( select count(uid) FROM EVENT_MARKETING_AGREEMENT WHERE  UID = max(A.uid)) 마케팅동의  
			, ( select gubun FROM EVENT_MARKETING_AGREEMENT WHERE  UID = max(A.uid)) 가입구분  
			, (select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where marketing_type_code = 119006 and uid = max(a.uid))  AS 신한생명  
			, (select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where marketing_type_code = 119007 and uid = max(a.uid))  AS 렌탈  
			, (select case when count(uid) > 0 then 'Y' else 'N' end FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where marketing_type_code = 119008 and uid = max(a.uid))  AS 뉴교보생명  
			from (     SELECT  uid, uname, SUBSTRING(birthdate+Gender,3,7) BDAY, phone1 + '-' + phone2 + '-' + phone3 AS PHONE,       hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE
			, zip1 + '-' + zip2 AS ZIPCODE, address, addr_detail
			,       CONVERT(varchar(10), reg_date, 112) as regdate 		,SUBSTRING((convert(varchar(10),reg_date,24)),1,2) + SUBSTRING((convert(varchar(10),reg_date,24)),4,2) + SUBSTRING((convert(varchar(10),reg_date,24)),7,2) reg_time
			,        umail, ConnInfo, replace(birth,'-','') as Birth, GETDATE() as nowDate, wedd_year, wedd_month, wedd_day       
			,( CASE        		WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN  			CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END 		ELSE 			CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END 	END ) AS site_div 	
			,(select convert(varchar(10),max(reg_date),112) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = m.uid) as settle_agree_date 	
			,(select SUBSTRING((convert(varchar(10),max(reg_date),24)),1,2) + SUBSTRING((convert(varchar(10),max(reg_date),24)),4,2) + SUBSTRING((convert(varchar(10),max(reg_date),24)),7,2) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = m.uid) as settle_reg_time     
			FROM dbo.S2_UserInfo_BHands m  ) A 
			left join S4_Event_Raina B on A.uid = B.uid AND event_div = 'MKevent'   
			WHERE B.reg_date >=  @s_dt  and B.reg_date <  @e_dt    
			group by  ConnInfo    )  tt  
			where tt.마케팅여부 = 'Y' and not exists ( select 'Y' FROM S4_Event_Raina WHERE event_div = 'MKevent' and UID = tt.uid and reg_Date < @s_dt ) 

		END

	ELSE
		BEGIN

		select hphone, uid 
		from [bar_shop1].[dbo].[MEMPLUS_DAILY_INFO_CANCEL]
		where convert(varchar(10),file_dt,112) = @e_dt

		END
END

GO
