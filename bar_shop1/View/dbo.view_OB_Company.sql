IF OBJECT_ID (N'dbo.view_OB_Company', N'V') IS NOT NULL DROP View dbo.view_OB_Company
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[view_OB_Company]
AS
SELECT   *
FROM      dbo.COMPANY
GO
