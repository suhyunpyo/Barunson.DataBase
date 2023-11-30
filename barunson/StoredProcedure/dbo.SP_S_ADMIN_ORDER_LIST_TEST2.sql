IF OBJECT_ID (N'dbo.SP_S_ADMIN_ORDER_LIST_TEST2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_ORDER_LIST_TEST2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_ORDER_LIST_TEST2]
/*************************************************************** 
작성자	:	표수현
작성일	:	2021-05-26
DESCRIPTION	:	ADMIN - 회원관리 - 주문한 회원목록 
SPECIAL LOGIC	: SP_S_ADMIN_ORDER_LIST '2021-10-01', '2021-10-31' , 'ORDER', 'ALL', 'PCC01_'
SP_S_ADMIN_ORDER_MEMBER '2021-05-19', '2021-05-26' , 'ALL',	'브'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/

 @START_DATE VARCHAR(10) = '2021-10-01',
 @END_DATE VARCHAR(10) = '2021-10-31',
 @SEARCHPERIOD VARCHAR(10) = 'ORDER',  --주문일 / 결재일
 @SEARCHMEMBERYN VARCHAR(10) = NULL,
 @SEARCHKIND VARCHAR(100) = NULL,
 @SEARCHBRAND  VARCHAR(100) = NULL,
 @SEARCHPAYMENTSTATUS VARCHAR(100) = 'ALL',
 @SEARCHTXT  VARCHAR(100) = NULL --검색어 
 
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 
-- DECLARE @START_DATE DATETIME = '2021-10-01'
-- DECLARE @END_DATE DATETIME = '2021-10-31'
-- DROP TABLE #TOTAL_ORDER_LIST
 
 IF @SEARCHPERIOD = 'ORDER' BEGIN 

	SELECT * INTO #ORDER_LIST1 
	FROM (  
			SELECT 주문사이트 = (
									SELECT TOP 1 CASE WHEN A.SALES_GUBUN = 'BM' THEN 'M' 
																WHEN A.SALES_GUBUN = 'SB' THEN '바른손' 
																WHEN A.SALES_GUBUN = 'SA' THEN '비핸즈' 
																WHEN A.SALES_GUBUN = 'ST' THEN '더카드' 
																WHEN A.SALES_GUBUN = 'SS' THEN '프리미어' 
																WHEN A.SALES_GUBUN = 'B' OR A.SALES_GUBUN = 'H' THEN '바른손몰' 
																WHEN A.SALES_GUBUN = 'SD' THEN '디얼디어' 
												  ELSE  '바른손몰' END

									FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
										 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
									WHERE STATUS_SEQ >= 9 AND  MEMBER_ID = T.[USER_ID] 
									GROUP BY A.SALES_GUBUN
								),
				   [USER_ID] = T.[USER_ID], 
				   ORDER_ID = T.ORDER_ID,
				   EMAIL = [T].[EMAIL],
				   CELLPHONE_NUMBER = T.CELLPHONE_NUMBER, 
				   COUPON_PRICE = T.COUPON_PRICE, 
				   [NAME] = T.[NAME],
				   ORDER_CODE = T.ORDER_CODE, 
				   ORDER_DATETIME = T.ORDER_DATETIME, 
				   ORDER_PATH = T.ORDER_PATH,
				   ORDER_PRICE = T.ORDER_PRICE, 
				   PAYMENT_DATETIME = T.PAYMENT_DATETIME,
				   PAYMENT_STATUS_CODE = [T].[PAYMENT_STATUS_CODE],
				   PAYMENT_PATH = T.PAYMENT_PATH, 
				   PAYMENT_PRICE = T.PAYMENT_PRICE,
				   REGIST_DATETIME1 = T.REGIST_DATETIME, 
				   PRODUCT_ID = T0.PRODUCT_ID,
				   PRODUCT_BRAND_CODE = T1.PRODUCT_BRAND_CODE,
				   PRODUCT_CATEGORY_CODE = T1.PRODUCT_CATEGORY_CODE,
				   PRODUCT_CODE = T1.PRODUCT_CODE,
				   CODE1 = T3.CODE,
				   CODE_NAME1 = T3.CODE_NAME,
				   CODE2 =T5.CODE, 
				   CODE_NAME2 =  T5.CODE_NAME,
				   INVITATION_URL = T7.INVITATION_URL, 
				   WEDDINGDATE = T7.WEDDINGDATE,	
				   REFUND_STATUS_CODE = T8.REFUND_STATUS_CODE,
				   REFUND_TYPE_CODE = T8.REFUND_TYPE_CODE,

				   
동의여부 = (
	select top 1 CHK_SMS from bar_shop1.dbo.s2_userinfo
	where uid = T.[User_ID]
	)
	
	,
예식장소  = (


	select top 1 c.Weddinghall_Name /*,c.WeddingHallDetail, c.Weddinghall_Address*/ 
	from tb_order a inner join 
		TB_Invitation b on a.order_id = b.order_id inner join 
		TB_Invitation_Detail c on b.Invitation_ID = c.Invitation_ID
where a.user_id = T.[User_ID] and a.Payment_Status_Code = 'PSC02'
)


	
			FROM [TB_ORDER] AS T
					INNER JOIN [TB_ORDER_PRODUCT] AS T0 ON T.[ORDER_ID] = T0.[ORDER_ID]
					INNER JOIN [TB_PRODUCT] AS T1 ON T0.[PRODUCT_ID] = T1.[PRODUCT_ID]
					INNER JOIN (
									SELECT [T2].[CODE_GROUP], [T2].[CODE], [T2].[CODE_NAME], [T2].[EXTRA_CODE], [T2].[REGIST_DATETIME],
										   [T2].[REGIST_IP], [T2].[REGIST_USER_ID], [T2].[SORT], [T2].[UPDATE_DATETIME], [T2].[UPDATE_IP], 
										   [T2].[UPDATE_USER_ID]
									FROM [TB_COMMON_CODE] AS [T2]
									WHERE [T2].[CODE_GROUP] = 'PAYMENT_STATUS_CODE'
								) AS [T3] ON T.[PAYMENT_STATUS_CODE] = [T3].[CODE]
					INNER JOIN (
									SELECT [T4].[CODE_GROUP], [T4].[CODE], [T4].[CODE_NAME], [T4].[EXTRA_CODE], [T4].[REGIST_DATETIME], [T4].[REGIST_IP], [T4].[REGIST_USER_ID], [T4].[SORT], [T4].[UPDATE_DATETIME], [T4].[UPDATE_IP], [T4].[UPDATE_USER_ID]
									FROM [TB_COMMON_CODE] AS [T4]
									WHERE [T4].[CODE_GROUP] = 'PAYMENT_METHOD_CODE'
								) AS [T5] ON T.[PAYMENT_METHOD_CODE] = [T5].[CODE]
					INNER JOIN [TB_INVITATION] AS [T6] ON T.[ORDER_ID] = [T6].[ORDER_ID]
					INNER JOIN [TB_INVITATION_DETAIL] AS [T7] ON [T6].[INVITATION_ID] = [T7].[INVITATION_ID]
					LEFT JOIN [TB_REFUND_INFO] AS [T8] ON T.[ORDER_ID] = [T8].[ORDER_ID]

			WHERE	(
						T.[PAYMENT_METHOD_CODE] IS NOT NULL AND ((T.[PAYMENT_METHOD_CODE] <> '') OR T.[PAYMENT_METHOD_CODE] IS NULL
					)

					) AND 
					(
						CONVERT(VARCHAR(10), T.[REGIST_DATETIME], 120) BETWEEN  CONVERT(VARCHAR(10), @START_DATE, 120) AND  CONVERT(VARCHAR(10), @END_DATE, 120)
					)
		) TB

 END ELSE BEGIN 

	SELECT * INTO #ORDER_LIST2 
	FROM (  
			SELECT 주문사이트 = (
									SELECT TOP 1 CASE WHEN A.SALES_GUBUN = 'BM' THEN 'M' 
																WHEN A.SALES_GUBUN = 'SB' THEN '바른손' 
																WHEN A.SALES_GUBUN = 'SA' THEN '비핸즈' 
																WHEN A.SALES_GUBUN = 'ST' THEN '더카드' 
																WHEN A.SALES_GUBUN = 'SS' THEN '프리미어' 
																WHEN A.SALES_GUBUN = 'B' OR A.SALES_GUBUN = 'H' THEN '바른손몰' 	
												  ELSE  '바른손몰' END

									FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
										 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
									WHERE STATUS_SEQ >= 9 AND  MEMBER_ID = T.[USER_ID] 
									GROUP BY A.SALES_GUBUN
								),
				   [USER_ID] = T.[USER_ID], 
				   ORDER_ID = T.ORDER_ID,
				   EMAIL = [T].[EMAIL],
				   CELLPHONE_NUMBER = T.CELLPHONE_NUMBER, 
				   COUPON_PRICE = T.COUPON_PRICE, 
				   [NAME] = T.[NAME],
				   ORDER_CODE = T.ORDER_CODE, 
				   ORDER_DATETIME = T.ORDER_DATETIME, 
				   ORDER_PATH = T.ORDER_PATH,
				   ORDER_PRICE = T.ORDER_PRICE, 
				   PAYMENT_DATETIME = T.PAYMENT_DATETIME,
				   PAYMENT_STATUS_CODE = [T].[PAYMENT_STATUS_CODE],
				   PAYMENT_PATH = T.PAYMENT_PATH, 
				   PAYMENT_PRICE = T.PAYMENT_PRICE,
				   REGIST_DATETIME1 = T.REGIST_DATETIME, 
				   PRODUCT_ID = T0.PRODUCT_ID,
				   PRODUCT_BRAND_CODE = T1.PRODUCT_BRAND_CODE,
				   PRODUCT_CATEGORY_CODE = T1.PRODUCT_CATEGORY_CODE,
				   PRODUCT_CODE = T1.PRODUCT_CODE,
				   CODE1 = T3.CODE,
				   CODE_NAME1 = T3.CODE_NAME,
				   CODE2 =T5.CODE, 
				   CODE_NAME2 =  T5.CODE_NAME,
				   INVITATION_URL = T7.INVITATION_URL, 
				   WEDDINGDATE = T7.WEDDINGDATE,	
				   REFUND_STATUS_CODE = T8.REFUND_STATUS_CODE,
				   REFUND_TYPE_CODE = T8.REFUND_TYPE_CODE
	
			FROM [TB_ORDER] AS T
					INNER JOIN [TB_ORDER_PRODUCT] AS T0 ON T.[ORDER_ID] = T0.[ORDER_ID]
					INNER JOIN [TB_PRODUCT] AS T1 ON T0.[PRODUCT_ID] = T1.[PRODUCT_ID]
					INNER JOIN (
									SELECT [T2].[CODE_GROUP], [T2].[CODE], [T2].[CODE_NAME], [T2].[EXTRA_CODE], [T2].[REGIST_DATETIME],
										   [T2].[REGIST_IP], [T2].[REGIST_USER_ID], [T2].[SORT], [T2].[UPDATE_DATETIME], [T2].[UPDATE_IP], 
										   [T2].[UPDATE_USER_ID]
									FROM [TB_COMMON_CODE] AS [T2]
									WHERE [T2].[CODE_GROUP] = 'PAYMENT_STATUS_CODE'
								) AS [T3] ON T.[PAYMENT_STATUS_CODE] = [T3].[CODE]
					INNER JOIN (
									SELECT [T4].[CODE_GROUP], [T4].[CODE], [T4].[CODE_NAME], [T4].[EXTRA_CODE], [T4].[REGIST_DATETIME], [T4].[REGIST_IP], [T4].[REGIST_USER_ID], [T4].[SORT], [T4].[UPDATE_DATETIME], [T4].[UPDATE_IP], [T4].[UPDATE_USER_ID]
									FROM [TB_COMMON_CODE] AS [T4]
									WHERE [T4].[CODE_GROUP] = 'PAYMENT_METHOD_CODE'
								) AS [T5] ON T.[PAYMENT_METHOD_CODE] = [T5].[CODE]
					INNER JOIN [TB_INVITATION] AS [T6] ON T.[ORDER_ID] = [T6].[ORDER_ID]
					INNER JOIN [TB_INVITATION_DETAIL] AS [T7] ON [T6].[INVITATION_ID] = [T7].[INVITATION_ID]
					LEFT JOIN [TB_REFUND_INFO] AS [T8] ON T.[ORDER_ID] = [T8].[ORDER_ID]

			WHERE	(
						T.[PAYMENT_METHOD_CODE] IS NOT NULL AND ((T.[PAYMENT_METHOD_CODE] <> '') OR T.[PAYMENT_METHOD_CODE] IS NULL)

					) AND 
					(
						CONVERT(VARCHAR(10), T.PAYMENT_DATETIME, 120) BETWEEN  CONVERT(VARCHAR(10), @START_DATE, 120) AND  CONVERT(VARCHAR(10), @END_DATE, 120)
					)

		) TB



 END 


 IF @SEARCHMEMBERYN = '1' BEGIN -- 회원검색

	IF @SEARCHKIND IS NOT NULL AND @SEARCHKIND <> '' BEGIN  -- 분류검색 
	
		IF @SEARCHBRAND IS NOT NULL AND @SEARCHBRAND <> '' BEGIN --브랜드검색 

				IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태검색 (취소/환불) 
							
							IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어검색 

									IF @SEARCHPERIOD = 'ORDER' BEGIN  -- 회원/ 분류/ 브랜드/ (취소/환불) /검색어
											
												SELECT * 
												FROM #ORDER_LIST1
												WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
														(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
														(PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
														(
														(
															(
																(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
															) OR
															(
																@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
															)
														) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
														)
												ORDER BY REGIST_DATETIME1 DESC

									END ELSE BEGIN   -- 결제일로 검색
											
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )

													ORDER BY PAYMENT_DATETIME DESC
									END 
							
							END ELSE BEGIN  --검색어X 


									IF @SEARCHPERIOD = 'ORDER' BEGIN    -- 회원/ 분류/ 브랜드/ (취소/환불)
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
												ORDER BY REGIST_DATETIME1 DESC

									END ELSE BEGIN   -- 결제일로 검색
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
												ORDER BY PAYMENT_DATETIME DESC

									END 
													

							END 

				END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN   -- 결제상태검색 (결제완료/입금대기)

							IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

									IF @SEARCHPERIOD = 'ORDER' BEGIN   -- 주문일로 검색 -- 회원/ 분류/ 브랜드/ (결제완료/입금대기) /검색어
										SELECT * 
										FROM #ORDER_LIST1 
										WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
												(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
												PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
												(
												(
													(
														(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
														OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
													) OR
													(
														@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
													)
												) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
												)
										ORDER BY REGIST_DATETIME1 DESC

									END ELSE BEGIN 
										SELECT * 
													FROM #ORDER_LIST2 
													WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															(
															(
																(
																	(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																	OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																) OR
																(
																	@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																)
															) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															)
										ORDER BY PAYMENT_DATETIME DESC

									END 
													

							
							END ELSE BEGIN 


										IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
											ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
											ORDER BY PAYMENT_DATETIME DESC

										END 
													

							END 

									
				END ELSE BEGIN -- 결제상태검색 (전체)
						
							IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

									IF @SEARCHPERIOD = 'ORDER' BEGIN   -- 회원/ 분류/ 브랜드/ /검색어

											SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
											ORDER BY REGIST_DATETIME1 DESC
									END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
										ORDER BY PAYMENT_DATETIME DESC
									END 
														

							END ELSE BEGIN    --검색어X 

									IF @SEARCHPERIOD = 'ORDER' BEGIN   -- 회원/ 분류/ 브랜드/
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
											ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 

											SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
											ORDER BY PAYMENT_DATETIME DESC			


									END 
													

							END 


							END


		END ELSE BEGIN 

	

							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
											ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
											ORDER BY PAYMENT_DATETIME DESC

											END
														
							
											END ELSE BEGIN 

												IF @SEARCHPERIOD = 'ORDER' BEGIN 
													SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
														ORDER BY REGIST_DATETIME1 DESC

												END ELSE BEGIN 
													SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
													ORDER BY PAYMENT_DATETIME DESC
												END 
													


											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 


										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										
														SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )

														ORDER BY REGIST_DATETIME1 DESC
										END ELSE BEGIN 
										
														SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC

										END 


							
										END ELSE BEGIN 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
														ORDER BY PAYMENT_DATETIME DESC

											END 
													

										END 

									
							END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
											ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
										SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC

										END
														
							
										END ELSE BEGIN 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
										ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 

										SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
											
											ORDER BY PAYMENT_DATETIME DESC
										END 
														


										END 


							END


					END 

	END ELSE BEGIN  --분류없음

			IF @SEARCHBRAND IS NOT NULL AND @SEARCHBRAND <> '' BEGIN --브랜드 

							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

														 IF @SEARCHPERIOD = 'ORDER' BEGIN -- 회원/분류/
																SELECT * 
																FROM #ORDER_LIST1 
																WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
																	  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
																	  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
																	  (
																		(
																			(
																				(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																				OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																			) OR
																			(
																				@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																			)
																		) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
																	  ) ORDER BY REGIST_DATETIME1 DESC

														 END ELSE BEGIN 

														 	SELECT * 
															FROM #ORDER_LIST2 
															WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
																  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
																  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
																  (
																	(
																		(
																			(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																			OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																		) OR
																		(
																			@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																		)
																	) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
																  )
																  ORDER BY PAYMENT_DATETIME DESC
														 END 
													

							
											END ELSE BEGIN 

											 IF @SEARCHPERIOD = 'ORDER' BEGIN 

											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 

ORDER BY REGIST_DATETIME1 DESC
											 END ELSE BEGIN 


											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
ORDER BY PAYMENT_DATETIME DESC

											 END 
														

											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC
	

										 END ELSE BEGIN 

										 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC
										 END 
														

							
										END ELSE BEGIN 

										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 	SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC

										 END ELSE BEGIN 

										 	SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC

										 END 
													


										END 

									
							END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 


										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )ORDER BY REGIST_DATETIME1 DESC


										 END ELSE BEGIN 
										 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC


										 END 
														
							
										END ELSE BEGIN 


											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
														ORDER BY REGIST_DATETIME1 DESC

											 END ELSE BEGIN 
											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
														
														ORDER BY PAYMENT_DATETIME DESC
											 END 
															


										END 


							END


			END ELSE BEGIN  --브랜드없음


							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 


											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

											 END ELSE BEGIN 

											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC

											 END 
														
							
											END ELSE BEGIN 

											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY REGIST_DATETIME1 DESC

											 END ELSE BEGIN 
											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY PAYMENT_DATETIME DESC

											 END 
														


											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 	SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)

															  )
															  ORDER BY REGIST_DATETIME1 DESC

											 END ELSE BEGIN 
											 	SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  	
ORDER BY PAYMENT_DATETIME DESC

											 END 
													

							
										END ELSE BEGIN 

										 IF @SEARCHPERIOD = 'ORDER' BEGIN 

										 	SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC
										 END ELSE BEGIN 
										 	SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC

										 END 
													


										END 

									
							END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										 IF @SEARCHPERIOD = 'ORDER' BEGIN 

										 	SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY REGIST_DATETIME1 DESC

							
										 END ELSE BEGIN 
										 	SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] <> ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC

							

										 END 
													
										END ELSE BEGIN -- 회원
										
											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
												FROM #ORDER_LIST1 
												WHERE [USER_ID] <> ''  --AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
												-- (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
												ORDER BY REGIST_DATETIME1 DESC
											 END ELSE BEGIN 

												SELECT * 
												FROM #ORDER_LIST2 
												WHERE [USER_ID] <> '' -- AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
													--  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
												ORDER BY PAYMENT_DATETIME DESC				
											 END 
														


										END 


							END


					END 




	END 




 END ELSE IF @SEARCHMEMBERYN = '0' BEGIN -- 비회원

    IF @SEARCHKIND IS NOT NULL AND @SEARCHKIND <> '' BEGIN  -- 분류있고 
	
			IF @SEARCHBRAND IS NOT NULL AND @SEARCHBRAND <> '' BEGIN --브랜드 

							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

											 END ELSE BEGIN 

											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC
											 END 
														
							
											END ELSE BEGIN 

											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY REGIST_DATETIME1 DESC

											 END ELSE BEGIN 
											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY PAYMENT_DATETIME DESC

											 END 
														

											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 


											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY REGIST_DATETIME1 DESC


											 END ELSE BEGIN
											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC


											 END 
														
							
										END ELSE BEGIN 

										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC

										 END ELSE BEGIN 
										 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC
										 END 
														


										END 

									
							END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 


										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY REGIST_DATETIME1 DESC

										 END ELSE BEGIN 

										 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC

										 END 
														

							
										END ELSE BEGIN 

											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 	SELECT * 
														FROM #ORDER_LIST1
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
															ORDER BY REGIST_DATETIME1 DESC
											 END ELSE BEGIN 

											 	SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) 
															  ORDER BY PAYMENT_DATETIME DESC
															
											 END 
													


										END 


							END


					END ELSE BEGIN 

	

							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 


											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 	SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC
	

											 END ELSE BEGIN 
											 	SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC

											 END 
													
							
											END ELSE BEGIN 

											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY REGIST_DATETIME1 DESC

											 END ELSE BEGIN 
											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY PAYMENT_DATETIME DESC

											 END 
														


											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

										 END ELSE BEGIN 
										 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC

										 END 
														
							
										END ELSE BEGIN 


										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC

										 END ELSE BEGIN 
										 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC


										 END 
														

										END 

									
							END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY REGIST_DATETIME1 DESC


										 END ELSE BEGIN 
										 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC


										 END 
														
							
										END ELSE BEGIN 

										 IF @SEARCHPERIOD = 'ORDER' BEGIN 
										 	SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
														ORDER BY REGIST_DATETIME1 DESC

										 END ELSE BEGIN 
										 	SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
														ORDER BY PAYMENT_DATETIME DESC

										 END 
														


										END 


							END


					END 

	END ELSE BEGIN  --분류없음

			IF @SEARCHBRAND IS NOT NULL AND @SEARCHBRAND <> '' BEGIN --브랜드 

							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = '' AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )

															  ORDER BY REGIST_DATETIME1 DESC
											 END ELSE BEGIN 
											 SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = '' AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )

															  ORDER BY PAYMENT_DATETIME DESC
											 END 
														
							
											END ELSE BEGIN 


											
											 IF @SEARCHPERIOD = 'ORDER' BEGIN 
											 	SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY REGIST_DATETIME1 DESC

											 END ELSE BEGIN 
											 	SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0))
															  ORDER BY PAYMENT_DATETIME DESC

											 END 
													


											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															   ORDER BY REGIST_DATETIME1 DESC
							

										END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC

							

										END
													
										END ELSE BEGIN 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC


											END ELSE BEGIN 

												SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC


											END 
													

										END 

									
							END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 


										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										
														SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
										
														SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC

										END 

							
										END ELSE BEGIN 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 

											SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) 
															  ORDER BY REGIST_DATETIME1 DESC
											END ELSE BEGIN 

											SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))  
															  ORDER BY PAYMENT_DATETIME DESC
											END 
														
															


										END 


							END


			END ELSE BEGIN  --브랜드없음 

	
							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

													IF @SEARCHPERIOD = 'ORDER' BEGIN 
													
														SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															   ORDER BY REGIST_DATETIME1 DESC
													END ELSE BEGIN 

													
														SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC
													END 


							
											END ELSE BEGIN 


											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY REGIST_DATETIME1 DESC
											END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
