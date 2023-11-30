IF OBJECT_ID (N'dbo.spCT', N'P') IS NOT NULL DROP PROCEDURE dbo.spCT
GO

USE [EagleSupport]
GO
/****** Object:  StoredProcedure [dbo].[spCT]    Script Date: 2023-03-17 오전 10:53:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [dbo].[spCT]    
 @TableNames as varchar(4000)    
as    
    
set nocount on    
    
    
    
    
declare @FirstTableName varchar(40) -- 첫번째 테이블 이름    
declare @firstNo int -- 컴마가 나오는 첫번째 문자열 주소    
declare @Length int -- 주어진 문자에 대한 길이    
    
--임시테이블하나를 만들자...    
declare  @TNAME  table (    
 Name char(40)  
)    
    
select @firstNo = 1 -- 반복문때문에 임의로 1로 준다..    
    
while @firstNo > 0     
begin    
 select @Length = len( @TableNames )    
    
 select @firstNo = patindex('%,%', @TableNames )    
     
 if (@firstNo = 0)    
 begin     
  select @FirstTableName = ltrim(rtrim(left(@TableNames, @Length)))    
  select @TableNames = ''    
 end    
 else    
 begin    
  select @FirstTableName = ltrim(rtrim(left(@TableNames,  @firstNo -1)))    
  select @TableNames = substring(@TableNames, @firstNo+1, @Length - @firstNo )    
    
 end    
     
 -- 뭉테기 테이블 이름들을 쪼갠것을 임시테이블에 때려 넣는다...    
 insert into @TNAME    
 select @FirstTableName    
    
end    
    
--일단 쪼갠 테이블 이름들이 유효한 것인지 판단한다...    
--유효하지 않은 테이블 이름들은 메시지 주고 빠진다....    
  
  
if exists (select A.name     
from @TNAME A left outer join sysobjects B on A.name= B.name and  B.xtype = 'U'    
where B.name is null)    
begin    
select  A.name as  '테이블이름 확인 바람....'      
 from @TNAME A left outer join sysobjects B on A.name= B.name and  B.xtype = 'U'    
 where B.name is null    
    
return    
end    
  
    
 --초기 변수들을 지정하자...    
 declare   @COLUMNS  varchar(5000)     
 declare  @CNT   int    
 declare  @TableName  varchar(776)       
 declare   @indid   smallint    
 declare   @objid  int    
     
 set @CNT  = 0    
     
 declare @TEMP table   (    
  SERNO int,    
  TEMP_DESCR varchar(4000)     
 )    
      
 declare curs  cursor local fast_forward    
     
   for  select  A.name     
  from @TNAME A    
   for read only    
 open curs     
     
 fetch next from curs into @TableName    
     
   while @@FETCH_STATUS = 0     
   begin    
  set @objid = object_id(@TableName)    
      
  insert  into @TEMP    
  select @CNT, ''     
  set @CNT = @CNT + 1    
    
  --insert into @TEMP    
  --select  @CNT , ' DROP TABLE   ' + @TableName       
  --set @CNT = @CNT + 1    
    
    
 -- insert  into @TEMP    
 -- select @CNT, 'go'   
 -- set @CNT = @CNT + 1    
  
  
  insert into @TEMP    
  select  @CNT , 'CREATE TABLE   ' + rtrim(@TableName) + space(3) + '('    
     
  insert into @TEMP    
  select  @CNT +  B.colid ,   space(10) + B.name + space(3)    
      
  + case    when B.iscomputed = 1 then ' as ' + Y.text  --계산 필드 들에 대한 처리 부분....    
   when xusertype = 62 then rtrim('  '+type_name(xusertype)+ '('+ convert(varchar(3), prec) + ') ') -- float     
   when xusertype = 59 then rtrim('  '+type_name(xusertype)+ '('+ convert(varchar(3), prec) + ') ')   --real    
   when xusertype = 56 then rtrim('  '+type_name(xusertype) )  --int     
   when xusertype = 52 then rtrim('  '+type_name(xusertype) )  --smallint   
   when xusertype = 108 then rtrim('  '+type_name(xusertype)+ '('+ convert(varchar(3), prec)+','+ convert(varchar(3), scale) + ') ') --numeric    
   when xusertype = 106 then rtrim('  '+type_name(xusertype)+ '('+ convert(varchar(3), prec)+','+ convert(varchar(3), scale) + ') ')  --decimal     
   when xusertype = 48 then rtrim('  '+type_name(xusertype) )  --tinyint   
   when xusertype = 34 then rtrim('  '+type_name(xusertype) )  -- image  
   when xusertype = 61 then rtrim('  '+type_name(xusertype) )  -- datetime  
    
   else  rtrim('  '+type_name(xusertype)+ '('+ convert(varchar(4), prec) + ') ') end --숫자형 타입이 아닌거는 그냥 뿌려줌...    
      
   + ' '    
  + case    when Z.colid is not null then 'IDENTITY(    ,    )'     
   when B.iscomputed = 1 then  ''  --계산 필드 들에 대한 처리 부분....    
   when isnullable = 0 then ' not null'     
   else ' null' end     
   + ' ' + isnull(X.Defaultvalues, '' ) + ','    
    
  from sysobjects A    
   left outer join  syscolumns B on A.id = B.id     
   -- 요 조인은 디폴트 내역을 찾아오기 위한 조인.....    
   left outer join ( select col_name(@objid ,A.info) as ColumnName     
    , ' CONSTRAINT DF_'+RTRIM(@TableName)+'_'+ RTRIM(col_name(@objid ,A.info)) + ' DEFAULT ' + replace(replace( ltrim(rtrim(B.text)),'(',''),')','') as Defaultvalues    
    from sysobjects A left outer join  syscomments B on A.id = B.id    
    where A.xtype = 'D '    
    and A.parent_obj = @objid) X     
   on B.name = X.ColumnName    
   --이 조인은 계산 필드내역을 찾아오기 위한 조인...    
   left outer join ( select C.id , C.number, C.text       
    from sysobjects A, syscolumns B, syscomments C    
    where A.id = B.id and B.iscomputed = 1 and  A.xtype = 'U'     
    and B.id = C.id and B.colid = C.number    
    ) Y    
   on B.id = Y.id and B.colid = Y.number    
   -- 요 조인은 아이덴티티인지를 찾아오기 위한 조인....    
   left outer join (select A.id ,B.colid     
     from sysobjects A, syscolumns B    
     where A.id = B.id  and B.autoval is not null    
     )Z    
   on B.id = Z.id and B.colid = Z.colid    
  where A.id = @objid    
  order by B.colid    
     
  select @CNT  = max(B.colid) + @CNT     
  from sysobjects A, syscolumns B      
  where A.id = B.id and A.id = @objid     
  --group by B.name    
    
  --프라이머리키 찾아오는 부분    
  declare      
    @i    int    
   ,@cnstid  int    
   ,@cnsttype  character(2)    
   ,@keys   nvarchar(2078)     
    
  select @cnstid= id, @cnsttype = xtype from sysobjects where parent_obj = @objid    
   and xtype in ('PK')     
  if @cnsttype in ('PK')    
  begin    
       
       
   select @indid = indid         
   from sysindexes    
   where name = object_name(@cnstid)    
     and id = @objid    
    
   -- Format keys string    
   declare @thiskey sysname    
   select @keys = index_col(@TableName, @indid, 1), @i = 2,    
     @thiskey = index_col(@TableName, @indid, 2)    
   while (@thiskey is not null )    
   begin    
    select @keys = @keys + ', ' + @thiskey, @i = @i + 1    
    select @thiskey = index_col(@TableName, @indid, @i)    
   end    
    
   insert into @TEMP select @CNT , ' CONSTRAINT PK_'+RTRIM(@TableName)+' PRIMARY KEY(' + @keys + ')'    
   set @CNT  = @CNT  +1    
   insert into @TEMP select @CNT ,  ' )'    
   set @CNT  = @CNT  +1    
   insert into @TEMP select  @CNT ,  ' go'    
   set @CNT  = @CNT  +1    
  end    
    
  fetch next from curs into @TableName    
      
   end    
  close curs     
  Deallocate curs    
    
    
    
    
    
 select  TEMP_DESCR from @TEMP order by SERNO    
    
set nocount off    
GO
