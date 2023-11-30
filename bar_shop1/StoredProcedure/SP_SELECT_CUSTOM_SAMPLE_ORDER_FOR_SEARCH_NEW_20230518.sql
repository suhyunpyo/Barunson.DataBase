USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH_NEW_20230518]    Script Date: 2023-05-24 오후 1:29:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_SEARCH_NEW_20230518]
    @P_SEARCH_TYPE			AS VARCHAR(10)
,	@P_SEARCH_VALUE			AS VARCHAR(50)
,	@P_SALES_GUBUN_LIST		AS VARCHAR(100)
,	@P_STATUS_SEQ			AS INT
,	@P_SEARCH_DATE_TYPE		AS INT
,	@P_SEARCH_START_DATE	AS VARCHAR(10)
,	@P_SEARCH_START_HOUR	AS VARCHAR(2)
,	@P_SEARCH_END_DATE		AS VARCHAR(10)
,	@P_SEARCH_END_HOUR		AS VARCHAR(2)
,	@P_ONCLICK_SAMPLE		AS VARCHAR(1)
,	@P_ERP_PART_CODE		AS VARCHAR(20)
,   @P_JOIN_DEVICE			AS VARCHAR(20)
,	@P_PRINT_STATUS			AS INT
,	@P_PACK_TYPE			AS VARCHAR(10)
,	@P_ORDER_BY_TYPE		AS INT
,	@P_LIST_TYPE			AS VARCHAR(50)
,   @P_MEMBER_TYPE          AS INT = 0


