IF OBJECT_ID (N'dbo.USP_T_PRODUCT_PLAN_DEL', N'P') IS NOT NULL DROP PROCEDURE dbo.USP_T_PRODUCT_PLAN_DEL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : USP_T_PRODUCT_PLAN_DEL
-- Author        : 박혜림
-- Create date   : 2022-01-28
-- Description   : 생산계획(PP) 입력 데이터 삭제
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_T_PRODUCT_PLAN_DEL]
       @Product_Process_Code	VARCHAR(30)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------------------------
DECLARE @Product_Main_ID INT

SET @Product_Main_ID = 0

----------------------------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY

		BEGIN TRAN

			SELECT @Product_Main_ID = Product_Main_ID
			  FROM ProductPlan.dbo.TB_Product_Main
			 WHERE Product_Process_Code = @Product_Process_Code

			IF @Product_Main_ID <> 0
			BEGIN
				----------------------------------------------------------------------------------
				-- [내부가공] 생산 품목/인쇄 공정/인쇄 공정 상세 테이블 삭제
				----------------------------------------------------------------------------------
				--SELECT T4.*
				DELETE FROM ProductPlan.dbo.TB_Print_Korea_Process_Detail
				  FROM ProductPlan.dbo.TB_Product_Main                    AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Korea              AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process        AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process_Detail AS T4 WITH(NOLOCK) ON (T3.Product_Korea_ID = T4.Product_Korea_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID

				--SELECT T3.*
				DELETE FROM ProductPlan.dbo.TB_Print_Korea_Process
				  FROM ProductPlan.dbo.TB_Product_Main             AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Korea       AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID

				--SELECT T2.*
				DELETE FROM ProductPlan.dbo.TB_Product_Korea
				  FROM ProductPlan.dbo.TB_Product_Main       AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Korea AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID


				----------------------------------------------------------------------------------
				-- 생산 품목/인쇄 공정/인쇄 공정 상세 테이블 삭제
				----------------------------------------------------------------------------------
				--SELECT T4.*
				DELETE FROM ProductPlan.dbo.TB_Print_Process_Detail
				  FROM ProductPlan.dbo.TB_Product_Main              AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Item         AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Process        AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Process_Detail AS T4 WITH(NOLOCK) ON (T3.Product_Item_ID = T4.Product_Item_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID

				--SELECT T3.*
				DELETE FROM ProductPlan.dbo.TB_Print_Process
				  FROM ProductPlan.dbo.TB_Product_Main       AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Item  AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Process AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID

				--SELECT T2.*
				DELETE FROM ProductPlan.dbo.TB_Product_Item
				  FROM ProductPlan.dbo.TB_Product_Main       AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Item  AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID


				----------------------------------------------------------------------------------
				-- 생산 공정/인쇄 판/인쇄 후가공/인쇄 제본 테이블 삭제
				----------------------------------------------------------------------------------
				--SELECT T5.*
				DELETE FROM ProductPlan.dbo.TB_Print_Plate_Binding
				  FROM ProductPlan.dbo.TB_Product_Main                 AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Process         AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Plate             AS T3 WITH(NOLOCK) ON (T2.Product_Main_ID = T3.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Plate_PostProcess AS T4 WITH(NOLOCK) ON (T3.Print_Plate_ID = T4.Print_Plate_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Plate_Binding     AS T5 WITH(NOLOCK) ON (T4.Print_Plate_ID = T5.Print_Plate_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID

				--SELECT T4.*
				DELETE FROM ProductPlan.dbo.TB_Print_Plate_PostProcess
				  FROM ProductPlan.dbo.TB_Product_Main                 AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Process         AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Plate             AS T3 WITH(NOLOCK) ON (T2.Product_Main_ID = T3.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Plate_PostProcess AS T4 WITH(NOLOCK) ON (T3.Print_Plate_ID = T4.Print_Plate_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID

				--SELECT T3.*
				DELETE FROM ProductPlan.dbo.TB_Print_Plate
				  FROM ProductPlan.dbo.TB_Product_Main         AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Process AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 INNER JOIN ProductPlan.dbo.TB_Print_Plate     AS T3 WITH(NOLOCK) ON (T2.Product_Main_ID = T3.Product_Main_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID

				--SELECT T2.*
				DELETE FROM ProductPlan.dbo.TB_Product_Process
				  FROM ProductPlan.dbo.TB_Product_Main         AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Product_Process AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID


				----------------------------------------------------------------------------------
				-- 생산 공정 변경이력 테이블 삭제
				----------------------------------------------------------------------------------
				--SELECT T2.*
				DELETE FROM ProductPlan.dbo.TB_Update_History
				  FROM ProductPlan.dbo.TB_Product_Main        AS T1 WITH(NOLOCK)
				 INNER JOIN ProductPlan.dbo.TB_Update_History AS T2 WITH(NOLOCK) ON (T1.Product_Main_ID = T2.Product_Main_ID)
				 WHERE T1.Product_Main_ID = @Product_Main_ID


				----------------------------------------------------------------------------------
				-- 생산 메인 테이블 삭제
				----------------------------------------------------------------------------------
				--SELECT *
				DELETE FROM ProductPlan.dbo.TB_Product_Main
				 WHERE Product_Main_ID = @Product_Main_ID

			END

		COMMIT TRAN

	END TRY

	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		 BEGIN
		     ROLLBACK TRAN
        END
	END CATCH

END
-- Execute Sample
/*
EXEC ProductPlan.dbo.USP_T_PRODUCT_PLAN_DEL 'P21_020'
*/
GO
