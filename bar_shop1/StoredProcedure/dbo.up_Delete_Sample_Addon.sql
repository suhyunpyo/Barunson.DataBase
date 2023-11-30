IF OBJECT_ID (N'dbo.up_Delete_Sample_Addon', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Delete_Sample_Addon
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		박동혁
-- Create date: 2015-05-08
-- Description:	추천샘플 프로모션 목록 삭제
--
/*
	exec up_Delete_Sample_Addon @Company_Seq='5007', @Sales_Gubun='ST', @Promotion_Year='2015', @Promotion_Month='05', @Card_Seq='35362', @Card_Code='BH5102'
*/
-- =============================================
CREATE PROCEDURE [dbo].[up_Delete_Sample_Addon]
(  
	  @Company_Seq INT
	, @Sales_Gubun VARCHAR(10)
	, @Promotion_Year CHAR(4)
	, @Promotion_Month CHAR(2)
	, @Card_Seq INT
	, @Card_Code VARCHAR(20)
)  
AS
BEGIN

	SET NOCOUNT ON;
	
	DELETE 
	FROM Sample_Addon
	WHERE Company_Seq = @Company_Seq
		AND Sales_Gubun = @Sales_Gubun
		AND Promotion_Year = @Promotion_Year
		AND Promotion_Month = @Promotion_Month
		AND Card_Seq = @Card_Seq
		AND Card_Code = @Card_Code;	
		
END

GO
