IF OBJECT_ID (N'dbo.SP_S_SCHEDULE_ORDER_STATISTICS_RECALL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_SCHEDULE_ORDER_STATISTICS_RECALL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_S_SCHEDULE_ORDER_STATISTICS_RECALL]
	@yymm VARCHAR(6) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	declare @YMD VARCHAR(8);
	declare @YM VARCHAR(6);

	SET @YM = @yymm
	SET @YMD = convert(varchar, dateadd(MONTH, -1, getdate()), 112)

	IF @yymm is NULL BEGIN
		SET @YM = left(@YMD, 6);
	END

/* 전체현황 일별 통계 등록 */
delete from TB_Total_Statistic_Day where Date like @YM+'%';

insert into TB_Total_Statistic_Day (
	Date,
	Free_Order_Count,
	Charge_Order_Count,
	Cancel_Count,
	Payment_Price,
	Cancel_Refund_Price,
	Profit_Price,
	Memberjoin_Count
)
select 
	DT.standard_date,
	isnull(OC.free_count, 0) free_count,
	isnull(OC.pay_count, 0) pay_count,
	isnull(OC2.cancel_count, 0) cancel_count,
	isnull(OC.total_price, 0) total_price,
	isnull(OC2.cancel_price, 0) cancel_price,
	isnull(OC.total_price, 0) - isnull(OC2.cancel_price, 0) net_price,
	isnull(UC.join_count, 0) join_count
from TB_Standard_Date DT
	left join (
		select 
			convert(varchar, Payment_DateTime, 112) order_date,
			sum(case when payment_price > 0 then 1 else 0 end) pay_count,
			sum(case when isnull(payment_price, 0) = 0 then 1 else 0 end) free_count,
			sum(payment_price) total_price
		from TB_Order
		where Payment_DateTime is not null
			and (Payment_Status_Code = 'PSC02' OR Payment_Status_Code = 'PSC03')
		group by convert(varchar, Payment_DateTime, 112)
	) AS OC
		ON DT.Standard_Date = order_date
	left join (
		select 
			convert(varchar, Cancel_DateTime, 112) cancel_date,
			sum(case when Cancel_DateTime is not null then 1 else 0 end) cancel_count,
			sum(case when Cancel_DateTime is not null then payment_price else 0 end) cancel_price
		from TB_Order
		where Cancel_DateTime is not null
		and Payment_Status_Code = 'PSC03'
		group by convert(varchar, Cancel_DateTime, 112)
	) AS OC2
		ON DT.Standard_Date = cancel_date
	left join (
		select
			count(1) join_count,
			U.reg_date
		from (
				select 
					uid, 
					convert(varchar, max(reg_date), 112) reg_date
				from [bar_shop1].[dbo].[S2_UserInfo]
				where REFERER_SALES_GUBUN = 'BM'
				group by uid
			) as U
		group by U.reg_date
	) UC
		ON DT.Standard_Date = UC.reg_date
where DT.Standard_Month = @YM;


/* 전체현황 월별 통계 등록 */
/*delete from TB_Total_Statistic_Month where Date is null; */
delete from TB_Total_Statistic_Month where Date = @YM;

insert into TB_Total_Statistic_Month (
	Date,
	Free_Order_Count,
	Charge_Order_Count,
	Cancel_Count,
	Payment_Price,
	Cancel_Refund_Price,
	Profit_Price,
	Memberjoin_Count
)
select 
	@YM AS Date,
	sum(Free_Order_Count) Free_Order_Count,
	sum(Charge_Order_Count) Charge_Order_Count,
	sum(Cancel_Count) Cancel_Count,
	sum(isnull(Payment_Price,0)) Payment_Price,
	sum(Cancel_Refund_Price) Cancel_Refund_Price,
	sum(Profit_Price) Profit_Price,
	sum(Memberjoin_Count) Memberjoin_Count
from TB_Total_Statistic_Day
where date like @YM+'%'



/* 매출통계 (일별) */
delete from TB_Sales_Statistic_Day where Date like @YM+'%';

insert into TB_Sales_Statistic_Day (
	Date,
	Barunn_Sales_Price,
	Barunn_Free_Order_Count,
	Barunn_Charge_Order_Count,
	Bhands_Sales_Price,
	Bhands_Free_Order_Count,
	Bhands_Charge_Order_Count,
	Thecard_Sales_Price,
	Thecard_Free_Order_Count,
	Thecard_Charge_Order_Count,
	Premier_Sales_Price,
	Premier_Free_Order_Count,
	Premier_Charge_Order_Count,
	Total_Sales_Price,
	Total_Free_Order_Count,
	Total_Charge_Order_Count
)
select
	DT.Standard_Date,
	isnull(OC.barunsoncard_pay_price, 0) - isnull(OC2.barunsoncard_cancel_price, 0) as barunsoncard_pay_price,
	isnull(OC.barunsoncard_free_count, 0) barunsoncard_free_count,
	isnull(OC.barunsoncard_pay_count, 0) barunsoncard_pay_count,
	isnull(OC.bhands_pay_price, 0) - isnull(OC2.bhands_cancel_price, 0) as bhands_pay_price,
	isnull(OC.bhands_free_count, 0) bhands_free_count,
	isnull(OC.bhands_pay_count, 0) bhands_pay_count,
	isnull(OC.thecard_pay_price, 0) - isnull(OC2.thecard_cancel_price, 0) as thecard_pay_price,
	isnull(OC.thecard_free_count, 0) thecard_free_count,
	isnull(OC.thecard_pay_count, 0) thecard_pay_count,
	isnull(OC.premierpaper_pay_price, 0) - isnull(OC2.premierpaper_cancel_price, 0) as premierpaper_pay_price,
	isnull(OC.premierpaper_free_count, 0) premierpaper_free_count,
	isnull(OC.premierpaper_pay_count, 0) premierpaper_pay_count,
	isnull(OC.pay_price, 0) - isnull(OC2.cancel_price, 0) as pay_price,
	isnull(OC.free_count, 0) free_count,
	isnull(OC.pay_count, 0) pay_count
from TB_Standard_Date DT
	left join (
		select
			convert(varchar, O.Payment_DateTime, 112) order_date,
	
			sum(case when P.Product_Brand_Code = 'PBC01' then isnull(O.Payment_Price,0) else 0 end) AS barunsoncard_pay_price,
			sum(case when P.Product_Brand_Code = 'PBC01' and isnull(O.Payment_Price,0) > 0 then  1 else 0 end) AS barunsoncard_pay_count,
			sum(case when P.Product_Brand_Code = 'PBC01' and isnull(O.Payment_Price,0) = 0 then  1 else 0 end) AS barunsoncard_free_count,

			sum(case when P.Product_Brand_Code = 'PBC02' then isnull(O.Payment_Price,0) else 0 end) AS bhands_pay_price,
			sum(case when P.Product_Brand_Code = 'PBC02' and isnull(O.Payment_Price,0) > 0 then  1 else 0 end) AS bhands_pay_count,
			sum(case when P.Product_Brand_Code = 'PBC02' and isnull(O.Payment_Price,0) = 0 then  1 else 0 end) AS bhands_free_count,

			sum(case when P.Product_Brand_Code = 'PBC03' then isnull(O.Payment_Price,0) else 0 end) AS thecard_pay_price,
			sum(case when P.Product_Brand_Code = 'PBC03' and isnull(O.Payment_Price,0) > 0 then  1 else 0 end) AS thecard_pay_count,
			sum(case when P.Product_Brand_Code = 'PBC03' and isnull(O.Payment_Price,0) = 0 then  1 else 0 end) AS thecard_free_count,

			sum(case when P.Product_Brand_Code = 'PBC04' then isnull(O.Payment_Price,0) else 0 end) AS premierpaper_pay_price,
			sum(case when P.Product_Brand_Code = 'PBC04' and isnull(O.Payment_Price,0) > 0 then  1 else 0 end) AS premierpaper_pay_count,
			sum(case when P.Product_Brand_Code = 'PBC04' and isnull(O.Payment_Price,0) = 0 then  1 else 0 end) AS premierpaper_free_count,
	
			sum(isnull(O.Payment_Price,0)) as pay_price,
			sum(case when isnull(O.Payment_Price,0) > 0 then 1 else 0 end) as pay_count,
			sum(case when isnull(O.Payment_Price,0) = 0 then 1 else 0 end) as free_count

		from TB_Order as O
			inner join TB_Order_Product AS OP
				ON O.Order_ID = OP.Order_ID
			inner join TB_Product AS P
				on OP.Product_ID = P.Product_ID
		where O.Payment_DateTime is not null
			and (Payment_Status_Code = 'PSC02' OR Payment_Status_Code = 'PSC03')
		group by convert(varchar, Payment_DateTime, 112)
	) AS OC
		on DT.Standard_Date = OC.order_date
	left join (
		select
			convert(varchar, O.Cancel_DateTime, 112) cancel_date,
			sum(case when P.Product_Brand_Code = 'PBC01' then isnull(O.Payment_Price,0) else 0 end) AS barunsoncard_cancel_price,
			sum(case when P.Product_Brand_Code = 'PBC02' then isnull(O.Payment_Price,0) else 0 end) AS bhands_cancel_price,
			sum(case when P.Product_Brand_Code = 'PBC03' then isnull(O.Payment_Price,0) else 0 end) AS thecard_cancel_price,
			sum(case when P.Product_Brand_Code = 'PBC04' then isnull(O.Payment_Price,0) else 0 end) AS premierpaper_cancel_price,
			sum(O.Payment_Price) as cancel_price
		from TB_Order as O
			inner join TB_Order_Product AS OP
				ON O.Order_ID = OP.Order_ID
			inner join TB_Product AS P
				on OP.Product_ID = P.Product_ID
		where O.Cancel_DateTime is not null
			AND O.Payment_Status_Code = 'PSC03'
		group by convert(varchar, Cancel_DateTime, 112)
	) AS OC2
		on DT.Standard_Date = OC2.cancel_date
WHERE DT.Standard_Month= @YM;



/* 매출통계 (월별) */
/* delete from TB_Sales_Statistic_Month where Date is null; */
delete from TB_Sales_Statistic_Month where Date = @YM;

insert into TB_Sales_Statistic_Month (
	Date,
	Barunn_Sales_Price,
	Barunn_Free_Order_Count,
	Barunn_Charge_Order_Count,
	Bhands_Sales_Price,
	Bhands_Free_Order_Count,
	Bhands_Charge_Order_Count,
	Thecard_Sales_Price,
	Thecard_Free_Order_Count,
	Thecard_Charge_Order_Count,
	Premier_Sales_Price,
	Premier_Free_Order_Count,
	Premier_Charge_Order_Count,
	Total_Sales_Price,
	Total_Free_Order_Count,
	Total_Charge_Order_Count
)
select
	@YM AS Date,
	sum(Barunn_Sales_Price) as Barunn_Sales_Price,
	sum(Barunn_Free_Order_Count) as Barunn_Free_Order_Count,
	sum(Barunn_Charge_Order_Count) as Barunn_Charge_Order_Count,
	sum(Bhands_Sales_Price) as Bhands_Sales_Price,
	sum(Bhands_Free_Order_Count) as Bhands_Free_Order_Count,
	sum(Bhands_Charge_Order_Count) as Bhands_Charge_Order_Count,
	sum(Thecard_Sales_Price) as Thecard_Sales_Price,
	sum(Thecard_Free_Order_Count) as Thecard_Free_Order_Count,
	sum(Thecard_Charge_Order_Count) as Thecard_Charge_Order_Count,
	sum(Premier_Sales_Price) as Premier_Sales_Price,
	sum(Premier_Free_Order_Count) as Premier_Free_Order_Count,
	sum(Premier_Charge_Order_Count) as Premier_Charge_Order_Count,
	sum(Total_Sales_Price) as Total_Sales_Price,
	sum(Total_Free_Order_Count) as Total_Free_Order_Count,
	sum(Total_Charge_Order_Count) as Total_Charge_Order_Count
from TB_Sales_Statistic_Day
WHERE Date like @YM+'%';


/* 결제수단 일별 */
delete from TB_Payment_Status_Day where Date like @YM+'%';

insert into TB_Payment_Status_Day (
	Date,
	Card_Payment_Price,
	Account_Transfer_Price,
	Virtual_Account_Price,
	Etc_Price,
	Total_Price,
	Cancel_Refund_Price,
	Profit_Price
)
select
	DT.Standard_Date,
	isnull(OC.card_pay_price, 0) card_pay_price,
	isnull(OC.banking_pay_price, 0) banking_pay_price,
	isnull(OC.vbanking_pay_price, 0) vbanking_pay_price,
	isnull(OC.etc_pay_price, 0) etc_pay_price,
	isnull(OC.total_pay_price, 0) total_pay_price,
	isnull(CC.cancel_price, 0) cancel_price,
	isnull(OC.total_pay_price, 0) - isnull(CC.cancel_price, 0) net_price
from TB_Standard_Date as DT
	left join (
		select
			convert(varchar, Payment_DateTime, 112) order_date,
			isnull(sum(case when Payment_Method_Code = 'PMC01' then Payment_Price else 0 end),0) card_pay_price,
			isnull(sum(case when Payment_Method_Code = 'PMC03' then Payment_Price else 0 end),0) banking_pay_price,
			isnull(sum(case when Payment_Method_Code = 'PMC02' then Payment_Price else 0 end),0) vbanking_pay_price,
			isnull(sum(case when Payment_Method_Code = 'PMC04' then Payment_Price else 0 end),0) etc_pay_price,
			isnull(sum(Payment_Price),0) as total_pay_price
		from TB_Order
		where Payment_DateTime is not null
			and (Payment_Status_Code = 'PSC02' OR Payment_Status_Code = 'PSC03')
		group by convert(varchar, Payment_DateTime, 112)
	) as OC
		on dt.Standard_Date = OC.order_date
	left join (
		select
			convert(varchar, Cancel_DateTime, 112) cancel_date,
			isnull(sum(Payment_Price), 0) as cancel_price
		from TB_Order
		where Cancel_DateTime is not null
			and Payment_Status_Code = 'PSC03'
		group by convert(varchar, Cancel_DateTime, 112)
	) AS CC
		on DT.Standard_Date = CC.cancel_date
where dt.Standard_Month = @YM;


/* 결제수단 월별 */
/* delete from TB_Payment_Status_Month where Date is NULL;*/
delete from TB_Payment_Status_Month where Date = @YM;

insert into TB_Payment_Status_Month(
	Date,
	Card_Payment_Price,
	Account_Transfer_Price,
	Virtual_Account_Price,
	Etc_Price,
	Total_Price,
	Cancel_Refund_Price,
	Profit_Price
)
select
	@YM AS Date,
	sum(Card_Payment_Price) as Card_Payment_Price,
	sum(Account_Transfer_Price) as Account_Transfer_Price,
	sum(Virtual_Account_Price) as Virtual_Account_Price,
	sum(Etc_Price) as Etc_Price,
	sum(Total_Price) as Total_Price,
	sum(Cancel_Refund_Price) as Cancel_Refund_Price,
	sum(Profit_Price) as Profit_Price
from TB_Payment_Status_Day
where Date like @YM+'%';

END
GO
