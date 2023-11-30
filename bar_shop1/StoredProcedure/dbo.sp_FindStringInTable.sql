IF OBJECT_ID (N'dbo.sp_FindStringInTable', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_FindStringInTable
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_FindStringInTable] @stringToFind VARCHAR(100), @schema sysname, @table sysname
AS
 
DECLARE @sqlCommand VARCHAR(8000)
DECLARE @where VARCHAR(8000)
DECLARE @columnName sysname
DECLARE @cursor VARCHAR(8000)
 
BEGIN TRY
   SET @sqlCommand = 'SELECT * FROM [' + @schema + '].[' + @table + '] WHERE'
   SET @where = ''
 
   SET @cursor = 'DECLARE col_cursor CURSOR FOR SELECT COLUMN_NAME
   FROM ' + DB_NAME() + '.INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = ''' + @schema + '''
   AND TABLE_NAME = ''' + @table + '''
   AND DATA_TYPE IN (''char'',''nchar'',''ntext'',''nvarchar'',''text'',''varchar'')'
 
   EXEC (@cursor)
 
   OPEN col_cursor   
   FETCH NEXT FROM col_cursor INTO @columnName   
 
   WHILE @@FETCH_STATUS = 0   
   BEGIN   
       IF @where <> ''
           SET @where = @where + ' OR'
 
       SET @where = @where + ' [' + @columnName + '] LIKE ''' + @stringToFind + ''''
       FETCH NEXT FROM col_cursor INTO @columnName   
   END   
 
   CLOSE col_cursor   
   DEALLOCATE col_cursor 
 
   SET @sqlCommand = @sqlCommand + @where
   --PRINT @sqlCommand
   EXEC (@sqlCommand) 
END TRY
BEGIN CATCH
   PRINT 'There was an error. Check to make sure object exists.'
   IF CURSOR_STATUS('variable', 'col_cursor') <> -3
   BEGIN
       CLOSE col_cursor   
       DEALLOCATE col_cursor 
   END
END CATCH
GO
