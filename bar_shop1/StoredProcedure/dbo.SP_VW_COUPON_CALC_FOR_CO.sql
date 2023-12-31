IF OBJECT_ID (N'dbo.SP_VW_COUPON_CALC_FOR_CO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_VW_COUPON_CALC_FOR_CO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_VW_COUPON_CALC_FOR_CO 's4guest', 2718274 

*/
CREATE PROCEDURE [dbo].[SP_VW_COUPON_CALC_FOR_CO]
    
    @P_UID			AS VARCHAR(50)
,	@P_ORDER_SEQ	AS INT

AS
BEGIN
    
	
	
	SELECT	ORDER_SEQ			
		,	UP_ORDER_SEQ			
		,	UID					
		,	COMPANY_SEQ			
		,	SALES_GUBUN			
		,	ORDER_TYPE		
		,	COUPON_ISSUE_SEQ
		,	COUPON_DETAIL_SEQ
		,	COUPON_NAME			
		,	COUPON_TYPE_CODE		
		,	COUPON_SERVICE_TYPE_CODE
		,	COUPON_SERVICE_TYPE_NAME
		,	DUP_COUPON_ALLOW_YN	
		,	AD_COUPON_ALLOW_YN	
		,	ADD_COUPON_ALLOW_YN	
		,	CARD_SEQ				
		,	ORDER_COUNT			
		,	LAST_TOTAL_PRICE		
		,	USE_DEVICE			
		,	DISCOUNT_FIXED_RATE_TYPE
		,	DISCOUNT_VALUE
		,	DISCOUNT_MAX_AMT
		,	ISNULL(CAST(ORDER_PRICE_TEMP								AS INT), 0)		AS ORDER_PRICE				
		,	ISNULL(CAST(FTICKET_PRICE_TEMP								AS INT), 0)		AS FTICKET_PRICE			
		,	ISNULL(CAST(GUESTBOOK_PRICE_TEMP							AS INT), 0)		AS GUESTBOOK_PRICE			
		,	ISNULL(CAST(LINING_ENV_PRICE_TEMP							AS INT), 0)		AS LINING_ENV_PRICE		
		,	ISNULL(CAST(PRINT_PRICE_TEMP								AS INT), 0)		AS PRINT_PRICE				
		,	ISNULL(CAST(EMBO_PRICE_TEMP									AS INT), 0)		AS EMBO_PRICE				
		,	ISNULL(CAST(JEBON_PRICE_TEMP								AS INT), 0)		AS JEBON_PRICE				
		,	ISNULL(CAST(ENVINSERT_PRICE_TEMP							AS INT), 0)		AS ENVINSERT_PRICE			
		,	ISNULL(CAST(EXPRESS_SHIPPING_PRICE_TEMP						AS INT), 0)		AS EXPRESS_SHIPPING_PRICE	
		,	ISNULL(CAST(DELIVERY_PRICE_TEMP								AS INT), 0)		AS DELIVERY_PRICE			

		,	ISNULL(CAST(DISCOUNT_TARGET_ORDER_PRICE_TEMP				AS INT), 0)		AS DISCOUNT_TARGET_ORDER_PRICE			
		,	ISNULL(CAST(DISCOUNT_TARGET_FTICKET_PRICE_TEMP				AS INT), 0)		AS DISCOUNT_TARGET_FTICKET_PRICE			
		,	ISNULL(CAST(DISCOUNT_TARGET_GUESTBOOK_PRICE_TEMP			AS INT), 0)		AS DISCOUNT_TARGET_GUESTBOOK_PRICE		
		,	ISNULL(CAST(DISCOUNT_TARGET_LINING_ENV_PRICE_TEMP			AS INT), 0)		AS DISCOUNT_TARGET_LINING_ENV_PRICE		
		,	ISNULL(CAST(DISCOUNT_TARGET_PRINT_PRICE_TEMP				AS INT), 0)		AS DISCOUNT_TARGET_PRINT_PRICE			
		,	ISNULL(CAST(DISCOUNT_TARGET_EMBO_PRICE_TEMP					AS INT), 0)		AS DISCOUNT_TARGET_EMBO_PRICE				
		,	ISNULL(CAST(DISCOUNT_TARGET_JEBON_PRICE_TEMP				AS INT), 0)		AS DISCOUNT_TARGET_JEBON_PRICE			
		,	ISNULL(CAST(DISCOUNT_TARGET_ENVINSERT_PRICE_TEMP			AS INT), 0)		AS DISCOUNT_TARGET_ENVINSERT_PRICE		
		,	ISNULL(CAST(DISCOUNT_TARGET_DELIVERY_PRICE_TEMP				AS INT), 0)		AS DISCOUNT_TARGET_DELIVERY_PRICE			
		,	ISNULL(CAST(DISCOUNT_TARGET_EXPRESS_SHIPPING_PRICE_TEMP		AS INT), 0)		AS DISCOUNT_TARGET_EXPRESS_SHIPPING_PRICE

		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_ORDER_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_ORDER_PRICE_TEMP				END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_ORDER_PRICE
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_FTICKET_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_FTICKET_PRICE_TEMP			END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_FTICKET_PRICE			
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_GUESTBOOK_PRICE_TEMP		> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_GUESTBOOK_PRICE_TEMP			END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_GUESTBOOK_PRICE			
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_LINING_ENV_PRICE_TEMP		> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_LINING_ENV_PRICE_TEMP		END AS NUMERIC(29, 6)), 0)		AS DISCOUNT_LINING_ENV_PRICE			
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_PRINT_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_PRINT_PRICE_TEMP				END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_PRINT_PRICE				
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_EMBO_PRICE_TEMP				> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_EMBO_PRICE_TEMP				END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_EMBO_PRICE				
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_JEBON_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_JEBON_PRICE_TEMP				END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_JEBON_PRICE				
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_ENVINSERT_PRICE_TEMP		> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_ENVINSERT_PRICE_TEMP			END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_ENVINSERT_PRICE			
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_DELIVERY_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_DELIVERY_PRICE_TEMP			END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_DELIVERY_PRICE			
		,	ISNULL(CAST(CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_EXPRESS_SHIPPING_PRICE_TEMP	> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_EXPRESS_SHIPPING_PRICE_TEMP	END	AS NUMERIC(29, 6)), 0)		AS DISCOUNT_EXPRESS_SHIPPING_PRICE	

		,	ISNULL
			(
					CAST
					(
							(
									CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_ORDER_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_ORDER_PRICE_TEMP				END 
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_FTICKET_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_FTICKET_PRICE_TEMP			END 			
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_GUESTBOOK_PRICE_TEMP		> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_GUESTBOOK_PRICE_TEMP			END 			
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_LINING_ENV_PRICE_TEMP		> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_LINING_ENV_PRICE_TEMP		END 			
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_PRINT_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_PRINT_PRICE_TEMP				END 				
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_EMBO_PRICE_TEMP				> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_EMBO_PRICE_TEMP				END 				
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_JEBON_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_JEBON_PRICE_TEMP				END 				
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_ENVINSERT_PRICE_TEMP		> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_ENVINSERT_PRICE_TEMP			END 			
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_DELIVERY_PRICE_TEMP			> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_DELIVERY_PRICE_TEMP			END 			
								+	CASE WHEN DISCOUNT_MAX_AMT > 0 AND DISCOUNT_EXPRESS_SHIPPING_PRICE_TEMP	> DISCOUNT_MAX_AMT THEN DISCOUNT_MAX_AMT ELSE DISCOUNT_EXPRESS_SHIPPING_PRICE_TEMP	END 
							) AS NUMERIC(29, 6)
					)
				, 0
			) AS DISCOUNT_TOTAL_PRICE	

	FROM	(

				SELECT	CO.ORDER_SEQ								AS ORDER_SEQ			
					,	MAX(CO.UP_ORDER_SEQ					)		AS UP_ORDER_SEQ			
					,	MAX(CI.UID							)		AS UID					
					,	MAX(CO.COMPANY_SEQ					)		AS COMPANY_SEQ			
					,	MAX(CO.SALES_GUBUN					)		AS SALES_GUBUN			
					,	MAX(CO.ORDER_TYPE					)		AS ORDER_TYPE		
					,	MAX(CI.COUPON_ISSUE_SEQ				)		AS COUPON_ISSUE_SEQ
					,	CI.COUPON_DETAIL_SEQ						AS COUPON_DETAIL_SEQ
					,	MAX(CM.COUPON_NAME					)		AS COUPON_NAME			
					,	MAX(CM.COUPON_TYPE_CODE				)		AS COUPON_TYPE_CODE		
					,	MIN(CA_SERVICE.CMMN_CODE			)		AS COUPON_SERVICE_TYPE_CODE
					,	MAX
						(
							CASE 
								WHEN CO.ORDER_TYPE IN (1, 6, 7) AND CC_SERVICE.CMMN_CODE = '131001' THEN '청첩장'
								WHEN CO.ORDER_TYPE IN (2)		AND CC_SERVICE.CMMN_CODE = '131002' THEN '감사장'
								WHEN CO.ORDER_TYPE IN (3)		AND CC_SERVICE.CMMN_CODE = '131003' THEN '초대장'
								ELSE CC_SERVICE.DTL_NAME
							END
						)											AS COUPON_SERVICE_TYPE_NAME
					,	MAX(CM.DUP_COUPON_ALLOW_YN			)		AS DUP_COUPON_ALLOW_YN	
					,	MAX(CM.AD_COUPON_ALLOW_YN			)		AS AD_COUPON_ALLOW_YN	
					,	MAX(CM.ADD_COUPON_ALLOW_YN			)		AS ADD_COUPON_ALLOW_YN	
					,	MAX(CO.CARD_SEQ						)		AS CARD_SEQ				
					,	MAX(CO.ORDER_COUNT					)		AS ORDER_COUNT			
					,	MAX(CO.LAST_TOTAL_PRICE				)		AS LAST_TOTAL_PRICE		
					,	MAX(CM.USE_DEVICE					)		AS USE_DEVICE			
				
					,	MAX(CM.DISCOUNT_FIXED_RATE_TYPE		)		AS DISCOUNT_FIXED_RATE_TYPE
					,	MAX(CM.DISCOUNT_VALUE				)		AS DISCOUNT_VALUE
					,	MAX(CM.DISCOUNT_MAX_AMT				)		AS DISCOUNT_MAX_AMT

					,	MAX(CO.ORDER_PRICE					)		AS ORDER_PRICE_TEMP								-- 카드 금액(청첩장, 감사장, 초대장)
											
					,	MAX(CO.FTICKET_PRICE				)		AS FTICKET_PRICE_TEMP							-- 식권
					,	MAX(CO.GUESTBOOK_PRICE				)		AS GUESTBOOK_PRICE_TEMP							-- 방명록
					,	MAX(ISNULL(COI.ITEM_SALE_PRICE, 0)	)		AS LINING_ENV_PRICE_TEMP							-- 유로 라이닝봉투
											
					,	MAX(CO.PRINT_PRICE					)		AS PRINT_PRICE_TEMP								-- 칼라인쇄
					,	MAX(CO.EMBO_PRICE					)		AS EMBO_PRICE_TEMP								-- 엠보인쇄
					,	MAX(CO.JEBON_PRICE					)		AS JEBON_PRICE_TEMP								-- 제본비 (속지 접착, 부속품 부착, 리본 부착)
					,	MAX(CO.ENVINSERT_PRICE				)		AS ENVINSERT_PRICE_TEMP							-- 봉투 제본비 (봉투삽입)
					,	MAX(
								CASE 
									WHEN CO.ISSPECIAL = 1 
									THEN	(CASE WHEN ETC_PRICE > 35000 THEN 35000 ELSE ETC_PRICE END)
									ELSE 0 
								END
							)										AS EXPRESS_SHIPPING_PRICE_TEMP					-- 초특급 배송비 (35,000)
					,	MAX(CO.DELIVERY_PRICE				)		AS DELIVERY_PRICE_TEMP							-- 배송비

					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE IN ('133001', '133002', '133003') THEN CO.ORDER_PRICE ELSE 0 END)		AS DISCOUNT_TARGET_ORDER_PRICE_TEMP
					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE = '134001' THEN CO.FTICKET_PRICE ELSE 0 END)								AS DISCOUNT_TARGET_FTICKET_PRICE_TEMP
					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE = '134002' THEN CO.GUESTBOOK_PRICE ELSE 0 END)							AS DISCOUNT_TARGET_GUESTBOOK_PRICE_TEMP
					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE = '134003' THEN ISNULL(CAST(COI.ITEM_SALE_PRICE AS INT), 0) ELSE 0 END)	AS DISCOUNT_TARGET_LINING_ENV_PRICE_TEMP
					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE = '135001' THEN CO.PRINT_PRICE ELSE 0 END)								AS DISCOUNT_TARGET_PRINT_PRICE_TEMP
					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE = '135002' THEN CO.EMBO_PRICE ELSE 0 END)								AS DISCOUNT_TARGET_EMBO_PRICE_TEMP
					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE = '135003' THEN CO.JEBON_PRICE ELSE 0 END)								AS DISCOUNT_TARGET_JEBON_PRICE_TEMP
					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE = '135004' THEN CO.ENVINSERT_PRICE ELSE 0 END)							AS DISCOUNT_TARGET_ENVINSERT_PRICE_TEMP
					,	MAX(CASE WHEN CA_SERVICE.CMMN_CODE = '135006' THEN CO.DELIVERY_PRICE ELSE 0 END)							AS DISCOUNT_TARGET_DELIVERY_PRICE_TEMP
					,	MAX(
								CASE 
										WHEN CA_SERVICE.CMMN_CODE = '135007' AND CO.ISSPECIAL = 1  
										THEN CASE WHEN ETC_PRICE > 35000 THEN 35000 ELSE ETC_PRICE END
										ELSE 0 
								END
						)																										AS DISCOUNT_TARGET_EXPRESS_SHIPPING_PRICE_TEMP

					,	MAX(CASE 
										WHEN CA_SERVICE.CMMN_CODE IN ('133001', '133002', '133003')
										THEN
												CASE 
														WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN CO.ORDER_PRICE - CM.DISCOUNT_VALUE <= 0 THEN CO.ORDER_PRICE ELSE CM.DISCOUNT_VALUE END
														ELSE CO.ORDER_PRICE * (1.0 * CM.DISCOUNT_VALUE / 100)
												END
										ELSE 0
						END) AS DISCOUNT_ORDER_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '134001'
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN CO.FTICKET_PRICE - CM.DISCOUNT_VALUE <= 0 THEN CO.FTICKET_PRICE ELSE CM.DISCOUNT_VALUE END
												ELSE CO.FTICKET_PRICE * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_FTICKET_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '134002'
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN CO.GUESTBOOK_PRICE - CM.DISCOUNT_VALUE <= 0 THEN CO.GUESTBOOK_PRICE ELSE CM.DISCOUNT_VALUE END
												ELSE CO.GUESTBOOK_PRICE * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_GUESTBOOK_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '134003'
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN ISNULL(COI.ITEM_SALE_PRICE, 0) - CM.DISCOUNT_VALUE <= 0 THEN ISNULL(COI.ITEM_SALE_PRICE, 0) ELSE CM.DISCOUNT_VALUE END
												ELSE ISNULL(COI.ITEM_SALE_PRICE, 0) * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_LINING_ENV_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '135001'
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN CO.PRINT_PRICE - CM.DISCOUNT_VALUE <= 0 THEN CO.PRINT_PRICE ELSE CM.DISCOUNT_VALUE END
												ELSE CO.PRINT_PRICE * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_PRINT_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '135002'
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN CO.EMBO_PRICE - CM.DISCOUNT_VALUE <= 0 THEN CO.EMBO_PRICE ELSE CM.DISCOUNT_VALUE END
												ELSE CO.EMBO_PRICE * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_EMBO_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '135003'
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN CO.JEBON_PRICE - CM.DISCOUNT_VALUE <= 0 THEN CO.JEBON_PRICE ELSE CM.DISCOUNT_VALUE END
												ELSE CO.JEBON_PRICE * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_JEBON_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '135004'
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN CO.ENVINSERT_PRICE - CM.DISCOUNT_VALUE <= 0 THEN CO.ENVINSERT_PRICE ELSE CM.DISCOUNT_VALUE END
												ELSE CO.ENVINSERT_PRICE * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_ENVINSERT_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '135006'
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN CO.DELIVERY_PRICE - CM.DISCOUNT_VALUE <= 0 THEN CO.DELIVERY_PRICE ELSE CM.DISCOUNT_VALUE END
												ELSE CO.DELIVERY_PRICE * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_DELIVERY_PRICE_TEMP
					,	MAX(CASE 
								WHEN CA_SERVICE.CMMN_CODE = '135007' AND CO.ISSPECIAL = 1  
								THEN
										CASE 
												WHEN CM.DISCOUNT_FIXED_RATE_TYPE = 'W' THEN CASE WHEN (CASE WHEN ETC_PRICE > 35000 THEN 35000 ELSE ETC_PRICE END) - CM.DISCOUNT_VALUE <= 0 THEN (CASE WHEN ETC_PRICE > 35000 THEN 35000 ELSE ETC_PRICE END) ELSE CM.DISCOUNT_VALUE END
												ELSE (CASE WHEN ETC_PRICE > 35000 THEN 35000 ELSE ETC_PRICE END) * (1.0 * CM.DISCOUNT_VALUE / 100)
										END
								ELSE 0
						END) AS DISCOUNT_EXPRESS_SHIPPING_PRICE_TEMP		

				FROM	COUPON_ISSUE				CI
				JOIN	COUPON_DETAIL				CD			ON	CD.COUPON_DETAIL_SEQ	= CI.COUPON_DETAIL_SEQ
				JOIN	COUPON_MST					CM			ON	CM.COUPON_MST_SEQ		= CD.COUPON_MST_SEQ
				JOIN	COUPON_APPLY_SERVICE		CA_SERVICE	ON	CM.COUPON_MST_SEQ		= CA_SERVICE.COUPON_MST_SEQ	
				JOIN	COMMON_CODE					CC_SERVICE  ON	CA_SERVICE.CMMN_CODE	= CC_SERVICE.CMMN_CODE
				JOIN	COUPON_APPLY_SITE			CA_SITE		ON	CM.COUPON_MST_SEQ		= CA_SITE.COUPON_MST_SEQ
																AND CA_SITE.COMPANY_SEQ		= CI.COMPANY_SEQ
				LEFT
				JOIN	COUPON_APPLY_CARD			CA_CARD		ON	CM.COUPON_MST_SEQ		= CA_CARD.COUPON_MST_SEQ
				JOIN	CUSTOM_ORDER				CO			ON	CO.MEMBER_ID			= CI.UID	
																
				LEFT
				JOIN	CUSTOM_ORDER_ITEM			COI			ON	COI.ORDER_SEQ			= CO.ORDER_SEQ AND COI.ITEM_TYPE = 'D'

				WHERE	1 = 1

				-- 브랜드 서비스 제외. 사용 안함
				AND		CA_SERVICE.CLSS_CODE NOT IN ('132')

				-- 쿠폰 마스터 사용 여부
				AND		CM.STATUS_ACTIVE_YN = 'Y'

				-- 개인별 쿠폰 사용 여부
				AND		CI.ACTIVE_YN = 'Y'

				AND		(
							(
								-- 청첩장
									CM.ORDER_TYPE_CODE LIKE '%137001%' 
								AND CO.ORDER_TYPE IN (1, 6, 7)
							)
							OR
							(
								-- 감사장
									CM.ORDER_TYPE_CODE LIKE '%137002%' 
								AND CO.ORDER_TYPE IN (2)
							)
							OR
							(
								-- 초대장
									CM.ORDER_TYPE_CODE LIKE '%137003%' 
								AND CO.ORDER_TYPE IN (3)
							)
						)

				-- 카드 허용 여부
				AND		(
							CA_CARD.CARD_SEQ IS NULL
							OR	
							(
									CA_CARD.CARD_SEQ IS NOT NULL 
								AND CA_CARD.CARD_ALLOW_YN = 'Y' 
								AND CO.CARD_SEQ = CA_CARD.CARD_SEQ
							)
							OR	 
							(
									CA_CARD.CARD_SEQ IS NULL 
								AND CA_CARD.CARD_ALLOW_YN = 'N' 
								AND CO.CARD_SEQ = CA_CARD.CARD_SEQ
							)
						)

				-- 사이트 허용 여부
				AND		(
							(CO.SALES_GUBUN = 'SB'				AND CA_SITE.COMPANY_SEQ = 5001)
							OR
							(CO.SALES_GUBUN = 'SA'				AND CA_SITE.COMPANY_SEQ = 5006)
							OR
							(CO.SALES_GUBUN = 'ST'				AND CA_SITE.COMPANY_SEQ = 5007)
							OR
							(CO.SALES_GUBUN = 'SS'				AND CA_SITE.COMPANY_SEQ = 5003)
							OR
							(CO.SALES_GUBUN IN ('B', 'C', 'H')	AND CA_SITE.COMPANY_SEQ = 5000)
						)

				-- 유효 기간
				AND		(
			
							CM.EXPIRY_TYPE = 'A' -- 없음

							OR
							(
									CM.EXPIRY_TYPE = 'P' -- 기간
								AND (CM.EXPIRY_START_DATE	IS NULL OR CM.EXPIRY_START_DATE <= GETDATE()) -- NULL 일 경우 제한없음 으로 간주한다
								AND (CM.EXPIRY_END_DATE		IS NULL OR CM.EXPIRY_END_DATE	>= GETDATE()) -- NULL 일 경우 제한없음 으로 간주한다
							)

							OR
							(
									CM.EXPIRY_TYPE = 'V' -- 가변
								AND (CI.END_DATE >= GETDATE())
							)
						)

				-- 주문 최소 금액
				/* 07-26 */
				/* 주문 최소 금액은 순수 카드 금액을 대상으로 한다 */
				AND		(CM.ORDER_AMT = 0 OR CO.ORDER_PRICE >= CM.ORDER_AMT)

				-- 주문 최소 수량
				AND		(CM.ORDER_CNT = 0 OR CO.ORDER_COUNT >= CM.ORDER_CNT)

				-- 원주문, 추가주문 구분
				AND		(
							-- 전체
							CM.ORDER_APPLY_TYPE = 'ALL' 

							OR 
							(
								-- 원주문
									CM.ORDER_APPLY_TYPE = 'ORG' 
								AND CO.UP_ORDER_SEQ IS NULL
							) 
							OR 
							(
								-- 추가주문
									CM.ORDER_APPLY_TYPE = 'ADD' 
								AND CO.UP_ORDER_SEQ IS NOT NULL
							)
						)

				GROUP BY CO.ORDER_SEQ, CI.COUPON_DETAIL_SEQ

			) COUPON

	WHERE	1 = 1
	
	AND		UID = @P_UID
	AND		ORDER_SEQ = @P_ORDER_SEQ

	ORDER BY COUPON_TYPE_CODE ASC, DISCOUNT_TOTAL_PRICE DESC



END
GO
