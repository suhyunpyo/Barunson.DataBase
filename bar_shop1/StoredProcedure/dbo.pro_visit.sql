IF OBJECT_ID (N'dbo.pro_visit', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_visit
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_visit]
@sid int
AS
update dbo.board set visit=visit+1 where sid=@sid

GO
