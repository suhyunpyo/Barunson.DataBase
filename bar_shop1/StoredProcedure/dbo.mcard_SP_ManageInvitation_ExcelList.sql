IF OBJECT_ID (N'dbo.mcard_SP_ManageInvitation_ExcelList', N'P') IS NOT NULL DROP PROCEDURE dbo.mcard_SP_ManageInvitation_ExcelList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 2016.12.12
-- Description:	모바일초대장 엑셀 다운로드(시즌2관리자)
-- =============================================
CREATE PROCEDURE [dbo].[mcard_SP_ManageInvitation_ExcelList]
	@searchType	VARCHAR(4) = ''
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


	SET @sql = 	N'
				SELECT INVITATIONCODE AS 주문번호
					,CASE WHEN SITECODE = ''SS'' THEN ''프리미어''
						  WHEN SITECODE = ''SB'' THEN ''바른손''
						  WHEN SITECODE = ''SA'' THEN ''비핸즈''
						  WHEN SITECODE = ''ST'' THEN ''더카드''
						  WHEN SITECODE = ''CE'' THEN ''셀레모''
						  WHEN (SELECT TOP 1 sales_Gubun FROM CUSTOM_ORDER WHERE ORDER_SEQ = M.ORDERSEQ) = ''H'' THEN ''바른손몰H''
						  WHEN SITECODE IN(''B'',''C'') THEN ''바른손몰B''
						  WHEN SITECODE = ''BE'' THEN ''비웨딩''
					END 주문사이트
					,REGISTERTIME 등록일자
					,COMPLETEDTIME 제작완료일
					,INVITATIONTYPE 유형
					,SKINCODE 스킨
					,ORDERERNAME 주문자명
					,ORDERERMOBILE 휴대전화
					,CONVERT(VARCHAR,DATEADD(M, 2,SUBSTRING(EVENTDATE , 1,10)),23) 만료일
				FROM MCARD_INVITATION M
				WHERE DELETEYN = ''N''
				AND COMPLETEDTIME IS NOT NULL
				'+ @optSql + '
				'+ @dateSql + '
				ORDER BY COMPLETEDTIME DESC
				';


	EXEC sp_executesql @sql;
	SET NOCOUNT OFF
	print @sql
GO
