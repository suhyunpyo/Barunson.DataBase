IF OBJECT_ID (N'dbo.SP_REPORT_MARKETING_AGREEMENT_DELETE_MONTHLY_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_MARKETING_AGREEMENT_DELETE_MONTHLY_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_REPORT_MARKETING_AGREEMENT_DELETE_MONTHLY_LIST '2020-08-01', '2020-08-31', 'SD'
EXEC SP_REPORT_MARKETING_AGREEMENT_DELETE_MONTHLY_LIST '2020-08-01', '2020-08-31', 'SB'

*/

CREATE PROCEDURE [dbo].[SP_REPORT_MARKETING_AGREEMENT_DELETE_MONTHLY_LIST]
		@P_START_DATE		AS VARCHAR(10)
	,	@P_END_DATE			AS VARCHAR(10)
    ,	@P_SITE_DIV			AS VARCHAR(2)

AS
BEGIN
	SET NOCOUNT ON

	DECLARE @V_SRC_SDATE VARCHAR(10) = @P_START_DATE
	DECLARE @V_SRC_EDATE VARCHAR(10) = @P_END_DATE



        BEGIN
            	SELECT
					*
				FROM (
					SELECT 
						'바른디자인' as SiteName
						,'SD' as SiteDiv
						,uid 
						,(SELECT uname FROM S2_UserInfo_Deardeer WHERE uid = A.uid) uname
						,MAX(CASE WHEN agreement_type = 'SAMSUNG' and chk_agreement = 'N' THEN 'Y' WHEN agreement_type = 'SAMSUNG' and chk_agreement = 'Y' THEN 'N' ELSE chk_agreement END)  as DeleteSamsung
						,MAX(CASE WHEN agreement_type = 'LG' and chk_agreement = 'N' THEN 'Y' WHEN agreement_type = 'LG' and chk_agreement = 'Y' THEN 'N'  ELSE chk_agreement END) as DeleteLg
						,MAX(CASE WHEN agreement_type = 'MEMPLUS' and chk_agreement = 'N' THEN 'Y' WHEN agreement_type = 'MEMPLUS' and chk_agreement = 'Y' THEN 'N' ELSE chk_agreement END) as DeleteMemplus
						,null DeleteCasamia
						,null DeleteKt
						,MAX(cancel_uid) as DeleteId
						,MAX(convert(varchar(16), cancel_date, 120)) as DeleteDate
						/* 추가 */
						,DELETE_HYUNDAI = 'N'
					FROM 
						S2_UserInfo_Deardeer_Marketing A
					WHERE
						cancel_date >= CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
						and cancel_date < DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
					GROUP by uid
					UNION ALL
					SELECT
						'바른컴퍼니' as SiteName
						,'SB' as SiteDiv
						,uid
						,uname
						,delete_samsung as DeleteSamsung
						,delete_lg as DeleteLg
						,delete_marketing as DeleteMemplus
						,delete_casamia as DeleteCasamia
						,delete_kt as DeleteKt
						,delete_uid	as DeleteId
						,convert(varchar(16), delete_date, 120) as DeleteDate
						,DELETE_HYUNDAI = isnull(DELETE_HYUNDAI, 'N')--추가
					FROM
						SAMSUNG_DELETE_MEMBER
					WHERE
						delete_date >= CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
						and delete_date < DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
				) AA
				WHERE 
					(
						(@P_SITE_DIV = 'SD') AND (ISNULL(AA.SiteDiv, 'AA') = 'SD')
						OR (@P_SITE_DIV = 'SB') AND (ISNULL(AA.SiteDiv, 'AA') = 'SB')
						OR (@P_SITE_DIV = 'AA') AND (ISNULL(AA.SiteDiv, 'AA') <> '')
					)
				order by DeleteDate desc
        END


END

GO
