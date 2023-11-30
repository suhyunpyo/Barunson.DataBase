IF OBJECT_ID (N'dbo.up_select_shinsegae', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_shinsegae
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		박동혁
-- Create date: 2016-01-12
-- Description:	시즌2 관리자, 샘플이용후기
-- EXEC up_select_shinsegae @Sales_Gubun='SA,B,C', @sdate='2015-12-15', @edate='2016-01-16',  @search_string='', @chk='0^1^2', @page=1, @pagesize=20, @ER_Type=0, @allchk_comp='1' 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_shinsegae]
	@Sales_Gubun		VARCHAR(100),
	@sdate				DATETIME,
	@edate				DATETIME,
	@search_string		NVARCHAR(50),
	@chk				NVARCHAR(50),
	@page				INT = 1,
	@pagesize			INT = 15,
	@allchk_comp		NVARCHAR(1),
	@ER_Type			INT,
	@searchType			NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE	@T_CNT	INT
	DECLARE	@SQL	NVARCHAR(1500)
	DECLARE	@SQL2	NVARCHAR(1500)
	DECLARE @member_table NVARCHAR(1000)
	
	IF @Sales_Gubun IS NULL or @Sales_Gubun = ''
	BEGIN
		SET @Sales_Gubun = 'SB'
	END

	DECLARE cur_Get_CompanySeq CURSOR FAST_FORWARD
	FOR
		SELECT DISTINCT Company_Seq FROM Company WHERE Sales_Gubun IN (SELECT value FROM dbo.[ufn_SplitTable](@Sales_Gubun, ','))
	OPEN cur_Get_CompanySeq

	DECLARE @CompanySeq VARCHAR(10)
	DECLARE @CompanySeqGroup VARCHAR(MAX) = '0'

	FETCH NEXT FROM cur_Get_CompanySeq INTO @CompanySeq

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @CompanySeqGroup = @CompanySeqGroup + ',' + @CompanySeq

		FETCH NEXT FROM cur_Get_CompanySeq INTO @CompanySeq
	END


	--SELECT @CompanySeqGroup

	CLOSE cur_Get_CompanySeq
	DEALLOCATE cur_Get_CompanySeq

	-- 전체 선택인 경우
	IF @allchk_comp = '0' 
	BEGIN
	
		SELECT COUNT(ER_Idx) 
		FROM S4_Event_Review A WITH(NOLOCK) 
		WHERE CONVERT(VARCHAR(10), ER_Regdate, 121) BETWEEN '' + CONVERT(NVARCHAR(10), @sdate, 121) + '' AND '' + CONVERT(NVARCHAR(10), @edate, 121) + '' 
			AND ER_Type = CONVERT(VARCHAR(5), @ER_Type)
			AND 1 = (SELECT 1 FROM S4_Event_Review_Status SER
			               WHERE A.ER_idx = SER.ERA_ER_idx
						   AND SER.ERA_Status IN (SELECT value FROM dbo.[ufn_SplitTable](@chk, ',')) 
				    )			
			AND CASE WHEN @search_String is null THEN ER_UserId 
			    ELSE 
					CASE WHEN @searchType = 'ER_UserId' THEN ER_UserId
					WHEN @searchType = 'ER_UserName' THEN ER_UserName 
					END
				END 
				LIKE '%'+@search_String+'%'					
		SELECT TOP (@pagesize)
			  ER_Idx
			, ER_Company_Seq
			, ER_Order_Seq
			, ER_Type
			, ER_Userid
			, ER_Regdate
			, ER_Recom_Cnt
			, ER_Review_Title
			, ER_Review_Url
			, ER_Review_Star
			, ER_Status
			, ER_View
			, ER_Review_Content
			, ER_UserName
			, (SELECT TOP 1 hphone FROM vw_user_info WHERE uid = ER_Userid ) AS hand_phone
			, ISNULL((SELECT ERA_Status FROM S4_Event_Review_Status WITH(NOLOCK) WHERE ERA_ER_idx = ER_idx), 0) AS ERA_Status
			, ISNULL(ER_Review_Url2, '') AS ER_Review_Url2
			, B.SALES_GUBUN
			, A.inflow_route
		FROM S4_Event_Review AS A WITH(NOLOCK)
			INNER JOIN Company AS B WITH(NOLOCK)
				ON A.ER_Company_Seq = B.COMPANY_SEQ
		WHERE ER_Idx NOT IN 
		(
			SELECT TOP (@pagesize * (@page - 1))
				ER_Idx 
			FROM S4_Event_Review WITH(NOLOCK)
			WHERE CONVERT(VARCHAR(10), ER_Regdate, 121) BETWEEN '' + CONVERT(NVARCHAR(10), @sdate, 121) + '' AND '' + CONVERT(NVARCHAR(10) , @edate , 121) + '' 
				AND ER_Type = CONVERT(VARCHAR(5), @ER_Type) 
			ORDER BY ER_Idx DESC  
		)
			AND CONVERT(VARCHAR(10), ER_Regdate, 121) BETWEEN '' + CONVERT(NVARCHAR(10), @sdate, 121) + '' AND '' + CONVERT(NVARCHAR(10) , @edate , 121) + '' 
			AND ER_Type = CONVERT(VARCHAR(5), @ER_Type)
			AND 1 = (SELECT 1 FROM S4_Event_Review_Status SER
			               WHERE A.ER_idx = SER.ERA_ER_idx
						   AND SER.ERA_Status IN (SELECT value FROM dbo.[ufn_SplitTable](@chk, ',')) 
				    )			
			AND CASE WHEN @search_String is null THEN A.ER_UserId 
			    ELSE 
					CASE WHEN @searchType = 'ER_UserId' THEN A.ER_UserId
					WHEN @searchType = 'ER_UserName' THEN A.ER_UserName 
					END
				END 
				LIKE '%'+@search_String+'%'					
		ORDER BY ER_Idx DESC
			
	END
	-- 개별 선택인 경우
	ELSE
	BEGIN

		SELECT COUNT(ER_Idx) 
		FROM S4_Event_Review A WITH(NOLOCK) 
		WHERE ER_Company_Seq IN (SELECT value FROM dbo.[ufn_SplitTable](@CompanySeqGroup, ',')) 
			AND CONVERT(VARCHAR(10), ER_Regdate, 121) BETWEEN CONVERT(NVARCHAR(10), @sdate, 121) AND CONVERT(NVARCHAR(10), @edate, 121) 
			AND ER_Type = CONVERT(VARCHAR(5), @ER_Type)
			AND 1 = (SELECT 1 FROM S4_Event_Review_Status SER
			               WHERE A.ER_idx = SER.ERA_ER_idx
						   AND SER.ERA_Status IN (SELECT value FROM dbo.[ufn_SplitTable](@chk, ',')) 
				    )			
			AND CASE WHEN @search_String is null THEN ER_UserId 
			   ELSE 
					CASE WHEN @searchType = 'ER_UserId' THEN ER_UserId
					WHEN @searchType = 'ER_UserName' THEN ER_UserName 
					END
				END 
				LIKE '%'+@search_String+'%'					
		SELECT TOP (@pagesize)
			  ER_Idx
			, ER_Company_Seq
			, ER_Order_Seq
			, ER_Type
			, ER_Userid
			, ER_Regdate
			, ER_Recom_Cnt
			, ER_Review_Title
			, ER_Review_Url
			, ER_Review_Star
			, ER_Status
			, ER_View
			, ER_Review_Content
			, ER_UserName
			, (SELECT TOP 1 hphone FROM vw_user_info WHERE uid = ER_Userid ) AS hand_phone
			, ISNULL((SELECT ERA_Status FROM S4_Event_Review_Status WITH(NOLOCK) WHERE ERA_ER_idx = ER_idx), 0) AS ERA_Status
			, ISNULL(ER_Review_Url2, '') AS ER_Review_Url2
			, B.SALES_GUBUN
			, A.inflow_route
		FROM S4_Event_Review AS A WITH(NOLOCK)
			INNER JOIN Company AS B WITH(NOLOCK)
				ON A.ER_Company_Seq = B.COMPANY_SEQ
		WHERE ER_Idx NOT IN 
		(
			SELECT TOP (@pagesize * (@page - 1)) 
				ER_Idx 
			FROM S4_Event_Review WITH(NOLOCK)
			WHERE ER_Company_Seq IN (SELECT value FROM dbo.[ufn_SplitTable](@CompanySeqGroup, ',')) 
				AND CONVERT(VARCHAR(10), ER_Regdate, 121) BETWEEN '' + CONVERT(NVARCHAR(10), @sdate, 121) + '' AND '' + CONVERT(NVARCHAR(10), @edate, 121) + '' 
				AND ER_Type = CONVERT(VARCHAR(5), @ER_Type)
			ORDER BY ER_Idx DESC  
		)
			AND ER_Company_Seq IN (SELECT value FROM dbo.[ufn_SplitTable](@CompanySeqGroup, ',')) 
			AND CONVERT(VARCHAR(10), ER_Regdate, 121) BETWEEN '' + CONVERT(NVARCHAR(10), @sdate, 121) + '' AND '' + CONVERT(NVARCHAR(10), @edate, 121) + '' 
			AND ER_Type = CONVERT(VARCHAR(5), @ER_Type)
			AND 1 = (SELECT 1 FROM S4_Event_Review_Status SER
			               WHERE A.ER_idx = SER.ERA_ER_idx
						   AND SER.ERA_Status IN (SELECT value FROM dbo.[ufn_SplitTable](@chk, ',')) 
				    )			
			AND CASE WHEN @search_String is null THEN A.ER_UserId 
			    ELSE 
					CASE WHEN @searchType = 'ER_UserId' THEN A.ER_UserId
					WHEN @searchType = 'ER_UserName' THEN A.ER_UserName 
					END
				END 
				LIKE '%'+@search_String+'%'					
		ORDER BY ER_Idx DESC

	END
