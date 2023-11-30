IF OBJECT_ID (N'dbo.fnHTMLtoTEXT', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fnHTMLtoTEXT', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fnHTMLtoTEXT', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fnHTMLtoTEXT', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fnHTMLtoTEXT', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fnHTMLtoTEXT
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   function [dbo].[fnHTMLtoTEXT] (@str varchar(8000))
returns varchar(8000)
as
begin 
declare  @nLen int,@st int,@ed int,@ds varchar(5000),@sf varchar(5000),@i int

set @nLen = Len(@str)
set @sf = @str
set @i = 0

WHILE @i <= @nLen
  BEGIN

  set @st = bar_shop1.dbo.INSTR(@i,@str,'<')
  set @ed = bar_shop1.dbo.INSTR(@st+1,@str,'>')

   IF @st > 0 And @ed > 0
       BEGIN
          set @ds = substring(@str,@st,(@ed+1)-@st)

          set @sf = replace(@sf,@ds,'')
          set @i = @ed
        END
set @i = @i + 1
END

return replace(@sf,' ','')

end
GO
