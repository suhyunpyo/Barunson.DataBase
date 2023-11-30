IF OBJECT_ID (N'dbo.SP_S_USER_ORDER_COUPON_lIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_USER_ORDER_COUPON_lIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_USER_ORDER_COUPON_lIST]
/***************************************************************
작성자	:	표수현
작성일	:	2021-02-15
DESCRIPTION	:	
SPECIAL LOGIC	:  
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
-- SP_S_USER_ORDER_COUPON_lIST 'thdxowjd' ,'MC1228'
-- SP_S_USER_ORDER_COUPON_lIST 'vyrudaks8888' ,'MC1228'
******************************************************************/
 @USER_ID	VARCHAR(50)  = 'vyrudaks8888',
 @PRODUCT_CODE VARCHAR(10) = 'MC1228'
AS
SELECT T.Coupon_ID, T.Coupon_Image_URL, T.Coupon_Name, 
		T.[Description], T.Discount_Method_Code, T.Discount_Price, T.Discount_Rate, 
		T.Period_Method_Code, T.Publish_End_Date, T.Publish_Method_Code, T.Publish_Period_Code, 
		T.Publish_Start_Date, T.Publish_Target_Code, T.Regist_DateTime, T.Regist_IP, T.Regist_User_ID, 
		T.Standard_Purchase_Price, T.Update_DateTime, T.Update_IP, T.Update_User_ID, T.Use_Available_Standard_Code, T.Use_YN, 
		[t1].[Coupon_Publish_ID], [t1].[Coupon_ID], [t1].[Expiration_Date], [t1].[Regist_DateTime], [t1].[Regist_IP], t1.Regist_User_ID,
		[t1].[Retrieve_DateTime], [t1].[Update_DateTime], [t1].[Update_IP], [t1].[Update_User_ID], [t1].[Use_DateTime], t1.Use_YN, 
		[t1].[User_ID],
		T.Coupon_Apply_Code, -- CET01 상품전체 CET02 지정 상품 적용 CET03 지정 상품 제외
		T.Coupon_Apply_Product_ID,
		COUPON_PRODUCT_YN = (
								case when  T.Coupon_Apply_Code = 'CET02' then
											(	
												select COUNT(1) 
												from TB_Apply_Product 
												where	Product_Apply_ID = T.Coupon_Apply_Product_ID 
														and Product_Code in (@PRODUCT_CODE)
											)
									when  T.Coupon_Apply_Code = 'CET03' then
											(
												select  case when COUNT(1) = 0 then
															1 ELSE 0 END 
												from TB_Apply_Product 
												where	Product_Apply_ID  = T.Coupon_Apply_Product_ID 
														and Product_Code  in (@PRODUCT_CODE))
									ELSE 1 END
								)
FROM TB_Coupon T
INNER JOIN (
    SELECT 
	[t0].[Coupon_Publish_ID], 
	[t0].[Coupon_ID], 
	[t0].[Expiration_Date], 
	[t0].[Regist_DateTime], 
	[t0].[Regist_IP], [t0].[Regist_User_ID], [t0].[Retrieve_DateTime],
	[t0].[Update_DateTime], [t0].[Update_IP],
	[t0].[Update_User_ID], [t0].[Use_DateTime], 
	[t0].[Use_YN], 
	[t0].[User_ID]
    FROM [TB_Coupon_Publish] AS [t0]
    WHERE (([t0].[User_ID] = @USER_ID) AND ([t0].[Retrieve_DateTime] IS NULL OR 
	(CONVERT(VARCHAR(100), [t0].[Retrieve_DateTime]) = N''))) AND ([t0].[Use_YN] = 'N')

) AS [t1] ON T.Coupon_ID = [t1].[Coupon_ID]
UNION ALL
SELECT T.Coupon_ID, T.Coupon_Image_URL, T.Coupon_Name, 
		T.[Description], T.Discount_Method_Code, T.Discount_Price, T.Discount_Rate, 
		T.Period_Method_Code, T.Publish_End_Date, 'PMC02' Publish_Method_Code, T.Publish_Period_Code, 
		T.Publish_Start_Date, '' Publish_Target_Code, T.Regist_DateTime, T.Regist_IP, T.Regist_User_ID, 
		T.Standard_Purchase_Price, T.Update_DateTime, T.Update_IP, T.Update_User_ID, T.Use_Available_Standard_Code, T.Use_YN, 
		[t1].[Coupon_Publish_ID], [t1].[Coupon_ID], [t1].[Expiration_Date], [t1].[Regist_DateTime], [t1].[Regist_IP], t1.Regist_User_ID,
		[t1].[Retrieve_DateTime], [t1].[Update_DateTime], [t1].[Update_IP], [t1].[Update_User_ID], [t1].[Use_DateTime], t1.Use_YN, 
		[t1].[User_ID],
		T.Coupon_Apply_Code, -- CET01 상품전체 CET02 지정 상품 적용 CET03 지정 상품 제외
		T.Coupon_Apply_Product_ID,
		COUPON_PRODUCT_YN = (
								case when  T.Coupon_Apply_Code = 'CET02' then
											(	
												select COUNT(1) 
												from TB_Serial_Apply_Product 
												where	Product_Apply_ID = T.Coupon_Apply_Product_ID 
														and Product_Code in (@PRODUCT_CODE)
											)
									when  T.Coupon_Apply_Code = 'CET03' then
											(
												select  case when COUNT(1) = 0 then
															1 ELSE 0 END 
												from TB_Serial_Apply_Product 
												where	Product_Apply_ID  = T.Coupon_Apply_Product_ID 
														and Product_Code  in (@PRODUCT_CODE))
									ELSE 1 END
								)
FROM TB_Serial_Coupon T
INNER JOIN (
    SELECT 
	[t0].[Coupon_Publish_ID], 
	[t0].[Coupon_ID], 
	[t0].[Expiration_Date], 
	[t0].[Regist_DateTime], 
	[t0].[Regist_IP], [t0].[Regist_User_ID], [t0].[Retrieve_DateTime],
	[t0].[Update_DateTime], [t0].[Update_IP],
	[t0].[Update_User_ID], [t0].[Use_DateTime], 
	[t0].[Use_YN], 
	[t0].[User_ID]
    FROM [TB_Serial_Coupon_Publish] AS [t0]
    WHERE (([t0].[User_ID] = @USER_ID) AND ([t0].[Retrieve_DateTime] IS NULL OR 
	(CONVERT(VARCHAR(100), [t0].[Retrieve_DateTime]) = N''))) AND ([t0].[Use_YN] = 'N')

) AS [t1] ON T.Coupon_ID = [t1].[Coupon_ID]
ORDER BY T.Discount_Method_Code DESC, T.Discount_Rate DESC, T.Discount_Price DESC


GO
