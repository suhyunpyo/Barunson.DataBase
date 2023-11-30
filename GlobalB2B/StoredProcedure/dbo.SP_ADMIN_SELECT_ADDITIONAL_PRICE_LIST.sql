IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ADDITIONAL_PRICE_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ADDITIONAL_PRICE_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ADDITIONAL_PRICE_LIST]
	-- Add the parameters for the stored procedure here
	@p_foreign_seq int,
	@p_type_code_list nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_type_code_table table(
		TYPE_CODE nvarchar(255)
    )
    
    DECLARE @paramlist varchar(500),
			@delim char,
			@currentStrIndex int,
			@findStr varchar(100)
			
	--SET @paramlist = 'AB,BB,CB,DB,EB';
	SET @paramlist = @p_type_code_list;
	SET @delim = '|';
	SET @currentStrIndex = 0;
	SET @findStr = '';
	
	IF(CHARINDEX(@delim,@paramList) > 0)
		BEGIN
			WHILE CHARINDEX(@delim,@paramlist,@currentStrIndex) > 0
			BEGIN
				DECLARE @findIndex int = CHARINDEX(@delim,@paramlist,@currentStrIndex);	
				SET @findIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex);
				-- 찾은 문자열 저장
				SET @findStr = SUBSTRING(@paramlist,@currentStrIndex,@findIndex-@currentStrIndex);
				INSERT INTO @t_type_code_table VALUES (@findStr);
				SET @currentStrIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex)+1;
			END--END WHILE
			
			IF((SELECT COUNT(*) FROM @t_type_code_table)>0)
			BEGIN
				INSERT INTO @t_type_code_table VALUES (SUBSTRING(@paramList,@findIndex+1,LEN(@paramList)-@findIndex));
			END 
		END
	ELSE
		BEGIN
			INSERT INTO @t_type_code_table VALUES (@paramList);
		END	
    
    
    SELECT 
    APM.*
    FROM
    ADDITIONAL_PRICE_MST APM
    WHERE APM.FOREIGN_SEQ = @p_foreign_seq AND APM.ADD_PRICE_TYPE_CODE IN (SELECT TYPE_CODE FROM @t_type_code_table)
    ORDER BY APM.ADD_PRICE_SEQ;
    
END
GO
