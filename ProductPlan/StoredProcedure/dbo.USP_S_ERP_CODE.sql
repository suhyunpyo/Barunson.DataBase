IF OBJECT_ID (N'dbo.USP_S_ERP_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.USP_S_ERP_CODE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : USP_S_ERP_CODE
-- Author        : 박혜림
-- Create date   : 2021-06-09
-- Description   : ERP CODE 조회
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[USP_S_ERP_CODE]
	   @ERP_Code VARCHAR(30)
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
		-- ERP 코드 조회
		----------------------------------------------------------------------------------
		IF @ERP_Code <> ''
		BEGIN
			SELECT LTRIM(RTRIM(ItemCode)) AS ERP_Code
				 , ItemName AS Item_Name
				 , ItemSpec AS Item_Size
				 , CONVERT(INT, ROUND(ISNULL(C_sobi, 0), 0)) AS Item_Price
			  FROM [ERPDB.BHANDSCARD.COM].XERP.dbo.ItemSiteMaster
			 WHERE SiteCode = 'BK10' AND ItemCode LIKE '%' + @ERP_Code + '%'
			 ORDER BY LTRIM(RTRIM(ItemCode)) ASC
		END
		ELSE	-- 공백인 경우
		BEGIN
			SELECT LTRIM(RTRIM(ItemCode)) AS ERP_Code
				 , ItemName AS Item_Name
				 , ItemSpec AS Item_Size
				 , CONVERT(INT, ROUND(ISNULL(C_sobi, 0), 0)) AS Item_Price
			  FROM [ERPDB.BHANDSCARD.COM].XERP.dbo.ItemSiteMaster
			 WHERE SiteCode = 'BK10' AND ItemCode = @ERP_Code
			 ORDER BY LTRIM(RTRIM(ItemCode)) ASC
		END
END

-- Execute Sample
/*

EXEC ProductPlan.dbo.USP_S_ERP_CODE 'BH84'

*/
GO
