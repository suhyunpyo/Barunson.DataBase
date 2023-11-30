IF OBJECT_ID (N'dbo.sp_BarunsonRanking_get', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_BarunsonRanking_get
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROC [dbo].[sp_BarunsonRanking_get]
	@sales_gubun as char(1),
	@gubun as char(1)
AS
	declare @gubun_data as varchar(8)

	IF @gubun = '0'  -- 주간구매
	begin
		if len(datepart(week,getdate())) = 1
			set @gubun_data	= cast(datepart(year,getdate()) as varchar(4)) + '0' + cast(datepart(week,getdate()) as varchar(1))
		else
			set @gubun_data	= cast(datepart(year,getdate()) as varchar(4)) + cast(datepart(week,getdate()) as varchar(2))
		
	end
	else
	begin

		if len(datepart(mm, dateadd(month,-1,getdate()))) = 1
			set @gubun_data	= cast(datepart(year,dateadd(month,-1,getdate())) as varchar(4)) + '0' + cast(datepart(mm, dateadd(month,-1,getdate())) as varchar(1))
		else
			set @gubun_data	= cast(datepart(year,dateadd(month,-1,getdate())) as varchar(4)) + cast(datepart(mm, dateadd(month,-1,getdate())) as varchar(2))

	end

	select A.rank,A.card_seq,B.card_code,B.company as card_company,B.disrate_type,B.card_price_customer,B.card_img_ms 
	from BestRanking_New A inner join card B on A.card_seq = B.card_seq
	where A.sales_gubun=@sales_gubun and A.gubun=@gubun and A.gubun_data=@gubun_data and B.display_yes_or_no='1' and B.is100='1' order by A.rank



GO
