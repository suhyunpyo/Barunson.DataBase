IF OBJECT_ID (N'dbo.pro_chkpass', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_chkpass
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_chkpass]
@sid int
AS
SELECT top 1 pass FROM dbo.board WHERE sid = @sid

GO
