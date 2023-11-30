IF OBJECT_ID (N'dbo.pro_view', N'P') IS NOT NULL DROP PROCEDURE dbo.pro_view
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[pro_view]
@sid int
AS
set nocount on
update dbo.board set visit=visit+1 where sid=@sid
SELECT * from dbo.board where sid=@sid
set nocount off

GO
