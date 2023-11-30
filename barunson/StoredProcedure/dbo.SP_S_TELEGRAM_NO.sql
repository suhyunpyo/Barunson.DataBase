IF OBJECT_ID (N'dbo.SP_S_TELEGRAM_NO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_TELEGRAM_NO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_S_TELEGRAM_NO]
	@date varchar(8) ,
	@telegramNo int output
AS
BEGIN

	DECLARE @today VARCHAR(8);
	--set @today = convert(varchar, getdate(), 112);

	select @telegramNo = isnull(Max(Unique_Number), 0) + 1  FROM TB_Daily_Unique WHERE Request_Date = @date
	
	insert into TB_Daily_Unique (Request_Date, Unique_Number) values (@date, @telegramNo);
	/*
	insert into TB_Daily_Unique (Request_Date, Unique_Number) output INSERTED.Unique_Number select convert(varchar, getdate(), 112), isnull(Max(Unique_Number), 0) + 1  FROM TB_Daily_Unique WHERE Request_Date = convert(varchar, getdate(), 112) ;
	*/
END
GO
