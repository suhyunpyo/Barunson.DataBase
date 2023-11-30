IF OBJECT_ID (N'dbo.USP_S_PRODUCT_PLAN_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.USP_S_PRODUCT_PLAN_ITEM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : USP_S_PRODUCT_PLAN_ITEM
-- Author        : 박혜림
-- Create date   : 2021-05-26
-- Description   : 생산 계획 품목별 조회
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_S_PRODUCT_PLAN_ITEM]
	   @Product_Main_ID INT			-- 생산 메인 ID
	 , @Item_Code       VARCHAR(6)	-- 품목 코드(IT_001:Card, IT_002:Inside, IT_003:Envelope, IT_004:Acc, IT_005:Sticker, IT_006:Box, IT_007:Etc)
	 , @Item_Sort       SMALLINT	-- 품목 순서
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
		-- 품목 정보 조회 
		----------------------------------------------------------------------------------
		SELECT T2.Product_Item_ID
		     , T2.Item_Code
			 , T2.Item_Sort
			 , ISNULL(T2.Readymade_Product_Code, '') AS Readymade_Product_Code
			 , T2.Folding_Size_Width		-- 접었을 때 너비(* 해당 품목을 입력한 경우 필수입력값)
			 , T2.Folding_Size_Height		-- 접었을 때 높이(* 해당 품목을 입력한 경우 필수입력값)
			 , T2.UnFolding_Size_Width
			 , T2.UnFolding_Size_Height
			 , T2.Paper_Temper_Code							-- 종이 재질
			 , ISNULL(T3.Code_Name, '') AS Paper_Temper_Nm	-- 종이 재질명
			 , T2.Laser_Cutting_Time
			 , ISNULL(T2.Storage_Status, '') AS Storage_Status
		  FROM ProductPlan.dbo.TB_Product_Main           AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Item      AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Item_Code = @Item_Code AND T2.Item_Sort =  @Item_Sort)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_Common_Code AS T3 WITH(NOLOCK) ON (T2.Paper_Temper_Code =T3.Code AND T3.Code_Group = 'Paper_Temper_Code')
		 WHERE T1.Product_Main_ID = @Product_Main_ID

		----------------------------------------------------------------------------------
		-- 인쇄 공정 조회 > Offset Print
		----------------------------------------------------------------------------------
		SELECT 'Offset_Print' AS Offset_Print
		     , T3.Print_Process_Code
			 , T3.Process_Difficulty_Code	-- 가공난이도
			 , ISNULL(T3.Process_Difficulty_Description, '') AS Process_Difficulty_Description
		  FROM ProductPlan.dbo.TB_Product_Main       AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Item  AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Item_Code = @Item_Code AND T2.Item_Sort =  @Item_Sort)
		 INNER JOIN ProductPlan.dbo.TB_Print_Process AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID AND T3.Print_Process_Code = 'PR_001')
		 WHERE T1.Product_Main_ID = @Product_Main_ID

		----------------------------------------------------------------------------------
		-- 인쇄 공정 상세 조회 > Offset Print
		----------------------------------------------------------------------------------
		SELECT 'Offset_Print_Detail' AS Offset_Print_Detail
		     , T4.Print_Process_Sort
		     , T4.Process_Item_Code
			 , ISNULL(T4.Process_Item_Color, '') AS Process_Item_Color
			 , T4.Process_Width
			 , T4.Process_Height
		  FROM ProductPlan.dbo.TB_Product_Main              AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Item         AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Item_Code = @Item_Code AND T2.Item_Sort =  @Item_Sort)
		 INNER JOIN ProductPlan.dbo.TB_Print_Process        AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID AND T3.Print_Process_Code = 'PR_001')
		 INNER JOIN ProductPlan.dbo.TB_Print_Process_Detail AS T4 WITH(NOLOCK) ON (T3.Product_Item_ID = T4.Product_Item_ID AND T3.Print_Process_Code = T4.Print_Process_Code)
		 WHERE T1.Product_Main_ID = @Product_Main_ID
		 ORDER BY T4.Print_Process_Sort ASC

		----------------------------------------------------------------------------------
		-- 인쇄 공정 조회 > Silk Print
		----------------------------------------------------------------------------------
		SELECT 'Silk_Print' AS Silk_Print
		     , T3.Print_Process_Code
			 , T3.Process_Difficulty_Code	-- 가공난이도
			 , ISNULL(T3.Process_Difficulty_Description, '') AS Process_Difficulty_Description
		  FROM ProductPlan.dbo.TB_Product_Main       AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Item  AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Item_Code = @Item_Code AND T2.Item_Sort =  @Item_Sort)
		 INNER JOIN ProductPlan.dbo.TB_Print_Process AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID AND T3.Print_Process_Code = 'PR_002')
		 WHERE T1.Product_Main_ID = @Product_Main_ID

		----------------------------------------------------------------------------------
		-- 인쇄 공정 상세 조회 > Silk Print
		----------------------------------------------------------------------------------
		SELECT 'Silk_Print_Detail' AS Silk_Print_Detail
		     , T4.Print_Process_Sort
		     , T4.Process_Item_Code
			 , ISNULL(T4.Process_Item_Color, '') AS Process_Item_Color
			 , T4.Process_Width
			 , T4.Process_Height
		  FROM ProductPlan.dbo.TB_Product_Main              AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Item         AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Item_Code = @Item_Code AND T2.Item_Sort =  @Item_Sort)
		 INNER JOIN ProductPlan.dbo.TB_Print_Process        AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID AND T3.Print_Process_Code = 'PR_002')
		 INNER JOIN ProductPlan.dbo.TB_Print_Process_Detail AS T4 WITH(NOLOCK) ON (T3.Product_Item_ID = T4.Product_Item_ID AND T3.Print_Process_Code = T4.Print_Process_Code)
		 WHERE T1.Product_Main_ID = @Product_Main_ID
		 ORDER BY T4.Print_Process_Sort ASC

		----------------------------------------------------------------------------------
		-- 인쇄 공정 조회 > Process
		----------------------------------------------------------------------------------
		SELECT 'Process' AS Process
		     , T3.Print_Process_Code
			 , T3.Process_Difficulty_Code	-- 가공난이도
			 , ISNULL(T3.Process_Difficulty_Description, '') AS Process_Difficulty_Description
		  FROM ProductPlan.dbo.TB_Product_Main       AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Item  AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Item_Code = @Item_Code AND T2.Item_Sort =  @Item_Sort)
		 INNER JOIN ProductPlan.dbo.TB_Print_Process AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID AND T3.Print_Process_Code = 'PR_003')
		 WHERE T1.Product_Main_ID = @Product_Main_ID

		----------------------------------------------------------------------------------
		-- 인쇄 공정 상세 조회 > Process
		----------------------------------------------------------------------------------
		SELECT 'Process_Detail' AS Process_Detail
		     , T4.Print_Process_Sort
		     , T4.Process_Item_Code
			 , ISNULL(T5.Code_Name, '') AS Process_Item_Code_Nm	-- 항목명
			 , ISNULL(T4.Process_Item_Color, '') AS Process_Item_Color
			 , T4.Process_Width
			 , T4.Process_Height
		  FROM ProductPlan.dbo.TB_Product_Main              AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Item         AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Item_Code = @Item_Code AND T2.Item_Sort =  @Item_Sort)
		 INNER JOIN ProductPlan.dbo.TB_Print_Process        AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID AND T3.Print_Process_Code = 'PR_003')
		 INNER JOIN ProductPlan.dbo.TB_Print_Process_Detail AS T4 WITH(NOLOCK) ON (T3.Product_Item_ID = T4.Product_Item_ID AND T3.Print_Process_Code = T4.Print_Process_Code)
		  LEFT OUTER JOIN ProductPlan.dbo.TB_Common_Code    AS T5 WITH(NOLOCK) ON (T4.Process_Item_Code =T5.Code AND T5.Code_Group = 'Process_Item_Code')
		 WHERE T1.Product_Main_ID = @Product_Main_ID
		 ORDER BY T4.Print_Process_Sort ASC

END

-- Execute Sample
/*

EXEC ProductPlan.dbo.USP_S_PRODUCT_PLAN_ITEM 20, 'IT_002', 1

*/ 
GO
