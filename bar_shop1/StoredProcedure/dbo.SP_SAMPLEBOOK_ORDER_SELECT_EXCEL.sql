IF OBJECT_ID (N'dbo.SP_SAMPLEBOOK_ORDER_SELECT_EXCEL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SAMPLEBOOK_ORDER_SELECT_EXCEL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SAMPLEBOOK_ORDER_SELECT_EXCEL]
	@SalesGubun VARCHAR(10)		--주문사이트
	, @RecoveryStatus CHAR(1)		--미회수 검색조건( 0:전체, 1:10일, 2:15일)
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

set nocount on



--Delivery_Status 
--etc_status_seq	0	주문중
--etc_status_seq	1	주문완료
--etc_status_seq	3	주문취소
--etc_status_seq	4	결제완료
--etc_status_seq	5	결제취소
--etc_status_seq	10	제품준비중
--etc_status_seq	12	발송완료

--etc_status_seq	13	회수신청
--etc_status_seq	14	회수진행
--etc_status_seq	15	회수완료
--etc_status_seq	16	입고완료

-- EXEC SP_SAMPLEBOOK_ORDER_SELECT N'010', N'0', N'3', N'2019-01-01', N'2019-07-09', N'12', N'0', N'', N'0', N'0'

SET @B_Date = REPLACE(@B_Date, '-', '')
SET @E_Date = REPLACE(@E_Date, '-', '')


SELECT A.order_seq
	, (		--청첩장 주문번호
			SELECT MIN(order_seq) 
			FROM Custom_order CO
			WHERE CO.member_id = A.member_id 
				and CO.status_seq = '15'  --배송완료
				and CO.order_date > a.order_date 
				and CO.order_type in ('1', '6', '7')				
		) as Card_Order_seq
INTO #Order_Temp
FROM custom_etc_order AS A 
WHERE order_type = 'U'
	AND A.status_seq >= 1 
		
	--사이트 검색
	AND A.sales_gubun = ANY(		
					SELECT CASE WHEN RIGHT(LEFT(@SalesGubun, 1), 1) = '1' THEN A.sales_gubun ELSE '' END 	
			UNION SELECT CASE WHEN RIGHT(LEFT(@SalesGubun, 2), 1) = '1' THEN 'SB' ELSE '' END 	
			UNION SELECT CASE WHEN RIGHT(LEFT(@SalesGubun, 3), 1) = '1' THEN 'SS' ELSE '' END 
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


	--주문경로
	AND A.pg_shopid = ANY(		
					SELECT CASE WHEN @JumunChannel = '0' THEN A.pg_shopid ELSE '' END 	
				UNION SELECT CASE WHEN @JumunChannel = '1' THEN 'bhands_c' ELSE '' END 	
				UNION SELECT CASE WHEN @JumunChannel = '2' THEN 'bhands_cm' ELSE '' END 
				UNION SELECT CASE WHEN @JumunChannel = '1' THEN 'pbhands' ELSE '' END 	
				UNION SELECT CASE WHEN @JumunChannel = '2' THEN 'pbhands_m' ELSE '' END 
			)	


	--미회수 10일, 15일 경과된 주문건
	AND CASE WHEN @RecoveryStatus = '0' THEN '20010101' ELSE CONVERT(CHAR(8),A.delivery_date, 112) END 
		<= CONVERT(CHAR(8), DATEADD(DAY, CASE @RecoveryStatus WHEN '1' THEN -10 WHEN '2' THEN -15 ELSE 0 END, getdate()), 112)





		SELECT ROW_NUMBER() OVER(ORDER BY A.ORDER_SEQ ) AS ROW_NUM
				--, A.order_seq AS CheckSeq
				, A.company_seq
				, B.company_name
				, A.order_type 
				, A.order_seq
				, CASE WHEN A.company_seq = 5001 THEN ISNULL(A.SampleBook_ID, '') 
						ELSE CASE WHEN ISNULL(I.SampleBook_ID, '') <> '' THEN CONVERT(CHAR(1), I.Cnt)+'개' ELSE '' END 
					END AS SampleBook_ID
				, CONVERT(CHAR(10), A.order_date, 23) AS order_date
				, CONVERT(CHAR(10), A.settle_date, 23) AS settle_date
				, CONVERT(CHAR(10), A.delivery_date, 23) AS delivery_date
				, CONVERT(CHAR(10), A.settle_Cancel_Date, 23) AS settle_Cancel_Date
				, CONVERT(CHAR(10), A.Return_Limit_Date, 23) AS Return_Limit_Date
				, CONVERT(CHAR(10), A.Return_Request_Date, 23) AS Return_Request_Date
				, CONVERT(CHAR(10), A.Return_Proceeding_Date, 23) AS Return_Proceeding_Date
				, CONVERT(CHAR(10), A.Return_Complete_Date, 23) AS Return_Complete_Date
				, CONVERT(CHAR(10), A.Stock_Date, 23) AS Stock_Date
				, A.status_seq
				, A.delivery_com
				, A.delivery_code
				, A.delivery_price
				, A.settle_price

				, O.Card_Order_seq as card_order_seqno 
				, MC.code_value AS card_sales_site
				, SC.Card_Code AS Card_Code2
				, C1.order_count AS card_order_count
				, C1.settle_price AS card_settle_price
				, C1.order_date AS card_order_date --, CONVERT(CHAR(10), C1.order_date, 23) AS card_order_date
				
				--, '' AS card_sales_site
				--, '' AS Card_Code2
				--, '' AS card_order_count    --C.order_count as card_order_count
				--, '' AS card_settle_price	--C.settle_price as card_settle_price
				--, '' AS card_order_date		--c.order_date as card_order_date

				, A.order_name

				, A.member_id
				, (SELECT IP FROM S4_LoginIpInfo WHERE seq = (SELECT MIN(seq) FROM S4_LoginIpInfo WHERE uid = A.member_id AND IP is not null)) AS IP
				, A.order_email
				, A.order_phone
				, A.order_hphone
				, A.recv_name
				, A.recv_phone
				, A.recv_hphone
				, A.recv_zip
				, A.recv_address
				, A.recv_address_detail
				
				, C.name AS return_name
				, C.phone AS return_phone
				, C.hphone AS return_hphone
				, C.zip as return_zip
				, C.addr AS return_addr
				, C.addr_detail as return_addr_detail

				, A.coupon_no
							   
		FROM #Order_Temp O
		JOIN custom_etc_order AS A ON O.order_seq = A.order_seq
		JOIN Company AS B ON A.company_seq = B.company_seq 
		LEFT JOIN custom_order AS C1 ON O.Card_Order_seq = C1.order_seq
		LEFT JOIN S2_card SC ON SC.Card_Seq = C1.card_seq
		LEFT JOIN manage_code MC ON MC.code_type = 'sales_gubun' AND MC.code = C1.sales_Gubun

		LEFT JOIN delivery_info AS C ON O.order_seq = C.ORDER_SEQ AND C.Delivery_Type = '141002' 
		LEFT JOIN ( 
					SELECT A.order_seq
						, COUNT(B.Card_seq) AS Cnt
						, MIN(B.SampleBook_ID) AS SampleBook_ID
					FROM custom_etc_order A
					JOIN CUSTOM_ETC_ORDER_ITEM B ON A.order_seq = B.order_seq
					WHERE A.order_type = 'U'
					GROUP BY A.order_seq 
			) AS I ON O.order_seq = I.order_seq
				
		WHERE 1=1

		ORDER BY O.order_seq

END

GO
