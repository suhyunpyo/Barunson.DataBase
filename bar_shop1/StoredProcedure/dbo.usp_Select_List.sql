IF OBJECT_ID (N'dbo.usp_Select_List', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_Select_List
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


--ㅁ usp_Select_List
--   Desc   : 기본 Select 프로시져
--   Last Updated : 2014.04.21  by 정주해

CREATE	PROCEDURE [dbo].[usp_Select_List]

	@TopField			Varchar(10) = '',
	@SelectField		Varchar(2000) = '',
	@FromField			Varchar(5000) = '',
	@WhereField			Varchar(5000) = '',
	@OrderByField		Varchar(5000) = ''

AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

	Declare @SQL  		Varchar(8000)

BEGIN

	Begin
		SET @SQL =  ' Select '
		SET @SQL = @SQL +  @TopField               
		SET @SQL = @SQL +  @SelectField               
		SET @SQL = @SQL + '  From '  + @FromField
		SET @SQL = @SQL + '  Where ' + @WhereField
		SET @SQL = @SQL + @OrderByField
		select @SQL
		--EXEC (@SQL)
	End

END
GO
