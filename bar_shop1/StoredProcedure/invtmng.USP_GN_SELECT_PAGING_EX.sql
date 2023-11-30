IF OBJECT_ID (N'invtmng.USP_GN_SELECT_PAGING_EX', N'P') IS NOT NULL DROP PROCEDURE invtmng.USP_GN_SELECT_PAGING_EX
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 현재의 10페이지 범위내에서 전체카운트를 계산(그이상의 카운트는 페이지 계산에 필요없으므로)

CREATE  PROC [invtmng].[USP_GN_SELECT_PAGING_EX] (
@strFields 		varchar(1000), 
@strTables 		varchar(1000), 
@strFilter 		varchar(1000) = null, 
@strSort 		varchar(1000) = null, 
@strGroup 		varchar(1000) = null,
@intPageNo 		int = 1, 
@intPageSize 	int = 10,
@intRecordCount int = 0 output,
@intPageCount	int = 0 output
) 
as

set nocount on
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

declare @bitBringAllRecords	bit 
declare @strPageNo 			varchar(50) 
declare @strPageSize 		varchar(50) 
declare @strSkippedRows 	varchar(50) 
declare @strFilterCriteria 		varchar(4000) 
declare @strSimpleFilter 		varchar(4000) 
declare @strSortCriteria1 	varchar(4000) 
declare @strSortCriteria2 	varchar(4000) 
declare @strSortCriteria3 	varchar(4000) 
declare @strGroupCriteria 	varchar(4000) 

declare @intCommaIdx		int
declare @intDotIdx		int
declare @intLastPage		int
declare @strQuery 		nvarchar(4000)

if @intPageNo < 1
	set @intPageNo = 1
set @strPageNo = convert(varchar(50), @intPageNo)

if @intPageSize is null or @intPageSize < 1
	set @bitBringAllRecords = 1
else
begin
	set @bitBringAllRecords = 0
	set @strPageNo = convert(varchar(50), @intPageNo)
	set @strPageSize = convert(varchar(50), @intPageSize)
	set @strSkippedRows = convert(varchar(50), @intPageSize * @intPageNo)
end

if @strFilter is not null and @strFilter != '' 
begin 
	set @strFilterCriteria = ' where ' + @strFilter + ' ' 
	set @strSimpleFilter = ' and ' + @strFilter + ' ' 
end 
else 
begin 
	set @strSimpleFilter = '' 
	set @strFilterCriteria = '' 
end 

if @strSort is not null and @strSort != '' 
	set @strSortCriteria1 = ' order by ' + @strSort
else 
	set @strSortCriteria1 = ''

if @strGroup is not null and @strGroup != '' 
	set @strGroupCriteria = ' group by ' + @strGroup + ' ' 
else 
	set @strGroupCriteria = '' 

set @intCommaIdx	= charindex(',', @strSort)
set @intDotIdx 		= charindex('.', @strSort)

if @intDotIdx > 0
begin
	set @strSortCriteria2 = ''
	set @strSortCriteria3 = ' order by '
end
else
begin 
	set @strSortCriteria2 = @strSortCriteria1
	set @strSortCriteria3 = @strSortCriteria1
end

while @intDotIdx > 0
begin
	if @intCommaIdx is null or @intCommaIdx <= 0
		set @intCommaIdx = len(@strSort)

	set @strSortCriteria3 = @strSortCriteria3 + substring(@strSort, @intDotIdx + 1, @intCommaIdx - @intDotIdx)
	set @intDotIdx 		= charindex('.', @strSort, @intDotIdx + 1)
	set @intCommaIdx 	= charindex(',', @strSort, @intCommaIdx + 1)
end

set @strSortCriteria2 = replace(lower(@strSortCriteria3), 'asc', 'temp_asc')  
set @strSortCriteria2 = replace(lower(@strSortCriteria2), 'desc', 'asc')      
set @strSortCriteria2 = replace(lower(@strSortCriteria2), 'temp_asc', 'desc') 

-- 현재의 10페이지 범위내에서 전체카운트를 계산(그이상의 카운트는 페이지 계산에 필요없으므로)
set @strQuery = 'select @inCnt = count(*) from (select top ' + convert(varchar(20), @intPageSize*(@intPageNo+11)) + ' ''1'' as zz  from ' + @strTables + @strFilterCriteria + ') ZZ_PAGE'
exec sp_executesql @strQuery, N'@inCnt int output', @inCnt = @intRecordCount output
select @intPageCount = ceiling(cast(@intRecordCount as float) / @intPageSize)

--print (@strQuery)
set @intLastPage = @intRecordCount % @intPageSize

if @intPageNo = @intPageCount and @intLastPage > 0
	set @strPageSize = convert(varchar(50), @intLastPage)

if @bitBringAllRecords = 1
	exec('select ' + @strFields + ' from ' + @strTables + @strFilterCriteria + @strGroupCriteria + @strSortCriteria1) 
else
begin
	if @intPageNo = 1
	begin
		set @strQuery = 'select top ' + @strPageSize + ' ' + @strFields + ' from ' + @strTables + @strFilterCriteria + @strGroupCriteria + @strSortCriteria1
		print @strQuery
		exec(@strQuery)
	end
	else
	begin
		set @strQuery = 'select * from (' +
			'select top ' + @strPageSize + ' * from (' +
				'select top ' + @strSkippedRows + ' ' + @strFields + ' from ' + @strTables + 
				@strFilterCriteria + @strGroupCriteria + @strSortCriteria1 + ') p_ex_a ' +
				@strGroupCriteria + @strSortCriteria2 + ') p_ex_b ' +
				@strGroupCriteria + @strSortCriteria3
		print (@strQuery)
		exec (@strQuery)
	end
end

GO
