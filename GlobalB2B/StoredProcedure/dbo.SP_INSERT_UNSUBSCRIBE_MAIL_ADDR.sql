IF OBJECT_ID (N'dbo.SP_INSERT_UNSUBSCRIBE_MAIL_ADDR', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_UNSUBSCRIBE_MAIL_ADDR
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
CREATE PROCEDURE [dbo].[SP_INSERT_UNSUBSCRIBE_MAIL_ADDR]
	@p_mail_addr nvarchar(255),
	@p_description text
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[UNSUBSCRIBE_MAIL_ADDR_MST]
           ([MAIL_ADDR]
           ,[DESCRIPTION]
           ,[REG_DATE])
     VALUES
           (@p_mail_addr
           ,@p_description
           ,GETDATE());
END


GO