ORDER BY PAYMENT_DATETIME DESC
											END 
													


											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''   AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  	 ORDER BY REGIST_DATETIME1 DESC
							

											END ELSE BEGIN 

											SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''   AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC

							
											END 
														
										END ELSE BEGIN 


										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										
														SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''   AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 

										
														SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''   AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC

										END 


										END 

									
							END ELSE BEGIN  
									
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 
										-- 비회원/검색어
											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
												FROM #ORDER_LIST1 
												WHERE [USER_ID] = '' 
												AND  
														(
															(
																(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
															) OR
															(
																@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
															)
														) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)

												
												--AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
														--(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
														--(
														--(
														--	(
														--		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
														--		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
														--	) OR
														--	(
														--		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
														--	)
														--) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
														--)
												ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE [USER_ID] = ''  
															AND  
														(
															(
																(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
															) OR
															(
																@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
															)
														) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)

												

														
														--AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															 -- (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 -- (
																--(
																--	(
																--		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																--		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																--	) OR
																--	(
																--		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																--	)
																--) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															 -- )

											ORDER BY PAYMENT_DATETIME DESC
											END 
														
										END ELSE BEGIN   --검색어X

										-- 비회원
										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										SELECT * 
														FROM #ORDER_LIST1 
														WHERE [USER_ID] = ''  --AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  --(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
										ORDER BY REGIST_DATETIME1 DESC
										END ELSE BEGIN 
											SELECT * 
											FROM #ORDER_LIST2 
											WHERE [USER_ID] = ''  --AND (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
													--(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))  
											ORDER BY PAYMENT_DATETIME DESC
															
										END 
														


										END 


							END


			END 




	END 


 END ELSE BEGIN -- 회원/비회원 모두 
 	
					
	IF @SEARCHKIND IS NOT NULL AND @SEARCHKIND <> '' BEGIN  -- 분류있고 
	
		IF @SEARCHBRAND IS NOT NULL AND @SEARCHBRAND <> '' BEGIN --브랜드 
		
			IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
						
						IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  -- 검색어 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										-- 분류/브랜드/결제상태(취소/환불)/검색어 
												SELECT * 
												FROM #ORDER_LIST1 
												WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
														(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
														(PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
														(
														(
															(
																(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
															) OR
															(
																@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
															)
														) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
												ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
												SELECT * 
												FROM #ORDER_LIST2 
												WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
														(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
														(PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
														(
														(
															(
																(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
															) OR
															(
																@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
															)
														) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
														)
												ORDER BY PAYMENT_DATETIME DESC


										END 
													

							
						END ELSE BEGIN   --검색어미존재 


										IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
ORDER BY REGIST_DATETIME1 DESC
											END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
ORDER BY PAYMENT_DATETIME DESC
											END 
													


						END 

			END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN   -- 결제상태검색 (결제완료/입금대기)

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC

											END 
														
							
										END ELSE BEGIN  --검색어 미존재

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE   (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS

															 ORDER BY REGIST_DATETIME1 DESC
										END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE   (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC

										END 
													

										END 

									
			END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC

											END 
													

							
										END ELSE BEGIN 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										SELECT * 
														FROM #ORDER_LIST1 
														WHERE   (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
ORDER BY REGIST_DATETIME1 DESC
										END ELSE BEGIN 
										SELECT * 
														FROM #ORDER_LIST2 
														WHERE   (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
																
ORDER BY PAYMENT_DATETIME DESC
										END 
														


										END 


							END


		END ELSE BEGIN  -- 브랜드없음
		

			IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

												IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC
							

												END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )

							ORDER BY PAYMENT_DATETIME DESC

												END 
														
											END ELSE BEGIN 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY PAYMENT_DATETIME DESC

											END 
													

											END 

			END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN   -- 결제상태검색 (결제완료/입금대기)

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
										SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )

															  ORDER BY PAYMENT_DATETIME DESC
										END 
														
							
										END ELSE BEGIN 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC
	

											END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC
											END 


													


										END 

									
			END ELSE BEGIN 
		
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC
							

											END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC

							

											END 
													
										END ELSE BEGIN 

										---분류 
										IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) --AND 
															  --(PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))  
												ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0))-- AND 
															 -- (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
											ORDER BY PAYMENT_DATETIME DESC
										END 
													
															


										END 


							END


					END 

	END ELSE BEGIN  --분류없음

			IF @SEARCHBRAND IS NOT NULL AND @SEARCHBRAND <> '' BEGIN --브랜드 
		
							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC


											END 
														
							
											END ELSE BEGIN  --검색어 X
												IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 

ORDER BY REGIST_DATETIME1 DESC
												END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 

ORDER BY PAYMENT_DATETIME DESC
												END 
														

											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
										
														SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
										
														SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )ORDER BY PAYMENT_DATETIME DESC

										END 

							
										END ELSE BEGIN 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS

ORDER BY PAYMENT_DATETIME DESC
										END 

													

										END 

									
							END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										IF @SEARCHPERIOD = 'ORDER' BEGIN  -- 브랜드
										SELECT * 
														FROM #ORDER_LIST1 
														WHERE --(PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
										SELECT * 
														FROM #ORDER_LIST2 
														WHERE-- (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC

										END 
														
							
										END ELSE BEGIN 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE -- (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
ORDER BY REGIST_DATETIME1 DESC
										END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE -- (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0))   
															
ORDER BY PAYMENT_DATETIME DESC
										END 
													


										END 


							END


			END ELSE BEGIN 

	

							IF @SEARCHPAYMENTSTATUS = 'PSC03_PSC05' BEGIN -- 결제상태 
							
											IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

												IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC
							

												END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )

												ORDER BY PAYMENT_DATETIME DESC

												END 
														
											END ELSE BEGIN 

												IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY REGIST_DATETIME1 DESC
												END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (PAYMENT_STATUS_CODE LIKE '' OR (CHARINDEX(PAYMENT_STATUS_CODE, @SEARCHPAYMENTSTATUS) > 0)) 
															  ORDER BY PAYMENT_DATETIME DESC
												END 


														


											END 

							END ELSE IF @SEARCHPAYMENTSTATUS != 'ALL' BEGIN  

										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
														FROM #ORDER_LIST1 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
												SELECT * 
														FROM #ORDER_LIST2 
														WHERE (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS AND 
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY PAYMENT_DATETIME DESC
											END 
													

							
										END ELSE BEGIN 

											IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY REGIST_DATETIME1 DESC
											END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															 PAYMENT_STATUS_CODE = @SEARCHPAYMENTSTATUS
															 ORDER BY PAYMENT_DATETIME DESC

											END 
														


										END 

									
							END ELSE BEGIN 
						
										IF @SEARCHTXT IS NOT NULL AND @SEARCHTXT <> '' BEGIN  --검색어 

										IF @SEARCHPERIOD = 'ORDER' BEGIN 
											SELECT * 
														FROM #ORDER_LIST1 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  )
															  ORDER BY REGIST_DATETIME1 DESC

										END ELSE BEGIN 
											SELECT * 
														FROM #ORDER_LIST2 
														WHERE  (PRODUCT_CATEGORY_CODE LIKE '' OR (CHARINDEX(PRODUCT_CATEGORY_CODE, @SEARCHKIND) > 0)) AND 
															  (PRODUCT_BRAND_CODE LIKE '' OR (CHARINDEX(PRODUCT_BRAND_CODE, @SEARCHBRAND) > 0)) AND  
															  (
																(
																	(
																		(@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,[NAME]) > 0) 
																		OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT,EMAIL) > 0)
																	) OR
																	(
																		@SEARCHTXT LIKE '' OR (CHARINDEX(@SEARCHTXT, ORDER_CODE) > 0)
																	)
																) OR (@SEARCHTXT LIKE '' OR CHARINDEX(@SEARCHTXT, [USER_ID]) > 0)
															  ) ORDER BY PAYMENT_DATETIME DESC

										END 


													
							
										END ELSE BEGIN -- 회원/비회원구분없고 조건값 없음 
										
											IF @SEARCHPERIOD = 'ORDER' BEGIN 
												SELECT * 
												FROM #ORDER_LIST1 
												ORDER BY REGIST_DATETIME1 DESC

											END ELSE BEGIN 
												SELECT * 
												FROM #ORDER_LIST2 
												ORDER BY PAYMENT_DATETIME DESC

											END 
													 
															


										END 


							END


					END 




	END 




 END 

GO
