IF OBJECT_ID (N'dbo.Where_Am_I', N'P') IS NOT NULL DROP PROCEDURE dbo.Where_Am_I
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[Where_Am_I]
@cString varchar(1000)
AS
	set nocount on
	Select @cString = 'select substring( o.name, 1, 100 ) as Object, count(*) as 
Occurences, ' +
		'case ' +
		' when o.xtype = ''D'' then ''Default'' ' +
		' when o.xtype = ''F'' then ''Foreign Key'' ' +
		' when o.xtype = ''P'' then ''Stored Procedure'' ' +
		' when o.xtype = ''PK'' then ''Primary Key'' ' +
		' when o.xtype = ''S'' then ''System Table'' ' +
		' when o.xtype = ''TR'' then ''Trigger'' ' +
		' when o.xtype = ''U'' then ''User Table'' ' +
		' when o.xtype = ''V'' then ''View'' ' +
		'end as Type ' +
		'from syscomments c join sysobjects o on c.id = o.id ' +
		'where patindex( ''%'  + @cString + '%'', c.text ) > 0 ' +
		'group by o.name, o.xtype ' +
		'order by o.xtype, o.name'

	Execute( @cString )
Return
GO
