IF OBJECT_ID (N'dbo.SP_INSERT_ADDITIONAL_PRICE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_ADDITIONAL_PRICE
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
CREATE PROCEDURE [dbo].[SP_INSERT_ADDITIONAL_PRICE]
	-- Add the parameters for the stored procedure here
	@p_price_type char(6),
	@p_foreign_seq int,
	@p_memo nvarchar(255),
	@p_price numeric(18,2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[ADDITIONAL_PRICE_MST]
           ([ADD_PRICE_TYPE_CODE]
           ,[FOREIGN_SEQ]
           ,LABEL
           ,[PRICE]
           ,[REG_DATE])
     VALUES
           (@p_price_type
           ,@p_foreign_seq
           ,@p_memo
           ,@p_price
           ,GETDATE());

END

GO
