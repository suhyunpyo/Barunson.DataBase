IF OBJECT_ID (N'dbo.proc_select_event_view_log', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_select_event_view_log
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jaewon.Cha
-- Create date: 2022-09-05
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[proc_select_event_view_log]
	@P_Event_Type varchar(10),
	@P_Start_date varchar(10) = '2022-01-01',
	@P_End_date varchar(10) = '2099-12-31',
	@P_Page_Scale int = 30, 
	@P_Page int = 1,
	@P_Type varchar(1) = 'L'
AS

BEGIN

declare @T_TOTAL int = 0

SELECT 
	*
	INTO #TEMP
FROM (
		select
			date_str REG_DATE_STR,
			case when day_str IS NULL THEN LEFT(DATENAME(WEEKDAY,CONVERT(DATE, date_str)),1) ELSE day_str END DAY_STR,
			ISNULL(CLICK_PC_CNT, 0) CLICK_PC_CNT,
			ISNULL(CLICK_MO_CNT, 0) CLICK_MO_CNT,
			ISNULL(LINK_PC_CNT, 0) LINK_PC_CNT,
			ISNULL(LINK_MO_CNT, 0) LINK_MO_CNT
		from (
				SELECT CONVERT(VARCHAR, DATEADD(D, NUMBER, @P_Start_date), 23) date_str
				FROM MASTER..SPT_VALUES
				WHERE TYPE = 'P'
					AND NUMBER <= DATEDIFF(D, @P_Start_date+' 00:00:00', @P_End_date+' 23:59:59')
			) A
			left join (
				select 
					REG_DATE_STR,
					LEFT(DATENAME(WEEKDAY,CONVERT(DATE, REG_DATE_STR)),1) AS DAY_STR,
					sum(CLICK_PC_CNT) CLICK_PC_CNT,
					sum(CLICK_MO_CNT) CLICK_MO_CNT,
					sum(LINK_PC_CNT) LINK_PC_CNT,
					sum(LINK_MO_CNT) LINK_MO_CNT
				from (
						select reg_date_str,
							[day] as d,
							case when device = 'PC' and point='click' then 1 else 0 end CLICK_PC_CNT,
							case when device = 'MO' and point='click' then 1 else 0 end CLICK_MO_CNT,
							case when device = 'PC' and (point='link' OR point is null) then 1 else 0 end LINK_PC_CNT,
							case when device = 'MO' and (point='link' OR point is null) then 1 else 0 end LINK_MO_CNT
						from Event_View_Log
						where event_type = @P_Event_Type
							and reg_date_str >= case when @P_Start_date is null or @P_Start_date = '' then '2022-01-01' else @P_Start_date end
							and reg_date_str <= case when @P_End_date is null or @P_End_date = '' then '2099-12-31' else @P_End_date end
					) A
				group by reg_date_str, d
			) B
				on A.date_str = B.reg_date_str
	) A
ORDER BY REG_DATE_STR DESC

SELECT @T_TOTAL = count(1) FROM #TEMP 

if @P_TYPE = 'E'
begin

	select 
		REG_DATE_STR,
		DAY_STR,
		CLICK_PC_CNT,
		CLICK_MO_CNT,
		LINK_PC_CNT,
		LINK_MO_CNT
	from #TEMP

end

else if @P_TYPE = 'L'
begin
	
	select
		REG_DATE_STR,
		DAY_STR,
		CLICK_PC_CNT,
		CLICK_MO_CNT,
		LINK_PC_CNT,
		LINK_MO_CNT
	from (
			select 
				CONVERT(INT, ROW_NUMBER() OVER(ORDER BY REG_DATE_STR desc)) AS ROW_NUM,
				*
			from #TEMP
		) A
	WHERE ROW_NUM > ((@P_Page - 1) * @P_Page_Scale)
		AND		ROW_NUM <= (@P_Page * @P_Page_Scale)
	order by REG_DATE_STR desc

end

else if @P_TYPE = 'C'
begin
	
	select convert(int, @T_TOTAL) AS TOTAL_COUNT
end



END
GO
