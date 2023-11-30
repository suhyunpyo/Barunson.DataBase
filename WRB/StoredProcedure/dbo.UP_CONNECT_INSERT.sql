IF OBJECT_ID (N'dbo.UP_CONNECT_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_CONNECT_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UP_CONNECT_INSERT]
@SESSIONID INT,
@EMAIL VARCHAR(50),
@DIRECTORY VARCHAR(20),
@CLIENT_IP VARCHAR(15)
AS
INSERT WRB_CONNECT (SESSIONID, EMAIL, DIRECTORY, CLIENT_IP)
VALUES (@SESSIONID, @EMAIL, @DIRECTORY, @CLIENT_IP)
GO
