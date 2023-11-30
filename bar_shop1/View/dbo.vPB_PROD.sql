IF OBJECT_ID (N'dbo.vPB_PROD', N'V') IS NOT NULL DROP View dbo.vPB_PROD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vPB_PROD]
AS
SELECT     dbo.TB_PB_OASIS.OASIS_IDX, dbo.TB_PB_OASIS.PRDT_NAME, dbo.TB_PB_OASIS.TB_PRDT_IDX, dbo.TB_PB_PRODUCT.CT_CODE, 
                      dbo.TB_PB_PRODUCT.PRDT_TYPE, dbo.TB_PB_OASIS.SIZE, dbo.TB_PB_OASIS.PAGES, dbo.TB_PB_OASIS.IDX, dbo.TB_PB_OASIS.COATING_YN, 
                      dbo.TB_PB_PRODUCT.PRDT_NAME AS COVER_NAME,dbo.TB_PB_PRODUCT.MAKE_COMCODE as makecom_code
FROM         dbo.TB_PB_OASIS INNER JOIN
                      dbo.TB_PB_PRODUCT ON dbo.TB_PB_OASIS.TB_PRDT_IDX = dbo.TB_PB_PRODUCT.IDX


GO