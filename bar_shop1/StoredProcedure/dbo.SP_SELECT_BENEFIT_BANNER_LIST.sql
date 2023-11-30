IF OBJECT_ID (N'dbo.SP_SELECT_BENEFIT_BANNER_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_BENEFIT_BANNER_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_BENEFIT_BANNER_LIST 5006

*/

CREATE PROCEDURE [dbo].[SP_SELECT_BENEFIT_BANNER_LIST]
	@P_COMPANY_SEQ		AS INT

AS

BEGIN

	SELECT	BB.SEQ													AS Seq
		,	ISNULL(BB.COMPANY_SEQ, @P_COMPANY_SEQ)					AS CompanySeq
		,	ISNULL(BB.B_TYPE, MST.B_TYPE)							AS BannerType
		,	ISNULL(BB.B_TYPE_NO, MST.B_TYPE_NO)						AS BannerTypeNo
		,	ISNULL(BB.DISPLAY_YN, 'N')								AS DisplayYN
		,	BB.EVENT_S_DT											AS EventStartDate
		,	BB.EVENT_E_DT											AS EventEndDate
		,	BB.MAIN_TITLE											AS MainTitle
		,	BB.SUB_TITLE											AS SubTitle
		,	BB.PAGE_URL												AS PageUrl
		,	BB.B_IMG												AS BannerImage
		,	BB.B_BACK_COLOR											AS BannerBackColor
		,	BB.WING_IMG												AS WingImage
		,	BB.WING_YN												AS WingYorN
		,	BB.BAND_YN												AS BandYorN
		,	BB.NEW_BLANK_YN											AS NewBlankYorN
		,	BB.JEHU_YN												AS JehuYorN
		,	BB.DELETE_YN											AS DeleteYorN
		,	BB.END_YN												AS EndYorN
		,	BB.REPLACE_YN											AS ReplaceYorN
		,	BB.ALWAYS_YN											AS AlwaysYorN
		,	BB.CREATED_DATE											AS CreatedDate
		,	BB.CREATED_UID											AS CreatedUserId
		,	BB.UPDATED_DATE											AS UpdatedDate
		,	BB.UPDATED_UID											AS UpdatedUserId

	FROM	(
				SELECT	VALUE AS B_TYPE
					,	1 AS B_TYPE_NO	
				FROM	DBO.FN_SPLIT('L1|S2|M2|S4|S5|M6|M7|S8|M9|S10|L11', '|') MST
				UNION ALL
				SELECT	VALUE AS B_TYPE
					,	2 AS B_TYPE_NO	
				FROM	DBO.FN_SPLIT('L1|S2|M2|S4|S5|M6|M7|S8|M9|S10|L11', '|') MST
				UNION ALL
				SELECT	VALUE AS B_TYPE
					,	3 AS B_TYPE_NO	
				FROM	DBO.FN_SPLIT('L1|S2|M2|S4|S5|M6|M7|S8|M9|S10|L11', '|') MST
			) MST
	LEFT 
	JOIN	BENEFIT_BANNER BB
		ON	BB.B_TYPE = MST.B_TYPE 
		AND BB.B_TYPE_NO = MST.B_TYPE_NO 
		AND BB.SEQ IN ( SELECT MAX(SEQ) FROM BENEFIT_BANNER WHERE COMPANY_SEQ = @P_COMPANY_SEQ GROUP BY B_TYPE, B_TYPE_NO )

	ORDER BY	CASE 
					WHEN MST.B_TYPE = 'L1' THEN 1
					WHEN MST.B_TYPE = 'S2' THEN 2
					WHEN MST.B_TYPE = 'M2' THEN 3
					WHEN MST.B_TYPE = 'S4' THEN 4
					WHEN MST.B_TYPE = 'S5' THEN 5
					WHEN MST.B_TYPE = 'M6' THEN 6
					WHEN MST.B_TYPE = 'M7' THEN 7
					WHEN MST.B_TYPE = 'S8' THEN 8
					WHEN MST.B_TYPE = 'M9' THEN 9
					WHEN MST.B_TYPE = 'S10' THEN 10
					WHEN MST.B_TYPE = 'L11' THEN 11
					ELSE 12
				END ASC
			,	MST.B_TYPE_NO ASC

END
GO
