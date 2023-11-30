IF OBJECT_ID (N'invtmng.USP_GN_SELECT', N'P') IS NOT NULL DROP PROCEDURE invtmng.USP_GN_SELECT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
====================================================
개체: 저장 프로시저 dbo.USP_GN_SELECT
=====================================================
*/

CREATE PROC [invtmng].[USP_GN_SELECT] (   
	@strFields varchar(1000),   
	@strTables varchar(2000),   
	@strFilter varchar(2000) = null,   
	@strSort varchar(1000) = null,   
	@strGroup varchar(1000) = null,   
	@intCount int = 0 output   
)   
as   
declare @strFilterCriteria varchar(2000)   
declare @strSortCriteria varchar(1000)   
declare @strGroupCriteria varchar(1000)   
declare @strQuery nvarchar(2000)         

--set nocount on   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @strFilter is not null and @strFilter != ''   
	set @strFilterCriteria = ' where ' + @strFilter + ' '   
else   
	set @strFilterCriteria = ''   

if @strSort is not null and @strSort != ''   
	set @strSortCriteria = ' order by ' + @strSort   
else   
	set @strSortCriteria = ''   

if @strGroup is not null and @strGroup != ''   
	set @strGroupCriteria = ' group by ' + @strGroup + ' '   
else   
	set @strGroupCriteria = ''   

set @strQuery = 'select ' + @strFields + ' from ' + @strTables + @strFilterCriteria + @strGroupCriteria + @strSortCriteria   
--print(@strQuery)
-- exec(@strQuery)
exec sp_executesql @strQuery

--return @@rowcount   
set @intCount = @@rowcount   
--print @intCount   

GO
