IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_USER_MST_FOR_CSV', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_USER_MST_FOR_CSV
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_USER_MST_FOR_CSV]
	@p_search_type char(1),
	@p_search_from datetime,
	@p_search_to datetime
AS
BEGIN
	SET NOCOUNT ON;

	SELECT T.USER_ID, T.FIRST_NAME, T.LAST_NAME, T.REG_DATE, T.MAILING_YORN, T.ACTIVATE_YORN, T.ADMIN_VERFIED_YORN, T.LAST_CONN_DATE
	FROM 
	(
		SELECT UM.USER_ID, UM.FIRST_NAME, UM.LAST_NAME, UM.REG_DATE, UM.MAILING_YORN, UM.ACTIVATE_YORN, UM.ADMIN_VERFIED_YORN, ISNULL(MAX(UCM.REG_DATE), UM.REG_DATE) AS LAST_CONN_DATE 
		FROM USER_MST UM 
			LEFT JOIN USER_CONN_MST UCM ON UCM.USER_SEQ = UM.USER_SEQ
		GROUP BY UM.USER_ID, UM.FIRST_NAME, UM.LAST_NAME, UM.REG_DATE, UM.MAILING_YORN, UM.ACTIVATE_YORN, UM.ADMIN_VERFIED_YORN
	) T 
	WHERE @p_search_type = 'R' AND (T.REG_DATE BETWEEN @p_search_from AND @p_search_to)
		OR @p_search_type = 'V' AND (T.LAST_CONN_DATE BETWEEN @p_search_from AND @p_search_to)
		 
END
GO
