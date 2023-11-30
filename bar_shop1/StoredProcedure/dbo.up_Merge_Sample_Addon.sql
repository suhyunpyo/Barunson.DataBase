IF OBJECT_ID (N'dbo.up_Merge_Sample_Addon', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Merge_Sample_Addon
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		박동혁
-- Create date: 2015-05-08
-- Description:	추천샘플 프로모션 목록 입력/수정
--
/*
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5102', @Use_YN='Y'
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5115', @Use_YN='Y'
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5125', @Use_YN='Y'
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5126', @Use_YN='Y'
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5127', @Use_YN='Y'
	
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5102', @Use_YN='N'
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5115', @Use_YN='N'
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5125', @Use_YN='N'
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5126', @Use_YN='N'
	exec up_Merge_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Code='BH5127', @Use_YN='N'
*/
-- =============================================
CREATE PROCEDURE [dbo].[up_Merge_Sample_Addon]
(  
	  @Company_Seq INT
	, @Sales_Gubun VARCHAR(10)
	, @Promotion_Year CHAR(4)
	, @Promotion_Month CHAR(2)
	, @Card_Code VARCHAR(20)
	, @Use_YN CHAR(1)
)  
AS
BEGIN
	
	BEGIN TRAN;
	
		DECLARE @Card_Seq INT;
		
		SELECT TOP 1 @Card_Seq = Card_Seq FROM S2_Card WHERE Card_Code = @Card_Code;

		MERGE INTO Sample_Addon AS A
		USING (
					SELECT
						  @Company_Seq AS Company_Seq
						, @Sales_Gubun AS Sales_Gubun
						, @Promotion_Year AS Promotion_Year
						, @Promotion_Month AS Promotion_Month
						, @Card_Seq AS Card_Seq
						, @Card_Code AS Card_Code
						, @Use_YN AS Use_YN
			  ) AS B
			ON A.Company_Seq = B.Company_Seq
			AND A.Sales_Gubun = B.Sales_Gubun
			AND A.Promotion_Year = B.Promotion_Year
			AND A.Promotion_Month = B.Promotion_Month
			AND A.Card_Seq = B.Card_Seq
			AND A.Card_Code = B.Card_Code
		WHEN MATCHED THEN
			UPDATE 
				SET A.Use_YN = @Use_YN
				  , A.Reg_Date = GETDATE()
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
						  Company_Seq
						, Sales_Gubun
						, Promotion_Year
						, Promotion_Month
						, Card_Seq
						, Card_Code
						, Use_YN
						, Reg_Date
				   ) 
			VALUES (
						  @Company_Seq
						, @Sales_Gubun
						, @Promotion_Year
						, @Promotion_Month
						, @Card_Seq
						, @Card_Code
						, @Use_YN
						, GETDATE()
				   );

	IF @@ERROR <> 0
		BEGIN
			PRINT '데이터 입력/수정 중 오류 발생!';
			ROLLBACK TRAN;
		END
	ELSE
		BEGIN
			COMMIT TRAN;
		END

END

GO
