IF OBJECT_ID (N'dbo.USP_T_PRODUCT_PLAN_REG', N'P') IS NOT NULL DROP PROCEDURE dbo.USP_T_PRODUCT_PLAN_REG
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : USP_T_PRODUCT_PLAN_REG
-- Author        : 박혜림
-- Create date   : 2021-05-28
-- Description   : 생산계획(PP) 입력 데이터 등록
-- Update History: 2021-07-21 (박혜림) - 제품 코드 추가
                   2021-09-07 (박혜림) - 데이터 중복 등록 방지를 위한 카운트 체크 추가
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_T_PRODUCT_PLAN_REG]
	  @Login_User_ID                   INT				-- 로그인 사용자 ID
	, @Product_Year                    SMALLINT			-- 생산 년도
	, @Product_Sort                    SMALLINT			-- 생산 순서				
	, @Product_Process_Code            VARCHAR(7)		-- 생산 공정 코드
	, @ERP_Code                        VARCHAR(30)		-- ERP 코드
	, @Product_Code                    VARCHAR(30)		-- 제품 코드
	, @Brand_Code                      VARCHAR(6)		-- 브랜드 코드
	, @Category_Code                   VARCHAR(6)		-- 카테고리 코드	
	, @Product_Center_Code             VARCHAR(6)		-- 생산지 코드
	, @Temp_Code                       VARCHAR(50)		-- 임시코드
	, @Count                           INT				-- 수량
	, @Caution                         NVARCHAR(600)	-- 주의사항
	, @Packing                         NVARCHAR(500)	-- 포장
	, @Sample_Original_File_Name       NVARCHAR(255)	-- 샘플 원본 파일명
	, @Sample_File_Path                NVARCHAR(255)	-- 샘플 파일 경로
	, @FoldingPrint1_Item_Code         VARCHAR(6)		-- 대첩1 항목 코드
	, @FoldingPrint2_Item_Code         VARCHAR(6)		-- 대첩2 항목 코드
	, @Card_FoldingPrint_Code          VARCHAR(6)		-- 카드 대첩 코드
	, @Inpaper_FoldingPrint_Code       VARCHAR(6)		-- 내지 대첩 코드
	, @FoldingPrint_Memo               NVARCHAR(300)	-- 대첩 메모
	, @FoldingPrint_Original_File_Name NVARCHAR(255)	-- 대첩 원본 파일명
	, @FoldingPrint_File_Path          NVARCHAR(255)	-- 대첩 파일 경로
	, @Signature1_User_ID              INT				-- 서명1 사용자 ID
	, @Signature2_User_ID              INT				-- 서명2 사용자 ID		
	, @Signature3_User_ID              INT				-- 서명3 사용자 ID
	, @Signature4_User_ID              INT				-- 서명4 사용자 ID

	, @Item_Code                       VARCHAR(1000)	-- 품목 코드(IT_001$IT_002$IT_003$...)
	, @Item_Sort                       VARCHAR(1000)	-- 품목 순서(1$1$I1$2$...)
	, @Readymade_Product_Code          VARCHAR(1000)	-- 기제품 코드(BH1203$BH1212$...)
	, @Folding_Size_Width              VARCHAR(1000)	-- 졉힌 크기 너비(10$20$30$...)
	, @Folding_Size_Height             VARCHAR(1000)	-- 졉힌 크기 높이(10$20$30$...)
	, @Unfolding_Size_Width            VARCHAR(1000)	-- 펼침 크기 너비(10$20$30$...)
	, @Unfolding_Size_Height           VARCHAR(1000)	-- 펼침 크기 높이(10$20$30$...)
	, @Paper_Temper_Code               VARCHAR(1000)	-- 종이 재질 코드(PA_001$PA_003$PA_010$...)
	, @Laser_Cutting_Time              VARCHAR(1000)	-- 레이저 절단 시간(5$5$10$...)
	, @Storage_Status                  NVARCHAR(3000)	-- 스토리지 상태(메모1$메모2$메모3$...)

	, @Main_Item_Code                  VARCHAR(2000)	-- 메인 품목 코드(IT_001$IT_002$IT_003$...)
	, @Main_Item_Sort                  VARCHAR(2000)	-- 메인 품목 순서(1$1$I1$2$...)
	, @Main_Print_Process_Code         VARCHAR(2000)	-- 메인 인쇄 공정 코드(PR_001$PR_002$PR_003$...)
	, @Process_Difficulty_Code         VARCHAR(2000)	-- 가공 난이도 코드(DI_001$DI_002$DI_003$...)
	, @Process_Difficulty_Description  NVARCHAR(2000)	-- 가공 난이도 설명(설명1$설명2$설명3$...)

	, @Sub_Item_Code                   VARCHAR(3000)	-- 서브 품목 코드(IT_001$IT_002$IT_003$...)
	, @Sub_Item_Sort                   VARCHAR(3000)	-- 서브 품목 순서(1$1$I1$2$...)
	, @Sub_Print_Process_Code          VARCHAR(3000)	-- 서브 인쇄 공정 코드(PR_001$PR_002$PR_003$...)
	, @Process_Item_Code               VARCHAR(3000)	-- 공정 항목 코드(OI_001$SI_001$PI_001$...)
	, @Process_Item_Color              NVARCHAR(3000)	-- 공정 항목 색상(빨강$노랑$파랑$...)
	, @Process_Width                   VARCHAR(3000)	-- 공정 너비(10$20$30$...)
	, @Process_Height                  VARCHAR(3000)	-- 공정 높이(10$20$30$...)

	, @Korea_Item_Code                 VARCHAR(200)		-- 내부가공 품목 코드(KI_001$KI_002$KI_003$...)
	, @Korea_Readymade_Product_Code    VARCHAR(200)		-- 내부가공 기 제품 코드(BH123$BH1212$BH030$...)
	, @Korea_Laser_Cutting_Time        VARCHAR(200)		-- 내부가공 레이저 절단 시간(10$20$30$...)

	, @Main_Korea_Item_Code            VARCHAR(500)		-- 메인 내부가공 품목 코드(KI_001$KI_001$KI_001$...)
	, @Main_Korea_Process_Code         VARCHAR(500)		-- 메인 내부가공 인쇄 공정 코드(KP_001$KP_002$KP_003$...)

	, @Sub_Korea_Item_Code             VARCHAR(1000)	-- 서브 내부가공 품목 코드(KI_001$KI_001$KI_001$...)
	, @Sub_Korea_Process_Code          VARCHAR(1000)	-- 서브 내부가공 인쇄 공정 코드(KP_001$KP_002$KP_003$...)
	, @Korea_Process_Item_Code         VARCHAR(1000)	-- 내부가공 공정 항목 코드(KC_001$KS_001$KO_017$...)
	, @Korea_Process_Item_Color        NVARCHAR(1000)	-- 내부가공 공정 항목 색상(빨강$노랑$파랑$...)
	, @Korea_Process_Width             VARCHAR(1000)	-- 내부가공 공정 너비(10$20$30$...)
	, @Korea_Process_Height            VARCHAR(1000)	-- 내부가공 공정 높이(10$20$30$...)

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

