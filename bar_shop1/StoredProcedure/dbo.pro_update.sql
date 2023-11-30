IF OBJECT_ID (N'dbo.pro_update', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_update
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_update]
@sid int
AS
SELECT top 1 * FROM dbo.board  WHERE sid =@sid

GO
