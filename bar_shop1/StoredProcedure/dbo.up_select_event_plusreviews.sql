IF OBJECT_ID (N'dbo.up_select_event_plusreviews', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_plusreviews
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- =============================================
CREATE PROCEDURE [dbo].[up_select_event_plusreviews]
	-- Add the parameters for the stored procedure here
	@page				int=1,
	@pagesize			int=15,
	@uid				nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE	@T_CNT	INT
	DECLARE	@SQL	nvarchar(4000)
	DECLARE	@SQL2	nvarchar(4000)

	if @uid = '0'
		begin
			
		set @SQL2 = ' select count(c_idx) from s2_event_UserComment_url with(nolock) '
		exec (@SQL2)
					

		set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' c_idx, c_uid, c_uname, c_regDate, isnull(c_title, '''') AS c_Title, isnull(c_url, '''') AS c_url '
		set @SQL = @SQL + ' , c_score, c_status, isnull(c_cancle_reply,'''') AS c_cancle_reply '
		set @SQL = @SQL + ' from s2_event_UserComment_url AS A '
		set @SQL = @SQL + ' where c_idx not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' c_idx from s2_event_UserComment_url with(nolock) order by c_idx desc  ) '
		set @SQL = @SQL + ' order by c_idx desc'
					
		exec (@SQL)
		print(@SQL)
			
		end
	else
		begin
			
		set @SQL2 = ' select count(c_idx) from s2_event_UserComment_url with(nolock) '
		exec (@SQL2)
					

		set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' c_idx, c_uid, c_uname, c_regDate, isnull(c_title, '''') AS c_Title, isnull(c_url, '''') AS c_url '
		set @SQL = @SQL + ' , c_score, c_status, isnull(c_cancle_reply,'''') AS c_cancle_reply '
		set @SQL = @SQL + ' from s2_event_UserComment_url AS A '
		set @SQL = @SQL + ' where c_idx not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' c_idx from s2_event_UserComment_url with(nolock) order by c_idx desc  ) '
		set @SQL = @SQL + ' and c_uid = ''' + CONVERT(VARCHAR(50),@UID) + '''  order by c_idx desc'
					
		exec (@SQL)
		print(@SQL)
			
		end


END

GO
