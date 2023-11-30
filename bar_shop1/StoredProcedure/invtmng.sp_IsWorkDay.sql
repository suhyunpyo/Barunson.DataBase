IF OBJECT_ID (N'invtmng.sp_IsWorkDay', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_IsWorkDay
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [invtmng].[sp_IsWorkDay] 
@iYear char(4),
@iMonth char(2),
@iDay char(2),
@rslt char(1) output
AS 
begin
	declare @id int
	select @id = id from TB_Holiday where hyear=@iYear and hmonth=@iMonth and hday=@iDay
	if @@FETCH_STATUS = 0 
	begin
		if @rslt > 0 set @rslt = '1'
		else
			set @rslt = '0'
	end
	else
		set @rslt = '0'
	return 
end
GO
