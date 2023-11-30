IF OBJECT_ID (N'dbo.SP_DELETE_WISH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_DELETE_WISH
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
CREATE PROCEDURE [dbo].[SP_DELETE_WISH]
	-- Add the parameters for the stored procedure here
	@p_prod_code_list nvarchar(255),
	@p_user_id nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	DECLARE @t_prod_seq int,
	@t_user_seq int,
	@paramlist varchar(500),
	@delim char,
    @currentStrIndex int,
	@findStr varchar(100);
	
	SET @paramlist = @p_prod_code_list;
	SET @delim = ',';
	SET @currentStrIndex = 0;
	SET @findStr = '';
	
	DECLARE @t_option_table table
    (
		OPTION_CODE nvarchar(100)
    )
	
	IF(CHARINDEX(@delim,@paramList) > 0)
		BEGIN
			WHILE CHARINDEX(@delim,@paramlist,@currentStrIndex) > 0
			BEGIN
				DECLARE @findIndex int = CHARINDEX(@delim,@paramlist,@currentStrIndex);	
				SET @findIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex);
				-- 찾은 문자열 저장
				SET @findStr = SUBSTRING(@paramlist,@currentStrIndex,@findIndex-@currentStrIndex);
				INSERT INTO @t_option_table VALUES (@findStr);
				SET @currentStrIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex)+1;
			END--END WHILE
			
			IF((SELECT COUNT(*) FROM @t_option_table)>0)
			BEGIN
				INSERT INTO @t_option_table VALUES (SUBSTRING(@paramList,@findIndex+1,LEN(@paramList)-@findIndex));
			END 
		END
	ELSE
		BEGIN
			INSERT INTO @t_option_table VALUES (@paramList);
		END	
		
		
	SELECT * FROM @t_option_table;
				
    SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID  = @p_user_id);
    
     
    DELETE CART_MST
    FROM CART_MST CM
    LEFT JOIN PROD_MST PM ON CM.PROD_SEQ = PM.PROD_SEQ
    LEFT JOIN @t_option_table TEMP_OM ON TEMP_OM.OPTION_CODE = PM.PROD_CODE
    WHERE 
    CM.USER_SEQ = @t_user_seq
    AND CM.CART_STATE_CODE = '118001'
    AND TEMP_OM.OPTION_CODE IS NOT NULL
END

GO
