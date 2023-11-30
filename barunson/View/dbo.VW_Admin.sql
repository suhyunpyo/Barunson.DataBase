IF OBJECT_ID (N'dbo.VW_Admin', N'V') IS NOT NULL DROP View dbo.VW_Admin
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VW_Admin]
AS

 SELECT ADMIN_NAME = ADMIN_NAME,
		ADMIN_ID = ADMIN_ID,
		ADMIN_PASSWORD = ADMIN_PWD,
		ADMIN_TYPE = ADMIN_LEVEL,
		REGIST_DATETIME = reg_date
 FROM BAR_SHOP1.DBO.S2_ADMINLIST(NOLOCK)

GO
