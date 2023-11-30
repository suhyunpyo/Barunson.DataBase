IF OBJECT_ID (N'dbo.SP_SELECT_SMARTAD_NOTICE_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SMARTAD_NOTICE_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_SMARTAD_NOTICE_LIST NULL, 9999, 1, 'REG_DATE', 'DESC'

*/

CREATE PROCEDURE [dbo].[SP_SELECT_SMARTAD_NOTICE_LIST]
		@P_SEARCH_VALUE AS VARCHAR(100) = ''
	,	@P_PAGE_SIZE AS INT
	,	@P_PAGE_NUMBER AS INT
	,	@P_ORDER_BY_NAME AS VARCHAR(50)
	,	@P_ORDER_BY_TYPE AS VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON


	SELECT	*
	FROM	(
				SELECT	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REG_DATE						ELSE 0 END ASC
												,	C.seq ASC
													
											) AS ROW_NUM
					,	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REG_DATE						ELSE 0 END DESC
												,	C.seq DESC
													
											) AS ROW_NUM_DESC
					,	*
				FROM	(
							SELECT	 
									SN.SEQ
								,	SN.writer
								,	SN.title
								,	SN.contents
								,	SN.viewcnt
								,	SN.notice_div
								,	SN.start_date
								,	SN.end_date
								,	SN.reg_date
								,   SN.display_YN
							FROM	SmartADNotice SN
							WHERE	1 = 1
							AND	 --(ISNULL(@P_SEARCH_VALUE,'') = '' OR SP.PARTNER_NAME LIKE '%' + @P_SEARCH_VALUE + '%')
								
									(
											CASE WHEN ISNULL(@P_SEARCH_VALUE,'') = '' THEN '' ELSE SN.contents END LIKE '%' + ISNULL(@P_SEARCH_VALUE,'') + '%'
									)

						) C

			) A

	WHERE	1 = 1
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END > (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE
		
	ORDER BY 
		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END ASC
	
END



GO
