IF OBJECT_ID (N'dbo.SP_SAMPLEBOOK_ORDER_SELECT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SAMPLEBOOK_ORDER_SELECT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SAMPLEBOOK_ORDER_SELECT]
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
-- EXEC SP_SAMPLEBOOK_ORDER_SELECT N'111', N'0', N'0', N'2019-08-12', N'2019-08-26', N'0', N'0', N'', N'0', N'0'


SET @B_Date = REPLACE(@B_Date, '-', '')
SET @E_Date = REPLACE(@E_Date, '-', '')



		SELECT A.order_seq AS CheckSeq
				, A.company_seq
				, B.company_name
				, A.order_type 
				, A.order_seq
				, CONVERT(CHAR(10), A.order_date, 23) AS order_date
				, A.order_name
				, A.member_id
				, CASE WHEN A.company_seq = 5001 THEN ISNULL(A.SampleBook_ID, '') 
						ELSE CASE WHEN ISNULL(I.SampleBook_ID, '') <> '' THEN CONVERT(CHAR(1), I.Cnt)+'개' ELSE '' END 
					END AS SampleBook_ID
				
				--, CASE WHEN I.Cnt = 1 THEN ISNULL(I.SampleBook_ID, ISNULL(A.SampleBook_ID, '')) ELSE CONVERT(CHAR(1), I.Cnt)+'개' END AS SampleBook_ID
				--, ISNULL(B.SampleBook_ID, ISNULL(A.SampleBook_ID, '')) AS SampleBook_ID
				, A.settle_price
				, A.status_seq

				, CASE WHEN A.status_seq IN ( '3', '5') THEN 'X' 
						WHEN A.status_seq IN ( '4', '10', '12', '13', '14', '15', '16' ) THEN '●' 
					ELSE '' END AS SettleStep --결제완료 단계

				, CASE WHEN A.status_seq IN ( '10', '12', '13', '14', '15', '16' ) THEN '●' 
					ELSE '' END AS ItemReadyStep  --제품준비 단계

				, CASE WHEN A.status_seq IN ('12', '13', '14', '15', '16' ) THEN '●' 
					ELSE '' END AS DeliveryCompleteStep  --발송완료 단계

				, CASE WHEN A.status_seq IN ('13', '14', '15', '16' ) THEN '●' 
					ELSE '' END AS CollectStep1  --회수신청 단계

				, CASE WHEN A.status_seq IN ('14', '15', '16') THEN '●'
					ELSE '' END AS CollectStep2  --회수진행 단계

				, CASE WHEN A.status_seq = '14' AND I.Status15 IS NOT NULL THEN I.Status15
						WHEN A.status_seq IN ('15', '16') THEN '●'
					ELSE '' END AS CollectStep3  --회수완료 단계

				, CASE WHEN A.status_seq IN ( '14', '15') AND I.Status16 IS NOT NULL THEN I.Status16
						WHEN A.status_seq IN ('16') THEN '●'
					ELSE '' END AS StockSuccessStep  --입고완료 단계





				--, CASE WHEN A.status_seq IN ('15', '16') THEN ISNULL(I.Status15, '●' )
				--	ELSE '' END AS CollectStep3  --회수완료 단계

				--, CASE WHEN A.status_seq IN ('16') THEN ISNULL(I.Status16, '●' )
				--	ELSE '' END AS StockSuccessStep  --입고완료 단계
		
				, (		--청첩장 주문번호
						SELECT MIN(order_seq) 
						FROM Custom_order CO
						WHERE CO.member_id = A.member_id 
							and CO.status_seq = '15'  --배송완료
							and CO.order_date > a.order_date 
							and CO.order_type in ('1', '6', '7')				
					) as card_order_seqno 

		FROM custom_etc_order AS A 
		JOIN Company AS B ON A.company_seq = B.company_seq 
		LEFT JOIN delivery_info AS C ON A.order_seq = C.ORDER_SEQ AND C.Delivery_Type = '141002' 
		LEFT JOIN ( 
					SELECT A.order_seq
						, COUNT(B.Card_seq) AS Cnt
						, MIN(B.SampleBook_ID) AS SampleBook_ID

						, CASE WHEN MIN(SampleBook_Status) = 14 AND 14 < MAX(SampleBook_Status) THEN '○' ELSE NULL END AS Status15
						, CASE WHEN MIN(SampleBook_Status) IN (14, 15) AND 15 < MAX(SampleBook_Status) THEN '○' ELSE NULL END AS Status16
						
						--, SUM(CASE WHEN ISNULL(B.SampleBook_Status, 0) = 14 THEN 1 ELSE 0 END) AS Status14
						--, SUM(CASE WHEN ISNULL(B.SampleBook_Status, 0) = 15 THEN 1 ELSE 0 END) AS Status15
						--, SUM(CASE WHEN ISNULL(B.SampleBook_Status, 0) = 16 THEN 1 ELSE 0 END) AS Status16
					FROM custom_etc_order A
					JOIN CUSTOM_ETC_ORDER_ITEM B ON A.order_seq = B.order_seq
					WHERE A.order_type = 'U'
					GROUP BY A.order_seq 
			

			) AS I ON A.order_seq = I.order_seq

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
		
			
			

			----주문경로
			AND A.pg_shopid = ANY(		
							SELECT CASE WHEN @JumunChannel = '0' THEN A.pg_shopid ELSE '' END 	
						UNION SELECT CASE WHEN @JumunChannel = '1' THEN 'bhands_c' ELSE '' END 	
						UNION SELECT CASE WHEN @JumunChannel = '2' THEN 'bhands_cm' ELSE '' END 
						UNION SELECT CASE WHEN @JumunChannel = '1' THEN 'pbhands' ELSE '' END 	
						UNION SELECT CASE WHEN @JumunChannel = '2' THEN 'pbhands_m' ELSE '' END 
					)	

			--AND ( CASE @JumunChannel WHEN '0' THEN '' ELSE A.pg_shopid END ) 
			--	= ( CASE @JumunChannel WHEN '0' THEN '' WHEN '1' THEN 'bhands_c' WHEN '2' THEN 'bhands_cm' ELSE '' END )


			--미회수 10일, 15일 경과된 주문건
			AND CASE WHEN @RecoveryStatus = '0' THEN '20010101' ELSE CONVERT(CHAR(8),A.delivery_date, 112) END 
				<= CONVERT(CHAR(8), DATEADD(DAY, CASE @RecoveryStatus WHEN '1' THEN -10 WHEN '2' THEN -15 ELSE 0 END, getdate()), 112)

		ORDER BY	
			( CASE @OrderType	--정렬방법
					WHEN '1' THEN CONVERT(CHAR(8),A.settle_date, 112)
					WHEN '2' THEN CONVERT(CHAR(8),A.prepare_date, 112) 
					WHEN '3' THEN CONVERT(CHAR(8),A.delivery_date, 112)
				ELSE A.order_seq END ) DESC
		

		

END


--

GO
