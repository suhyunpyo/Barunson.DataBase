IF OBJECT_ID (N'dbo.SP_S_ADMIN_ORDER_LIST2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_ORDER_LIST2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_ADMIN_ORDER_LIST2]
/***************************************************************
작성자	:	표수현
작성일	:	2021-05-26
DESCRIPTION	:	ADMIN - 회원관리 - 주문한 회원목록 
SPECIAL LOGIC	: SP_S_ADMIN_ORDER_MEMBER '2021-05-19', '2021-05-26' , 'ALL', NULL
SP_S_ADMIN_ORDER_MEMBER '2021-05-19', '2021-05-26' , 'ALL',	'브'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/

 @Start_Date varchar(10) = '2021-10-01',
 @End_Date varchar(10) = '2021-10-31',
 @SearchPeriod varchar(10) = 'Order'  --주문일 / 결재일
 -- @SearchMemberYn varchar(10) = null,
 -- @SearchKind varchar(100) = null,
 --@SearchBrand  varchar(100) = null,
 --@SearchPaymentStatus varchar(10) = 'ALL',
 -- @Searchtxt  varchar(100) = null --검색어 

AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 
 
 if @SearchPeriod = 'Order' begin 

-- DECLARE @Start_Date datetime = '2021-10-01'
--DECLARE @End_Date datetime = '2021-10-31'
--drop table #TOTAL_ORDER_LISt  
 SELECT 
		
	주문사이트 =  (select top 1 CASE WHEN A.SALES_GUBUN = 'BM' THEN 'M' 
											WHEN A.SALES_GUBUN = 'SB' THEN '바른손' 
											WHEN A.SALES_GUBUN = 'SA' THEN '비핸즈' 
											WHEN A.SALES_GUBUN = 'ST' THEN '더카드' 
											WHEN A.SALES_GUBUN = 'SS' THEN '프리미어' 
											WHEN A.SALES_GUBUN = 'B' OR A.SALES_GUBUN = 'H' THEN '바른손몰' 	
												ELSE '' END

		FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
			 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
		WHERE STATUS_SEQ >= 9 and  MEMBER_ID = [t].[USER_ID] 
		GROUP BY A.SALES_GUBUN
	
	),
	[t].[User_ID],
		[t].[Order_ID], [t].[Account_Number], [t].[Cancel_DateTime], 
		[t].[Cancel_Time], [t].[Card_Installment], [t].[CashReceipt_Publish_YN],
		[t].[CellPhone_Number], [t].[Coupon_Price], [t].[Deposit_DeadLine_DateTime], 
		[t].[Email], [t].[Escrow_YN], [t].[Finance_Auth_Number], [t].[Finance_Name], [t].[Name],
		[t].[Noint_YN], [t].[Order_Code], [t].[Order_DateTime], [t].[Order_Path], [t].[Order_Price], 
		[t].[Order_Status_Code], [t].[PG_ID], [t].[Payer_Name], [t].[Payment_DateTime], [t].[Payment_Method_Code], 
		[t].[Payment_Path], [t].[Payment_Price], [t].[Payment_Status_Code], [t].[Previous_Order_ID], 
		Regist_DateTime1 = [t].[Regist_DateTime], [t].[Trading_Number], 
	[t0].[Product_ID], [t0].[Item_Count], 
		[t0].[Item_Price], [t0].[Product_Type_Code], Regist_DateTime2 = [t0].[Regist_DateTime], 
		[t0].[Total_Price],
		 [t1].[Display_YN], [t1].[Main_Image_URL], [t1].[Original_Product_Code],
		[t1].[Preview_Image_URL], [t1].[Price], [t1].[Product_Brand_Code], [t1].[Product_Category_Code],
		[t1].[Product_Code], [t1].[Product_Description], [t1].[Product_Name], Regist_DateTime3 = [t1].[Regist_DateTime],
	
	 Code_Group1 = [t3].[Code_Group], Code1 = [t3].[Code], Code_Name1 = [t3].[Code_Name], --[t3].[Extra_Code], Regist_DateTime4 = [t3].[Regist_DateTime], 
		--[t3].[Sort],
	  Code2 =[t5].[Code], Code_Name2 =  [t5].[Code_Name], [t5].[Extra_Code],  Regist_DateTime5 = [t5].[Regist_DateTime],
		[t5].[Sort], [t6].[Invitation_ID], [t6].[Invitation_Display_YN], 
		 Regist_DateTime6 = [t6].[Regist_DateTime],
	[t7].[Bride_EngName], [t7].[Bride_Global_Phone_Number], [t7].[Bride_Global_Phone_YN],
		[t7].[Bride_Name], [t7].[Bride_Parents1_Global_Phone_Number], [t7].[Bride_Parents1_Global_Phone_Number_YN], [t7].[Bride_Parents1_Name],
		[t7].[Bride_Parents1_Phone], [t7].[Bride_Parents1_Title], [t7].[Bride_Parents2_Global_Phone_Number], [t7].[Bride_Parents2_Global_Phone_Number_YN], 
		[t7].[Bride_Parents2_Name], [t7].[Bride_Parents2_Phone], [t7].[Bride_Parents2_Title], [t7].[Bride_Phone], [t7].[Delegate_Image_Height],
		[t7].[Delegate_Image_URL], [t7].[Delegate_Image_Width], [t7].[Etc_Information_Use_YN], [t7].[Gallery_Type_Code], [t7].[Gallery_Use_YN], 
		[t7].[Greetings], [t7].[Groom_EngName], [t7].[Groom_Global_Phone_Number], [t7].[Groom_Global_Phone_YN], [t7].[Groom_Name], 
		[t7].[Groom_Parents1_Global_Phone_Number], [t7].[Groom_Parents1_Global_Phone_Number_YN], [t7].[Groom_Parents1_Name],
		[t7].[Groom_Parents1_Phone], [t7].[Groom_Parents1_Title], [t7].[Groom_Parents2_Global_Phone_Number], [t7].[Groom_Parents2_Global_Phone_Number_YN], 
		[t7].[Groom_Parents2_Name], [t7].[Groom_Parents2_Phone], [t7].[Groom_Parents2_Title], [t7].[Groom_Phone], [t7].[GuestBook_Use_YN],
		[t7].[Invitation_Title], [t7].[Invitation_URL], [t7].[Invitation_Video_Type_Code], [t7].[Invitation_Video_URL],
		[t7].[Invitation_Video_Use_YN], [t7].[Location_LAT], [t7].[Location_LOT], [t7].[MMS_Send_YN], [t7].[MoneyAccount_Remit_Use_YN],
		[t7].[MoneyGift_Remit_Use_YN], [t7].[Outline_Image_URL], [t7].[Outline_Type_Code], [t7].[Parents_Information_Use_YN],  Regist_DateTime7 = [t7].[Regist_DateTime],
		 [t7].[SNS_Image_Height], [t7].[SNS_Image_URL], [t7].[SNS_Image_Width], [t7].[Sender], [t7].[Time_Type_Code], 
		[t7].[Time_Type_Eng_YN], [t7].[WeddingDD], [t7].[WeddingDate],
		[t7].[WeddingHHmm], [t7].[WeddingHallDetail], [t7].[WeddingHour], [t7].[WeddingMM], [t7].[WeddingMin], [t7].[WeddingWeek], 
		[t7].[WeddingWeek_Eng_YN], [t7].[WeddingYY], [t7].[Weddinghall_Address], [t7].[Weddinghall_Name], [t7].[Weddinghall_PhoneNumber],
		[t8].[Refund_ID], [t8].[AccountNumber], [t8].[Bank_Type_Code], [t8].[Depositor_Name], [t8].[Refund_Content], [t8].[Refund_DateTime],
		[t8].[Refund_Price], [t8].[Refund_Status_Code], [t8].[Refund_Type_Code],  Regist_DateTime8 = [t8].[Regist_DateTime]
	
FROM [TB_Order] AS [t]
INNER JOIN [TB_Order_Product] AS [t0] ON [t].[Order_ID] = [t0].[Order_ID]
INNER JOIN [TB_Product] AS [t1] ON [t0].[Product_ID] = [t1].[Product_ID]
INNER JOIN (
    SELECT [t2].[Code_Group], [t2].[Code], [t2].[Code_Name], [t2].[Extra_Code], [t2].[Regist_DateTime], [t2].[Regist_IP], [t2].[Regist_User_ID], [t2].[Sort], [t2].[Update_DateTime], [t2].[Update_IP], [t2].[Update_User_ID]
    FROM [TB_Common_Code] AS [t2]
    WHERE [t2].[Code_Group] = 'Payment_Status_Code'
) AS [t3] ON [t].[Payment_Status_Code] = [t3].[Code]
INNER JOIN (
    SELECT [t4].[Code_Group], [t4].[Code], [t4].[Code_Name], [t4].[Extra_Code], [t4].[Regist_DateTime], [t4].[Regist_IP], [t4].[Regist_User_ID], [t4].[Sort], [t4].[Update_DateTime], [t4].[Update_IP], [t4].[Update_User_ID]
    FROM [TB_Common_Code] AS [t4]
    WHERE [t4].[Code_Group] = 'Payment_Method_Code'
) AS [t5] ON [t].[Payment_Method_Code] = [t5].[Code]
INNER JOIN [TB_Invitation] AS [t6] ON [t].[Order_ID] = [t6].[Order_ID]
INNER JOIN [TB_Invitation_Detail] AS [t7] ON [t6].[Invitation_ID] = [t7].[Invitation_ID]
LEFT JOIN [TB_Refund_Info] AS [t8] ON [t].[Order_ID] = [t8].[Order_ID]
--LEFT JOIN (
--			select top 1 MEMBER_ID, SALES_GUBUN = CASE WHEN A.SALES_GUBUN = 'BM' THEN 'M' 
--											WHEN A.SALES_GUBUN = 'SB' THEN '바른손' 
--											WHEN A.SALES_GUBUN = 'SA' THEN '비핸즈' 
--											WHEN A.SALES_GUBUN = 'ST' THEN '더카드' 
--											WHEN A.SALES_GUBUN = 'SS' THEN '프리미어' 
--											WHEN A.SALES_GUBUN = 'B' OR A.SALES_GUBUN = 'H' THEN '바른손몰' 	
--												ELSE '' END

--		FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
--			 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
--		WHERE STATUS_SEQ >= 9  --and  A.MEMBER_ID = 'zun0228'
--		GROUP BY A.MEMBER_ID, A.SALES_GUBUN

--		--SELECT MEMBER_ID, 
--		--	CARD_CODE = B.CARD_CODE, 
--		--	CASE WHEN COUNT(1) >= 0 THEN 'Y' ELSE 'N' END  AS ORDER_YN
--		--FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
--		--	 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
--		--WHERE STATUS_SEQ > 9
--		--GROUP BY MEMBER_ID, B.CARD_CODE	
--	) AS B
--		ON [t].[USER_ID]  = B.MEMBER_ID


WHERE	(
			[t].[Payment_Method_Code] IS NOT NULL AND 
			
			(
				([t].[Payment_Method_Code] <> '') OR [t].[Payment_Method_Code] IS NULL
			)

		) AND 
		(
		--	(

				convert(varchar(10), [t].[Regist_DateTime], 120) BETWEEN  convert(varchar(10), @Start_Date, 120) and  convert(varchar(10), @End_Date, 120)
				--[t].[Regist_DateTime] >= @Start_Date

			--) AND 
		--	(
			--	[t].[Regist_DateTime] <= @End_Date
		--	)
		)-- and t.User_ID = 'kimbeomkyu'
--ORDER BY [t].[Regist_DateTime] DESC


 end else begin 

 
 SELECT 
		
	주문사이트 =  (select top 1 CASE WHEN A.SALES_GUBUN = 'BM' THEN 'M' 
											WHEN A.SALES_GUBUN = 'SB' THEN '바른손' 
											WHEN A.SALES_GUBUN = 'SA' THEN '비핸즈' 
											WHEN A.SALES_GUBUN = 'ST' THEN '더카드' 
											WHEN A.SALES_GUBUN = 'SS' THEN '프리미어' 
											WHEN A.SALES_GUBUN = 'B' OR A.SALES_GUBUN = 'H' THEN '바른손몰' 	
												ELSE '' END

		FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
			 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
		WHERE STATUS_SEQ >= 9 and  MEMBER_ID = [t].[USER_ID] 
		GROUP BY A.SALES_GUBUN
	
	),
	[t].[User_ID],
		[t].[Order_ID], [t].[Account_Number], [t].[Cancel_DateTime], 
		[t].[Cancel_Time], [t].[Card_Installment], [t].[CashReceipt_Publish_YN],
		[t].[CellPhone_Number], [t].[Coupon_Price], [t].[Deposit_DeadLine_DateTime], 
		[t].[Email], [t].[Escrow_YN], [t].[Finance_Auth_Number], [t].[Finance_Name], [t].[Name],
		[t].[Noint_YN], [t].[Order_Code], [t].[Order_DateTime], [t].[Order_Path], [t].[Order_Price], 
		[t].[Order_Status_Code], [t].[PG_ID], [t].[Payer_Name], [t].[Payment_DateTime], [t].[Payment_Method_Code], 
		[t].[Payment_Path], [t].[Payment_Price], [t].[Payment_Status_Code], [t].[Previous_Order_ID], 
		Regist_DateTime1 = [t].[Regist_DateTime], [t].[Trading_Number], 
	[t0].[Product_ID], [t0].[Item_Count], 
		[t0].[Item_Price], [t0].[Product_Type_Code], Regist_DateTime2 = [t0].[Regist_DateTime], 
		[t0].[Total_Price],
		 [t1].[Display_YN], [t1].[Main_Image_URL], [t1].[Original_Product_Code],
		[t1].[Preview_Image_URL], [t1].[Price], [t1].[Product_Brand_Code], [t1].[Product_Category_Code],
		[t1].[Product_Code], [t1].[Product_Description], [t1].[Product_Name], Regist_DateTime3 = [t1].[Regist_DateTime],
	
	 Code_Group1 = [t3].[Code_Group], Code1 = [t3].[Code], Code_Name1 = [t3].[Code_Name], --[t3].[Extra_Code], Regist_DateTime4 = [t3].[Regist_DateTime], 
		--[t3].[Sort],
	  Code2 =[t5].[Code], Code_Name2 =  [t5].[Code_Name], [t5].[Extra_Code],  Regist_DateTime5 = [t5].[Regist_DateTime],
		[t5].[Sort], [t6].[Invitation_ID], [t6].[Invitation_Display_YN], 
		 Regist_DateTime6 = [t6].[Regist_DateTime],
	[t7].[Bride_EngName], [t7].[Bride_Global_Phone_Number], [t7].[Bride_Global_Phone_YN],
		[t7].[Bride_Name], [t7].[Bride_Parents1_Global_Phone_Number], [t7].[Bride_Parents1_Global_Phone_Number_YN], [t7].[Bride_Parents1_Name],
		[t7].[Bride_Parents1_Phone], [t7].[Bride_Parents1_Title], [t7].[Bride_Parents2_Global_Phone_Number], [t7].[Bride_Parents2_Global_Phone_Number_YN], 
		[t7].[Bride_Parents2_Name], [t7].[Bride_Parents2_Phone], [t7].[Bride_Parents2_Title], [t7].[Bride_Phone], [t7].[Delegate_Image_Height],
		[t7].[Delegate_Image_URL], [t7].[Delegate_Image_Width], [t7].[Etc_Information_Use_YN], [t7].[Gallery_Type_Code], [t7].[Gallery_Use_YN], 
		[t7].[Greetings], [t7].[Groom_EngName], [t7].[Groom_Global_Phone_Number], [t7].[Groom_Global_Phone_YN], [t7].[Groom_Name], 
		[t7].[Groom_Parents1_Global_Phone_Number], [t7].[Groom_Parents1_Global_Phone_Number_YN], [t7].[Groom_Parents1_Name],
		[t7].[Groom_Parents1_Phone], [t7].[Groom_Parents1_Title], [t7].[Groom_Parents2_Global_Phone_Number], [t7].[Groom_Parents2_Global_Phone_Number_YN], 
		[t7].[Groom_Parents2_Name], [t7].[Groom_Parents2_Phone], [t7].[Groom_Parents2_Title], [t7].[Groom_Phone], [t7].[GuestBook_Use_YN],
		[t7].[Invitation_Title], [t7].[Invitation_URL], [t7].[Invitation_Video_Type_Code], [t7].[Invitation_Video_URL],
		[t7].[Invitation_Video_Use_YN], [t7].[Location_LAT], [t7].[Location_LOT], [t7].[MMS_Send_YN], [t7].[MoneyAccount_Remit_Use_YN],
		[t7].[MoneyGift_Remit_Use_YN], [t7].[Outline_Image_URL], [t7].[Outline_Type_Code], [t7].[Parents_Information_Use_YN],  Regist_DateTime7 = [t7].[Regist_DateTime],
		 [t7].[SNS_Image_Height], [t7].[SNS_Image_URL], [t7].[SNS_Image_Width], [t7].[Sender], [t7].[Time_Type_Code], 
		[t7].[Time_Type_Eng_YN], [t7].[WeddingDD], [t7].[WeddingDate],
		[t7].[WeddingHHmm], [t7].[WeddingHallDetail], [t7].[WeddingHour], [t7].[WeddingMM], [t7].[WeddingMin], [t7].[WeddingWeek], 
		[t7].[WeddingWeek_Eng_YN], [t7].[WeddingYY], [t7].[Weddinghall_Address], [t7].[Weddinghall_Name], [t7].[Weddinghall_PhoneNumber],
		[t8].[Refund_ID], [t8].[AccountNumber], [t8].[Bank_Type_Code], [t8].[Depositor_Name], [t8].[Refund_Content], [t8].[Refund_DateTime],
		[t8].[Refund_Price], [t8].[Refund_Status_Code], [t8].[Refund_Type_Code],  Regist_DateTime8 = [t8].[Regist_DateTime]
	
FROM [TB_Order] AS [t]
INNER JOIN [TB_Order_Product] AS [t0] ON [t].[Order_ID] = [t0].[Order_ID]
INNER JOIN [TB_Product] AS [t1] ON [t0].[Product_ID] = [t1].[Product_ID]
INNER JOIN (
    SELECT [t2].[Code_Group], [t2].[Code], [t2].[Code_Name], [t2].[Extra_Code], [t2].[Regist_DateTime], [t2].[Regist_IP], [t2].[Regist_User_ID], [t2].[Sort], [t2].[Update_DateTime], [t2].[Update_IP], [t2].[Update_User_ID]
    FROM [TB_Common_Code] AS [t2]
    WHERE [t2].[Code_Group] = 'Payment_Status_Code'
) AS [t3] ON [t].[Payment_Status_Code] = [t3].[Code]
INNER JOIN (
    SELECT [t4].[Code_Group], [t4].[Code], [t4].[Code_Name], [t4].[Extra_Code], [t4].[Regist_DateTime], [t4].[Regist_IP], [t4].[Regist_User_ID], [t4].[Sort], [t4].[Update_DateTime], [t4].[Update_IP], [t4].[Update_User_ID]
    FROM [TB_Common_Code] AS [t4]
    WHERE [t4].[Code_Group] = 'Payment_Method_Code'
) AS [t5] ON [t].[Payment_Method_Code] = [t5].[Code]
INNER JOIN [TB_Invitation] AS [t6] ON [t].[Order_ID] = [t6].[Order_ID]
INNER JOIN [TB_Invitation_Detail] AS [t7] ON [t6].[Invitation_ID] = [t7].[Invitation_ID]
LEFT JOIN [TB_Refund_Info] AS [t8] ON [t].[Order_ID] = [t8].[Order_ID]
--LEFT JOIN (
--			select top 1 MEMBER_ID, SALES_GUBUN = CASE WHEN A.SALES_GUBUN = 'BM' THEN 'M' 
--											WHEN A.SALES_GUBUN = 'SB' THEN '바른손' 
--											WHEN A.SALES_GUBUN = 'SA' THEN '비핸즈' 
--											WHEN A.SALES_GUBUN = 'ST' THEN '더카드' 
--											WHEN A.SALES_GUBUN = 'SS' THEN '프리미어' 
--											WHEN A.SALES_GUBUN = 'B' OR A.SALES_GUBUN = 'H' THEN '바른손몰' 	
--												ELSE '' END

--		FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
--			 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
--		WHERE STATUS_SEQ >= 9  --and  A.MEMBER_ID = 'zun0228'
--		GROUP BY A.MEMBER_ID, A.SALES_GUBUN

--		--SELECT MEMBER_ID, 
--		--	CARD_CODE = B.CARD_CODE, 
--		--	CASE WHEN COUNT(1) >= 0 THEN 'Y' ELSE 'N' END  AS ORDER_YN
--		--FROM BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
--		--	 BAR_SHOP1.DBO.S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ
--		--WHERE STATUS_SEQ > 9
--		--GROUP BY MEMBER_ID, B.CARD_CODE	
--	) AS B
--		ON [t].[USER_ID]  = B.MEMBER_ID


WHERE	(
			[t].[Payment_Method_Code] IS NOT NULL AND 
			
			(
				([t].[Payment_Method_Code] <> '') OR [t].[Payment_Method_Code] IS NULL
			)

		) AND 
		(
		--	(

				convert(varchar(10), [t].Payment_DateTime, 120) BETWEEN  convert(varchar(10), @Start_Date, 120) and  convert(varchar(10), @End_Date, 120)
				--[t].[Regist_DateTime] >= @Start_Date

			--) AND 
		--	(
			--	[t].[Regist_DateTime] <= @End_Date
		--	)
		)-- and t.User_ID = 'kimbeomkyu'
--ORDER BY [t].[Regist_DateTime] DESC




 end 



GO
