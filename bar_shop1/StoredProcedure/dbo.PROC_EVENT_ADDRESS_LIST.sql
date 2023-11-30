IF OBJECT_ID (N'dbo.PROC_EVENT_ADDRESS_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_EVENT_ADDRESS_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[PROC_EVENT_ADDRESS_LIST]
(
	@P_WEDD_S_DATE varchar(10) = '2022-01-01',
	@P_WEDD_E_DATE varchar(10) = '2099-12-31',
	@P_KEYWORD varchar(50) = '',
	@P_PAGE_SCALE int = 30,
	@P_PAGE_NUMBER int = 1,
	@P_TYPE int = 1
)
AS

declare 
	@T_YEAR int = YEAR(GETDATE()),
	@T_TOTAL int = 0

SELECT 
	*
	INTO #TEMP
FROM (
		select 
			a.member_id MEMBER_ID
			, isnull(d.uname, a.order_name) NAME
			, a.order_seq ORDER_SEQ
			, (select card_code from s2_card where card_seq = a.card_seq) as CARD_CODE
			, a.order_count ORDER_COUNT
			, a.last_total_price SETTLE_PRICE
			, convert(int, case when d.birth is not null then convert(varchar, @T_YEAR - convert(int,left(d.birth, 4))) else '' end) AGE
			, a.order_date ORDER_DATE
			, a.src_send_date SEND_DATE
			, (SELECT CODE_VALUE FROM MANAGE_CODE WHERE CODE_TYPE='status_seq' and code = a.status_seq) STATUS
			, convert(int,a.settle_status) SETTLE_STATUS
			, isnull((select top 1 '('+ZIP+')'+ADDR+' '+ADDR_DETAIL from delivery_info  where order_seq = a.order_seq and DELIVERY_SEQ = 1), '') ORDER_ADDR1
			, isnull((select top 1 '('+ZIP+')'+ADDR+' '+ADDR_DETAIL from delivery_info  where order_seq = a.order_seq and DELIVERY_SEQ = 2), '') ORDER_ADDR2
			, isnull((select top 1 '('+ZIP+')'+ADDR+' '+ADDR_DETAIL from delivery_info  where order_seq = a.order_seq and DELIVERY_SEQ = 3), '') ORDER_ADDR3
			, isnull((select top 1 '('+env_zip+')'+env_addr+' '+env_addr_detail env_addr from custom_order_plist where order_seq = a.order_seq and title='신랑봉투' and print_type = 'E' and print_count > 0 and isNotPrint = 0 and env_zip <> '' and env_addr <> '' ), '') ENV_ADDR1
			, isnull((select top 1 '('+env_zip+')'+env_addr+' '+env_addr_detail env_addr from custom_order_plist where order_seq = a.order_seq and title='신부봉투' and print_type = 'E' and print_count > 0 and isNotPrint = 0 and env_zip <> '' and env_addr <> '' ), '') ENV_ADDR2
			, isnull((select top 1 '('+env_zip+')'+env_addr+' '+env_addr_detail env_addr from custom_order_plist where order_seq = a.order_seq and title <> '신랑봉투' and title <> '신부봉투' and print_type = 'E' and print_count > 0 and isNotPrint = 0 and env_zip <> '' and env_addr <> '' ), '') ENV_ADDR3
			, case 
				when b.event_year is not null and len(b.event_year) = 4 then b.event_year 
					+ '-' + (case when len(b.event_month) < 2 then '0' + b.event_month else '' + b.event_month end)
					+ '-' + (case when len(b.event_Day) < 2 then '0' + b.event_Day else '' + b.event_Day end)
				else ''
			end EVENT_DATE
			, b.wedd_name WEDD_NAME
			, isnull(isnull(b.wedd_road_Addr, b.wedd_addr),'') WEDD_ADDR
			, isnull(c.name, '') THANKS_NAME
			, isnull(c.HPHONE, '') THANKS_HPHONE
			, isnull(('('+c.ZIP+')' + c.ADDR +' '+ c.ADDR_DETAIL ), '') THANKS_ADDR
		from custom_order a
			inner join custom_order_WeddInfo b
				on a.order_seq = b.order_seq
			left join EVENT_DELIVERY_INFO c
				on a.order_seq = c.ORDER_SEQ
			left join S2_UserInfo_TheCard d
				on a.member_id = d.uid
		where up_order_seq is null
			and IsThanksCard = '1'
			and status_seq > 0
			and a.sales_Gubun = 'SB'
			and (@P_KEYWORD is null or convert(varchar, a.order_seq) = @P_KEYWORD or isnull(d.uname, a.order_name) like '%'+@P_KEYWORD+'%')
	) A
WHERE (@P_WEDD_S_DATE IS NULL OR EVENT_DATE >= @P_WEDD_S_DATE)
	and (@P_WEDD_E_DATE IS NULL OR EVENT_DATE <= @P_WEDD_E_DATE)


SELECT @T_TOTAL = count(1) FROM #TEMP 

if @P_TYPE = 0
begin

	select 
		@T_TOTAL IDX,
		CONVERT(INT, ROW_NUMBER() OVER(ORDER BY order_seq asc)) AS ROW_NUM,
		*
	from #TEMP
	order by order_seq desc

end

else if @P_TYPE = 1
begin
	
	select
		@T_TOTAL - ROW_NUM + 1 AS IDX,
		*
	from (
			select 
				CONVERT(INT, ROW_NUMBER() OVER(ORDER BY order_seq desc)) AS ROW_NUM,
				*
			from #TEMP
		) A
	WHERE ROW_NUM > ((@P_PAGE_NUMBER - 1) * @P_PAGE_SCALE)
		AND		ROW_NUM <= (@P_PAGE_NUMBER * @P_PAGE_SCALE)
	order by order_seq desc

end

else if @P_TYPE = 2
begin
	
	select @T_TOTAL AS TOTAL_COUNT
end

GO
