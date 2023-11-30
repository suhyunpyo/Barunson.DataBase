IF OBJECT_ID (N'dbo.view_OB_Card', N'V') IS NOT NULL DROP View dbo.view_OB_Card
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[view_OB_Card]  
AS  
SELECT   dbo.CARD.*  
FROM      dbo.CARD  


GO
