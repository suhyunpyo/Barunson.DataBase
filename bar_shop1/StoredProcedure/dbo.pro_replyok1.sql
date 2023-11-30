IF OBJECT_ID (N'dbo.pro_replyok1', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_replyok1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_replyok1]
@sid int
AS
SELECT grp,seq,lev from dbo.board
               WHERE sid =@sid

GO