-----------------------------------------------------------------------------------------------------------------------
-- Declare Block
-----------------------------------------------------------------------------------------------------------------------
DECLARE @Product_Main_ID    INT
DECLARE @Product_Item_ID    INT
DECLARE @Product_Korea_ID   INT

DECLARE @Item_Code_Cnt      INT
DECLARE @Korea_Item_Code_Cnt INT

DECLARE @Print_Process_Sort SMALLINT
DECLARE @Korea_Process_Sort SMALLINT

DECLARE @Product_Process_Code_Cnt INT

SET @Product_Main_ID     = 0
SET @Product_Item_ID     = 0
SET @Product_Korea_ID    = 0

SET @Item_Code_Cnt       = 0
SET @Korea_Item_Code_Cnt = 0

SET @Print_Process_Sort  = 0
SET @Korea_Process_Sort  = 0

SET @Product_Process_Code_Cnt = 0
-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	--BEGIN TRY

		----------------------------------------------------------------------------------
		-- 데이터 중복 등록 방지를 위한 카운트 체크
		----------------------------------------------------------------------------------
		SELECT @Product_Process_Code_Cnt = COUNT(*)
		  FROM ProductPlan.dbo.TB_Product_Main
		 WHERE Product_Process_Code = @Product_Process_Code
		   AND Product_Sort = @Product_Sort

		IF @Product_Process_Code_Cnt = 0
		BEGIN

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
					VALUES
						 ( @Product_Year
						 , @Product_Sort
						 , @Product_Process_Code
						 , @ERP_Code
						 , @Product_Code
						 , @Brand_Code
						 , @Login_User_ID
						 , @Category_Code
						 , @Product_Center_Code
						 , @Temp_Code
						 , @Count
						 , @Caution
						 , @Packing
						 , CASE WHEN @Sample_Original_File_Name <> '' THEN @Sample_Original_File_Name END
						 , CASE WHEN @Sample_File_Path <> '' THEN @Sample_File_Path END
						 , @FoldingPrint1_Item_Code
						 , @FoldingPrint2_Item_Code
						 , @Card_FoldingPrint_Code
						 , @Inpaper_FoldingPrint_Code
						 , @FoldingPrint_Memo
						 , CASE WHEN @FoldingPrint_Original_File_Name <> '' THEN @FoldingPrint_Original_File_Name END
						 , CASE WHEN @FoldingPrint_File_Path <> '' THEN @FoldingPrint_File_Path END
						 , @Signature1_User_ID
						 , CASE WHEN @Signature1_User_ID <> 0 THEN GETDATE() END
						 , @Signature2_User_ID
						 , CASE WHEN @Signature2_User_ID <> 0 THEN GETDATE() END
						 , @Signature3_User_ID
						 , CASE WHEN @Signature3_User_ID <> 0 THEN GETDATE() END
						 , @Signature4_User_ID
						 , CASE WHEN @Signature4_User_ID <> 0 THEN GETDATE() END
						 , @Login_User_ID
						 , GETDATE()
						 , @Login_User_ID
						 , GETDATE()
						 )

					SET @Product_Main_ID = @@IDENTITY

					----------------------------------------------------------------------------------
					-- 생산 품목/인쇄 공정/인쇄 공정 상세 테이블 저장
					----------------------------------------------------------------------------------
					SELECT @Item_Code_Cnt = COUNT(*)
						FROM ProductPlan.dbo.SplitTableStr(@Item_Code,'$')

					IF @Item_Code_Cnt > 0
					BEGIN

						-------------------------
						-- // 1차 커서용 변수 //
						-------------------------
						-- 품목 코드
						SELECT IndexNo
							 , Value AS Item_Code
						  INTO #TempItem_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Item_Code, '$')

						-- 품목 순서
						SELECT IndexNo
							 , Value AS Item_Sort
						  INTO #TempItem_Sort
						  FROM ProductPlan.dbo.SplitTableStr(@Item_Sort, '$')

						-- 기제품 코드
						SELECT IndexNo
							 , Value AS Readymade_Product_Code
						  INTO #TempReadymade_Product_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Readymade_Product_Code, '$')

						-- 접힌 크기 너비
						SELECT IndexNo
							 , Value AS Folding_Size_Width
						  INTO #TempFolding_Size_Width
						  FROM ProductPlan.dbo.SplitTableStr(@Folding_Size_Width, '$')

						-- 접힌 크기 높이
						SELECT IndexNo
							 , Value AS Folding_Size_Height
						  INTO #TempFolding_Size_Height
						  FROM ProductPlan.dbo.SplitTableStr(@Folding_Size_Height, '$')

						-- 펼침 크기 너비
						SELECT IndexNo
							 , Value AS Unfolding_Size_Width
						  INTO #TempUnfolding_Size_Width
						  FROM ProductPlan.dbo.SplitTableStr(@Unfolding_Size_Width, '$')

						-- 펼침 크기 높이
						SELECT IndexNo
							 , Value AS Unfolding_Size_Height
						  INTO #TempUnfolding_Size_Height
						  FROM ProductPlan.dbo.SplitTableStr(@Unfolding_Size_Height, '$')

						-- 종이 재질 코드
						SELECT IndexNo
							 , Value AS Paper_Temper_Code
						  INTO #TempPaper_Temper_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Paper_Temper_Code, '$')

						-- 레이저 절단 시간
						SELECT IndexNo
							 , Value AS Laser_Cutting_Time
						  INTO #TempLaser_Cutting_Time
						  FROM ProductPlan.dbo.SplitTableStr(@Laser_Cutting_Time, '$')

						-- 스토리지 상태
						SELECT IndexNo
							 , Value AS Storage_Status
						  INTO #TempStorage_Status
						  FROM ProductPlan.dbo.SplitTableStr(@Storage_Status, '$')

						-------------------------
						-- // 2차 커서용 변수 //
						-------------------------
						-- 메인 품목 코드
						SELECT IndexNo
							 , Value AS Main_Item_Code
						  INTO #TempMain_Item_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Main_Item_Code, '$')

						-- 메인 품목 순서
						SELECT IndexNo
							 , Value AS Main_Item_Sort
						  INTO #TempMain_Item_Sort
						  FROM ProductPlan.dbo.SplitTableStr(@Main_Item_Sort, '$')

						-- 메인 인쇄 공정 코드
						SELECT IndexNo
							 , Value AS Main_Print_Process_Code
						  INTO #TempMain_Print_Process_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Main_Print_Process_Code, '$')

						-- 가공 난이도 코드
						SELECT IndexNo
							 , Value AS Process_Difficulty_Code
						  INTO #TempProcess_Difficulty_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Process_Difficulty_Code, '$')

						-- 가공 난이도 설명
						SELECT IndexNo
							 , Value AS Process_Difficulty_Description
						  INTO #TempProcess_Difficulty_Description
						  FROM ProductPlan.dbo.SplitTableStr(@Process_Difficulty_Description, '$')

						-------------------------
						-- // 3차 커서용 변수 //
						-------------------------
						-- 서브 품목 코드
						SELECT IndexNo
							 , Value AS Sub_Item_Code
						  INTO #TempSub_Item_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Sub_Item_Code, '$')

						-- 서브 품목 순서
						SELECT IndexNo
							 , Value AS Sub_Item_Sort
						  INTO #TempSub_Item_Sort
						  FROM ProductPlan.dbo.SplitTableStr(@Sub_Item_Sort, '$')

						-- 서브 인쇄 공정 코드
						SELECT IndexNo
							 , Value AS Sub_Print_Process_Code
						  INTO #TempSub_Print_Process_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Sub_Print_Process_Code, '$')

						-- 공정 항목 코드
						SELECT IndexNo
							 , Value AS Process_Item_Code
						  INTO #TempProcess_Item_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Process_Item_Code, '$')

						-- 공정 항목 색상
						SELECT IndexNo
							 , Value AS Process_Item_Color
						  INTO #TempProcess_Item_Color
						  FROM ProductPlan.dbo.SplitTableStr(@Process_Item_Color, '$')

						-- 공정 너비
						SELECT IndexNo
							 , Value AS Process_Width
						  INTO #TempProcess_Width
						  FROM ProductPlan.dbo.SplitTableStr(@Process_Width, '$')

						-- 공정 높이
						SELECT IndexNo
							 , Value AS Process_Height
						  INTO #TempProcess_Height
						  FROM ProductPlan.dbo.SplitTableStr(@Process_Height, '$')

						----------------------------------------------------------------------------------
						-- 생산 품목(1차 Cursor)
						----------------------------------------------------------------------------------
						DECLARE CURSOR_Product_Item CURSOR FOR
					
						SELECT T1.Item_Code
							 , T2.Item_Sort
							 , T3.Readymade_Product_Code
							 , T4.Folding_Size_Width
							 , T5.Folding_Size_Height
							 , T6.Unfolding_Size_Width
							 , T7.Unfolding_Size_Height
							 , T8.Paper_Temper_Code
							 , T9.Laser_Cutting_Time
							 , T10.Storage_Status
						  FROM #TempItem_Code                   AS T1
						 INNER JOIN #TempItem_Sort              AS T2 ON (T1.IndexNo = T2.IndexNo)
						 INNER JOIN #TempReadymade_Product_Code AS T3 ON (T2.IndexNo = T3.IndexNo)
						 INNER JOIN #TempFolding_Size_Width     AS T4 ON (T3.IndexNo = T4.IndexNo)
						 INNER JOIN #TempFolding_Size_Height    AS T5 ON (T4.IndexNo = T5.IndexNo)
						 INNER JOIN #TempUnfolding_Size_Width   AS T6 ON (T5.IndexNo = T6.IndexNo)
						 INNER JOIN #TempUnfolding_Size_Height  AS T7 ON (T6.IndexNo = T7.IndexNo)
						 INNER JOIN #TempPaper_Temper_Code      AS T8 ON (T7.IndexNo = T8.IndexNo)
						 INNER JOIN #TempLaser_Cutting_Time     AS T9 ON (T8.IndexNo = T9.IndexNo)
						 INNER JOIN #TempStorage_Status         AS T10 ON (T9.IndexNo = T10.IndexNo)
				         					 									 
						OPEN CURSOR_Product_Item
				
						FETCH NEXT FROM CURSOR_Product_Item INTO @Item_Code, @Item_Sort, @Readymade_Product_Code, @Folding_Size_Width, @Folding_Size_Height, @Unfolding_Size_Width, @Unfolding_Size_Height, @Paper_Temper_Code, @Laser_Cutting_Time, @Storage_Status					
					
						WHILE @@fetch_status = 0
						BEGIN
							-- 접힌 사이즈가 공백이 아닌 경우에만 등록
							IF @Folding_Size_Width <> '' AND @Folding_Size_Height <> ''
							BEGIN
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
								VALUES
									 ( @Product_Main_ID
									 , @Item_Code
									 , CONVERT(SMALLINT, @Item_Sort)
									 , @Readymade_Product_Code
									 , CASE WHEN @Folding_Size_Width <> '' THEN CONVERT(SMALLINT, @Folding_Size_Width) ELSE 0 END
									 , CASE WHEN @Folding_Size_Height <> '' THEN CONVERT(SMALLINT, @Folding_Size_Height) ELSE 0 END
									 , CASE WHEN @Unfolding_Size_Width <> '' THEN CONVERT(SMALLINT, @Unfolding_Size_Width) ELSE 0 END
									 , CASE WHEN @Unfolding_Size_Height <> '' THEN CONVERT(SMALLINT, @Unfolding_Size_Height) ELSE 0 END
									 , @Paper_Temper_Code
									 , CASE WHEN @Laser_Cutting_Time <> '' THEN CONVERT(INT, @Laser_Cutting_Time) ELSE 0 END
									 , @Storage_Status
									)

								SET @Product_Item_ID = @@IDENTITY

								----------------------------------------------------------------------------------
								-- 인쇄 공정(2차 Cursor)
								----------------------------------------------------------------------------------
								DECLARE CURSOR_Print_Process CURSOR FOR

								SELECT T1.Main_Item_Code
									 , T2.Main_Item_Sort
									 , T3.Main_Print_Process_Code
									 , T4.Process_Difficulty_Code
									 , T5.Process_Difficulty_Description
								  FROM #TempMain_Item_Code                      AS T1
								 INNER JOIN #TempMain_Item_Sort                 AS T2 ON (T1.IndexNo = T2.IndexNo)
								 INNER JOIN #TempMain_Print_Process_Code        AS T3 ON (T2.IndexNo = T3.IndexNo)
								 INNER JOIN #TempProcess_Difficulty_Code        AS T4 ON (T3.IndexNo = T4.IndexNo)
								 INNER JOIN #TempProcess_Difficulty_Description AS T5 ON (T4.IndexNo = T5.IndexNo)

								OPEN CURSOR_Print_Process

								FETCH NEXT FROM CURSOR_Print_Process INTO @Main_Item_Code, @Main_Item_Sort, @Main_Print_Process_Code, @Process_Difficulty_Code, @Process_Difficulty_Description

								WHILE @@fetch_status = 0
								BEGIN
									-- Item_Code & Item_Sort가 일치하는 데이터만 등록
									IF @Item_Code = @Main_Item_Code AND @Item_Sort = @Main_Item_Sort
									BEGIN
										INSERT INTO ProductPlan.dbo.TB_Print_Process
											 ( Product_Item_ID
											 , Print_Process_Code
											 , Process_Difficulty_Code
											 , Process_Difficulty_Description
											 )
										VALUES
											 ( @Product_Item_ID
											 , @Main_Print_Process_Code
											 , @Process_Difficulty_Code
											 , @Process_Difficulty_Description
											 )

										----------------------------------------------------------------------------------
										-- 인쇄 공정 상세(3차 Cursor)
										----------------------------------------------------------------------------------
										DECLARE CURSOR_Print_Process_Detail CURSOR FOR

										SELECT T1.Sub_Item_Code
											 , T2.Sub_Item_Sort
											 , T3.Sub_Print_Process_Code
											 , T4.Process_Item_Code
											 , T5.Process_Item_Color
											 , T6.Process_Width
											 , T7.Process_Height
										  FROM #TempSub_Item_Code               AS T1
										 INNER JOIN #TempSub_Item_Sort          AS T2 ON (T1.IndexNo = T2.IndexNo)
										 INNER JOIN #TempSub_Print_Process_Code AS T3 ON (T2.IndexNo = T3.IndexNo)
										 INNER JOIN #TempProcess_Item_Code      AS T4 ON (T3.IndexNo = T4.IndexNo)
										 INNER JOIN #TempProcess_Item_Color     AS T5 ON (T4.IndexNo = T5.IndexNo)
										 INNER JOIN #TempProcess_Width          AS T6 ON (T5.IndexNo = T6.IndexNo)
										 INNER JOIN #TempProcess_Height         AS T7 ON (T6.IndexNo = T7.IndexNo)

										 OPEN CURSOR_Print_Process_Detail

										 FETCH NEXT FROM CURSOR_Print_Process_Detail INTO @Sub_Item_Code, @Sub_Item_Sort, @Sub_Print_Process_Code, @Process_Item_Code, @Process_Item_Color, @Process_Width, @Process_Height

										 WHILE @@fetch_status = 0
										 BEGIN
										
											-- Item_Code & Item_Sort & Print_Process_Code가 일치하는 데이터만 등록
											IF @Main_Item_Code = @Sub_Item_Code AND @Main_Item_Sort = @Sub_Item_Sort AND @Main_Print_Process_Code = @Sub_Print_Process_Code
											BEGIN
												-- 입력데이터 중 하나라도 공백이 아닌 경우 등록
												IF @Process_Item_Code <> '' OR @Process_Item_Color <> '' OR @Process_Width <> '' OR @Process_Height <> ''
												BEGIN
												
													-- 등록된 인쇄 공정 항목 수 조회
													SELECT @Print_Process_Sort = Count(*)
													  FROM ProductPlan.dbo.TB_Print_Process_Detail
													 WHERE Product_Item_ID = @Product_Item_ID
													   AND Print_Process_Code = @Sub_Print_Process_Code

													INSERT INTO ProductPlan.dbo.TB_Print_Process_Detail
														 ( Product_Item_ID
														 , Print_Process_Code
														 , Print_Process_Sort
														 , Process_Item_Code
														 , Process_Item_Color
														 , Process_Width
														 , Process_Height
														 )
													VALUES
														 ( @Product_Item_ID
														 , @Sub_Print_Process_Code
														 , @Print_Process_Sort + 1
														 , @Process_Item_Code
														 , @Process_Item_Color
														 , CASE WHEN @Process_Width <> '' THEN CONVERT(SMALLINT, @Process_Width) ELSE 0 END
														 , CASE WHEN @Process_Height <> '' THEN CONVERT(SMALLINT, @Process_Height) ELSE 0 END
														 )
												END
											END

											FETCH NEXT FROM CURSOR_Print_Process_Detail INTO @Sub_Item_Code, @Sub_Item_Sort, @Sub_Print_Process_Code, @Process_Item_Code, @Process_Item_Color, @Process_Width, @Process_Height
										 END

										 CLOSE CURSOR_Print_Process_Detail
										 DEALLOCATE CURSOR_Print_Process_Detail

									END

									FETCH NEXT FROM CURSOR_Print_Process INTO @Main_Item_Code, @Main_Item_Sort, @Main_Print_Process_Code, @Process_Difficulty_Code, @Process_Difficulty_Description

								END

								CLOSE CURSOR_Print_Process
								DEALLOCATE CURSOR_Print_Process

							END	-- //접힌 사이즈 입력여부 체크
								  
							FETCH NEXT FROM CURSOR_Product_Item INTO @Item_Code, @Item_Sort, @Readymade_Product_Code, @Folding_Size_Width, @Folding_Size_Height, @Unfolding_Size_Width, @Unfolding_Size_Height, @Paper_Temper_Code, @Laser_Cutting_Time, @Storage_Status
						END
				
						CLOSE CURSOR_Product_Item
						DEALLOCATE CURSOR_Product_Item


						DROP TABLE #TempItem_Code
						DROP TABLE #TempItem_Sort
						DROP TABLE #TempReadymade_Product_Code
						DROP TABLE #TempFolding_Size_Width
						DROP TABLE #TempFolding_Size_Height
						DROP TABLE #TempUnfolding_Size_Width
						DROP TABLE #TempUnfolding_Size_Height
						DROP TABLE #TempPaper_Temper_Code
						DROP TABLE #TempStorage_Status
						DROP TABLE #TempMain_Item_Code
						DROP TABLE #TempMain_Item_Sort
						DROP TABLE #TempMain_Print_Process_Code
						DROP TABLE #TempProcess_Difficulty_Code
						DROP TABLE #TempProcess_Difficulty_Description
						DROP TABLE #TempSub_Item_Code
						DROP TABLE #TempSub_Item_Sort
						DROP TABLE #TempSub_Print_Process_Code
						DROP TABLE #TempProcess_Item_Code
						DROP TABLE #TempProcess_Item_Color
						DROP TABLE #TempProcess_Width
						DROP TABLE #TempProcess_Height

					END

					----------------------------------------------------------------------------------
					-- [내부가공] 생산 품목/인쇄 공정/인쇄 공정 상세 테이블 저장
					----------------------------------------------------------------------------------
					SELECT @Korea_Item_Code_Cnt = COUNT(*)
					  FROM ProductPlan.dbo.SplitTableStr(@Korea_Item_Code,'$')

					IF @Korea_Item_Code_Cnt > 0
					BEGIN
						-------------------------
						-- // 1차 커서용 변수 //
						-------------------------
						-- 품목 코드
						SELECT IndexNo
							 , Value AS Korea_Item_Code
						  INTO #TempKorea_Item_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Korea_Item_Code, '$')

						-- 기 제품 코드
						SELECT IndexNo
							 , Value AS Korea_Readymade_Product_Code
						  INTO #TempKorea_Readymade_Product_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Korea_Readymade_Product_Code, '$')

						-- 레이저 절단 시간
						SELECT IndexNo
							 , Value AS Korea_Laser_Cutting_Time
						  INTO #TempKorea_Laser_Cutting_Time
						  FROM ProductPlan.dbo.SplitTableStr(@Korea_Laser_Cutting_Time, '$')

						-------------------------
						-- // 2차 커서용 변수 //
						-------------------------
						-- 메인 품목 코드
						SELECT IndexNo
							 , Value AS Main_Korea_Item_Code
						  INTO #TempMain_Korea_Item_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Main_Korea_Item_Code, '$')

						-- 메인 공정 코드
						SELECT IndexNo
							 , Value AS Main_Print_Korea_Process_Code
						  INTO #TempMain_Print_Korea_Process_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Main_Korea_Process_Code, '$')

						-------------------------
						-- // 3차 커서용 변수 //
						-------------------------
						-- 서브 품목 코드
						SELECT IndexNo
							 , Value AS Sub_Korea_Item_Code
						  INTO #TempSub_Korea_Item_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Sub_Korea_Item_Code, '$')

						-- 서브 인쇄 공정 코드
						SELECT IndexNo
							 , Value AS Sub_Print_Korea_Process_Code
						  INTO #TempSub_Print_Korea_Process_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Sub_Korea_Process_Code, '$')

						-- 공정 항목 코드
						SELECT IndexNo
							 , Value AS Korea_Process_Item_Code
						  INTO #TempKorea_Process_Item_Code
						  FROM ProductPlan.dbo.SplitTableStr(@Korea_Process_Item_Code, '$')

						-- 공정 항목 색상
						SELECT IndexNo
							 , Value AS Korea_Process_Item_Color
						  INTO #TempKorea_Process_Item_Color
						  FROM ProductPlan.dbo.SplitTableStr(@Korea_Process_Item_Color, '$')

						-- 공정 너비
						SELECT IndexNo
							 , Value AS Korea_Process_Width
						  INTO #TempKorea_Process_Width
						  FROM ProductPlan.dbo.SplitTableStr(@Korea_Process_Width, '$')

						-- 공정 높이
						SELECT IndexNo
							 , Value AS Korea_Process_Height
						  INTO #TempKorea_Process_Height
						  FROM ProductPlan.dbo.SplitTableStr(@Korea_Process_Height, '$')

						----------------------------------------------------------------------------------
						-- 내부가공 생산 품목(1차 Cursor)
						----------------------------------------------------------------------------------
						DECLARE CURSOR_Korea_Product_Item CURSOR FOR

						SELECT T1.Korea_Item_Code
							 , T2.Korea_Readymade_Product_Code
							 , T3.Korea_Laser_Cutting_Time
						  FROM #TempKorea_Item_Code                   AS T1
						 INNER JOIN #TempKorea_Readymade_Product_Code AS T2 ON (T1.IndexNo = T2.IndexNo)
						 INNER JOIN #TempKorea_Laser_Cutting_Time     AS T3 ON (T2.IndexNo = T3.IndexNo)

						OPEN CURSOR_Korea_Product_Item
				
						FETCH NEXT FROM CURSOR_Korea_Product_Item INTO @Korea_Item_Code, @Korea_Readymade_Product_Code, @Korea_Laser_Cutting_Time			
					
						WHILE @@fetch_status = 0
						BEGIN

							-- 내부가공 품목 코드가 공백이 아닌 경우에만 등록
							IF @Korea_Item_Code <> ''
							BEGIN
								INSERT INTO ProductPlan.dbo.TB_Product_Korea
									 ( Product_Main_ID
									 , Korea_Item_Code
									 , Korea_Readymade_Product_Code
									 , Korea_Laser_Cutting_Time
									 )
								VALUES
									 ( @Product_Main_ID
									 , @Korea_Item_Code
									 , @Korea_Readymade_Product_Code
									 , CASE WHEN @Korea_Laser_Cutting_Time <> '' THEN CONVERT(INT, @Korea_Laser_Cutting_Time) ELSE 0 END
									 )

								SET @Product_Korea_ID = @@IDENTITY

								----------------------------------------------------------------------------------
								-- 내부가공 인쇄 공정(2차 Cursor)
								----------------------------------------------------------------------------------
								DECLARE CURSOR_Print_Korea_Process CURSOR FOR

								SELECT T1.Main_Korea_Item_Code
									 , T2.Main_Print_Korea_Process_Code
								  FROM #TempMain_Korea_Item_Code               AS T1
								 INNER JOIN #TempMain_Print_Korea_Process_Code AS T2 ON (T1.IndexNo = T2.IndexNo)

								OPEN CURSOR_Print_Korea_Process

								FETCH NEXT FROM CURSOR_Print_Korea_Process INTO @Main_Korea_Item_Code, @Main_Korea_Process_Code

								WHILE @@fetch_status = 0
								BEGIN
									-- Korea_Item_Code가 일치하는 데이터만 등록
									IF @Korea_Item_Code = @Main_Korea_Item_Code
									BEGIN
										INSERT INTO ProductPlan.dbo.TB_Print_Korea_Process
											 ( Product_Korea_ID
											 , Korea_Process_Code
											 )
										VALUES
											 ( @Product_Korea_ID
											 , @Main_Korea_Process_Code
											 )

										----------------------------------------------------------------------------------
										-- 내부가공 인쇄 공정 상세(3차 Cursor)
										----------------------------------------------------------------------------------
										DECLARE CURSOR_Print_Korea_Process_Detail CURSOR FOR

										SELECT T1.Sub_Korea_Item_Code
											 , T2.Sub_Print_Korea_Process_Code
											 , T3.Korea_Process_Item_Code
											 , T4.Korea_Process_Item_Color
											 , T5.Korea_Process_Width
											 , T6.Korea_Process_Height
										  FROM #TempSub_Korea_Item_Code               AS T1
										 INNER JOIN #TempSub_Print_Korea_Process_Code AS T2 ON (T1.IndexNo = T2.IndexNo)
										 INNER JOIN #TempKorea_Process_Item_Code      AS T3 ON (T2.IndexNo = T3.IndexNo)
										 INNER JOIN #TempKorea_Process_Item_Color     AS T4 ON (T3.IndexNo = T4.IndexNo)
										 INNER JOIN #TempKorea_Process_Width          AS T5 ON (T4.IndexNo = T5.IndexNo)
										 INNER JOIN #TempKorea_Process_Height         AS T6 ON (T5.IndexNo = T6.IndexNo)

										 OPEN CURSOR_Print_Korea_Process_Detail

										 FETCH NEXT FROM CURSOR_Print_Korea_Process_Detail INTO @Sub_Korea_Item_Code, @Sub_Korea_Process_Code, @Korea_Process_Item_Code, @Korea_Process_Item_Color, @Korea_Process_Width, @Korea_Process_Height

										 WHILE @@fetch_status = 0
										 BEGIN

											-- Item_Code & Print_Process_Code가 일치하는 데이터만 등록
											IF @Main_Korea_Item_Code = @Sub_Korea_Item_Code AND @Main_Korea_Process_Code = @Sub_Korea_Process_Code
											BEGIN
												-- 입력데이터 중 하나라도 공백이 아닌 경우 등록
												IF @Korea_Process_Item_Code <> '' OR @Korea_Process_Item_Color <> '' OR @Korea_Process_Width <> '' OR @Korea_Process_Height <> ''
												BEGIN
													-- 등록된 인쇄 공정 항목 수 조회
													SELECT @Korea_Process_Sort = Count(*)
													  FROM ProductPlan.dbo.TB_Print_Korea_Process_Detail
													 WHERE Product_Korea_ID = @Product_Korea_ID
													   AND Korea_Process_Code = @Sub_Korea_Process_Code

													INSERT INTO ProductPlan.dbo.TB_Print_Korea_Process_Detail
														 ( Product_Korea_ID
														 , Korea_Process_Code
														 , Korea_Process_Sort
														 , Korea_Process_Item_Code
														 , Korea_Process_Item_Color
														 , Korea_Process_Width
														 , Korea_Process_Height
														 )
													VALUES
														 ( @Product_Korea_ID
														 , @Sub_Korea_Process_Code
														 , @Korea_Process_Sort + 1
														 , @Korea_Process_Item_Code
														 , @Korea_Process_Item_Color
														 , CASE WHEN @Korea_Process_Width <> '' THEN CONVERT(SMALLINT, @Korea_Process_Width) ELSE 0 END
														 , CASE WHEN @Korea_Process_Height <> '' THEN CONVERT(SMALLINT, @Korea_Process_Height) ELSE 0 END
														 )
												END
											END

											FETCH NEXT FROM CURSOR_Print_Korea_Process_Detail INTO @Sub_Korea_Item_Code, @Sub_Korea_Process_Code, @Korea_Process_Item_Code, @Korea_Process_Item_Color, @Korea_Process_Width, @Korea_Process_Height
										END

										CLOSE CURSOR_Print_Korea_Process_Detail
										DEALLOCATE CURSOR_Print_Korea_Process_Detail

									END

									FETCH NEXT FROM CURSOR_Print_Korea_Process INTO @Main_Korea_Item_Code, @Main_Korea_Process_Code

								END

								CLOSE CURSOR_Print_Korea_Process
								DEALLOCATE CURSOR_Print_Korea_Process

							END	-- //내부가공 품목 코드 입력여부 체크

							FETCH NEXT FROM CURSOR_Korea_Product_Item INTO @Korea_Item_Code, @Korea_Readymade_Product_Code, @Korea_Laser_Cutting_Time
						END

						CLOSE CURSOR_Korea_Product_Item
						DEALLOCATE CURSOR_Korea_Product_Item

						DROP TABLE #TempKorea_Item_Code
						DROP TABLE #TempKorea_Readymade_Product_Code
						DROP TABLE #TempKorea_Laser_Cutting_Time
						DROP TABLE #TempMain_Korea_Item_Code
						DROP TABLE #TempMain_Print_Korea_Process_Code
						DROP TABLE #TempSub_Korea_Item_Code
						DROP TABLE #TempSub_Print_Korea_Process_Code
						DROP TABLE #TempKorea_Process_Item_Code
						DROP TABLE #TempKorea_Process_Item_Color
						DROP TABLE #TempKorea_Process_Width
						DROP TABLE #TempKorea_Process_Height

					END

			COMMIT TRAN
		END

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
EXEC ProductPlan.dbo.USP_T_PRODUCT_PLAN_REG
	   1				
	 , 2021						
     , 17					
	 , 'P21_017'					
	 , ''
	 , 'BR_002'	-- 프리미어페이퍼
	 , 'CA_003'	-- 박스
	 , 'PC_002'	-- KOREA
	 , ''		-- 임시코드
	 , 0		-- 수량
	 , NULL					
	 , NULL		-- 포장				
	 , NULL						
	 , NULL
	 , ''		-- 대첩1 항목 코드
	 , ''
	 , ''		-- 카드 대첩 코드			
	 , ''						
	 , NULL		-- 대첩 메모				
	 , NULL		-- 대첩 원본 파일명				
     , NULL		-- 대첩 파일 경로			
     , 0		-- 서명1 사용자 ID
	 , 0
	 , 0
	 , 0

     , 'IT_001$IT_002'	--품목 코드
     , '1$1'
	 , '$'
	 , '10$'	-- 접힌 크기 너비
	 , '20$'	-- 접힌 크기 높이
	 , '$'
	 , '$'
	 , '$'	-- 종이 재질 코드
	 , '$'
	 , '$'	-- 스토리지 상태

	 , 'IT_001$IT_001$IT_001$IT_002$IT_002$IT_002'	-- 메인 품목 코드
	 , '1$1$1$1$1$1'
	 , 'PR_001$PR_002$PR_003$PR_001$PR_002$PR_003'
	 , '$$$$$'
	 , '$$$$$'

	 , 'IT_001$IT_001$IT_001$IT_002$IT_002$IT_002'	-- 서브 품목 코드
	 , '1$1$1$1$1$1'
	 , 'PR_001$PR_002$PR_003$PR_001$PR_002$PR_003'
	 , '$$$$$'
	 , '$$$$$'
	 , '$$$$$'
	 , '$$$$$'

	 , 'KI_001$KI_002$KI_003$KI_004$KI_005'			-- 내부가공 품목 코드
	 , '$$$$$'
	 , '$$$$$'

	 , 'KI_001$KI_001$KI_001$KI_002$KI_002$KI_002$KI_003$KI_003$KI_003$KI_004$KI_004$KI_004$KI_005$KI_005$KI_005'	-- 메인 내부가공 풀목 코드
	 , 'KP_001$KP_002$KP_003$KP_001$KP_002$KP_003$KP_001$KP_002$KP_003$KP_001$KP_002$KP_003$KP_001$KP_002$KP_003'

	 , 'KI_001$KI_001$KI_001$KI_002$KI_002$KI_002$KI_003$KI_003$KI_003$KI_004$KI_004$KI_004$KI_005$KI_005$KI_005'	-- 서브 내부가공 품목 코드
	 , 'KP_001$KP_002$KP_003$KP_001$KP_002$KP_003$KP_001$KP_002$KP_003$KP_001$KP_002$KP_003$KP_001$KP_002$KP_003'
	 , '$$$KC_001$KS_001$KO_017$$$$$$$$$'
	 , '$$$$$$$$$$$$$$'
	 , '$$$$$10$$$$$$$$$'
	 , '$$$$$30$$$$$$$$$'
*/
GO
