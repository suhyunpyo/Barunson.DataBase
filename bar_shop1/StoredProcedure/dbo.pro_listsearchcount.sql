IF OBJECT_ID (N'dbo.pro_listsearchcount', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_listsearchcount
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    PROC [dbo].[pro_listsearchcount] 
@field varchar(10),
@str varchar(10)
AS
Begin
	Begin Tran
	SET NOCOUNT ON
	DECLARE @REC VARCHAR(1000)
                            
	Declare @strError int
	Set @strError = 0
	SET @REC = 'SELECT  COUNT(*) as total_row  FROM dbo.board where '+@field+' LIKE ''%'+@str+'%'''
              EXEC (@REC)
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
