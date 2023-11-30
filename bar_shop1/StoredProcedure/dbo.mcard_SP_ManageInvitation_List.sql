IF OBJECT_ID (N'dbo.mcard_SP_ManageInvitation_List', N'P') IS NOT NULL DROP PROCEDURE dbo.mcard_SP_ManageInvitation_List
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[mcard_SP_ManageInvitation_List]
	@pageNo	INT
	, @pageSize	INT
	, @searchType	VARCHAR(4) = ''
	, @searchText	NVARCHAR(100) = ''
	, @s_date	NVARCHAR(20) = ''
	, @e_Date	NVARCHAR(20) = ''
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @sql NVARCHAR(3000)
	, @optSql NVARCHAR(500)
	, @siteSql NVARCHAR(500)
	, @dateSql NVARCHAR(500)

SET @optSql = N'';
SET @dateSql = N'';

IF @searchType = 'PBDT' AND ISDATE(@searchText) = 0
	SET @searchText = ''

if @s_date <> '' and @e_Date <> '' 
	BEGIN
		set @dateSql = @dateSql + ' AND RegisterTime >='''+ @s_date +''' 
		                            AND RegisterTime < dateadd(d , 1 , CAST('''+ @e_Date +''' AS DATETIME))
		                          '
		             
					 
	END

IF @searchText <> '' AND @searchType <> ''
BEGIN

	IF @searchType = 'SITE' AND @searchText = 'B'
		BEGIN
			SET @siteSql = 'AND SiteCode in (''B'' , ''C'' , ''H'')'
		END
	ELSE
		BEGIN
			SET @siteSql = 'AND SiteCode = '''+@searchText+''' '
		END

	SET @optSql = @optSql + CASE @searchType 
			WHEN 'ORNO' THEN ' AND (InvitationCode LIKE ''%'+@searchText+''' OR OrderSeq = '''+@searchText+''') '
			WHEN 'PBDT' THEN ' AND CompletedTime BETWEEN '''+@searchText+' 00:00:00'' AND '''+@searchText+' 23:59:59'' '
			WHEN 'SITE' THEN   @siteSql
			WHEN 'MBID' THEN ' AND AuthCode LIKE ''%'+@searchText+'%'' '
			WHEN 'MBNM' THEN ' AND OrdererName LIKE ''%'+@searchText+'%'' '
			WHEN 'MOBL' THEN ' AND OrdererMobile LIKE ''%'+@searchText+'%'' '
			WHEN 'IVTP' THEN ' AND InvitationType = '''+@searchText+''' '
			WHEN 'SKCD' THEN ' AND SkinCode = '''+@searchText+''' '
			ELSE ''
		END;
END

SET @sql = 
N'
SELECT
	RowNo
	, InvitationID
	, InvitationCode
	, CASE WHEN (SELECT TOP 1 sales_Gubun FROM CUSTOM_ORDER WHERE ORDER_SEQ = A.ORDERSEQ) = ''H''THEN ''H'' ELSE SiteCode END SiteCode
	, OrderSeq
	, CompletedTime
	, InvitationType
	, SkinCode
	, AuthCode
	, OrdererName
	, OrdererEmail
	, OrdererMobile
	, ExpiredTime
	, OnlineYN
	, TotalCount
	, (TotalCount - RowNo + 1) AS CurrentRowNo
FROM
(
	SELECT 
		CAST(RowNo AS INT) AS RowNo
		, InvitationID
		, InvitationCode
		, SiteCode
		, OrderSeq
		--, CONVERT(VARCHAR(10), CompletedTime, 121) AS CompletedTime
		, CompletedTime
		, InvitationType
		, SkinCode
		, AuthCode
		, OrdererName
		, OrdererEmail
		, OrdererMobile
		--, CONVERT(VARCHAR(10), ExpiredTime, 121) AS ExpiredTime
		, ExpiredTime
		, OnlineYN
		--, (SELECT COUNT(*) FROM mcard_Invitation WHERE 1 = 1 AND PublishYN = ''Y'' AND DeleteYN = ''N''' + @optSql + ') AS TotalCount
		, TotalCount
	FROM (
			SELECT 
				  ROW_NUMBER() OVER (ORDER BY InvitationID DESC) AS RowNo
				, COUNT(*)OVER() TotalCount
				, InvitationID
				, InvitationCode
				, SiteCode
				, OrderSeq
				, CompletedTime
				, InvitationType
				, SkinCode
				, AuthCode
				, OrdererName
				, OrdererEmail
				, OrdererMobile
				--, DATEADD(m, 2, CompletedTime) AS ExpiredTime
				, CONVERT(VARCHAR,DATEADD(m, 2,substring(EventDate , 1,10)),23) ExpiredTime
				, OnlineYN
			FROM mcard_Invitation 
			WHERE 1 = 1
				AND PublishYN = ''Y''
				AND DeleteYN = ''N''
				'+ @optSql + '
				'+ @dateSql + '
		) AS MI
	WHERE 
		RowNo >= ((@pageNo - 1) * @pageSize + 1) AND RowNo <= (@pageNo * @pageSize)
) AS A order by RowNo
';

EXEC sp_executesql @sql, N'@pageNo INT, @pageSize INT', @pageNo = @pageNo, @pageSize = @pageSize;
SET NOCOUNT OFF
print @sql
GO
