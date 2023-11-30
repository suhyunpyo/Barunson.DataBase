IF OBJECT_ID (N'dbo.up_select_event_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-02
-- Description:	Event List
-- up_select_event_list 2, 1, 20

-- =============================================
CREATE PROCEDURE [dbo].[up_select_event_list]
	
	@kind			int,				-- 이벤트 목록 종류 (진행 중, 지난)		
	@page			int,				-- 페이지 번호
	@pagesize		int					-- 페이지 사이즈 (페이지당 노출 갯수)	
	
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	DECLARE @startDate DATETIME
	DECLARE @endDate DATETIME
	DECLARE @temp VARCHAR(10)
	
	
	IF @kind = 1	-- 진행 중 이벤트
		BEGIN
			SET @startDate = GETDATE()
			SET @temp = CONVERT(VARCHAR(10), @startDate, 126)	
			SET @startDate = CONVERT(DATETIME, @temp + ' 00:00:00.000')
	
			SET @endDate = DATEADD(year, 10, GETDATE()) 
		END
	ELSE			-- 지난 이벤트
		BEGIN
			SET @startDate = CONVERT(DATETIME, '2000-01-01 00:00:00.000')
			
			SET @endDate = DATEADD(day, -1, GETDATE())  
			SET @temp = CONVERT(VARCHAR(10), @endDate, 126)	
			SET @endDate = CONVERT(DATETIME, @temp + ' 23:59:59.000')
		END
	
	--SELECT @startDate
	--SELECT @endDate
	
	-- Count --
	--SELECT	COUNT(*) AS cnt
	--FROM tEvent
	--WHERE 1 = 1
	--  AND ViewYN = 'Y'
	--  AND (ToDt BETWEEN @startDate AND @endDate)
	SELECT COUNT(*) AS cnt
	FROM
	(
		SELECT
			ROW_NUMBER() OVER (ORDER BY A.InsertDT DESC) AS RowNum
			, A.*
		FROM (
				SELECT
					EventIdx
					, EventNM
					, FromDt
					, ToDt
					, Contents
					, Banner
					, MainImage
					, MainHtml
					, templateYN
					, templateUrl
					, InsertDT
				FROM tEvent
				WHERE 1 = 1
					AND ViewYN = 'Y'
					AND EventIdx <> 3
					AND (ToDt BETWEEN @startDate AND @endDate)
		  
				UNION ALL	

				SELECT
					A.EventIdx
					, A.EventNM
					, CASE WHEN A.EventIdx = 3 THEN B.hp_Sdate ELSE A.FromDt END AS FromDt
					, CASE WHEN A.EventIdx = 3 THEN B.hp_Edate ELSE A.ToDt END AS ToDt
					, A.Contents
					, A.Banner
					, A.MainImage
					, A.MainHtml
					, A.templateYN
					, A.templateUrl
					, A.InsertDT
				FROM tEvent AS A
					INNER JOIN S5_Happy_Price_Main AS B
						ON A.EventIdx = 3
						AND B.hp_idx = (SELECT MAX(hp_idx) FROM S5_Happy_Price_Main WHERE hp_Edate <= GETDATE())
				WHERE 1 = 1
					AND A.ViewYN = 'Y'
					AND (B.hp_Edate >= @startDate)
		) AS A	  
	) AS RESULT






	
	-- Paging List --	
	SELECT * 
	FROM
	(
		--SELECT   ROW_NUMBER() OVER (ORDER BY InsertDT DESC) AS RowNum
		--		,EventIdx
		--		,EventNM
		--		,FromDt
		--		,ToDt
		--		,Contents
		--		,Banner
		--		,MainImage
		--		,MainHtml
		--		,templateYN
		--		,templateUrl
		--FROM tEvent AS A
		--WHERE 1 = 1
		--  AND ViewYN = 'Y'
		--  AND (ToDt BETWEEN @startDate AND @endDate)
		  
		SELECT
			ROW_NUMBER() OVER (ORDER BY A.InsertDT DESC) AS RowNum
			, A.*
		FROM (
				SELECT
					EventIdx
					, EventNM
					, FromDt
					, ToDt
					, Contents
					, Banner
					, MainImage
					, MainHtml
					, templateYN
					, templateUrl
					, InsertDT
				FROM tEvent
				WHERE 1 = 1
				  AND ViewYN = 'Y'
				  AND EventIdx <> 3
				  AND (ToDt BETWEEN @startDate AND @endDate)
		  
				UNION ALL	

				SELECT
					A.EventIdx
					, A.EventNM
					, CASE WHEN A.EventIdx = 3 THEN B.hp_Sdate ELSE A.FromDt END AS FromDt
					, CASE WHEN A.EventIdx = 3 THEN B.hp_Edate ELSE A.ToDt END AS ToDt
					, A.Contents
					, A.Banner
					, A.MainImage
					, A.MainHtml
					, A.templateYN
					, A.templateUrl
					, A.InsertDT
				FROM tEvent AS A
					INNER JOIN S5_Happy_Price_Main AS B
						ON A.EventIdx = 3
						AND B.hp_idx = (SELECT MAX(hp_idx) FROM S5_Happy_Price_Main WHERE hp_Edate >= GETDATE() + ' 00:00:00.000')
				WHERE 1 = 1
				  AND A.ViewYN = 'Y'
				  AND (B.hp_Edate >= @startDate)
		) AS A	  
	) AS RESULT
	WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )
	order by EventIdx DESC
	
END
GO
