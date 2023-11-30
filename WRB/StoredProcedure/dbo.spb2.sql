IF OBJECT_ID (N'dbo.spb2', N'P') IS NOT NULL DROP PROCEDURE dbo.spb2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spb2]
(
  @TableNm  VarChar(100) = null
  , @Owner Varchar(100) = 'dbo'
)
AS
BEGIN
 SET NOCOUNT ON
 
 
    
DECLARE @T_MappingType TABLE (Name VARCHAR(30) , NetType VARCHAR(30), AdoType VARCHAR(30))    
  
	--======================================================================================
	-- S: 컬럼탑입에 대한 C# 매칭 타입 정보 INSERT....
	INSERT INTO @T_MappingType (Name, NetType , AdoType )
	SELECT Name 
	 , (case ISNULL(sys.types.name, N'') 
	   When 'bigint' Then 'long'
	   When 'bit' Then 'bool'
	   --When 'bit' Then 'int'  --sql bit 데이터는 :0/1로 표시 되기 때문에 int로 처리
	   --When 'char' Then 'char'
	   When 'char' Then 'string'
	   When 'datetime' Then 'DateTime'
	   When 'decimal' Then 'decimal'
	   When 'float' Then 'float'
	   When 'image' Then 'object'
	   When 'int' Then 'int'
	   When 'money' Then 'double'
	   When 'nchar' Then 'string'
	   When 'ntext' Then 'string'
	   When 'numeric' Then 'double'
	   When 'nvarchar' Then 'string'
	   When 'real' Then 'object'
	   When 'smalldatetime' Then 'DateTime'
	   When 'smallint' Then 'int'
	   When 'smallmoney' Then 'double'
	   When 'text' Then 'string'
	   When 'timestamp' Then 'object'
	   When 'tinyint' Then 'int'
	   When 'uniqueidentifier' Then 'object'
	   When 'varbinary' Then 'object'
	   When 'varchar' Then 'string'
	   When 'xml' Then 'string' 
	  Else '' End ) As 'NetType'
	  

	, (case ISNULL(sys.types.name, N'')
	 When 'bigint' Then 'SqlDbType.BigInt'
	 When 'bit' Then 'SqlDbType.Bit'
	 When 'char' Then 'SqlDbType.Char'
	 When 'datetime' Then 'SqlDbType.DateTime'
	 When 'decimal' Then 'SqlDbType.Decimal'
	 When 'float' Then 'SqlDbType.Float'
	 When 'image' Then 'SqlDbType.Image'
	 When 'int' Then 'SqlDbType.Int'
	 When 'money' Then 'SqlDbType.Money'
	 When 'nchar' Then 'SqlDbType.NChar'
	 When 'ntext' Then 'SqlDbType.NText'
	 When 'numeric' Then 'SqlDbType.Decimal'
	 When 'nvarchar' Then 'SqlDbType.NVarChar'
	 When 'real' Then 'SqlDbType.Real'
	 When 'smalldatetime' Then 'SqlDbType.SmallDateTime'
	 When 'smallint' Then 'SqlDbType.SmallInt'
	 When 'smallmoney' Then 'SqlDbType.SmallMoney'
	 When 'text' Then 'SqlDbType.Text'
	 When 'timestamp' Then 'SqlDbType.Timestamp'
	 When 'tinyint' Then 'SqlDbType.TinyInt'
	 When 'uniqueidentifier' Then 'SqlDbType.UniqueIdentifier'
	 When 'varbinary' Then 'SqlDbType.VarBinary'
	 When 'varchar' Then 'SqlDbType.VarChar'
	 When 'xml' Then 'SqlDbType.Xml' 
	Else '' End ) As 'NetDbType'         
	FROM sys.types   
	-- E: 컬럼탑입에 대한 C# 매칭 타입 정보 INSERT....
	--======================================================================================
   
   
	--======================================================================================
	-- S: 변수 선언부 
	Declare @Sql_Select Varchar(Max) ; Set @Sql_Select  = ''    
	Declare @Sql_WherePk Varchar(Max) ; Set @Sql_WherePk = ''    
	Declare @Sql_WhereAll Varchar(Max) ; Set @Sql_WhereAll = ''    
	Declare @Sql_WhereAll_Param Varchar(Max) ; Set @Sql_WhereAll_Param = ''    
	Declare @Sp_Declare Varchar(Max) ; Set @Sp_Declare = ''    
	Declare @Net_Declare Varchar(Max) ; Set @Net_Declare = ''    
	-- E: 변수 선언부 
	--======================================================================================


	--======================================================================================
	-- S: 쿼리만들기
	Select 
	 -- Select 
	 @Sql_Select = @Sql_Select + (Case  infoCol.Ordinal_Position When 1 Then '' Else ',' End) + Sac.name

	 -- Pk 기준으로 Where 조건절
	 , @Sql_WherePk = @Sql_WherePk + (Case When infoKcu.COLUMN_NAME Is Null Then '' Else (Case @Sql_WherePk When '' Then '' Else ' And ' End) + Sac.name + ' = @' + Sac.name End)

	 -- 전체 항목 기준으로 조건절
	 , @Sql_WhereAll = @Sql_WhereAll + (Case  infoCol.Ordinal_Position When 1 Then '' Else ' And ' End) + Sac.name + ' = @'+Sac.name
	 
	 -- 프로시져 변수 선언문
	 , @Sp_Declare = @Sp_Declare + (Case @Sp_Declare When '' Then '' Else ',' End)+ 'Declare @'+Sac.name + ' ' + InfoCol.Data_Type 
	  + ( Case InfoCol.Data_Type When 'decimal' then '('+cast(Sac.[precision] as varchar) + '^' + cast(Sac.scale as varchar) + ')' else '' end )
	  + (Case IsNull(Sep.VALUE,'') When '' Then '' Else '    -- ' + Cast(IsNull(Sep.VALUE,'') As Varchar) End)


	 -- Net 변수 선언
	 , @Net_Declare = @Net_Declare + (Case IsNull(Sep.VALUE,'') When '' Then '' Else char(13)+char(13)+'/// <summary>'+Char(13)+'///' + Cast(IsNull(Sep.VALUE,'') As Varchar) +char(13)+ '/// <summary>' + char(13) End)
	  + ' public '+NetType+' '+Sac.name + '{get;set;}' + char(13)
	  + (Case infoCol.Ordinal_Position When 1 Then '' Else char(13) End)
	From sys.all_columns As Sac
	 Inner Join sys.Tables As Stb On
	  Stb.Object_id = Sac.Object_Id
	 Left Outer Join 
	  (
	   SELECT major_id, minor_id, VALUE FROM sys.extended_properties WHERE class = 1
	  ) AS Sep ON 
	  Sep.major_id = Sac.object_id AND Sep.minor_id = Sac.column_id
	 Left Outer join [INFORMATION_SCHEMA].[COLUMNS] As infoCol On
	  infoCol.Table_Name = Stb.Name
	  And infoCol.Column_Name = Sac.name
	 Left Outer Join
	 (
	  SELECT COLUMN_NAME 
	  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	  WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_NAME), 'ISPRIMARYKEY') = 1
	  AND TABLE_NAME = @TableNm
	  
	 ) As infoKcu On
	  infoKcu.COLUMN_NAME = Sac.name
	 LEFT OUTER JOIN @T_MappingType AS T_MappingType
		   ON T_MappingType.Name = InfoCol.Data_Type
	Where Stb.Name = @TableNm
	Order By infoCol.Ordinal_Position Asc
	-- E: 쿼리만들기
	--======================================================================================




	--- Select 관련 쿼리 모음
	Print '--Select 관련 쿼리 모음============================='
	Print ' Select ' + @Sql_Select + char(13) + ' From ' + @TableNm + Char(13) + ' Where ' + Replace(@Sql_WherePk,'And',Char(13)+' And')
	Print  char(13) 
	Print ' Select ' + @Sql_Select + char(13) + ' From ' + @TableNm + Char(13) + ' Where ' + Replace(@Sql_WhereAll,'And',Char(13)+' And')
	Print  char(13) 
	

	--- Insert 관련 쿼리 모음
	Print '--Insert 관련 쿼리 모음============================='
	Print ' Insert '+@TableNm+' ('+@Sql_Select+') ' +Char(13)+' Values(@'+Replace(@Sql_Select,',',',@') + ')'
	Print  char(13)
	
	

	--- Delete 관련 쿼리 모음
	Print '--Delete 관련 쿼리 모음============================='
	Print '-- Delete From '+@TableNm + Char(13) + ' Where ' + Replace(@Sql_WherePk,'And',Char(13)+' And')
	Print  char(13)
	Print '-- Delete From '+@TableNm + Char(13) + ' Where ' + Replace(@Sql_WhereAll,'And',Char(13)+' And')
	Print  char(13)
	

	--- Update 관련 쿼리 모음
	Print '--Update 관련 쿼리 모음============================='
	Print '-- Update '+@TableNm+' Set ' +Char(13)+' '+Replace(@Sql_WhereAll,'And',Char(13)+' ,') + char(13) + ' From ' + @TableNm + Char(13) + ' Where ' + Replace(@Sql_WherePk,'And',Char(13)+' And')
	Print  char(13)
	Print '-- Update '+@TableNm+' Set ' +Char(13)+' '+Replace(@Sql_WhereAll,'And',Char(13)+' ,') + char(13) + ' From ' + @TableNm + Char(13) + ' Where ' + Replace(@Sql_WhereAll,'And',Char(13)+' And')
	Print  char(13)


	 

	--- 프로시져 변수선언문
	Print '--프로시져 변수선언문============================='
	Print Replace(Replace(@Sp_Declare,',',Char(13)),'^',',')
	Print char(13)

	--- Sp Input 선언
	Print '--Sp Input 선언============================='
	Print Replace(Replace(Replace(@Sp_Declare,'Declare @','@'),',',Char(13)+','),'^',',')
	Print char(13)


	--- Net 변수 선언
	Print '--Net 변수 선언============================='
	Print @Net_Declare
	Print char(13)

	 
	--- Class 선언
	Print '--Class 선언============================='
	Print 'public class ' + @TableNm + Char(13) + '{' + @Net_Declare + char(13) + '}'
	Print char(13)
	 
 

 

SET NOCOUNT OFF
End

 

GO
