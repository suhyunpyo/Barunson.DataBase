IF OBJECT_ID (N'dbo.coperation_check', N'P') IS NOT NULL DROP PROCEDURE dbo.coperation_check
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[coperation_check]
  @Con_id int
 AS 
	IF @Con_id <> 0
	BEGIN
			insert into dbo.coperation (con_id) 
			values(@Con_id)
	END

GO
