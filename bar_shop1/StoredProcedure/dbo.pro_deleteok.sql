IF OBJECT_ID (N'dbo.pro_deleteok', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_deleteok
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_deleteok]
@sid int
AS
DELETE from dbo.board  
WHERE sid =@sid

GO
