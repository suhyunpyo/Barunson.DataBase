IF OBJECT_ID (N'dbo.SP_INSERT_USER_CONN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_USER_CONN
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
CREATE PROCEDURE [dbo].[SP_INSERT_USER_CONN]
	@p_conn_code nvarchar(40)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[USER_CONN_MST]
           ([USER_SEQ]
           ,[CONN_CODE]
           ,[REG_DATE])
     VALUES
           (NULL
           ,@p_conn_code
           ,GETDATE());
END
GO
