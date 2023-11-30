IF OBJECT_ID (N'dbo.up_S4_EventMusic_Str_Period_Check', N'P') IS NOT NULL DROP PROCEDURE dbo.up_S4_EventMusic_Str_Period_Check
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

up_S4_EventMusic_Str_Period_Check

*/

create PROCEDURE [dbo].[up_S4_EventMusic_Str_Period_Check]
    @seq                  AS INT

AS

BEGIN

	if Exists(
			select seq
			from S4_EventMusic_Str
			where seq = @seq and start_date <= convert(varchar(10), getdate(), 120) and end_date >= convert(varchar(10), getdate(), 120)
			)
		begin
			select '1'
		end
	else
		begin
			select '0'
		end

END
GO
