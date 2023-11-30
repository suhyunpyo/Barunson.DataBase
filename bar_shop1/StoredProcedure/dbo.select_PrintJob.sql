IF OBJECT_ID (N'dbo.select_PrintJob', N'P') IS NOT NULL DROP PROCEDURE dbo.select_PrintJob
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    procedure [dbo].[select_PrintJob]
 @pdate as varchar(10) 
as
begin

--########################################################################################
--차수별 카드/봉투 인쇄수량 집계 (2012-10-17 김수경)
--########################################################################################


select e.cseq,c_psum,c_psum_cmt,ISNULL(e_psum,0) as e_psum,ISNULL(f.e_psum_cmt,0) as e_psum_cmt from
	(
	select c.cseq,c_psum,c_psum_cmt,d.e_psum from 
		(
			select A.cseq,A.c_psum,ISNULL(b.c_psum_cmt,0) as c_psum_cmt from
				(
					select TB.cseq,ISNULL(TA.c_psum,0) as c_psum from 
					(select cseq
						from CUSTOM_ORDER_PRINTJOB 
						where pdate=@pdate group by cseq
						) TB
						left join 				
					(select cseq,ISNULL(SUM(pcount),0) as c_psum 
						from CUSTOM_ORDER_PRINTJOB 
						where pdate=@pdate and ptype='C' group by cseq) 
						TA
						on TB.cseq = TA.cseq 
				)a 
				left join
				(	
					select cseq,ISNULL(SUM(pcount),0) as c_psum_cmt 
					from CUSTOM_ORDER_PRINTJOB 
					where pdate=@pdate and ptype='C' and printer_id is not null  
					group by cseq
				) 
				b on a.cseq = b.cseq
			) 
		c
		left join
			(
				select cseq,ISNULL(SUM(pcount),0) as e_psum 
				from CUSTOM_ORDER_PRINTJOB 
				where pdate=@pdate and ptype='E' 
				group by cseq
			) 
			d 
			on c.cseq=d.cseq
		) e
	left join
	(
		select cseq,ISNULL(SUM(pcount),0) as e_psum_cmt 
		from CUSTOM_ORDER_PRINTJOB 
		where pdate=@pdate and ptype='E' and printer_id is not null  
		group by cseq
	) f on e.cseq = f.cseq
	order by e.cseq
end
GO
