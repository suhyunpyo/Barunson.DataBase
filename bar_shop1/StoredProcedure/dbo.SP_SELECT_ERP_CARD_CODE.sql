SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*  
  
 EXEC SP_SELECT_ERP_CARD_CODE 'BSI002'  
  
*/  
ALTER PROCEDURE [dbo].[SP_SELECT_ERP_CARD_CODE]  
    @P_CARD_CODE AS VARCHAR(100)  
AS  
BEGIN  
  
 SELECT  ltrim(rtrim(ItemCode)) AS ItemCode    , ItemName    , ItemSpec AS ItemSize    , CONVERT(INT, ROUND(ISNULL(C_sobi, 0), 0))  AS ItemPrice  
 FROM XERP.dbo.ItemSiteMaster  
 WHERE SiteCode = 'BK10' AND ItemCode = @P_CARD_CODE  
  
END  
GO
