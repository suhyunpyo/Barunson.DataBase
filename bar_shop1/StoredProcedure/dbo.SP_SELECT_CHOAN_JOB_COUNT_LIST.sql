IF OBJECT_ID (N'dbo.SP_SELECT_CHOAN_JOB_COUNT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CHOAN_JOB_COUNT_LIST
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

-- EXEC [SP_SELECT_CHOAN_JOB_COUNT_LIST] '2016-01-01', '2016-12-31', 'N'

CREATE PROCEDURE [dbo].[SP_SELECT_CHOAN_JOB_COUNT_LIST]
	@p_start_date AS VARCHAR(10)
,	@p_end_date AS VARCHAR(10)
,   @p_order_date_yorn AS CHAR(1)

AS
BEGIN

SELECT  SUM(A.C_DEFAULT) C_DEFAULT, 
        SUM(A.C_SPECIAL) C_SPECIAL,
        SUM(A.C_ADD) C_ADD,
        SUM(A.C_ADD_SPECIAL) C_ADD_SPECIAL,
        SUM(A.C_TOT) C_TOT,

        SUM(A.CMOD_DEFAULT) CMOD_DEFAULT,
        SUM(A.CMOD_SPECIAL) CMOD_SPECIAL,
        SUM(A.CMOD_ADD) CMOD_ADD,
        SUM(A.CMOD_ADD_SPECIAL) CMOD_ADD_SPECIAL,
        SUM(A.CMOD_TOT) CMOD_TOT,
			
		SUM(A.WEDD_TOT) WEDD_TOT, 
			
	    ISNULL(A.ADMIN_ID, '합계') AS ADMIN_ID,

        CASE WHEN A.ADMIN_ID IS NULL THEN '9999' ELSE '1_' + A.ADMIN_ID END
FROM (
 
 	SELECT  A.C_DEFAULT,
            A.C_SPECIAL,
            A.C_ADD,
            A.C_ADD_SPECIAL,
            A.C_DEFAULT + A.C_SPECIAL + A.C_ADD + A.C_ADD_SPECIAL AS C_TOT,
 	
            0 AS CMOD_DEFAULT,
            0 AS CMOD_SPECIAL,
            0 AS CMOD_ADD,
            0 AS CMOD_ADD_SPECIAL,
            0 AS CMOD_TOT,
 		 
            0 AS WEDD_TOT, 
			 		 
            ISNULL(ADMIN_ID, '') AS ADMIN_ID
    FROM    ( 
 			    SELECT 
 			            /* 초안등록 일반 */
 			            SUM( CASE WHEN ISSPECIAL NOT IN (1, 2) AND UP_ORDER_SEQ IS NULL THEN 1 ELSE 0 END ) AS C_DEFAULT, 
 			 
                        /* 초안등록 초특급 */ 
 				        SUM( CASE WHEN ISSPECIAL IN (1, 2) AND UP_ORDER_SEQ IS NULL THEN 1 ELSE 0 END ) C_SPECIAL,
 					 
 				        /* 초안등록 추가 */
 				        SUM( CASE WHEN UP_ORDER_SEQ IS NOT NULL AND ORDER_ADD_FLAG = 1 THEN 1 ELSE 0 END ) C_ADD,
 					 
 				        /* 초안등록 추가 초특급 */
 				        --SUM( CASE WHEN ISSPECIAL IN (1, 2) AND UP_ORDER_SEQ IS NOT NULL THEN 1 ELSE 0 END ) 
                        0 AS C_ADD_SPECIAL,

 				        SRC_COMPOSE_ADMIN_ID AS ADMIN_ID

 		        FROM    CUSTOM_ORDER A
 			    WHERE 1 = 1 
                AND     (CASE @p_order_date_yorn WHEN 'Y' THEN ORDER_DATE ELSE SRC_COMPOSE_DATE END) >= '' + @p_start_date + ' 00:00:00'
                AND     (CASE @p_order_date_yorn WHEN 'Y' THEN ORDER_DATE ELSE SRC_COMPOSE_DATE END) <= '' + @p_end_date + ' 23:59:59'									
 			    --AND STATUS_SEQ NOT IN (-1, 0, 1, 3, 5) 
 			    AND     SRC_COMPOSE_DATE IS NOT NULL

                AND     SRC_COMPOSE_ADMIN_ID IS NOT NULL
                AND     SRC_COMPOSE_ADMIN_ID <> ''
			    /* AND UP_ORDER_SEQ IS NULL */
 			    --AND ISCOREL = '1'
 			    GROUP BY A.SRC_COMPOSE_ADMIN_ID 
 		    ) A
 	 
 	 
 	 
    UNION ALL 



    SELECT  0 AS C_DEFAULT,
            0 AS C_SPECIAL, 
            0 AS C_ADD, 
            0 AS C_ADD_SPECIAL, 
            0 AS C_TOT, 
 	
            A.CMOD_DEFAULT, 
            A.CMOD_SPECIAL, 
            A.CMOD_ADD, 
            A.CMOD_ADD_SPECIAL, 
            A.CMOD_DEFAULT + A.CMOD_SPECIAL + A.CMOD_ADD + A.CMOD_ADD_SPECIAL AS CMOD_TOT, 
 	 
            0 AS WEDD_TOT, 
			 		 
            ISNULL(ADMIN_ID, '') AS ADMIN_ID
    FROM    ( 
 		        SELECT 
 				        /* 초안수정 일반 */ 
 				        SUM( CASE WHEN ISSPECIAL NOT IN (1, 2) AND UP_ORDER_SEQ IS NULL THEN 1 ELSE 0 END ) AS CMOD_DEFAULT, 
 					
 				        /* 초안수정 초특급 */ 
 				        SUM( CASE WHEN ISSPECIAL IN (1, 2) AND UP_ORDER_SEQ IS NULL THEN 1 ELSE 0 END ) AS CMOD_SPECIAL, 
 					
 				        /* 초안수정 추가 */ 
 				        SUM( CASE WHEN UP_ORDER_SEQ IS NOT NULL THEN 1 ELSE 0 END ) CMOD_ADD,
			
			            /* 초안수정 추가 초특급 */
			            --SUM( CASE WHEN ISSPECIAL IN (1, 2) AND UP_ORDER_SEQ IS NOT NULL THEN 1 ELSE 0 END ) AS 
                        0 AS CMOD_ADD_SPECIAL,

 				        SRC_COMPOSE_MOD_ADMIN_ID AS ADMIN_ID 

 		        FROM    CUSTOM_ORDER A 
                JOIN    CUSTOM_ORDER_HISTORY B ON A.ORDER_SEQ = B.ORDER_SEQ
 		        WHERE   1 = 1
                AND     B.HTYPE = '초안 수정 등록'
	            AND     (CASE @p_order_date_yorn WHEN 'Y' THEN A.ORDER_DATE ELSE B.REG_DATE END) >= '' + @p_start_date + ' 00:00:00'
                AND     (CASE @p_order_date_yorn WHEN 'Y' THEN A.ORDER_DATE ELSE B.REG_DATE END) <= '' + @p_end_date + ' 23:59:59'
 		        --AND     STATUS_SEQ NOT IN (-1, 0, 1, 3, 5)
 		        AND     SRC_COMPOSE_MOD_DATE IS NOT NULL 
                AND     SRC_COMPOSE_ADMIN_ID IS NOT NULL
                AND     SRC_COMPOSE_ADMIN_ID <> ''
 		        /* AND SRC_COMPOSE_DATE <> SRC_COMPOSE_MOD_DATE */
 		        --AND     ISCOREL = '1' 
 		        GROUP BY A.SRC_COMPOSE_MOD_ADMIN_ID 
            ) A 
 		
 	
 		
	UNION ALL
 


	SELECT  0 AS C_DEFAULT, 
			0 AS C_SPECIAL, 
			0 AS C_ADD, 
			0 AS C_ADD_SPECIAL, 
			0 AS C_TOT, 

			0 AS CMOD_DEFAULT,
			0 AS CMOD_SPECIAL,
			0 AS CMOD_ADD,
			0 AS CMOD_ADD_SPECIAL,
			0 AS CMOD_TOT,
			 			
			WEDD_TOT, 

			ISNULL(ADMIN_ID, '') AS ADMIN_ID 
    FROM    (
			    SELECT
			 		    COUNT(ADMIN_ID) AS WEDD_TOT,
			 		    ADMIN_ID

			    FROM    WEDDINGHALL_LOG
			    WHERE   REG_DATE >= '' + @p_start_date + ' 00:00:00' 
			    AND     REG_DATE <= '' + @p_end_date + ' 23:59:59' 
			    AND     GUBUN = 'UPDATE_WEDD'
			    GROUP BY ADMIN_ID
		    ) A 
) A
 
 GROUP BY A.ADMIN_ID WITH ROLLUP
 ORDER BY CASE WHEN A.ADMIN_ID IS NULL THEN '9999' ELSE '1_' + A.ADMIN_ID END ASC





END


GO
