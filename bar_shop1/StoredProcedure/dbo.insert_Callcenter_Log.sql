IF OBJECT_ID (N'dbo.insert_Callcenter_Log', N'P') IS NOT NULL DROP PROCEDURE dbo.insert_Callcenter_Log
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[insert_Callcenter_Log]
 @yivr as varchar(20),
 @ycallerid as varchar(20),
 @ymenu as varchar(2)
as
begin

INSERT INTO Callcenter_Log(YIVR,YCallerID,YMenu) values(@yivr,@ycallerid,@ymenu)
end


GO
