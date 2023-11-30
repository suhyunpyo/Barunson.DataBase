IF OBJECT_ID (N'dbo.coperation_list', N'P') IS NOT NULL DROP PROCEDURE dbo.coperation_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  Procedure [dbo].[coperation_list]
	@SDAY			datetime
as
 	SELECT  count(coperation_seq) as con_id, con_id as con_id1,sum(coperation_seq) as total
		FROM dbo.coperation 
	WHERE convert(varchar(10),reg_date,21) = @SDAY group by Con_id having count(Con_id) >1

GO
