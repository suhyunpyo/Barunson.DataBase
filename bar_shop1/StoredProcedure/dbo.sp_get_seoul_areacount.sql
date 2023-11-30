IF OBJECT_ID (N'dbo.sp_get_seoul_areacount', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_get_seoul_areacount
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*-------------------------------------

서울시 지역구별 카운트

[dbo].[sp_get_seoul_areacount] '2013-01-01','2013-02-01'



--------------------------------------*/

create PROC [dbo].[sp_get_seoul_areacount]
	@sdate as varchar(255),        
	@edate as varchar(255)

AS

select
(
	select COUNT(*) 
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강남구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강남구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강남구%'

	) a
) 강남구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강동구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강동구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강동구%'

	) b	
) 강동구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강북구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강북구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강북구%'

	) b	
) 강북구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강서구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강서구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%강서구%'

	) b	
) 강서구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%관악구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%관악구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%관악구%'

	) b	
) 관악구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%광진구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%광진구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%광진구%'

	) b	
) 광진구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%구로구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%구로구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%구로구%'

	) b	
) 구로구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%금천구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%금천구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%금천구%'

	) b	
) 금천구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%노원구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%노원구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%노원구%'

	) b	
) 노원구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%도봉구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%도봉구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%도봉구%'

	) b	
) 도봉구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%동대문구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%동대문구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%동대문구%'

	) b	
) 동대문구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%동작구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%동작구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%동작구%'

	) b	
) 동작구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%마포구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%마포구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%마포구%'

	) b	
) 마포구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%서대문구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%서대문구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%서대문구%'

	) b	
) 서대문구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%서초구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%서초구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%서초구%'

	) b	
) 서초구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%성동구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%성동구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%성동구%'

	) b	
) 성동구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%성북구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%성북구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%성북구%'

	) b	
) 성북구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%송파구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%송파구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%송파구%'

	) b	
) 송파구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%양천구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%양천구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%양천구%'

	) b	
) 양천구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%영등포구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%영등포구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%영등포구%'

	) b	
) 영등포구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%용산구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%용산구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%용산구%'

	) b	
) 용산구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%은평구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%은평구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%은평구%'

	) b	
) 은평구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%종로구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%종로구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%종로구%'

	) b	
) 종로구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%중구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%중구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%중구%'

	) b	
) 중구 ,

(
	select COUNT(*)  
	from 
	(
		select uid from S2_UserInfo_BHands with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%중랑구%'
		union 
		select uid from S2_UserInfo with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%중랑구%'
		union 
		select uid from S2_UserInfo_TheCard with(nolock) where reg_date >= @sdate and reg_date < @edate and address like '서울%' and address like '%중랑구%'

	) b	
) 중랑구 


GO
