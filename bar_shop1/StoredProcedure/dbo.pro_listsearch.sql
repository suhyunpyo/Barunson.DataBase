IF OBJECT_ID (N'dbo.pro_listsearch', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_listsearch
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--  EXEC pro_listsearch 1,2,2,5,NAME,'a'
--select * from board
CREATE     PROC [dbo].[pro_listsearch] 
@page int,
@psize int,
@field varchar(10),
@str varchar(10)
AS
Begin
	Begin Tran
	SET NOCOUNT ON
	DECLARE @SQL VARCHAR(1000)
	Declare @strError int
	Set @strError = 0
	SET @SQL = 'SELECT TOP ' + CONVERT(VARCHAR(20), @psize)
	SET @SQL = @SQL +  ' * FROM dbo.board where '+ @field+ ' LIKE ''%'+@str+'%''  and sid not in(SELECT TOP '
	SET @SQL = @SQL + CONVERT(VARCHAR(20), ((@page - 1) * @psize)) 
	SET @SQL = @SQL + ' sid FROM dbo.board where '+@field+' LIKE ''%'+@str+'%'' order by grp DESC, seq) order by grp DESC, seq'
	EXEC (@SQL)
     
			
	Set @strError = @@Error
		
	If (@strError<> 0)
	Begin
		RollBack Tran
	End
	Else
	Begin
		Commit Tran
	End
	SET NOCOUNT OFF
End

GO
