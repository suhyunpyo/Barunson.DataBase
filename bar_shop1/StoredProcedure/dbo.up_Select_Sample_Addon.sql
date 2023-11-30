IF OBJECT_ID (N'dbo.up_Select_Sample_Addon', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_Sample_Addon
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		박동혁
-- Create date: 2015-05-08
-- Description:	추천샘플 프로모션 목록 조회
--
/*
	exec up_Select_Sample_Addon '5007', 'ST'
*/
-- =============================================
CREATE PROCEDURE [dbo].[up_Select_Sample_Addon]
(  
	  @Company_Seq INT
	, @Sales_Gubun VARCHAR(10)
	, @Promotion_Year CHAR(4) = NULL
	, @Promotion_Month CHAR(2) = NULL
	, @Card_Seq INT = NULL
	, @Card_Code VARCHAR(20) = NULL
	, @Use_YN CHAR(1) = NULL
)  
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT
		  A.Sample_Addon_Seq
		, A.Company_Seq
		, A.Sales_Gubun
		, A.Promotion_Year
		, A.Promotion_Month
		, A.Card_Seq
		, A.Card_Code
		, B.Card_Name
		, A.Use_YN
		, A.Reg_Date	
	FROM Sample_Addon AS A
		INNER JOIN S2_Card AS B
			ON A.Card_Seq = B.Card_Seq
	WHERE A.Company_Seq = @Company_Seq
		AND A.Sales_Gubun = @Sales_Gubun
		AND (A.Promotion_Year = @Promotion_Year OR '' = ISNULL(@Promotion_Year, ''))
		AND (A.Promotion_Month = @Promotion_Month OR '' = ISNULL(@Promotion_Month, ''))
		AND (A.Card_Seq = @Card_Seq OR '' = ISNULL(@Card_Seq, ''))
		AND (A.Card_Code = @Card_Code OR '' = ISNULL(@Card_Code, ''))
		AND (A.Use_YN = @Use_YN OR '' = ISNULL(@Use_YN, ''))
		
END

GO
