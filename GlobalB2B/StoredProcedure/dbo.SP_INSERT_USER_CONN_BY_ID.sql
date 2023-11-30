IF OBJECT_ID (N'dbo.SP_INSERT_USER_CONN_BY_ID', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_USER_CONN_BY_ID
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
CREATE PROCEDURE [dbo].[SP_INSERT_USER_CONN_BY_ID]
	-- Add the parameters for the stored procedure here
	@p_user_id nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
    DECLARE @t_user_seq int;
    
    SET @t_user_seq = (SELECT UM.USER_SEQ FROM USER_MST UM WHERE UM.USER_ID = @p_user_id);
    
    IF(@t_user_seq > 0 AND @t_user_seq IS NOT NULL)
		BEGIN
			INSERT INTO [GlobalB2B].[dbo].[USER_CONN_MST]
				   ([USER_SEQ]
				   ,[REG_DATE])
			 VALUES
				   (@t_user_seq
				   ,GETDATE());		
		END

END
GO
