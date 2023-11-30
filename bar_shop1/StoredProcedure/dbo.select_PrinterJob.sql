IF OBJECT_ID (N'dbo.select_PrinterJob', N'P') IS NOT NULL DROP PROCEDURE dbo.select_PrinterJob
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[select_PrinterJob]
 @pdate as varchar(10),
 @printer_id as varchar(5),
 @cseq as integer output,
 @ptype as char(1) output,
 @job_prct as float output
as
begin

	declare @psum as float
	declare @psum_end as float
	set @job_prct =0
	select top 1 @cseq= cseq,@ptype = ptype from CUSTOM_ORDER_PRINTJOB where pdate=@pdate and printer_id=@printer_id order by printer_date desc
	
	select @psum = ISNULL(SUM(pcount),0) from CUSTOM_ORDER_PRINTJOB where pdate=@pdate and cseq=@cseq and ptype=@ptype
	select @psum_end = ISNULL(SUM(pcount),0) from CUSTOM_ORDER_PRINTJOB where pdate=@pdate and cseq=@cseq and printer_id is not null and ptype=@ptype
	if(@psum > 0)
	begin
		set @job_prct = (@psum_end/@psum)*100
	end
end

GO
