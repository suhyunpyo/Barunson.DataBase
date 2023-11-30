IF OBJECT_ID (N'dbo.select_WOrder_CallSMS', N'P') IS NOT NULL DROP PROCEDURE dbo.select_WOrder_CallSMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE    procedure [dbo].[select_WOrder_CallSMS]
 @p_hphone as varchar(12) 
as
begin
	
	--DECLARE 
	--	@hphone1 AS varchar(15)
	--	,@hphone2 AS varchar(15)
	
	--SET @hphone1 = REPLACE(@p_hphone,'-','')

	--IF LEN(@hphone1) >= 11 
	--BEGIN
	--	SET @hphone2 = SUBSTRING(@hphone1, 1, 3) + '-' + SUBSTRING(@hphone1, 4, 4) + '-' + SUBSTRING(@hphone1, 8, LEN(@hphone1) - 7)
	--END
	--ELSE IF LEN(@hphone1) = 10
	--BEGIN
	--	SET @hphone2 = SUBSTRING(@hphone1, 1, 2) + '-' + SUBSTRING(@hphone1, 3, 4) + '-' + SUBSTRING(@hphone1, 7, LEN(@hphone1) - 6)
	--END
	
	SET @p_hphone = REPLACE(@p_hphone,'-','')
	
	select	order_seq,'1' isworder,order_date
	from	custom_order 
	where	replace(order_hphone, '-', '') like '%' + @p_hphone + '%'
	--and		datediff(month,order_date,getdate())<=3
	and		order_date >= CONVERT(smalldatetime, DATEADD(MONTH, -3, GETDATE()))
	and		order_date <= CONVERT(smalldatetime, GETDATE())
	
	and		status_seq>=1
	order by order_date desc
	
	
	
end

GO
