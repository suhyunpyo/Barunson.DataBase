IF OBJECT_ID (N'dbo.pro_list', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--pro_list 1,5,name,b,0,0
CREATE  PROC [dbo].[pro_list]
@page int,
@psize int,
@pagecount INT OUTPUT,
@recordcount INT OUTPUT
AS
DECLARE @SQL VARCHAR(1000)
              set nocount on
	SELECT @recordcount = COUNT(*) FROM dbo.board
	SET @pagecount = Ceiling((@recordcount-1)/@psize)+1
	SET @SQL = 'SELECT TOP ' + CONVERT(VARCHAR(20), @psize)
	SET @SQL = @SQL +  ' * FROM board where  sid not in(SELECT TOP '
	SET @SQL = @SQL + CONVERT(VARCHAR(20), ((@page - 1) * @psize)) 
	SET @SQL = @SQL + ' sid FROM board  order by grp DESC, seq) order by grp DESC, seq'
	EXEC (@SQL)
              set nocount off

GO
