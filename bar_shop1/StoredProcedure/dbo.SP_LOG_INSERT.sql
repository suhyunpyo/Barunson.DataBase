IF OBJECT_ID (N'dbo.SP_LOG_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_LOG_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SP_LOG_INSERT]
	@orderSeq 	varchar(20),
	@errMsg 	text
AS
BEGIN

	INSERT INTO ERR_TBL(login_id,err_desc) values(@orderSeq, @errMsg)



END

GO
