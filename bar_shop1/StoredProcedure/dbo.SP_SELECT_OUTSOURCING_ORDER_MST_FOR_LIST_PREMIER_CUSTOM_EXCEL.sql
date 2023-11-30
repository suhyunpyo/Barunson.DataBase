IF OBJECT_ID (N'dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_PREMIER_CUSTOM_EXCEL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_PREMIER_CUSTOM_EXCEL
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
/*

EXEC SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_PREMIER_CUSTOM_EXCEL '', '', '', '', '', '', '', '2016-12-20', '2017-11-27','','','14690|14336'
13350,13349,13348
*/

CREATE PROCEDURE [dbo].[SP_SELECT_OUTSOURCING_ORDER_MST_FOR_LIST_PREMIER_CUSTOM_EXCEL]
    @P_COMPANY_TYPE_CODE AS VARCHAR(200)
,   @P_SITE_TYPE_CODE AS VARCHAR(6)
,   @P_ORDER_TYPE_CODE AS VARCHAR(6)
,   @P_ORDER_SUB_TYPE_CODE AS VARCHAR(6)
,   @P_ERP_PART_TYPE_CODE AS VARCHAR(6)
,   @P_SEARCH_TYPE_CODE AS VARCHAR(200)
,   @P_SEARCH_VALUE AS VARCHAR(200)
,   @P_START_DATE AS VARCHAR(20)
,   @P_END_DATE AS VARCHAR(20)
,   @P_ORDER_STATUS_CODE AS VARCHAR(6)
,   @P_ORDER_DELIVERY_CODE AS VARCHAR(6) = ''
,   @P_EXCEL_ORDER_MST_SEQS AS VARCHAR(2000) = ''
AS
BEGIN


	IF @P_EXCEL_ORDER_MST_SEQS <> '' 
		BEGIN

			SELECT  ROW_NUMBER() OVER(ORDER BY A.REG_DATE ASC) AS ROW_NUM
				--,   A.* 
				, A.COMPANY_TYPE_CODE    as COMPANY_TYPE_CODE  --업체코드
				, A.COMPANY_TYPE_NAME    as COMPANY_TYPE_NAME  --업체명
				, SC.CARD_NAME           as CARD_NAME  --상품명
				, B.ORDER_SEQ            as ORDER_SEQ  --주문번호
				, CASE WHEN B.up_order_seq IS NULL THEN '정상' ELSE '추가' END  AS ORDER_GUBUN    --정상/추가
				, B.order_date           as ORDER_DATE  --주문일자
				, B.settle_date          as SETTLE_DATE  --결제일자
				, A.RECEIPT_DATE           --업체접수일
				, CONVERT(VARCHAR(10),A.EXPECT_DATE,121) AS EXPECT_DATE   --예상발송일
				, (SELECT STUFF((SELECT '|' + D.ZIP +'^' + D.ADDR+'^' + D.ADDR_DETAIL+'^' + D.DELIVERY_COM+'^' + D.DELIVERY_CODE_NUM+'^' + ISNULL(CONVERT(VARCHAR(10),D.DELIVERY_DATE, 121),'') + '^' + CONVERT(VARCHAR, D.DELIVERY_SEQ)
					  FROM DELIVERY_INFO D
					  WHERE (D.ORDER_SEQ = B.ORDER_SEQ) ORDER BY D.DELIVERY_SEQ --A.ORDER_SEQ)
					  FOR XML PATH ('')),1,1,'')
				  ) AS ADDR_SET            --배송정보에대한 STRING (우편번호, 주소, 상세주소, 택배사, 송장번호, 배송일자, SEQ )
				, CASE WHEN B.settle_method = '1' THEN '계좌이체'
				       WHEN B.settle_method = '3' THEN '무통장'
					   WHEN B.settle_method = '8' THEN '카카오페이'
					   ELSE '기타결제'
					   END AS SETTLE_METHOD --결제방법
				, B.settle_price          as SETTLE_PRICE --결제금액
				, CASE WHEN B.settle_status = '0' THEN '결제이전'
				       WHEN B.settle_status = '1' THEN '입금대기'
					   WHEN B.settle_status = '2' THEN '결제완료'
					   ELSE '결제취소'
					   END AS SETTLE_STATUS --결제방법

				, CASE WHEN B.order_type IN ('1','6','7') THEN '청첩장'
				       WHEN B.order_type IN ('2','3') THEN '감사장/초대장'
					   ELSE '기타카드'
					   END AS ORDER_TYPE --결제방법
				, B.order_count           as ORDER_COUNT --주문수량
				, SC.CardSet_Price        as CARDSET_PRICE --카드단가
				, B.order_name            as ORDER_NAME --주문자
				, B.order_phone + '/' + B.order_hphone  AS ORDER_PHONE --연락처(전화번호/휴대폰)
				, B.member_id             as MEMBER_ID --고객아이디
				, COW.wedd_date           as WEDD_DATE --웨딩일자
				, B.order_email           as ORDER_EMAIL --이메일
				,case when B.isinpaper='0' then 'X' 
					when B.isinpaper='1' then '유료'
					when B.isinpaper='2' then '무료' end ISINPAPER
				,case when B.ishandmade='0' then 'X' 
					when B.ishandmade='1' then '유료'
					when B.ishandmade='2' then '무료' end ISHANDMADE
				,case when B.isenvinsert='0' then 'X' 
					when B.isenvinsert='1' then '유료'
					when B.isenvinsert='2' then '무료' end ISENVINSERT
				, B.jebon_price          as JEBON_PRICE  --제본가격
				, B.LiningJaebon_price   as LININGJAEBON_PRICE  --라이닝제본가격
				, B.label_price          as LABEL_PRICE  --라벨가격
				, (SELECT STUFF((SELECT '|' + COI.ITEM_TYPE +'^'+ S2C.CARD_NAME +'^'+ S2C.Card_Div +'^'+ CONVERT(VARCHAR, COI.item_count)+'^' + CONVERT(VARCHAR,(COI.item_sale_price * COI.item_count ))
					  FROM custom_order_item COI
					   LEFT JOIN S2_CARD S2C ON

						COI.card_seq = S2C.Card_Seq
					  WHERE COI.ORDER_SEQ = B.ORDER_SEQ AND COI.item_type IN ('F') --A.ORDER_SEQ)
					  FOR XML PATH ('')),1,1,'')				
				 ) AS  PLIST_SET
			FROM    VW_OUTSOURCING_ORDER_MST AS A
				LEFT OUTER JOIN CUSTOM_ORDER AS B
					ON A.ORDER_SEQ = B.ORDER_SEQ
				LEFT OUTER JOIN custom_order_WeddInfo AS COW
					ON B.order_seq = COW.order_seq
				LEFT OUTER JOIN S2_Card AS SC
					ON B.CARD_SEQ = SC.CARD_SEQ
			WHERE   1 = 1
			AND     A.REG_DATE >= @P_START_DATE + ' 00:00:00'
			AND     A.REG_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, CAST(@P_END_DATE AS DATETIME)), 120) + ' 00:00:00'
    
			AND		A.COMPANY_TYPE_CODE LIKE '10701%'

			AND     A.COMPANY_TYPE_CODE LIKE (CASE WHEN @P_COMPANY_TYPE_CODE <> '' THEN @P_COMPANY_TYPE_CODE ELSE '%' END)

			AND     (
						CASE WHEN @P_SITE_TYPE_CODE = '' THEN '' ELSE A.SITE_TYPE_CODE END
					)
						=
					(
						CASE WHEN @P_SITE_TYPE_CODE = '' THEN '' ELSE @P_SITE_TYPE_CODE END
					)

			AND     (
						CASE WHEN @P_ORDER_TYPE_CODE = '' THEN '' ELSE A.ORDER_TYPE_CODE END
					)
						=
					(
						CASE WHEN @P_ORDER_TYPE_CODE = '' THEN '' ELSE @P_ORDER_TYPE_CODE END
					)

			AND     (
						CASE WHEN @P_ORDER_SUB_TYPE_CODE = '' THEN '' ELSE A.ORDER_SUB_TYPE_CODE END
					)
						=
					(
						CASE WHEN @P_ORDER_SUB_TYPE_CODE = '' THEN '' ELSE @P_ORDER_SUB_TYPE_CODE END
					)


			AND     (
						CASE WHEN @P_ERP_PART_TYPE_CODE = '' THEN '' ELSE A.ERP_PART_TYPE_CODE END
					)
						=
					(
						CASE WHEN @P_ERP_PART_TYPE_CODE = '' THEN '' ELSE @P_ERP_PART_TYPE_CODE END
				   )

			AND     (
						CASE    
							  WHEN @P_SEARCH_TYPE_CODE = '1' AND @P_SEARCH_VALUE <> '' THEN CONVERT(VARCHAR(50), ISNULL(A.ORDER_SEQ, ''))
								WHEN @P_SEARCH_TYPE_CODE = '2' AND @P_SEARCH_VALUE <> '' THEN A.ORDER_NAME
								WHEN @P_SEARCH_TYPE_CODE = '3' AND @P_SEARCH_VALUE <> '' THEN A.CARD_CODE
								WHEN @P_SEARCH_TYPE_CODE = '4' AND @P_SEARCH_VALUE <> '' THEN A.REQUESTOR_NAME
								ELSE ''
						END
					) 
						= 
					(
						CASE    
								WHEN @P_SEARCH_TYPE_CODE IN ('1','2','3','4') AND @P_SEARCH_VALUE <> '' THEN CONVERT(VARCHAR(50), @P_SEARCH_VALUE)
								ELSE ''
						END
					)
			AND     (
						CASE WHEN @P_ORDER_STATUS_CODE = '' THEN '' ELSE A.ORDER_STATUS_CODE END
					)
						=
					(
						CASE WHEN @P_ORDER_STATUS_CODE = '' THEN '' ELSE @P_ORDER_STATUS_CODE END
					)

			AND ( 
					ISNULL(@P_EXCEL_ORDER_MST_SEQS, '') = '' OR  OUTSOURCING_ORDER_SEQ IN ( SELECT * FROM [dbo].[ufn_SplitTable] (@P_EXCEL_ORDER_MST_SEQS, '|') )
				)

		 

			--AND     (
			--            CASE WHEN @P_ORDER_DELIVERY_CODE = '' THEN '' 
						--CASE WHEN @P_ORDER_DELIVERY_CODE = '1'THEN  ELSE D.DELIVERY_COUNT END
			--        )
			--            =                 --D.DELIVERY_COUNT = @P_ORDER_STATUS_CODE
			--        (
			--            CASE WHEN @P_ORDER_DELIVERY_CODE = '' THEN '' ELSE @P_ORDER_STATUS_CODE END
			--        )
			ORDER BY A.REG_DATE DESC



		END
	
	
END
GO
