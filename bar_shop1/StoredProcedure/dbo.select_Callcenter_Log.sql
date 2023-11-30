IF OBJECT_ID (N'dbo.select_Callcenter_Log', N'P') IS NOT NULL DROP PROCEDURE dbo.select_Callcenter_Log
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[select_Callcenter_Log]
 @ycallerid as varchar(20)
as
begin
select top 1 A.*,B.etc3 as yivr_id from callcenter_log A inner join manage_code B on A.yivr = B.etc2 
where YCallerID=@ycallerid order by id desc
end
GO
