IF OBJECT_ID (N'dbo.pro_maxsid', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_maxsid
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_maxsid]
AS
SELECT max(sid) from dbo.board

GO
