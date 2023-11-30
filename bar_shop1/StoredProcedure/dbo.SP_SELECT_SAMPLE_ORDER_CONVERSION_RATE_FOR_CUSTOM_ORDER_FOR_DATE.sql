IF OBJECT_ID (N'dbo.SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_FOR_DATE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_FOR_DATE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: <2018.09.19>
-- Description:	<샘플 주문 전환율 날짜기준 검색>
-- EXEC SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_FOR_DATE '2022-01-01', '2022-05-31', 'SB|SA|ST|SS|B|C|H'
-- EXEC SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_FOR_DATE '2022-05-01', '2022-05-31', 'SS'

-- Update date: 2022.05.27, 김광호
-- Description: 회원만 검색,  추가주문 집계 제거
-- =============================================

CREATE PROCEDURE  [dbo].[SP_SELECT_SAMPLE_ORDER_CONVERSION_RATE_FOR_CUSTOM_ORDER_FOR_DATE]
		@P_START_DATE AS VARCHAR(10)
	,	@P_END_DATE AS VARCHAR(10)
	,	@P_SALES_GUBUN AS VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	declare	@START_DATE AS smalldatetime
		,	@END_DATE AS smalldatetime

	Set @START_DATE = @P_START_DATE;
	Set @END_DATE = DATEADD(day,1, @P_END_DATE);
		
	DECLARE @T_MONTH TABLE
    (
		[MONTH] VARCHAR(7),
		[fdate] smalldatetime,
		[tdate] smalldatetime
	)	
	declare @fdate smalldatetime, @tdate smalldatetime, @lastdate smalldatetime
	set @fdate = @START_DATE
	set @tdate = DATEADD(month, 1, DATEADD(month, DATEDIFF(month, 0, @fdate), 0))
	set @lastdate = DATENAME(Year, DATEADD(YEAR, 1, @fdate)) + '-12-01'

	while (@fdate <= @lastdate)
	Begin
		insert into @T_MONTH ([MONTH], [fdate], [tdate])
		values (CONVERT(varchar(7), @fdate, 121), @fdate, @tdate)
	
		set @fdate = @tdate
		set @tdate = DATEADD(month, 1, @fdate)
	End

	Select 
		CSO.SampleDeliveryMonth, CSO.ConversionMonth, 
		isnull(WeddingInvitationCount,0) as WeddingInvitationCount,
		CSO.SampleCount,
		ROUND(1.0 * isnull(WeddingInvitationCount,0) / CSO.SampleCount * 100, 2)	AS Rate
	From (
			Select a.[MONTH] as SampleDeliveryMonth, 
					b.[MONTH] as ConversionMonth, 
					Count(*) as SampleCount
			From  CUSTOM_SAMPLE_ORDER as o
				Inner Join @T_MONTH as a
					on o.DELIVERY_DATE >= a.fdate 
					And o.DELIVERY_DATE < a.tdate 
				Cross Join @T_MONTH as b
			Where o.DELIVERY_DATE >= @START_DATE
			And	  o.DELIVERY_DATE < @END_DATE
			And   o.STATUS_SEQ >= 1
			AND	  (@P_SALES_GUBUN = '' OR o.SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))
			Group by a.[MONTH], b.[MONTH]
		) AS CSO
		Left Join (
			Select  a.[MONTH] as SampleDeliveryMonth, 
					b.[MONTH] as ConversionMonth, 
					Count(*) as WeddingInvitationCount
			From (
				Select	s.DELIVERY_DATE,
						min(o.src_send_date) as src_send_date,
						s.sample_order_seq, s.MEMBER_ID, o.SALES_GUBUN
				From CUSTOM_SAMPLE_ORDER as s
					Inner Join CUSTOM_ORDER o 
						On   o.MEMBER_ID = s.MEMBER_ID  
						And	 o.SRC_SEND_DATE >= s.DELIVERY_DATE
						AND  o.SALES_GUBUN IN ('SB', 'SA', 'ST', 'SS', 'SD', 'B', 'C', 'H')
				Where s.DELIVERY_DATE >= @START_DATE
				And   s.DELIVERY_DATE < @END_DATE
				And   s.STATUS_SEQ >= 1
				AND	  ISNULL(s.MEMBER_ID, '') <> ''
				AND	  (@P_SALES_GUBUN = '' OR s.SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SALES_GUBUN, '|')))
				AND	  o.STATUS_SEQ = 15
				AND   o.UP_ORDER_SEQ IS NULL	
				and	  o.SRC_SEND_DATE < @lastdate
				group by s.DELIVERY_DATE, s.sample_order_seq, s.MEMBER_ID, o.SALES_GUBUN
				) as so
				Inner Join @T_MONTH as a
					on   so.DELIVERY_DATE >= a.fdate 
					And  so.DELIVERY_DATE < a.tdate 
				Inner Join @T_MONTH as b
					On   so.SRC_SEND_DATE  >= b.fdate 
					And  so.SRC_SEND_DATE < b.tdate 

			Group by a.[MONTH],b.[MONTH]
			
		) AS CO 
		ON CSO.SampleDeliveryMonth = co.SampleDeliveryMonth 
		And CSO.ConversionMonth = co.ConversionMonth
	Order by CSO.SampleDeliveryMonth,  CSO.ConversionMonth
END
GO
