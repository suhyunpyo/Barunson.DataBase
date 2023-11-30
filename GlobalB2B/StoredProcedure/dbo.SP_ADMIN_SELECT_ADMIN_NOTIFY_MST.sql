IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ADMIN_NOTIFY_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ADMIN_NOTIFY_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ADMIN_NOTIFY_MST]
	-- Add the parameters for the stored procedure here
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_page_num int;
    
    IF(@p_search_type IS NULL)
		SET @p_search_type = 'title';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
	
	SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
	
	
	SET @r_total_count = (
							SELECT COUNT(*) FROM ADMIN_NOTIFY_MST ANM
							LEFT JOIN ADMIN_USER_MST AUM ON ANM.ADMIN_USER_SEQ = AUM.ADMIN_USER_SEQ
							WHERE 
							(
								(
									CASE @p_search_type
									WHEN 'title' THEN ANM.NOTIFY_TITLE
									WHEN 'content' THEN ANM.NOTIFY_CONTENTS
									WHEN 'user' THEN AUM.ADMIN_USER_ID + AUM.ADMIN_USER_NAME
									ELSE ANM.NOTIFY_TITLE END
								) LIKE @p_search_value
								OR
								(
									CASE @p_search_type
									WHEN 'content' THEN ANM.NOTIFY_TITLE
									ELSE @p_search_value END
								) LIKE @p_search_value
							)
							
						);
    
    SELECT TOP(@p_page_row_size)
    ANM.*
    ,AUM.ADMIN_USER_NAME
	,AUM.ADMIN_USER_ID
    FROM ADMIN_NOTIFY_MST ANM
    LEFT JOIN ADMIN_USER_MST AUM ON ANM.ADMIN_USER_SEQ = AUM.ADMIN_USER_SEQ
    WHERE ANM.NOTIFY_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		IANM.NOTIFY_SEQ
		FROM ADMIN_NOTIFY_MST IANM
		LEFT JOIN ADMIN_USER_MST IAUM ON IANM.ADMIN_USER_SEQ = IAUM.ADMIN_USER_SEQ
		WHERE 
		(
			(
				CASE @p_search_type
				WHEN 'title' THEN ANM.NOTIFY_TITLE
				WHEN 'content' THEN ANM.NOTIFY_CONTENTS
				WHEN 'user' THEN AUM.ADMIN_USER_ID + AUM.ADMIN_USER_NAME
				ELSE ANM.NOTIFY_TITLE END
			) LIKE @p_search_value
			OR
			(
				CASE @p_search_type
				WHEN 'content' THEN ANM.NOTIFY_TITLE
				ELSE @p_search_value END
			) LIKE @p_search_value
		)
		ORDER BY IANM.REG_DATE DESC
    )
    AND
	(
		(
			(
				CASE @p_search_type
				WHEN 'title' THEN ANM.NOTIFY_TITLE
				WHEN 'content' THEN ANM.NOTIFY_CONTENTS
				WHEN 'user' THEN AUM.ADMIN_USER_ID + AUM.ADMIN_USER_NAME
				ELSE ANM.NOTIFY_TITLE END
			) LIKE @p_search_value
			OR
			(
				CASE @p_search_type
				WHEN 'content' THEN ANM.NOTIFY_TITLE
				ELSE @p_search_value END
			) LIKE @p_search_value
		)
	)
	ORDER BY ANM.REG_DATE DESC
END
GO
