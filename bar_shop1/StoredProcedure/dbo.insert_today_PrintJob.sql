IF OBJECT_ID (N'dbo.insert_today_PrintJob', N'P') IS NOT NULL DROP PROCEDURE dbo.insert_today_PrintJob
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[insert_today_PrintJob]
 @pdate as varchar(10) ,
 @pseq as int
as
begin

delete from today_printjob where pdate=@pdate and pseq=@pseq
INSERT INTO TODAY_PRINTJOB(pdate,pseq,pid,pcount,ptype)
select A.pdate,A.pseq,C.id,C.print_count,ptype=CASE	
						WHEN C.print_type='E' then 'E'
						else 'C'
						end
from custom_order_chasu A inner join custom_order B on A.order_seq = B.order_seq and A.pdate=@pdate and A.pseq=@pseq
,custom_order_plist C,S2_CardViewMerge D,card_printinfo E
where A.order_seq = C.order_seq and C.card_seq = D.card_seq and D.card_code = E.card_code 
and C.print_type = E.print_type and E.printer_group = 0
and B.status_seq>=10 and B.status_seq<=14 and C.isNotPrint='0' and C.print_type<>'M' and E.printer_group=0

end

GO
