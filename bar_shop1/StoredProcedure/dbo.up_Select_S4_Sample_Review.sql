IF OBJECT_ID (N'dbo.up_Select_S4_Sample_Review', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_S4_Sample_Review
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author :		시스템지원팀, 장형일 과장
-- Create date : 2015-08-24
-- Description :	샘플리뷰 이벤트 참여 리스트, S4_Sample_Review
--                 (프리미어페이퍼)
-- EXEC up_Select_S4_Sample_Review 5003, 1, 10
-- =============================================
CREATE proc [dbo].[up_Select_S4_Sample_Review]

	@COMPANY_SEQ  INT
	,	@PAGE  SMALLINT
	,	@PAGE_SIZE  SMALLINT
		
AS

	SET NOCOUNT ON;
	DECLARE @StartRowNum SMALLINT, @EndRowNum SMALLINT, @TotalCNT INT

	SET @StartRowNum = (@PAGE - 1) * @PAGE_SIZE + 1
	SET @EndRowNum = @PAGE * @PAGE_SIZE

	SELECT	@TotalCNT = COUNT(ER_Idx)
	FROM	S4_Event_Review AS R
		LEFT OUTER JOIN S4_Event_Review_Status AS S 
			ON R.ER_Idx = S.ERA_ER_idx
	WHERE	ER_Company_Seq = @COMPANY_SEQ 
		AND R.ER_View = 0

	SELECT @TotalCNT AS TotalCount
		, @TotalCNT - RowNum + 1 AS RowIndex
		, *
	FROM
	(
		SELECT ROW_NUMBER() OVER(ORDER BY A.Reg_Date DESC) AS RowNum
			, *
		FROM
		( 	 
			SELECT	--ROW_NUMBER() OVER(ORDER BY R.ER_RegDate DESC) AS RowNum
					R.ER_Review_Star
				,	R.ER_Review_Title
				,	R.ER_Review_Url
				,	R.ER_UserId
				,	CONVERT(VARCHAR(10), R.ER_RegDate, 102) AS Reg_Date
				,	(SELECT TOP 1 uname FROM vw_user_info WHERE uid = ER_Userid ) AS uname
				,	ERA_Status
				,	ERA_Comment
				,	ERA_Comment_Cancel
				,   case when CONVERT(VARCHAR, R.ER_RegDate  ,  23) >= '2016-06-29' then 'Y' else 'N' end  ER_RegDate
			FROM	S4_Event_Review AS R
				LEFT OUTER JOIN S4_Event_Review_Status AS S 
					ON R.ER_Idx = S.ERA_ER_idx
			WHERE	R.ER_Company_Seq = 5003 
				AND R.ER_View = 0

			UNION ALL	

			SELECT	--ROW_NUMBER() OVER(ORDER BY R.ER_RegDate DESC) AS RowNum
					R.ER_Review_Star
				,	R.ER_Review_Title
				,	R.ER_Review_Url
				,	R.ER_UserId
				,	CONVERT(VARCHAR(10), R.ER_RegDate, 102) AS Reg_Date
				,	(SELECT TOP 1 uname FROM vw_user_info WHERE uid = ER_Userid ) AS uname
				,	ERA_Status
				,	ERA_Comment
				,	ERA_Comment_Cancel
				,   case when CONVERT(VARCHAR, R.ER_RegDate  ,  23) >= '2016-06-29' then 'Y' else 'N' end  ER_RegDate
			FROM	S4_Event_Review AS R
				LEFT OUTER JOIN S4_Event_Review_Status AS S 
					ON R.ER_Idx = S.ERA_ER_idx
				LEFT OUTER JOIN COMPANY AS C 
					ON R.ER_Company_Seq = C.COMPANY_SEQ
			WHERE C.SALES_GUBUN = 'H'
				AND R.ER_View = 0
		) AS A
	) AS TABLE_REVIEW
	WHERE TABLE_REVIEW.RowNum BETWEEN @StartRowNum AND @EndRowNum
GO
