IF OBJECT_ID (N'dbo.SP_CONCIERGE_ORDER_SELECT_EXCEL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CONCIERGE_ORDER_SELECT_EXCEL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CONCIERGE_ORDER_SELECT_EXCEL]
	@SalesGubun VARCHAR(10)		--주문사이트
	, @DateType CHAR(1)		--검색일 타입
	, @B_Date VARCHAR(10)		--검색시작일자
	, @E_Date VARCHAR(10)		--검색마직막일자
	, @JumunStatus  VARCHAR(2)		--주문상태값
	, @SearchType CHAR(1)			--키워드타입
	, @SearchValue VARCHAR(30)		--키워드검색값
	, @OrderType  CHAR(1)			--정렬방법
	, @JumunChannel  CHAR(1)		--주문경로 PC, 모바일

AS
BEGIN
-- EXEC SP_CONCIERGE_ORDER_SELECT_EXCEL N'11', N'0', N'2020-11-01', N'2020-11-15', N'0', N'0', N'', N'0', N'0'

SET @B_Date = REPLACE(@B_Date, '-', '')
SET @E_Date = REPLACE(@E_Date, '-', '')

SELECT  A.company_seq
		, B.company_name
		, A.order_seq
		, A.order_date
		, A.settle_date
		, A.DELIVERY_DATE
		, A.settle_cancel_date
		, A.status_seq
		, A.settle_price
		, A.order_name
		, A.member_id
		, A.order_phone
		, A.order_hphone
		, A.order_email
		, A.recv_name
		, A.recv_phone
		, A.recv_hphone
		, A.recv_zip
		, A.recv_address
FROM custom_etc_order AS A 
JOIN Company AS B ON A.company_seq = B.company_seq 
WHERE order_type = '3'
AND A.status_seq >= 1 	

--사이트 검색
			AND A.sales_gubun = ANY(		
							SELECT CASE WHEN RIGHT(LEFT(@SalesGubun, 1), 1) = '1' THEN A.sales_gubun ELSE '' END 	
					UNION SELECT CASE WHEN RIGHT(LEFT(@SalesGubun, 2), 1) = '1' THEN 'SS' ELSE '' END 
				)	

--검색타입에 맞는 기간검색
AND CASE @DateType 
WHEN '0' THEN CONVERT(CHAR(8), A.order_date, 112)
WHEN '1' THEN CONVERT(CHAR(8), A.settle_date, 112)
WHEN '2' THEN CONVERT(CHAR(8), A.prepare_date, 112)
WHEN '3' THEN CONVERT(CHAR(8), A.delivery_date, 112)
ELSE CONVERT(CHAR(8), A.order_date, 112) END  BETWEEN @B_Date AND @E_Date

--주문상태값 검색
AND CASE WHEN @JumunStatus = '0' THEN '0' ELSE A.status_Seq END = @JumunStatus

--키워드 검색
AND CASE WHEN @SearchType = '0' AND ISNULL(LTRIM(RTRIM(@SearchValue)), '') <> '' THEN A.order_seq ELSE '' END 
= CASE WHEN @SearchType = '0' AND ISNULL(LTRIM(RTRIM(@SearchValue)), '') <> ''  THEN @SearchValue ELSE '' END 		
AND (
		CASE @SearchType 
			WHEN '1' THEN ISNULL(A.order_name, '')		-- 주문자이름
			WHEN '2' THEN ISNULL(A.member_id, '')		-- 회원아이디
			WHEN '3' THEN ISNULL(REPLACE(A.order_hphone, '-', ''), '')	-- 휴대전화번호
			WHEN '4' THEN ISNULL(A.coupon_no, '')			-- 쿠폰번호
			WHEN '5' THEN ISNULL(A.SampleBook_ID, '')	-- 샘플북일련번호
		ELSE ISNULL(LTRIM(RTRIM(@SearchValue)), '') END LIKE '%'+ISNULL(LTRIM(RTRIM(@SearchValue)), '')+'%'  -- 주문번호

		OR A.order_seq IN (
				SELECT DISTINCT A.order_seq 
				FROM CUSTOM_ETC_ORDER_ITEM A
				WHERE CASE WHEN @SearchType = '5' THEN ISNULL(A.SampleBook_ID, '') ELSE NULL END LIKE '%'+ISNULL(LTRIM(RTRIM(@SearchValue)), '')+'%' 
				) 					
)			

----주문경로
AND A.pg_shopid = ANY(		
	SELECT CASE WHEN @JumunChannel = '0' THEN A.pg_shopid ELSE '' END 	
	UNION SELECT CASE WHEN @JumunChannel = '1' THEN 'pbhands' ELSE '' END 	
	UNION SELECT CASE WHEN @JumunChannel = '2' THEN 'pbhands_m' ELSE '' END 
)	

ORDER BY	
( 
	CASE @OrderType	--정렬방법
	WHEN '1' THEN CONVERT(CHAR(8),A.settle_date, 112)
	WHEN '2' THEN CONVERT(CHAR(8),A.prepare_date, 112) 
	WHEN '3' THEN CONVERT(CHAR(8),A.delivery_date, 112)
	ELSE A.order_seq END 
) DESC

END

GO
