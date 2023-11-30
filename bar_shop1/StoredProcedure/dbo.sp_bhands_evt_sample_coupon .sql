IF OBJECT_ID (N'dbo.sp_bhands_evt_sample_coupon ', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_bhands_evt_sample_coupon 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------------------------------------------  
내용 : 전일 샘플발송한 고객에게 10% 할인 쿠폰 발급

 coupon_detail.coupon_detail_seq = 364269 (coupon_code : 6CAB-BBA0-45CA-BF41)
 coupon_mst.coupon_mst_seq = 174 (coupon_name : 비핸즈카드 10% 할인쿠폰)

 -- 2018.08.09 부터 쿠폰 번호 변경
  coupon_detail.coupon_detail_seq = 373093 (coupon_code : 6CAB-BBA0-45CA-BF41)
 coupon_mst.coupon_mst_seq = 189 (coupon_name : 비핸즈카드 10% 할인쿠폰)

 매일 오전 5:35 발송
작성일 : 2018.06.18   

 사용 방법 
exec [dbo].[sp_bhands_evt_sample_coupon] 

-----------------------------------------------------------------------------------------------*/  
CREATE Procedure [dbo].[sp_bhands_evt_sample_coupon ]  
  
as  
begin  
  
	insert into COUPON_ISSUE (coupon_detail_seq, uid, active_yn, company_seq, sales_gubun , end_date, REG_DATE) 
		select 
			373093
		,	member_id 
		,	'Y'
		,	company_Seq
		,	sales_gubun
		,	convert(varchar(10),GETDATE()+30,120)  + ' 23:59:59.997'
		,   getdate()
		from CUSTOM_SAMPLE_ORDER 
			where company_seq = 5006 and status_Seq = 12  
				and convert(varchar(10),delivery_date,120) >= convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120)  
				and convert(varchar(10),delivery_date,120) < convert(varchar(10),GETDATE(),120)
				and NOT EXISTS (SELECT 'Y' FROM COUPON_ISSUE WHERE UID= member_id and coupon_detail_seq = 373093 )


END  
  
GO