AS
BEGIN
    
	SET NOCOUNT ON;

	--SET @P_SALES_GUBUN_LIST = REPLACE(@P_SALES_GUBUN_LIST, 'B , C', 'B')

	DECLARE @SEARCH_DATE_START_OF_DAY AS DATETIME
	DECLARE @SEARCH_DATE_END_OF_DAY AS DATETIME
	SET @SEARCH_DATE_START_OF_DAY = CAST(@P_SEARCH_START_DATE + ' ' + @P_SEARCH_START_HOUR + ':00:00' AS DATETIME)
	SET @SEARCH_DATE_END_OF_DAY = CAST(@P_SEARCH_END_DATE + ' ' + @P_SEARCH_END_HOUR + ':59:59' AS DATETIME)


	Declare @sampleorderseqs as table (sample_order_seq int)

	IF @P_SEARCH_DATE_TYPE = 0 
	  Begin
		insert into @sampleorderseqs
		Select [sample_order_seq] From CUSTOM_SAMPLE_ORDER with(nolock) Where REQUEST_DATE >= @SEARCH_DATE_START_OF_DAY And REQUEST_DATE <= @SEARCH_DATE_END_OF_DAY
	  End
	Else IF @P_SEARCH_DATE_TYPE = 1 
	   Begin
		insert into @sampleorderseqs
		Select [sample_order_seq] From CUSTOM_SAMPLE_ORDER with(nolock) Where SETTLE_DATE >= @SEARCH_DATE_START_OF_DAY And SETTLE_DATE <= @SEARCH_DATE_END_OF_DAY
	  End
	Else IF @P_SEARCH_DATE_TYPE = 2 
	   Begin
		insert into @sampleorderseqs
		Select [sample_order_seq] From CUSTOM_SAMPLE_ORDER with(nolock) Where PREPARE_DATE >= @SEARCH_DATE_START_OF_DAY And PREPARE_DATE <= @SEARCH_DATE_END_OF_DAY
	  End
	Else IF @P_SEARCH_DATE_TYPE = 3 
	   Begin
		insert into @sampleorderseqs
		Select [sample_order_seq] From CUSTOM_SAMPLE_ORDER with(nolock) Where DELIVERY_DATE >= @SEARCH_DATE_START_OF_DAY And DELIVERY_DATE <= @SEARCH_DATE_END_OF_DAY
	  End



		SELECT	1 AS STATUS
			,	CASE 
						WHEN @P_PACK_TYPE = 'PACK' THEN MEMBER_FAX
						ELSE ''
				END AS ORDER_BY_MULTI_PACK
			,	CASE	
						WHEN @P_ORDER_BY_TYPE = 1 THEN CSO.SETTLE_DATE
						WHEN @P_ORDER_BY_TYPE = 2 THEN CSO.PREPARE_DATE
						WHEN @P_ORDER_BY_TYPE = 3 THEN CSO.DELIVERY_DATE
						ELSE GETDATE()
				END AS ORDER_BY_DATE,
				VUI.INTERGRATION_DATE --회원가입일
			,	CSO.SAMPLE_ORDER_SEQ
			,	CSO.SALES_GUBUN
			,	C.ERP_PARTCODE
			,	CSO.COMPANY_SEQ
			,	CSO.REQUEST_DATE
			,	DATEPART(HOUR, CSO.REQUEST_DATE) AS REQUEST_HOUR
			,	CSO.PREPARE_DATE
			,	CSO.SETTLE_DATE
			,	DATEPART(HOUR, CSO.SETTLE_DATE) AS SETTLE_HOUR
			,	CSO.SETTLE_PRICE
			,	CSO.STATUS_SEQ

			,	ISNULL(CAST(CSO.MEMBER_FAX AS VARCHAR(20)), '') AS MEMBER_FAX
			,	ISNULL(CAST(CSO.MULTI_PACK_SEQ AS VARCHAR(20)), '') AS MULTI_PACK_SEQ
			,	ISNULL(CAST(CSO.MULTI_PACK_SUB_SEQ AS VARCHAR(20)), '') AS MULTI_PACK_SUB_SEQ
			,	ISNULL(CONVERT(VARCHAR(19), CSO.MULTI_PACK_REG_DATE, 120), '') AS MULTI_PACK_REG_DATE
			,	CASE WHEN CSO.MULTI_PACK_SEQ IS NULL THEN 'N' ELSE 'Y' END AS MULTI_PACK_YORN
			,	CSO.DELIVERY_DATE
			,	CSO.CANCEL_DATE
			,	CSO.DELIVERY_PRICE
			,	CSO.MEMBER_ID
			,	CSO.MEMBER_EMAIL
			,	CSO.MEMBER_NAME
			,	CSO.MEMBER_PHONE
			,	CSO.MEMBER_HPHONE
			,	CSO.MEMBER_ZIP
			,	CSO.MEMBER_ADDRESS + ' ' + CSO.MEMBER_ADDRESS_DETAIL AS MEMBER_ADDRESS
			,	DATEDIFF(YEAR, CASE WHEN ISDATE(VUI.BIRTH) = 1 THEN VUI.BIRTH ELSE GETDATE() END, GETDATE()) AS MEMBER_AGE
			,	C.COMPANY_NAME
			,	CSO.INVOICE_PRINT_YORN
			,	CSO.JOB_ORDER_PRINT_YORN
			,	CSO.DSP_PRINT_YORN
			,	CASE WHEN CSO.JOIN_DIVISION = 'WEB' THEN 'PC' WHEN CSO.JOIN_DIVISION = 'MOBILE' THEN 'MOBILE' ELSE '' END AS INFLOW_ROUTE
			,	ISNULL(CSO.ISONECLICKSAMPLE, 'N') AS ISONECLICKSAMPLE

			

			-- EXCEL 출력시에 필요한 항목
			,	ISNULL(VUI.CHK_SMS, 'N') AS SMS_YORN
			,	CASE WHEN ISNULL(CSO.MEMBER_ID, '') <> '' AND ISNULL(VUI.WEDD_YEAR, '') <> '' AND ISNULL(VUI.WEDD_MONTH, '') <> '' AND ISNULL(VUI.WEDD_DAY, '') <> '' THEN ISNULL(VUI.WEDD_YEAR + '-' + VUI.WEDD_MONTH + '-' + VUI.WEDD_DAY, '') 
						--WHEN ISNULL(CSO.MEMBER_ID, '') = '' AND ISNULL(CSO.WEDD_DATE, '') <> '' THEN CSO.WEDD_DATE
                     ELSE ISNULL(CSO.WEDD_DATE, '')
                END AS WEDDING_DAY

			,   CASE WHEN CSO.SALES_GUBUN = 'SD' THEN CSO.MEMBER_ID ELSE (CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN '비회원' WHEN VUI.UID IS NULL THEN '탈퇴회원' ELSE CSO.MEMBER_ID END) END  AS [USER_ID]
			,   CASE WHEN CSO.SALES_GUBUN = 'SD' THEN '회원' ELSE (CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN '비회원' WHEN VUI.UID IS NULL THEN '탈퇴회원' ELSE '회원' END) END AS MEMBER_YORN
		
			-- EXCEL 출력시에 필요한 항목
			,   CASE 
						WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
						THEN ISNULL	(
										STUFF	(
													(
														SELECT	'|' + CONVERT(VARCHAR(30), SALES_GUBUN)
														FROM	CUSTOM_SAMPLE_ORDER with(nolock)
														WHERE	DELIVERY_DATE >= @SEARCH_DATE_START_OF_DAY
														AND     DELIVERY_DATE <= @SEARCH_DATE_END_OF_DAY
														AND     STATUS_SEQ >= 1
														AND     MEMBER_ID = CSO.MEMBER_ID
                                                        AND     ISNULL(MEMBER_ID, '') <> ''
                                                        AND     ISNULL(CSO.MEMBER_ID, '') <> ''
														ORDER BY SALES_GUBUN ASC
                                                        FOR XML PATH('')
													)
												, 1, 1, '')
									, CSO.SALES_GUBUN)
						ELSE ''
				END AS ACTUAL_SAMPLE_SITE
		
			-- EXCEL 출력시에 필요한 항목
			,   CASE 
						WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
						THEN ISNULL	(
										( 
											SELECT SUM(CNT) FROM (
												SELECT  COUNT(ORDER_SEQ) CNT
												FROM	CUSTOM_ORDER with(nolock)
												WHERE	1 = 1
													AND     SRC_SEND_DATE >= CSO.REQUEST_DATE
													AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
													AND     STATUS_SEQ = 15 
													AND     UP_ORDER_SEQ IS NULL
													AND     COMPANY_SEQ = CSO.COMPANY_SEQ
													AND     SALES_GUBUN = CSO.SALES_GUBUN
													AND     MEMBER_ID = CSO.MEMBER_ID
													AND     ISNULL(MEMBER_ID, '') <> ''
													AND     ISNULL(CSO.MEMBER_ID, '') <> ''
												UNION ALL
												SELECT  COUNT(ORDER_SEQ) CNT
												FROM	CUSTOM_ORDER with(nolock)
												WHERE	1 = 1
													AND     SRC_SEND_DATE >= CSO.REQUEST_DATE
													AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
													AND     STATUS_SEQ = 15 
													AND     UP_ORDER_SEQ IS NULL
													AND     COMPANY_SEQ = CSO.COMPANY_SEQ
													AND     SALES_GUBUN = CSO.SALES_GUBUN
													AND     ((ISNULL(MEMBER_ID, '') = '' and sales_Gubun <> 'SD') or sales_Gubun = 'SD')
													AND     ((ISNULL(CSO.MEMBER_ID, '') = '' and cso.sales_Gubun <> 'SD') or cso.SALES_GUBUN = 'SD')   /* 비회원 주문*/
													AND     (order_hphone = CSO.MEMBER_HPHONE OR order_email = CSO.MEMBER_EMAIL)
											) AS A
										)
									, 0) 
						ELSE 0
				END AS ACTUAL_ORDER_CNT 

			-- EXCEL 출력시에 필요한 항목
			,   CASE 
						WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
						THEN ISNULL	(
										STUFF	(
													(  
														SELECT	'|' + CONVERT(VARCHAR(30), SALES_GUBUN)
														FROM (
																SELECT SALES_GUBUN
																FROM	CUSTOM_ORDER with(nolock)
																WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
																	AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
																	AND     STATUS_SEQ = 15 
																	AND     UP_ORDER_SEQ IS NULL
																	AND     MEMBER_ID = CSO.MEMBER_ID
																	AND     ISNULL(MEMBER_ID, '') <> ''
																	AND     ISNULL(CSO.MEMBER_ID, '') <> ''
																UNION ALL
																SELECT SALES_GUBUN
																FROM	CUSTOM_ORDER with(nolock)
																WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
																	AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
																	AND     STATUS_SEQ = 15 
																	AND     UP_ORDER_SEQ IS NULL
																	AND     ((ISNULL(MEMBER_ID, '') = '' and sales_Gubun <> 'SD') or sales_Gubun = 'SD')
																	AND     ((ISNULL(CSO.MEMBER_ID, '') = '' and cso.sales_Gubun <> 'SD') or cso.SALES_GUBUN = 'SD')   /* 비회원 주문*/
																	AND     (order_hphone = CSO.MEMBER_HPHONE OR order_email = CSO.MEMBER_EMAIL)
															) A
														ORDER BY SALES_GUBUN ASC 
														FOR XML PATH('')
													)
												, 1, 1, '')
									, '')
						ELSE ''
				END AS ACTUAL_ORDER_SITE,

				청첩장주문일 =  CASE WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
									THEN ISNULL	(
														(  
															SELECT	MAX(CONVERT(VARCHAR(10), ORDER_DATE, 120))
															FROM (
															SELECT ORDER_DATE
															FROM	CUSTOM_ORDER with(nolock)
															WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
																AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
																AND     STATUS_SEQ = 15 
																AND     UP_ORDER_SEQ IS NULL
																AND     MEMBER_ID = CSO.MEMBER_ID
																AND     ISNULL(MEMBER_ID, '') <> ''
																AND     ISNULL(CSO.MEMBER_ID, '') <> ''
															UNION ALL
															SELECT ORDER_DATE
															FROM	CUSTOM_ORDER with(nolock)
															WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
																AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
																AND     STATUS_SEQ = 15 
																AND     UP_ORDER_SEQ IS NULL
																AND     ((ISNULL(MEMBER_ID, '') = '' and sales_Gubun <> 'SD') or sales_Gubun = 'SD')
																AND     ((ISNULL(CSO.MEMBER_ID, '') = '' and cso.sales_Gubun <> 'SD') or cso.SALES_GUBUN = 'SD')   /* 비회원 주문*/
																AND     (order_hphone = CSO.MEMBER_HPHONE OR order_email =CSO.MEMBER_EMAIL)
															) A
														)
												, '')
									ELSE ''
									END ,
				청첩장결제일  =  CASE WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
									THEN ISNULL	(
														(  
															SELECT	MAX(CONVERT(VARCHAR(10), SETTLE_DATE, 120))  
															FROM (
																SELECT SETTLE_DATE
																FROM	CUSTOM_ORDER with(nolock)
																WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
																	AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
																	AND     STATUS_SEQ = 15 
																	AND     UP_ORDER_SEQ IS NULL
																	AND     MEMBER_ID = CSO.MEMBER_ID
																	AND     ISNULL(MEMBER_ID, '') <> ''
																	AND     ISNULL(CSO.MEMBER_ID, '') <> ''
																UNION ALL
																SELECT SETTLE_DATE
																FROM	CUSTOM_ORDER with(nolock)
																WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
																	AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
																	AND     STATUS_SEQ = 15 
																	AND     UP_ORDER_SEQ IS NULL
																	AND     ((ISNULL(MEMBER_ID, '') = '' and sales_Gubun <> 'SD') or sales_Gubun = 'SD')
																	AND     ((ISNULL(CSO.MEMBER_ID, '') = '' and cso.sales_Gubun <> 'SD') or cso.SALES_GUBUN = 'SD')   /* 비회원 주문*/
																	AND     (order_hphone = CSO.MEMBER_HPHONE OR order_email =CSO.MEMBER_EMAIL)
															) A
														)
												, '')
									ELSE ''
									END ,

				청첩장배송일 =   CASE WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
									THEN ISNULL	(
														(  
															SELECT	MAX(CONVERT(VARCHAR(10), SRC_SEND_DATE, 120))	
															FROM (
																SELECT SRC_SEND_DATE 
																FROM	CUSTOM_ORDER with(nolock)
																WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
																	AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
																	AND     STATUS_SEQ = 15 
																	AND     UP_ORDER_SEQ IS NULL
																	AND     MEMBER_ID = CSO.MEMBER_ID
																	AND     ISNULL(MEMBER_ID, '') <> ''
																	AND     ISNULL(CSO.MEMBER_ID, '') <> ''
																UNION ALL
																SELECT SRC_SEND_DATE 
																FROM	CUSTOM_ORDER with(nolock)
																WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
																	AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
																	AND     STATUS_SEQ = 15 
																	AND     UP_ORDER_SEQ IS NULL
																	AND     ((ISNULL(MEMBER_ID, '') = '' and sales_Gubun <> 'SD') or sales_Gubun = 'SD')
																	AND     ((ISNULL(CSO.MEMBER_ID, '') = '' and cso.sales_Gubun <> 'SD') or cso.SALES_GUBUN = 'SD')   /* 비회원 주문*/
																	AND     (order_hphone = CSO.MEMBER_HPHONE OR order_email =CSO.MEMBER_EMAIL)
															) A
														)
												, '')
									ELSE ''
									END ,
				회원가입사이트 =   CASE WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0 
									THEN 

											CASE
												WHEN VUI.REFERER_SALES_GUBUN = 'SB' THEN '바른손카드'
												WHEN VUI.REFERER_SALES_GUBUN = 'SS' THEN '프리미어페이퍼'
												WHEN VUI.REFERER_SALES_GUBUN = 'H' THEN '바른손몰(H)'
												WHEN VUI.REFERER_SALES_GUBUN = 'SA' THEN '비핸즈카드'
												WHEN VUI.REFERER_SALES_GUBUN = 'B' THEN '바른손몰(B)'
												WHEN VUI.REFERER_SALES_GUBUN = 'C' THEN '비핸즈카드 제휴'
												WHEN VUI.REFERER_SALES_GUBUN = 'ST' THEN '더카드'
												ELSE '기타'
											END 

									ELSE ''
									END 
			,회원가입일 = VUI.INTERGRATION_DATE
			-- EXCEL 출력시에 필요한 항목
			,   CASE 
						WHEN CHARINDEX('EXCEL', @P_LIST_TYPE) > 0
						THEN ISNULL	(
										STUFF	(
													(  
														SELECT	'|' + CONVERT(VARCHAR(30), CARD_SEQ)
														FROM	CUSTOM_ORDER with(nolock)
														WHERE	SRC_SEND_DATE >= CSO.REQUEST_DATE
														AND     SRC_SEND_DATE < DATEADD(YEAR, 1, CSO.REQUEST_DATE)
														AND     STATUS_SEQ = 15 
                                                        AND     UP_ORDER_SEQ IS NULL
														AND     MEMBER_ID = CSO.MEMBER_ID
                                                        AND     ISNULL(MEMBER_ID, '') <> ''
														AND   ISNULL(CSO.MEMBER_ID, '') <> ''
														ORDER BY CARD_SEQ ASC 
                                                       FOR XML PATH('')
													)
												, 1, 1, '')
									, '') 
						ELSE ''
				END AS ACTUAL_ORDER_CARD_SEQS,
				
				ADDR = CSO.MEMBER_ADDRESS,
				ADDR_DETAIL = CSO.MEMBER_ADDRESS_DETAIL

        INTO    #TEMP_CUSTOM_SAMPLE_ORDER
		FROM	CUSTOM_SAMPLE_ORDER AS CSO with(nolock) 

		LEFT 
		OUTER 
		JOIN	COMPANY AS C with(nolock) ON CSO.COMPANY_SEQ = C.COMPANY_SEQ

		LEFT 
		OUTER 
		JOIN	S2_USERINFO_THECARD AS VUI with(nolock)  ON CSO.MEMBER_ID = VUI.UID AND INTEGRATION_MEMBER_YORN = 'Y'
				
		WHERE	1 = 1
		AND		CSO.DELIVERY_CHANGO = '1'
		AND		CSO.STATUS_SEQ >= 1 
		AND		(@P_STATUS_SEQ = 0 OR CSO.STATUS_SEQ = @P_STATUS_SEQ)
		AND		CSO.SALES_GUBUN IN ( SELECT VALUE FROM FN_SPLIT(REPLACE(@P_SALES_GUBUN_LIST, ' ', ''), ',') )
		AND		(@P_JOIN_DEVICE = '' OR (@P_JOIN_DEVICE <> '' AND CSO.JOIN_DIVISION = @P_JOIN_DEVICE))
		AND		(@P_ERP_PART_CODE = '' OR (@P_ERP_PART_CODE <> '' AND C.ERP_PARTCODE = @P_ERP_PART_CODE))
		-- 2022 05 25 표수현 - 바른손몰 주문건인데 비핸즈 검색시 나오는 현상때문에 
		-- CUSTOM_SAMPLE_ORDER의 바른손몰 주문건의 SALES_GUBUN값과 COMPANY의 SALES_GUBUN값이 일치한것만..
		--AND		(CASE WHEN CSO.COMPANY_SEQ = '5000' THEN CSO.SALES_GUBUN  ELSE '1' END) =  
		--		(CASE WHEN CSO.COMPANY_SEQ = '5000' THEN C.SALES_GUBUN   ELSE '1' END) 
		-- 날짜 검색
		AND	    CSO.sample_order_seq in (Select sample_order_seq From @sampleorderseqs)
		--AND		(
		--			(
		--					@P_SEARCH_DATE_TYPE = 0 
		--				AND	CSO.REQUEST_DATE >= @SEARCH_DATE_START_OF_DAY
		--				AND	CSO.REQUEST_DATE <= @SEARCH_DATE_END_OF_DAY
		--			)
		--			OR
		--			(
		--					@P_SEARCH_DATE_TYPE = 1 
		--				AND	CSO.SETTLE_DATE >= @SEARCH_DATE_START_OF_DAY
		--				AND	CSO.SETTLE_DATE <= @SEARCH_DATE_END_OF_DAY
		--			)
		--			OR
		--			(
		--					@P_SEARCH_DATE_TYPE = 2
		--				AND	CSO.PREPARE_DATE >= @SEARCH_DATE_START_OF_DAY
		--				AND	CSO.PREPARE_DATE <= @SEARCH_DATE_END_OF_DAY
		--			)
		--			OR
		--			(
		--					@P_SEARCH_DATE_TYPE = 3 
		--				AND	CSO.DELIVERY_DATE >= @SEARCH_DATE_START_OF_DAY
		--				AND	CSO.DELIVERY_DATE <= @SEARCH_DATE_END_OF_DAY
		--			)
		--		)

		-- 검색어 검색
		AND		(
					@P_SEARCH_TYPE = ''
					OR
					(
							@P_SEARCH_TYPE = '0'
						AND CASE WHEN ISNUMERIC(@P_SEARCH_VALUE) = 1 THEN CSO.SAMPLE_ORDER_SEQ ELSE 0 END
							=
							CASE WHEN ISNUMERIC(@P_SEARCH_VALUE) = 1 THEN CAST(@P_SEARCH_VALUE AS INT) ELSE 0 END
					)
					OR
					(
							@P_SEARCH_TYPE = '1'
						AND CSO.MEMBER_NAME LIKE '%' + @P_SEARCH_VALUE + '%'
					)
					OR
					(
							@P_SEARCH_TYPE = '2'
						AND CSO.MEMBER_ID LIKE '%' + @P_SEARCH_VALUE + '%'
					)
					OR
					(
							@P_SEARCH_TYPE = '4'
						AND REPLACE(CSO.member_hphone, '-', '') = REPLACE(@P_SEARCH_VALUE, '-', '')
					)
					OR
					(
							@P_SEARCH_TYPE = '5'
						AND CSO.DELIVERY_CODE_NUM = @P_SEARCH_VALUE
					)
				)

		-- 인쇄 상태 검색
		AND		(
					@P_PRINT_STATUS = 0
					OR
					(
							@P_PRINT_STATUS = 1
						AND	INVOICE_PRINT_YORN = 'Y'
					)
					OR
					(
							@P_PRINT_STATUS = 2
						AND	JOB_ORDER_PRINT_YORN = 'Y'
					)
					OR
					(
							@P_PRINT_STATUS = 3
						AND	DSP_PRINT_YORN = 'Y'
					)
				)        
	
		-- 원클릭 샘플 검색
		AND		(
					@P_ONCLICK_SAMPLE <> '1'
					OR
					(
							@P_ONCLICK_SAMPLE = '1'
						AND CSO.ISONECLICKSAMPLE = 'Y'
					)
				)
	
		-- 묶음 배송건 검색
		AND		(
					@P_PACK_TYPE = ''
					OR
					(
							@P_PACK_TYPE = 'PACK'
						AND CSO.MEMBER_FAX IS NOT NULL
					)
					OR
					(
							@P_PACK_TYPE = 'NORMAL'
						AND CSO.MEMBER_FAX IS NULL
					)
				)

        -- 회원/비회원 검색
        AND     (
@P_MEMBER_TYPE = 0
            OR
(
    @P_MEMBER_TYPE = 1 AND ISNULL(CSO.MEMBER_ID, '') <> ''
                    )
                    OR
                    (
                            @P_MEMBER_TYPE = 2 AND ISNULL(CSO.MEMBER_ID, '') = ''
                    )
                )

	SELECT	DISTINCT
			CST.*
		,	CASE WHEN CST.ACTUAL_ORDER_CNT > 0 THEN 'Y' ELSE 'N' END AS ACTUAL_ORDER_YORN
		,   CASE 
					WHEN @P_LIST_TYPE = 'EXCEL_WITH_ITEM' THEN CHARINDEX(CAST(CSOI.CARD_SEQ AS VARCHAR(10)), CST.ACTUAL_ORDER_CARD_SEQS)
					ELSE 0
			END AS ACTUAL_CARD_SAME_YORN
		,	ISNULL(SCV.OLD_CODE	    , '') AS OLD_CODE
		,	ISNULL(SCV.CARD_CODE	, '') AS CARD_CODE
		,	ISNULL(SCV.BRAND_NAME	, '') AS BRAND_NAME
		,	ISNULL(SCV.CARD_PRICE	, 0)  AS CARD_PRICE
		,	ISNULL(CSOI.CARD_PRICE	, 0)  AS CARD_SALE_PRICE
		,   (SELECT IP FROM S4_LoginIpInfo with(nolock)  WHERE seq = (SELECT MIN(seq) FROM S4_LoginIpInfo with(nolock)  WHERE uid = CST.MEMBER_ID AND CST.MEMBER_ID IS NOT NULL and CST.MEMBER_ID <> ''  AND IP is not null)) AS IP
		-- 20221017 상품유형 추가
		,PRODUCT_KIND = '',
		--,  PRODUCT_KIND = STUFF(( 
		--			SELECT '|' + SCKI.CARDKIND FROM S2_CARDKINDINFO SCKI 
		--			WHERE SCKI.CARDKIND_SEQ IN 
		--					( 
		--						SELECT ISNULL(SCKIND.CARDKIND_SEQ,0) 
		--					    FROM S2_CARDKIND SCKIND 
		--					    WHERE SCKIND.CARD_SEQ IN
		--						(
		--							SELECT A.CARD_SEQ 
		--							FROM CUSTOM_SAMPLE_ORDER_ITEM A INNER JOIN 
		--								 S2_CARDVIEW B ON A.CARD_SEQ = B.CARD_SEQ
		--							WHERE SAMPLE_ORDER_SEQ = CST.SAMPLE_ORDER_SEQ
		--						)
		--					) 
		--	FOR XML PATH('')),1,1,''),
			
			레이저여부 =   CASE WHEN CHARINDEX('EXCEL_WITH_ITEM', @P_LIST_TYPE) > 0 --주문의 아이템개수별
									THEN 
									(
									
											SELECT 레이저 =  CASE	WHEN B.ISLASER <> '0' THEN '1'
																	ELSE '0'  END 
															 FROM	CUSTOM_SAMPLE_ORDER_ITEM A with(nolock)  INNER JOIN 
																	S2_CARDOPTION B with(nolock)  ON A.CARD_SEQ = B.CARD_SEQ
															 WHERE	SAMPLE_ORDER_SEQ =  CST.SAMPLE_ORDER_SEQ AND   
																	A.CARD_SEQ = SCV.CARD_SEQ
										

									)
									ELSE (  --주문건별
										
											SELECT CASE	WHEN CHARINDEX('Y', TB.레이저) > 0 THEN '1'
											ELSE '0' END ISLASER
											FROM (
													 SELECT 레이저 =  STUFF(
																			 ( SELECT ',' + CASE WHEN B.ISLASER <> '0' THEN 'Y'
																							ELSE 'N'  END 
																				FROM CUSTOM_SAMPLE_ORDER_ITEM A with(nolock)  INNER JOIN 
																					 S2_CARDOPTION B with(nolock)  ON A.CARD_SEQ = B.CARD_SEQ
																				WHERE SAMPLE_ORDER_SEQ =  CST.SAMPLE_ORDER_SEQ
																				FOR XML PATH('')
																			  ), 1, 1, ''
																			) 
												  ) TB


																
										)
									END ,

		디지털여부 =   CASE WHEN CHARINDEX('EXCEL_WITH_ITEM', @P_LIST_TYPE) > 0 --주문의 아이템개수별
									THEN 
									(

										SELECT 디지털 =  CASE	WHEN B.IsInternalDigital = '1' THEN '1'
																		ELSE '0' END 
																FROM	CUSTOM_SAMPLE_ORDER_ITEM A with(nolock)  INNER JOIN 
																		S2_CARDOPTION B with(nolock)  ON A.CARD_SEQ = B.CARD_SEQ
																WHERE SAMPLE_ORDER_SEQ = CST.SAMPLE_ORDER_SEQ AND   
																		A.CARD_SEQ = SCV.CARD_SEQ
																			


										
									)
									ELSE (  --주문건별

											SELECT	CASE	WHEN CHARINDEX('Y', TB.디지털) > 0 THEN '1'
													ELSE '0' END IsInternalDigital
											FROM (
													SELECT 디지털 =  STUFF(
																			(	SELECT ',' + CASE	WHEN B.IsInternalDigital = '1' THEN 'Y'
																							ELSE 'N' END 
																				FROM CUSTOM_SAMPLE_ORDER_ITEM A with(nolock)  INNER JOIN 
																					 S2_CARDOPTION B with(nolock)  ON A.CARD_SEQ = B.CARD_SEQ
																				WHERE SAMPLE_ORDER_SEQ = CST.SAMPLE_ORDER_SEQ
																				FOR XML PATH('')
																			), 1, 1, ''
																		  ) 
												  ) TB

									)
									END,
	
		형압여부 =   CASE WHEN CHARINDEX('EXCEL_WITH_ITEM', @P_LIST_TYPE) > 0	  --주문의 아이템개수별
						THEN 
							(
								SELECT 형압 = CASE	WHEN SUBSTRING(LTRIM(B.PRINTMETHOD),3,1) = '1' THEN '1'
												ELSE '0' END 
								FROM CUSTOM_SAMPLE_ORDER_ITEM A with(nolock)  INNER JOIN 
									 S2_CARDOPTION B with(nolock)  ON A.CARD_SEQ = B.CARD_SEQ
								WHERE SAMPLE_ORDER_SEQ =  CST.SAMPLE_ORDER_SEQ  AND
								A.CARD_SEQ = SCV.CARD_SEQ


							)
							ELSE 
							(
								SELECT CASE	WHEN CHARINDEX('Y', TB.형압) > 0 THEN '1'
										ELSE '0' END 형압
								FROM (
										SELECT 형압 =  STUFF((
																SELECT ',' + CASE WHEN SUBSTRING(LTRIM(B.PRINTMETHOD),3,1) = '1' THEN 'Y'
																			ELSE '' END 
																FROM CUSTOM_SAMPLE_ORDER_ITEM A with(nolock)  INNER JOIN 
																	S2_CARDOPTION B with(nolock)  ON A.CARD_SEQ = B.CARD_SEQ
																WHERE SAMPLE_ORDER_SEQ =  CST.SAMPLE_ORDER_SEQ
																FOR XML PATH('')
																), 1, 1, ''
															 ) 
									 ) TB
								)
							END,
		박여부 =   CASE WHEN CHARINDEX('EXCEL_WITH_ITEM', @P_LIST_TYPE) > 0	 --주문의 아이템개수별
					THEN (
																			
							SELECT 박 =  CASE WHEN SUBSTRING(B.PRINTMETHOD, 1,1)  <> '0'  THEN '1'
										 ELSE '0' END 
							FROM CUSTOM_SAMPLE_ORDER_ITEM A with(nolock)  INNER JOIN 
								 S2_CARDOPTION B with(nolock)  ON A.CARD_SEQ = B.CARD_SEQ
							WHERE SAMPLE_ORDER_SEQ =  CST.SAMPLE_ORDER_SEQ  AND
								  A.CARD_SEQ = SCV.CARD_SEQ
							)
					ELSE (

							SELECT CASE	WHEN CHARINDEX('Y', TB.박) > 0 THEN '1'
											ELSE '0' END 박
							FROM (
									SELECT 박 =  STUFF(( 
															SELECT ',' + CASE WHEN SUBSTRING(B.PRINTMETHOD, 1,1)  <> '0'  THEN 'Y'
																		ELSE '' END 

															FROM CUSTOM_SAMPLE_ORDER_ITEM A with(nolock)  INNER JOIN 
																	S2_CARDOPTION B with(nolock)  ON A.CARD_SEQ = B.CARD_SEQ
															WHERE SAMPLE_ORDER_SEQ =  CST.SAMPLE_ORDER_SEQ
															FOR XML PATH('')
														), 1, 1, ''
														) 
							      ) TB
						  )
						END

	FROM	#TEMP_CUSTOM_SAMPLE_ORDER CST

	LEFT
	OUTER
	JOIN	CUSTOM_SAMPLE_ORDER_ITEM CSOI with(nolock) ON CST.SAMPLE_ORDER_SEQ = CSOI.SAMPLE_ORDER_SEQ AND @P_LIST_TYPE = 'EXCEL_WITH_ITEM'

	LEFT
	OUTER
	JOIN	S2_CARDVIEWN AS SCV with(nolock) ON CSOI.CARD_SEQ = SCV.CARD_SEQ

	ORDER BY	ORDER_BY_MULTI_PACK ASC
			,	ORDER_BY_DATE DESC
			,	CST.SAMPLE_ORDER_SEQ DESC
    
	
	
END




