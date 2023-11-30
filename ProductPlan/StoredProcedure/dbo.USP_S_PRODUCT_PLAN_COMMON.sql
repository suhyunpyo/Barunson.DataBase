IF OBJECT_ID (N'dbo.USP_S_PRODUCT_PLAN_COMMON', N'P') IS NOT NULL DROP PROCEDURE dbo.USP_S_PRODUCT_PLAN_COMMON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : USP_S_PRODUCT_PLAN_COMMON
-- Author        : 박혜림
-- Create date   : 2021-05-21
-- Description   : 생산 계획 공통정보 조회
-- Update History: 2021-07-21 (박혜림) - 제품 코드 추가
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_S_PRODUCT_PLAN_COMMON]
	   @Product_Main_ID INT
AS

--SET NOCOUNT ON
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

-----------------------------------------------------------------------------------------------------------------
-- Declare Block
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------
BEGIN
		----------------------------------------------------------------------------------
		-- PP 공통정보 조회 
		----------------------------------------------------------------------------------
		SELECT T1.ERP_Code
		     , T1.Product_Code	-- 제품 코드
			 , T1.Brand_Code
			 , T1.Designer_User_ID
			 , T2.[Name] AS Designer_Nm	-- 디자이너
			 , T1.Category_Code
			 , T1.Product_Center_Code
			 , T1.Temp_Code
			 , T1.[Count] AS Quantity
			 , ISNULL(T1.Caution, '') AS Caution
			 , ISNULL(T1.Packing, '') AS Packing
			 , ISNULL(T1.Sample_Original_File_Name, '') AS Sample_Original_File_Name	-- 샘플파일명
			 , ISNULL(T1.Sample_File_Path, '') AS Sample_File_Path	-- 샘플파일
			 , T1.FoldingPrint1_Item_Code
			 , T1.FoldingPrint2_Item_Code
			 , T1.Card_FoldingPrint_Code
			 , T1.Inpaper_FoldingPrint_Code
			 , ISNULL(T1.FoldingPrint_Memo, '') AS FoldingPrint_Memo
			 , ISNULL(T1.FoldingPrint_Original_File_Name, '') AS FoldingPrint_Original_File_Name	-- 대첩파일명
			 , ISNULL(T1.FoldingPrint_File_Path, '') AS FoldingPrint_File_Path	-- 대첩파일
			 , Signature1_User_ID	-- 서명_1
			 , ISNULL(T4.Original_File_Name, '') AS Signature1_Original_File_Name
			 , ISNULL(T4.File_Path, '') AS Signature1_File_Path
			 , Signature2_User_ID	-- 서명_2
			 , ISNULL(T6.Original_File_Name, '') AS Signature2_Original_File_Name
			 , ISNULL(T6.File_Path, '') AS Signature2_File_Path
			 , Signature3_User_ID	-- 서명_3
			 , ISNULL(T8.Original_File_Name, '') AS Signature3_Original_File_Name
			 , ISNULL(T8.File_Path, '') AS Signature3_File_Path
			 , Signature4_User_ID	-- 서명_4
			 , ISNULL(T10.Original_File_Name, '') AS Signature4_Original_File_Name
			 , ISNULL(T10.File_Path, '') AS Signature4_File_Path
			 , T1.Regist_DateTime
			 , T1.Update_DateTime
		  FROM ProductPlan.dbo.TB_Product_Main         AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_User            AS T2 WITH(NOLOCK) ON (T1.Designer_User_ID = T2.User_ID)	-- 디자이너
		  LEFT OUTER JOIN ProductPlan.dbo.TB_User      AS T3 WITH(NOLOCK) ON (T1.Signature1_User_ID = T3.User_ID)	-- 서명_1(PersonInCharge)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_Signature AS T4 WITH(NOLOCK) ON (T3.Signature_ID = T4.Signature_ID)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_User      AS T5 WITH(NOLOCK) ON (T1.Signature2_User_ID = T5.User_ID)	-- 서명_2(GroupLeader)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_Signature AS T6 WITH(NOLOCK) ON (T5.Signature_ID = T6.Signature_ID)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_User      AS T7 WITH(NOLOCK) ON (T1.Signature3_User_ID = T7.User_ID)	-- 서명_3(GeneralManager)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_Signature AS T8 WITH(NOLOCK) ON (T7.Signature_ID = T8.Signature_ID)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_User      AS T9 WITH(NOLOCK) ON (T1.Signature4_User_ID = T9.User_ID)	-- 서명_4(Adviser)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_Signature AS T10 WITH(NOLOCK) ON (T9.Signature_ID = T10.Signature_ID)
		 WHERE T1.Product_Main_ID = @Product_Main_ID

END

-- Execute Sample
/*

EXEC ProductPlan.dbo.USP_S_PRODUCT_PLAN_COMMON 10

*/ 
GO
