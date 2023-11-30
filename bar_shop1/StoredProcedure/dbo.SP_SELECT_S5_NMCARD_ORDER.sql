IF OBJECT_ID (N'dbo.SP_SELECT_S5_NMCARD_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S5_NMCARD_ORDER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT CONVERT(VARCHAR(20) , GETDATE() , 120)

EXEC SP_SELECT_S5_NMCARD_ORDER 's4guests4guest'

SELECT	*
FROM	S5_NMCARDORDER
WHERE	1 = 1
--AND		ADDR = 's4guests4guest'
AND		SHOW_HASH IS NOT NULL

*/

CREATE PROCEDURE [dbo].[SP_SELECT_S5_NMCARD_ORDER]
	@MCARD_ADDRESS AS VARCHAR(50)
AS
BEGIN

	SELECT	TOP 1
			EVENT_YEAR
		,	EVENT_MONTH
		,	EVENT_DAY
		,	EVENT_AMPM
		,	EVENT_HOUR
		,	EVENT_MINUTE
		,	DATENAME(DW, EVENT_YEAR + '-' + EVENT_MONTH + '-' + EVENT_DAY) AS EVENT_WEEKNAME
		,	EVENT_YEAR + '년 ' + EVENT_MONTH + '월 ' + EVENT_DAY + '일 ' 
			+ DATENAME(DW, EVENT_YEAR + '-' + EVENT_MONTH + '-' + EVENT_DAY) 
			+ ' ' + RTRIM(LTRIM(EVENT_AMPM)) + ' ' + EVENT_HOUR + '시 ' + CASE WHEN EVENT_MINUTE <> '00' AND EVENT_MINUTE <> '0' THEN EVENT_MINUTE + '분' ELSE '' END
			AS EVENT_WEDDING_DAY
		,	CONVERT(VARCHAR(10), DATEDIFF(D, GETDATE(), EVENT_YEAR + '-' + EVENT_MONTH + '-' + EVENT_DAY)) AS EVENT_D_DAY
		,	ISNULL(ORDER_NAME, '')                  AS ORDER_NAME
		,	ISNULL(SNMCO.GROOM_NAME_KOR, '')		AS GROOM_NAME_KOR
		,	ISNULL(SNMCO.GROOM_HPHONE, '')			AS GROOM_HPHONE
		,	ISNULL(SNMCO.BRIDE_NAME_KOR, '')		AS BRIDE_NAME_KOR
		,	ISNULL(SNMCO.BRIDE_HPHONE, '')			AS BRIDE_HPHONE
		,	ISNULL(SNMCO.GROOM_NAME_KOR, '') + ' ♥ ' + ISNULL(BRIDE_NAME_KOR, '') AS BRIDE_AND_GROOM_NAME
		,	ISNULL(SNMCO.GREETING_CONTENT, '')		AS GREETING_CONTENT
		,	ISNULL(SNMCO.ADDR, '')					AS MCARD_ADDRESS
		,	ISNULL(SNMCO.WEDDINGADDR, '')			AS WEDDING_ADDRESS
		,	ISNULL(SNMCO.WEDD_PLACE, '')			AS WEDDING_PLACE
		,	ISNULL(SNMCO.WEDDINGHALL, '')			AS WEDDING_HALL
		,	ISNULL(SNMCO.WEDD_PHONE, '')			AS WEDDING_PHONE
		,	ISNULL(SNMCO.LATITUDE, '0')				AS LATITUDE
		,	ISNULL(SNMCO.LONGITUDE, '0')			AS LONGITUDE
		,	ISNULL(SNMCO.ORDER_SEQ, 0)				AS ORDER_SEQ
		,	ISNULL(SNMCO.WORDER_SEQ, 0)				AS W_ORDER_SEQ
		,	ISNULL(MAIN_IMG.FILEINDEX, 0)           AS MAIN_IMAGE_FILE_INDEX
		,	ISNULL(MAIN_IMG.FILENAME, '')           AS MAIN_IMAGE_FILE_NAME
		,	ISNULL(MAIN_IMG.IMAGESIZEW, 0)          AS MAIN_IMAGE_SIZE_WIDTH
		,	ISNULL(MAIN_IMG.IMAGESIZEH, 0)          AS MAIN_IMAGE_SIZE_HEIGHT
		,	ISNULL(SHOW_HASH, '')					AS MOVIE_VALUE
		
	FROM	S5_NMCARDORDER SNMCO
	LEFT JOIN	(
					SELECT	ROW_NUMBER() OVER(PARTITION BY A.ORDER_SEQ ORDER BY A.SORTING_NUM ASC) AS ROW_NUM
						,	A.ORDER_SEQ
						,	A.FILEINDEX
						,	A.FILENAME
						,	A.IMAGESIZEW
						,	A.IMAGESIZEH 
					FROM	(
								SELECT	ORDER_SEQ, FILEINDEX, FILENAME, IMAGESIZEW, IMAGESIZEH
									,	CASE 
												WHEN IMAGESIZEW <= 640	THEN 1 
												WHEN IMAGESIZEW > 640	THEN 9
										END AS SORTING_NUM
								FROM	S5_NMCARDIMAGEINFO 
								WHERE	1 = 1
								AND		FILETYPE = 3
								AND		ORDER_SEQ IN ( SELECT ORDER_SEQ FROM S5_NMCARDORDER WHERE ADDR = @MCARD_ADDRESS )

								UNION ALL
					
								SELECT	ORDER_SEQ, FILEINDEX, FILENAME, IMAGESIZEW, IMAGESIZEH 
									,	CASE 
												WHEN IMAGESIZEW <= 640	THEN 2 
												WHEN IMAGESIZEW > 640	THEN 3
										END AS SORTING_NUM
								FROM	S5_NMCARDIMAGEINFO 
								WHERE	1 = 1
								AND		FILETYPE IN (7, 8) 
								AND		ORDER_SEQ IN ( SELECT ORDER_SEQ FROM S5_NMCARDORDER WHERE ADDR = @MCARD_ADDRESS )
							) A
				) MAIN_IMG ON SNMCO.ORDER_SEQ = MAIN_IMG.ORDER_SEQ AND MAIN_IMG.ROW_NUM = 1
	WHERE	1 = 1
	AND		SNMCO.ADDR = @MCARD_ADDRESS

END

GO