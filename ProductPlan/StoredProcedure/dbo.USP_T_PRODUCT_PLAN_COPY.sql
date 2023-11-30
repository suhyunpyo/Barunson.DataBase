IF OBJECT_ID (N'dbo.USP_T_PRODUCT_PLAN_COPY', N'P') IS NOT NULL DROP PROCEDURE dbo.USP_T_PRODUCT_PLAN_COPY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : USP_T_PRODUCT_PLAN_COPY
-- Author        : 박혜림
-- Create date   : 2021-06-17
-- Description   : 생산계획(PP) 입력 데이터 복사
-- Update History: 2021-07-21 (박혜림) - ERP 코드는 복사, 제품 코드 공백으로 저장되도록 수정
                   2021-09-08 (박혜림) - ERP 코드도 공백으로 처리(남현지 팀장님 요청)
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_T_PRODUCT_PLAN_COPY]
	  @Login_User_ID        INT			-- 로그인 사용자 ID
    , @Copy_Product_Main_ID INT			-- 생산 메인 ID
	, @Product_Year         SMALLINT	-- 생산 년도
	, @Product_Sort         SMALLINT	-- 생산 순서		
	, @Product_Process_Code VARCHAR(7)	-- 생산 공정 코드
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

-----------------------------------------------------------------------------------------------------------------------
-- Declare Block
-----------------------------------------------------------------------------------------------------------------------
DECLARE @Product_Main_ID INT
DECLARE @Product_Item_ID INT, @Item_Code VARCHAR(6), @Item_Sort SMALLINT
DECLARE @Product_Korea_ID INT, @Korea_Item_Code VARCHAR(6)

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	--BEGIN TRY
		BEGIN TRAN

				----------------------------------------------------------------------------------
				-- 생산 메인 테이블 저장
				----------------------------------------------------------------------------------
				INSERT INTO ProductPlan.dbo.TB_Product_Main
					 ( Product_Year
					 , Product_Sort
					 , Product_Process_Code
					 , ERP_Code
					 , Product_Code
					 , Brand_Code
					 , Designer_User_ID
					 , Category_Code
					 , Product_Center_Code
					 , Temp_Code
					 , [Count]
					 , Caution
					 , Packing
					 , Sample_Original_File_Name
					 , Sample_File_Path
					 , FoldingPrint1_Item_Code
					 , FoldingPrint2_Item_Code
					 , Card_FoldingPrint_Code
					 , Inpaper_FoldingPrint_Code
					 , FoldingPrint_Memo
					 , FoldingPrint_Original_File_Name
					 , FoldingPrint_File_Path
					 , Signature1_User_ID
					 , Signature1_DateTime
					 , Signature2_User_ID
					 , Signature2_DateTime
					 , Signature3_User_ID
					 , Signature3_DateTime
					 , Signature4_User_ID
					 , Signature4_DateTime
					 , Regist_User_ID
					 , Regist_DateTime
					 , Update_User_ID
					 , Update_DateTime
					 )
				SELECT @Product_Year
					 , @Product_Sort
					 , @Product_Process_Code
					 , ''
					 , ''
					 , Brand_Code
					 , @Login_User_ID	-- PP를 복사한 사용자로 변경
					 , Category_Code
					 , Product_Center_Code
					 , Temp_Code
					 , [Count]
					 , Caution
					 , Packing
					 , Sample_Original_File_Name
					 , Sample_File_Path
					 , FoldingPrint1_Item_Code
					 , FoldingPrint2_Item_Code
					 , Card_FoldingPrint_Code
					 , Inpaper_FoldingPrint_Code
					 , FoldingPrint_Memo
					 , FoldingPrint_Original_File_Name
					 , FoldingPrint_File_Path
					 , 0
					 , NULL
					 , 0
					 , NULL
					 , 0
					 , NULL
					 , 0
					 , NULL
					 , @Login_User_ID
					 , GETDATE()
					 , @Login_User_ID
					 , GETDATE()
				  FROM ProductPlan.dbo.TB_Product_Main
				 WHERE Product_Main_ID = @Copy_Product_Main_ID

				SET @Product_Main_ID = @@IDENTITY

				----------------------------------------------------------------------------------
				-- 생산 품목 테이블 저장
				----------------------------------------------------------------------------------
				INSERT INTO ProductPlan.dbo.TB_Product_Item
				     ( Product_Main_ID
					 , Item_Code
					 , Item_Sort
					 , Readymade_Product_Code
					 , Folding_Size_Width
					 , Folding_Size_Height
					 , Unfolding_Size_Width
					 , Unfolding_Size_Height
					 , Paper_Temper_Code
					 , Laser_Cutting_Time
					 , Storage_Status
					 )
				SELECT @Product_Main_ID
				     , Item_Code
					 , Item_Sort
					 , Readymade_Product_Code
					 , Folding_Size_Width
					 , Folding_Size_Height
					 , Unfolding_Size_Width
					 , Unfolding_Size_Height
					 , Paper_Temper_Code
					 , Laser_Cutting_Time
					 , Storage_Status
				  FROM ProductPlan.dbo.TB_Product_Item
				 WHERE Product_Main_ID = @Copy_Product_Main_ID

				----------------------------------------------------------------------------------
				-- 인쇄 공정/인쇄 공정 상세 테이블 저장
				----------------------------------------------------------------------------------
				DECLARE CURSOR_Print CURSOR FOR

				SELECT Product_Item_ID
				     , Item_Code
					 , Item_Sort
				  FROM ProductPlan.dbo.TB_Product_Item
				 WHERE Product_Main_ID = @Product_Main_ID

				OPEN CURSOR_Print

				FETCH NEXT FROM CURSOR_Print INTO @Product_Item_ID, @Item_Code, @Item_Sort

				WHILE @@fetch_status = 0
				BEGIN

					-------------------------
					-- // 인쇄 공정 //
					-------------------------
					INSERT INTO ProductPlan.dbo.TB_Print_Process
					     ( Product_Item_ID
						 , Print_Process_Code
						 , Process_Difficulty_Code
						 , Process_Difficulty_Description
						 )
					SELECT @Product_Item_ID
					     , T2.Print_Process_Code
						 , T2.Process_Difficulty_Code
						 , T2.Process_Difficulty_Description
					  FROM ProductPlan.dbo.TB_Product_Item       AS T1 WITH(NOLOCK)
					 INNER JOIN ProductPlan.dbo.TB_Print_Process AS T2 WITH(NOLOCK) ON (T1.Product_Item_ID = T2.Product_Item_ID)
					 WHERE T1.Product_Main_ID = @Copy_Product_Main_ID
					   AND T1.Item_Code = @Item_Code
					   AND T1.Item_Sort = @Item_Sort

					-------------------------
					-- // 인쇄 공정 상세 //
					-------------------------
					INSERT INTO ProductPlan.dbo.TB_Print_Process_Detail
					     ( Product_Item_ID
						 , Print_Process_Code
						 , Print_Process_Sort
						 , Process_Item_Code
						 , Process_Item_Color
						 , Process_Width
						 , Process_Height
						 )
					SELECT @Product_Item_ID
					     , T3.Print_Process_Code
						 , T3.Print_Process_Sort
						 , T3.Process_Item_Code
						 , T3.Process_Item_Color
						 , T3.Process_Width
						 , T3.Process_Height
					  FROM ProductPlan.dbo.TB_Product_Item              AS T1 WITH(NOLOCK)
					 INNER JOIN ProductPlan.dbo.TB_Print_Process        AS T2 WITH(NOLOCK) ON (T1.Product_Item_ID = T2.Product_Item_ID)
					 INNER JOIN ProductPlan.dbo.TB_Print_Process_Detail AS T3 WITH(NOLOCK) ON (T2.Product_Item_ID = T3.Product_Item_ID AND T2.Print_Process_Code = T3.Print_Process_Code)
					 WHERE T1.Product_Main_ID = @Copy_Product_Main_ID
					   AND T1.Item_Code = @Item_Code
					   AND T1.Item_Sort = @Item_Sort

					FETCH NEXT FROM CURSOR_Print INTO @Product_Item_ID, @Item_Code, @Item_Sort
				END

				CLOSE CURSOR_Print
				DEALLOCATE CURSOR_Print

				----------------------------------------------------------------------------------
				-- [내부가공] 생산 품목 테이블 저장
				----------------------------------------------------------------------------------
				INSERT INTO ProductPlan.dbo.TB_Product_Korea
				     ( Product_Main_ID
					 , Korea_Item_Code
					 , Korea_Readymade_Product_Code
					 , Korea_Laser_Cutting_Time
					 )
				SELECT @Product_Main_ID
				     , Korea_Item_Code
					 , Korea_Readymade_Product_Code
					 , Korea_Laser_Cutting_Time
				  FROM ProductPlan.dbo.TB_Product_Korea
				 WHERE Product_Main_ID = @Copy_Product_Main_ID

				----------------------------------------------------------------------------------
				-- [내부가공] 인쇄 공정/인쇄 공정 상세 테이블 저장
				----------------------------------------------------------------------------------
				DECLARE CURSOR_Print_Korea CURSOR FOR

				SELECT Product_Korea_ID
				     , Korea_Item_Code
				  FROM ProductPlan.dbo.TB_Product_Korea
				 WHERE Product_Main_ID = @Product_Main_ID

				OPEN CURSOR_Print_Korea

				FETCH NEXT FROM CURSOR_Print_Korea INTO @Product_Korea_ID, @Korea_Item_Code

				WHILE @@fetch_status = 0
				BEGIN

					-------------------------
					-- // 내부가공 인쇄 공정 //
					-------------------------
					INSERT INTO ProductPlan.dbo.TB_Print_Korea_Process
					     ( Product_Korea_ID
						 , Korea_Process_Code
						 )
					SELECT @Product_Korea_ID
					     , T2.Korea_Process_Code
					  FROM ProductPlan.dbo.TB_Product_Korea            AS T1 WITH(NOLOCK)
					 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process AS T2 WITH(NOLOCK) ON (T1.Product_Korea_ID = T2.Product_Korea_ID)
					 WHERE T1.Product_Main_ID = @Copy_Product_Main_ID
					   AND T1.Korea_Item_Code = @Korea_Item_Code

					-----------------------------
					-- // 내부가공 인쇄 공정 상세 //
					-----------------------------
					INSERT INTO ProductPlan.dbo.TB_Print_Korea_Process_Detail
					     ( Product_Korea_ID
						 , Korea_Process_Code
						 , Korea_Process_Sort
						 , Korea_Process_Item_Code
						 , Korea_Process_Item_Color
						 , Korea_Process_Width
						 , Korea_Process_Height
					     )
					SELECT @Product_Korea_ID
					     , T3.Korea_Process_Code
						 , T3.Korea_Process_Sort
						 , T3.Korea_Process_Item_Code
						 , T3.Korea_Process_Item_Color
						 , T3.Korea_Process_Width
						 , T3.Korea_Process_Height
					  FROM ProductPlan.dbo.TB_Product_Korea                   AS T1 WITH(NOLOCK)
					 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process        AS T2 WITH(NOLOCK) ON (T1.Product_Korea_ID = T2.Product_Korea_ID)
					 INNER JOIN ProductPlan.dbo.TB_Print_Korea_Process_Detail AS T3 WITH(NOLOCK) ON (T2.Product_Korea_ID = T3.Product_Korea_ID AND T2.Korea_Process_Code = T3.Korea_Process_Code)
					 WHERE T1.Product_Main_ID = @Copy_Product_Main_ID
					   AND T1.Korea_Item_Code = @Korea_Item_Code

					FETCH NEXT FROM CURSOR_Print_Korea INTO @Product_Korea_ID, @Korea_Item_Code
				END

				CLOSE CURSOR_Print_Korea
				DEALLOCATE CURSOR_Print_Korea

		COMMIT TRAN

	--END TRY


	--BEGIN CATCH
	--	IF ( XACT_STATE() ) <> 0
	--	 BEGIN
	--	     ROLLBACK TRAN
 --       END
	--END CATCH

END

-- Execute Sample
/*
EXEC ProductPlan.dbo.USP_T_PRODUCT_PLAN_COPY
       1
	 , 32				
	 , 2021						
     , 23					
	 , 'P21_023'		
*/
GO
