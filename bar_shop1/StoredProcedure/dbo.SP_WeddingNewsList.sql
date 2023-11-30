IF OBJECT_ID (N'dbo.SP_WeddingNewsList', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_WeddingNewsList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		임승인
-- Create date: 2023-02-21
-- Description:	웨딩뉴스 리스트
-- =============================================

--[SP_WeddingNewsList] '2023-02-01','2023-03-06','','','','',1,0

CREATE PROCEDURE [dbo].[SP_WeddingNewsList]
	@StartDate varchar(10),
	@EndDate varchar(10),
	@TemplateIdx int,
	@Status varchar(1),
	@Sort varchar(10),
	@SearchText varchar(20),
	@Page int,
	@Type int
AS
SET NOCOUNT ON
BEGIN

	DECLARE @SQL NVARCHAR(3000)
	DECLARE @SEARCH_SQL NVARCHAR(3000)
	DECLARE @ORDERBY_SQL NVARCHAR(1000)

	IF @TYPE = 0 
	BEGIN
		SET @SQL = N'SELECT a.WeddingNewsIdx,a.TemplateIdx,a.OrderSeq,a.Status,a.UserId,a.UserName,a.Title,a.Mode,Convert(varchar(10),a.RegDate,120) RegDate,Convert(varchar(10),a.ModDate,120) ModDate, b.Url '		
	END
	ELSE
	BEGIN
		SET @SQL = N'SELECT COUNT(*) COUNT '
	END
		
	SET @SQL = @SQL + 'FROM WeddingNews a LEFT JOIN WeddingNewsResult b ON a.WeddingNewsIdx=b.WeddingNewsIdx '
	SET @SEARCH_SQL = 'WHERE 1=1 AND CONVERT(VARCHAR(10),RegDate,120) >= ''' + @StartDate + ''' AND CONVERT(VARCHAR(10),RegDate,120) <= ''' + @EndDate + ''' '

	IF @TemplateIdx > 0
	BEGIN
		SET @SEARCH_SQL = @SEARCH_SQL + ' AND TemplateIdx = ' + CONVERT(VARCHAR(2),@TemplateIdx)
	END
		
	IF @Status <> ''
	BEGIN
		SET @SEARCH_SQL = @SEARCH_SQL + ' AND Status = ''' + @Status + ''''
	END

	IF @SearchText <> ''
	BEGIN
		SET @SEARCH_SQL = @SEARCH_SQL + ' AND (UserId = ''' + @SearchText + ''' OR UserName = ''' + @SearchText + ''' OR CONVERT(VARCHAR(10),OrderSeq) = ''' + @SearchText + ''')'
	END

	IF @TYPE = 0 
	BEGIN
		IF @Sort <> ''
		BEGIN
			SET @ORDERBY_SQL = ' Order By WeddingNewsIdx ' + @Sort
		END
		ELSE
		BEGIN
			SET @ORDERBY_SQL = ' Order By WeddingNewsIdx Desc' 
		END
	END

	EXEC (@SQL+@SEARCH_SQL+@ORDERBY_SQL)
	--Print @SQL+@SEARCH_SQL+@ORDERBY_SQL

	SET NOCOUNT OFF
	
END



GO