END


/*

원래 소스 : 2016-01-12 박동혁 변경

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[up_select_shinsegae]
	-- Add the parameters for the stored procedure here
	@company_seq		nvarchar(50),
	@sdate				datetime,
	@edate				datetime,
	@search_string		nvarchar(50),
	@chk				nvarchar(50),
	@page				int=1,
	@pagesize			int=15,
	@allchk_comp		nvarchar(1),
	@ER_Type			int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE	@T_CNT	INT
	DECLARE	@SQL	nvarchar(1500)
	DECLARE	@SQL2	nvarchar(1500)
	DECLARE @member_table nvarchar(1000)
	
	
	IF @company_seq IS NULL or @company_seq=''
		begin
			set @company_seq='1'
		end
	
	
	

    -- Insert statements for procedure here
	/*
	SELECT @T_CNT = count(ER_Idx) from S4_Event_Review with(nolock) where ER_Company_Seq in (select convert(varchar(20),@company_seq))
	SET @result_cnt = @T_CNT
	*/
	
	if @allchk_comp = '0' 
	
		begin
			set @SQL2 = ' select count(ER_Idx) from S4_Event_Review with(nolock) where convert(varchar(10),ER_Regdate,121) between '''+convert(nvarchar(10),@sdate,121)+''' and '''+convert(nvarchar(10),@edate,121)+''' and ER_Type='+CONVERT(VARCHAR(5),@ER_Type)
			exec (@SQL2)
			
			
			set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, ER_Review_Title, ER_Review_Url, '
			set @SQL = @SQL + ' ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_UserName, '
			set @SQL = @SQL + ' (SELECT TOP 1 HPHONE FROM VW_USER_INFO WHERE UID = ER_Userid ) AS hand_phone, '
			set @SQL = @SQL + ' isnull((select ERA_Status from S4_Event_Review_Status with(nolock) where ERA_ER_idx=ER_idx),0) AS ERA_Status, ISNULL(ER_Review_Url2, '''') AS ER_Review_Url2 '
			set @SQL = @SQL + ' from S4_Event_Review AS A with(nolock) '
			set @SQL = @SQL + ' where ER_Idx not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' ER_Idx from S4_Event_Review with(nolock) '
			set @SQL = @SQL + ' where convert(varchar(10),ER_Regdate,121) between '''+convert(nvarchar(10),@sdate,121)+''' and '''+convert(nvarchar(10),@edate,121)+''' and ER_Type='+CONVERT(VARCHAR(5),@ER_Type)+' order by ER_idx desc  ) '
			set @SQL = @SQL + ' and  convert(varchar(10),ER_Regdate,121) between '''+convert(nvarchar(10),@sdate,121)+''' and '''+convert(nvarchar(10),@edate,121)+''' and ER_Type='+CONVERT(VARCHAR(5),@ER_Type)+' order by ER_idx desc'
			
			--select @SQL

			exec (@SQL)
		end
	else
		begin
			set @SQL2 = ' select count(ER_Idx) from S4_Event_Review with(nolock) where ER_Company_Seq in ('+@company_seq+') and convert(varchar(10),ER_Regdate,121) between '''+convert(nvarchar(10),@sdate,121)+''' and '''+convert(nvarchar(10),@edate,121)+''' and E
R
_Type='+CONVERT(VARCHAR(5),@ER_Type)
			exec (@SQL2)
			
			
			set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, ER_Review_Title, ER_Review_Url, '
			set @SQL = @SQL + ' ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_UserName, '
			set @SQL = @SQL + ' (SELECT TOP 1 HPHONE FROM VW_USER_INFO WHERE UID = ER_Userid ) AS hand_phone, '
			set @SQL = @SQL + ' isnull((select ERA_Status from S4_Event_Review_Status with(nolock) where ERA_ER_idx=ER_idx),0) AS ERA_Status, ISNULL(ER_Review_Url2, '''') AS ER_Review_Url2 '
			set @SQL = @SQL + ' from S4_Event_Review AS A with(nolock) '
			set @SQL = @SQL + ' where ER_Idx not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' ER_Idx from S4_Event_Review with(nolock) '
			set @SQL = @SQL + ' where ER_Company_Seq in ('+@company_seq+') and convert(varchar(10),ER_Regdate,121) between '''+convert(nvarchar(10),@sdate,121)+''' and '''+convert(nvarchar(10),@edate,121)+''' and ER_Type='+CONVERT(VARCHAR(5),@ER_Type)+' order by E

R_idx desc  ) '
			set @SQL = @SQL + ' and ER_Company_Seq in ('+@company_seq+') and convert(varchar(10),ER_Regdate,121) between '''+convert(nvarchar(10),@sdate,121)+''' and '''+convert(nvarchar(10),@edate,121)+''' and ER_Type='+CONVERT(VARCHAR(5),@ER_Type)+' order by ER_

idx desc'
			
			--select @SQL

			exec (@SQL)
		end
	
END



*/
GO
