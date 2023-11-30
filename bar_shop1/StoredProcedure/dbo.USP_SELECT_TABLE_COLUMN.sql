IF OBJECT_ID (N'dbo.USP_SELECT_TABLE_COLUMN', N'P') IS NOT NULL DROP PROCEDURE dbo.USP_SELECT_TABLE_COLUMN
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- =============================================
-- AUTHOR:	이상민
-- CREATE DATE: 2018-07-13
-- DESCRIPTION:	테이블 별 컬럼 코멘트 조회
-- TEST : [USP_SELECT_TABLE_COLUMN] 'custom_order'
-- =============================================

CREATE	PROCEDURE [dbo].[USP_SELECT_TABLE_COLUMN]
	@TABLE_NAME			VARCHAR(50)

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
BEGIN


	-- 전체 테이블 별 칼럼 코멘트 조회
	SELECT      u.name + '.' + t.name AS [table],
				td.value AS [table_desc],
				c.name AS [column],
				cd.value AS [column_desc]
	FROM  sysobjects t
	INNER JOIN  sysusers u ON      u.uid = t.uid
	LEFT OUTER JOIN sys.extended_properties td  ON      td.major_id = t.id AND     td.minor_id = 0 AND     td.name = 'MS_Description'

	INNER JOIN  syscolumns c ON      c.id = t.id 
	LEFT OUTER JOIN sys.extended_properties cd ON      cd.major_id = c.id AND     cd.minor_id = c.colid AND     cd.name = 'MS_Description'

	WHERE t.type = 'u'
		and u.name + '.' + t.name = RTRIM(LTRIM(@TABLE_NAME))
	ORDER BY    t.name, c.colorder;




END
GO
