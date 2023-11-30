IF OBJECT_ID (N'dbo.sp_sns_daily_sum', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_sns_daily_sum
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[sp_sns_daily_sum]
    @term_gubun     varchar(1)      -- D/M (일자별/월별)
    , @s_start_date varchar(10)
    , @s_end_date   varchar(10)
AS
    BEGIN

        IF @term_gubun = 'M'  -- 월별 조회

            SELECT
                isnull(B.visit_yyyymm, 'total') CountDate, sum(cnt_1) ClickOvrYCount, sum(cnt_2) ClickOvrNCount
            FROM (
                SELECT
                    convert(nvarchar(7), visit_yyyymmdd, 23) visit_yyyymm, count(*) cnt_1, count(DISTINCT user_ip) cnt_2
                FROM (
                    select 
                        user_ip
                        , convert(nvarchar, visit_date, 23) AS visit_yyyymmdd
                    FROM 
                        SNS_CLICK A
                    WHERE
                        visit_date >= @s_start_date
                        AND visit_date < @s_end_date
                ) AA
                GROUP BY (AA.visit_yyyymmdd)
            ) B
            Group BY rollup (B.visit_yyyymm)


        ELSE    -- 일자별 조회

            SELECT
                isnull(B.visit_yyyymmdd, 'total') CountDate, sum(cnt_1) ClickOvrYCount, sum(cnt_2) ClickOvrNCount
            FROM (
                SELECT
                    visit_yyyymmdd, count(*) cnt_1 , count(DISTINCT user_ip) cnt_2
                FROM (
                    select 
                        user_ip
                        , convert(nvarchar, visit_date, 23) AS visit_yyyymmdd
                    FROM 
                        SNS_CLICK A
                    WHERE
                        visit_date >= @s_start_date
                        AND visit_date < @s_end_date
                ) AA
                GROUP BY AA.visit_yyyymmdd
            ) B
            Group BY rollup (B.visit_yyyymmdd)


        

    END
GO
