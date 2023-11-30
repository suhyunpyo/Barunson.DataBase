IF OBJECT_ID (N'dbo.SP_S_ADMIN_STATISTICS_ORDER_PATTERN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_STATISTICS_ORDER_PATTERN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_S_ADMIN_STATISTICS_ORDER_PATTERN]
	@START_DT VARCHAR(10) = '2021-01-01',
	@END_DT VARCHAR(10) = '2050-12-31'

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
select 
	mcard_order_1_count,
	mcard_order_2_count,
	multi_order_1_count,
	multi_order_2_count,
	UC.join_count,
	order_user_count
from (
		select 
			isnull(sum(case when (U.WEDDINGCARD_ORDER_YN is null or U.WEDDINGCARD_ORDER_YN = 'N') and OC.order_count = 1 then 1 else 0 end), 0) mcard_order_1_count,
			isnull(sum(case when (U.WEDDINGCARD_ORDER_YN is null or U.WEDDINGCARD_ORDER_YN = 'N') and OC.order_count > 1 then 1 else 0 end), 0) mcard_order_2_count,
			isnull(sum(case when (U.WEDDINGCARD_ORDER_YN = 'Y') and OC.order_count = 1 then 1 else 0 end), 0) multi_order_1_count,
			isnull(sum(case when (U.WEDDINGCARD_ORDER_YN = 'Y') and OC.order_count > 1 then 1 else 0 end), 0) multi_order_2_count
		from (
				select
				user_id,
				count(1) order_count
				from tb_order AS O
				where Order_DateTime is not null
					 and Order_DateTime >=@START_DT + ' 00:00:00'
					 and Order_DateTime <=@END_DT + ' 23:59:59'
				group by O.User_ID
			) AS OC
			left join VW_User AS U
				on OC.User_ID = U.USER_ID
		) AS A
		, (
			select
				count(1) order_user_count
			from (
					select 
						member_id
					from [bar_shop1].[dbo].[custom_order]
					where status_seq = 15
						 and src_packing_date >= @START_DT + ' 00:00:00'
						 and src_packing_date <= @END_DT + ' 23:59:59'
					group by member_id
				) as U
		) AS B
		,
		(
			select
				count(1) join_count
			from (
					select 
						uid, 
						convert(varchar, max(reg_date), 112) reg_date
					from [bar_shop1].[dbo].[S2_UserInfo_thecard]
					where reg_date >=@START_DT + ' 00:00:00'
							and reg_date <=@END_DT + ' 23:59:59'
					group by uid
				) as U
		) UC
END
GO
