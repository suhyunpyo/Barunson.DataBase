IF OBJECT_ID (N'dbo.USP_S_PRODUCT_PLAN_KOREA_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.USP_S_PRODUCT_PLAN_KOREA_ITEM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : USP_S_PRODUCT_PLAN_KOREA_ITEM
-- Author        : 박혜림
-- Create date   : 2021-06-03
-- Description   : 내부가공(Korea) 품목별 조회
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_S_PRODUCT_PLAN_KOREA_ITEM]
	   @Product_Main_ID INT			-- 생산 메인 ID
	 , @Koera_Item_Code VARCHAR(6)	-- 내부가공 품목 코드(KI_001:카드, KI_002:봉투, KI_003:내지, KI_004:부속, KI_005:기타)
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
		SELECT T2.Product_Korea_ID
			 , ISNULL(T2.Korea_Readymade_Product_Code, '') AS Korea_Readymade_Product_Code
			 , T2.Korea_Laser_Cutting_Time
		  FROM ProductPlan.dbo.TB_Product_Main       AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Korea AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Korea_Item_Code = @Koera_Item_Code)
		 WHERE T1.Product_Main_ID = @Product_Main_ID

		----------------------------------------------------------------------------------
		-- 인쇄 공정 조회 > Print
		----------------------------------------------------------------------------------
		SELECT 'Print' AS [Print]
		     , T3.Korea_Process_Code	-- 내부가공 공정 코드
		  FROM ProductPlan.dbo.TB_Product_Main             AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Korea       AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Korea_Item_Code = @Koera_Item_Code)
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID AND T3.Korea_Process_Code = 'KP_001')
		 WHERE T1.Product_Main_ID = @Product_Main_ID

		----------------------------------------------------------------------------------
		-- 인쇄 공정 상세 조회 > Print
		----------------------------------------------------------------------------------
		SELECT 'Print_Detail' AS Print_Detail
		     , T4.Korea_Process_Sort
		     , T4.Korea_Process_Item_Code
			 , ISNULL(T4.Korea_Process_Item_Color, '') AS Korea_Process_Item_Color
			 , T4.Korea_Process_Width
			 , T4.Korea_Process_Height
		  FROM ProductPlan.dbo.TB_Product_Main                    AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Korea              AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Korea_Item_Code = @Koera_Item_Code)
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process        AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID AND T3.Korea_Process_Code = 'KP_001')
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process_Detail AS T4 WITH(NOLOCK) ON (T3.Product_Korea_ID = T4.Product_Korea_ID AND T3.Korea_Process_Code = T4.Korea_Process_Code)
		 WHERE T1.Product_Main_ID = @Product_Main_ID
		 ORDER BY T4.Korea_Process_Sort ASC

		----------------------------------------------------------------------------------
		-- 인쇄 공정 조회 > Special Print
		----------------------------------------------------------------------------------
		SELECT 'Special_Print' AS Special_Print
		     , T3.Korea_Process_Code	-- 내부가공 공정 코드
		  FROM ProductPlan.dbo.TB_Product_Main             AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Korea       AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Korea_Item_Code = @Koera_Item_Code)
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID AND T3.Korea_Process_Code = 'KP_002')
		 WHERE T1.Product_Main_ID = @Product_Main_ID

		----------------------------------------------------------------------------------
		-- 인쇄 공정 상세 조회 > Special Print
		----------------------------------------------------------------------------------
		SELECT 'Special_Print_Detail' AS Special_Print_Detail
		     , T4.Korea_Process_Sort
		     , T4.Korea_Process_Item_Code
			 , ISNULL(T4.Korea_Process_Item_Color, '') AS Korea_Process_Item_Color
			 , T4.Korea_Process_Width
			 , T4.Korea_Process_Height
		  FROM ProductPlan.dbo.TB_Product_Main                    AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Korea              AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Korea_Item_Code = @Koera_Item_Code)
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process        AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID AND T3.Korea_Process_Code = 'KP_002')
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process_Detail AS T4 WITH(NOLOCK) ON (T3.Product_Korea_ID = T4.Product_Korea_ID AND T3.Korea_Process_Code = T4.Korea_Process_Code)
		 WHERE T1.Product_Main_ID = @Product_Main_ID
		 ORDER BY T4.Korea_Process_Sort ASC

		----------------------------------------------------------------------------------
		-- 인쇄 공정 조회 > Process
		----------------------------------------------------------------------------------
		SELECT 'Process' AS Process
		     , T3.Korea_Process_Code	-- 내부가공 공정 코드
		  FROM ProductPlan.dbo.TB_Product_Main             AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Korea       AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Korea_Item_Code = @Koera_Item_Code)
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID AND T3.Korea_Process_Code = 'KP_003')
		 WHERE T1.Product_Main_ID = @Product_Main_ID

		----------------------------------------------------------------------------------
		-- 인쇄 공정 상세 조회 > Process
		----------------------------------------------------------------------------------
		SELECT 'Process_Detail' AS Process_Detail
		     , T4.Korea_Process_Sort
		     , T4.Korea_Process_Item_Code
			 , ISNULL(T4.Korea_Process_Item_Color, '') AS Korea_Process_Item_Color
			 , T4.Korea_Process_Width
			 , T4.Korea_Process_Height
		  FROM ProductPlan.dbo.TB_Product_Main                    AS T1 WITH(NOLOCK)
		 INNER JOIN ProductPlan.dbo.TB_Product_Korea              AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID AND T2.Korea_Item_Code = @Koera_Item_Code)
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process        AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID AND T3.Korea_Process_Code = 'KP_003')
		 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process_Detail AS T4 WITH(NOLOCK) ON (T3.Product_Korea_ID = T4.Product_Korea_ID AND T3.Korea_Process_Code = T4.Korea_Process_Code)
		 WHERE T1.Product_Main_ID = @Product_Main_ID
		 ORDER BY T4.Korea_Process_Sort ASC

END

-- Execute Sample
/*

EXEC ProductPlan.dbo.USP_S_PRODUCT_PLAN_KOREA_ITEM 19, 'KI_001'

*/ 
GO
