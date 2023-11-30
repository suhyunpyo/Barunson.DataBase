IF OBJECT_ID (N'dbo.spB', N'P') IS NOT NULL DROP PROCEDURE dbo.spB
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  procedure [dbo].[spB]
 @TABLE_NAME as varchar(40),
 @WhereClause as varchar(8000) = NULL ,
 @NullCheck as varchar(1) = NULL
as

set nocount on

	declare @COLUMNS varchar(8000), @CNT int, @MAX_CNT int, @TABLE_ID int
	declare @Values varchar(8000)
	declare @DataType varchar(1), @TempColumn varchar(8000)

-- get the Column List
	select @TABLE_ID = (select ID from sysobjects where NAME = @TABLE_NAME )
	select @CNT = 1, @MAX_CNT = (select max(COLID) from syscolumns where ID = @TABLE_ID)
	select @COLUMNS  = '', @Values = ''
	while @CNT <= @MAX_CNT
	begin
		IF ( ISNULL(@NullCheck, '' ) <> 'Y' )	--NOT NULL 컬럼만 가져오기
		BEGIN 
		
			if ( 0 = ( select iscomputed from syscolumns where ID = @TABLE_ID and COLID = @CNT ) )
			begin
				select	@TempColumn =  name   from syscolumns where ID = @TABLE_ID and COLID = @CNT
				set	@COLUMNS = @COLUMNS + case when @CNT = 1 then '' else ', ' end + @TempColumn
				-- 숫자인지 문자인지 식별해서 Values Clause에 들어갈 구문을 조합
				select @DataType = case when A.name in ( 'char', 'varchar', 'nchar', 'nvarchar', 'text', 'ntext' )  then 'S' else 'N' end
				from systypes A, syscolumns B 
				where A.xusertype = B.xusertype and B.ID = @TABLE_ID and B.COLID = @CNT
				
				set @Values = @Values + case when @CNT = 1 then '' else '+' + char(39) + ', ' + char(39) + '+' end
						+ case when @DataType = 'S' then ' case when ' + @TempColumn + ' is null then ' + char(39) + 'NULL' + char(39)
							+ ' else '  + char(39) + 'N' + char(39) + ' + char(39)+rtrim (' + @TempColumn + ')+char(39) end'
						else ' case when ' + ' cast(' + @TempColumn + ' as varchar(100)) is null then ' + char(39) + 'NULL' + char(39)
							+ ' else rtrim(cast(' + @TempColumn + ' as varchar(100))) end'
						end
			end
		END 
		ELSE
		BEGIN 
			if ( 0 = ( select iscomputed from syscolumns where ID = @TABLE_ID and COLID = @CNT AND isnullable = 0) )
			begin
				select	@TempColumn =  name   from syscolumns where ID = @TABLE_ID and COLID = @CNT
				set	@COLUMNS = @COLUMNS + case when @CNT = 1 then '' else ', ' end + @TempColumn
				-- 숫자인지 문자인지 식별해서 Values Clause에 들어갈 구문을 조합
				select @DataType = case when A.name in ( 'char', 'varchar', 'nchar', 'nvarchar', 'text', 'ntext' )  then 'S' else 'N' end
				from systypes A, syscolumns B 
				where A.xusertype = B.xusertype and B.ID = @TABLE_ID and B.COLID = @CNT
				
				set @Values = @Values + case when @CNT = 1 then '' else '+' + char(39) + ', ' + char(39) + '+' end
						+ case when @DataType = 'S' then ' case when ' + @TempColumn + ' is null then ' + char(39) + 'NULL' + char(39)
							+ ' else '  + char(39) + 'N' + char(39) + ' + char(39)+rtrim (' + @TempColumn + ')+char(39) end'
						else ' case when ' + ' cast(' + @TempColumn + ' as varchar(100)) is null then ' + char(39) + 'NULL' + char(39)
							+ ' else rtrim(cast(' + @TempColumn + ' as varchar(100))) end'
						end
			end	
		
		END

		set @CNT= @CNT + 1
	end
		--select @COLUMNS
		--select @DataType
		--select @Values

	declare @ResultString varchar(8000)
	set @ResultString = 'select ' + char(13) + char(39) + 'insert into ' + @TABLE_NAME + ' ( ' + @COLUMNS + ' ) ' + char(13) 
		+ 'values ( ' + char(39) + ' + ' + @Values + '  + ' + char(39) + ' )' + char(39) + ' as DataScriptingQuery'
		+ char(13) + 'from ' + @TABLE_NAME + ' ' + IsNull ( @WhereClause, '' )
	--select @ResultString
	
	select '-- delete from ' + @TABLE_NAME + ' ' + IsNUll ( @WhereClause, '' ) as DeleteQuery
	exec ( @ResultString )


set nocount off


--sp_helptext spb

--spb poOrderHeader
--spb SiteMaster



GO
