IF OBJECT_ID (N'dbo.pro_updateok', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_updateok
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_updateok]
@sid int,
@subject varchar(80),
@content text,
@name varchar(80),
@tag char(1)
AS
UPDATE dbo.board SET name=@name,
	                 subject=@subject,
	                 content=@content,
	                 tag=@tag
	                 WHERE sid =@sid

GO
