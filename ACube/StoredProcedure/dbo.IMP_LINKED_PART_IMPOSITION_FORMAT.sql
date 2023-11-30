IF OBJECT_ID (N'dbo.IMP_LINKED_PART_IMPOSITION_FORMAT', N'P') IS NOT NULL DROP PROCEDURE dbo.IMP_LINKED_PART_IMPOSITION_FORMAT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		송지웅
-- Create date: <Create Date,,>
-- Description:	파트 코드와 IMPOSITION FORMAT 정보(판배열 제어 수치값)를 연결한다.
-- =============================================
CREATE PROCEDURE [dbo].[IMP_LINKED_PART_IMPOSITION_FORMAT]
	@p_part_cd nvarchar(max),
	@p_imposition_format_save_name nvarchar(max)
AS
BEGIN

	DECLARE @t_imposition_format_code int;
	
	SET @t_imposition_format_code = (SELECT TOP 1 IMPOSITION_FORMAT_CODE	FROM dbo.IMPOSITION_FORMAT_MST WHERE SAVE_NAME = @p_imposition_format_save_name);
	
	IF(@t_imposition_format_code IS NOT NULL)
		BEGIN
			
			DECLARE	@return_value int
			EXEC	@return_value = [dbo].[IMP_UNLINKED_PART_IMPOSITION_FORMAT]
					@p_part_cd = @p_part_cd
			
			INSERT INTO [dbo].[IMPOSITION_PART_LINKED_FORMAT_MST]
           ([PART_CD]
           ,[IMPOSITION_FORMAT_CODE]
           ,[REG_DATE])
			VALUES
           (@p_part_cd
           ,@t_imposition_format_code
           ,GETDATE())
		
		END
	
END
GO
