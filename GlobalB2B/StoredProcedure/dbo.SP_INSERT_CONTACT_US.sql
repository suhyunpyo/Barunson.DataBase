IF OBJECT_ID (N'dbo.SP_INSERT_CONTACT_US', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_CONTACT_US
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
CREATE PROCEDURE [dbo].[SP_INSERT_CONTACT_US]
	-- Add the parameters for the stored procedure here
	@p_name nvarchar(150),
	@p_email nvarchar(300),
	@p_tel nvarchar(150),
	@p_contents text
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [GlobalB2B].[dbo].[CONTACT_US_MSG_MST]
           ([GUEST_NAME]
           ,[EMAIL]
           ,[TEL]
           ,[PRODUCT_CODE]
           ,[CONTENTS]
           ,[REG_DATE])
     VALUES
           (@p_name
           ,@p_email
           ,@p_tel
           ,''
           ,@p_contents
           ,GETDATE());
    
END
GO
