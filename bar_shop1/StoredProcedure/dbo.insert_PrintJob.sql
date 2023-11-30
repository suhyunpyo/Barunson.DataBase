IF OBJECT_ID (N'dbo.insert_PrintJob', N'P') IS NOT NULL DROP PROCEDURE dbo.insert_PrintJob
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create  procedure [dbo].[insert_PrintJob]
 @chasu_date as varchar(10) ,
 @chasu_seq as int,
 @pdate as varchar(10)
as
begin

delete from custom_order_printjob where cdate=@chasu_date and cseq=@chasu_seq
INSERT INTO custom_order_printjob(pdate,cdate,cseq,pid,pcount,ptype)
select @pdate,A.pdate,A.pseq,C.id,C.print_count,ptype=CASE	
						WHEN C.print_type='E' then 'E'
						else 'C'
						end
from custom_order_chasu A inner join custom_order B on A.order_seq = B.order_seq and A.pdate=@chasu_date and A.pseq=@chasu_seq
,custom_order_plist C,S2_CardViewMerge D,card_printinfo E
where A.order_seq = C.order_seq and C.card_seq = D.card_seq and D.card_code = E.card_code 
and C.print_type = E.print_type and E.printer_group = 0
and B.status_seq>=10 and B.status_seq<=14 and C.isNotPrint='0' and C.print_type<>'M' and E.printer_group=0

end



GO
