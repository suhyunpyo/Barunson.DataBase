IF OBJECT_ID (N'dbo.SP_INSERT_OUTSOURCING_ORDER_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_OUTSOURCING_ORDER_MST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM COMMON_CODE
SELECT * FROM OUTSOURCING_ORDER_MST
EXEC SP_INSERT_OUTSOURCING_ORDER_MST '100011', null, 'BH4704', '테스트', 100, '용지 종류', '용지 크기', 1, 0, 'Y', 'Y', 'Y', 'Y', 'Y', '금', 'Y', '107001', '108001'

UPDATE OUTSOURCING_ORDER_MST SET 
BOTH_SIDE_YORN = 'Y'
,OSI_YORN = 'Y'
,CUTOUT_YORN = 'Y'
,GLOSSY_YORN = 'Y'
,PRESS_YORN = 'Y'
,FOIL_TYPE_NAME = '금'
,LASER_CUT_YORN = 'Y'


*/

CREATE PROCEDURE [dbo].[SP_INSERT_OUTSOURCING_ORDER_MST]
    @ORDER_STATUS_CODE          AS VARCHAR(6)
,   @ORDER_SEQ                  AS INT
,   @SITE_TYPE_CODE             AS VARCHAR(6)
,	@ORDER_SUB_TYPE_CODE		AS VARCHAR(6)
,   @CARD_CODE                  AS NVARCHAR(200)
,   @ORDER_NAME                 AS NVARCHAR(200)
,   @ORDER_QTY                  AS INT
,   @PAPER_TYPE_NAME            AS NVARCHAR(400)
,   @PAPER_SIZE                 AS NVARCHAR(400)
,   @PAGES_PER_SHEET_VALUE      AS NUMERIC(18, 2)
,   @PRINT_LOSS_VALUE           AS NUMERIC(18, 2)
,   @BOTH_SIDE_YORN             AS CHAR(1)
,   @OSI_YORN                   AS CHAR(1)
,   @CUTOUT_YORN                AS CHAR(1)
,   @GLOSSY_YORN                AS CHAR(1)
,   @PRESS_YORN                 AS CHAR(1)
,   @FOIL_TYPE_NAME             AS NVARCHAR(100)
,   @LASER_CUT_YORN             AS CHAR(1)
,   @REQUESTOR_NAME             AS NVARCHAR(200)
,   @COMPANY_TYPE_CODE          AS VARCHAR(6)
,   @DELIVERY_TYPE_CODE         AS VARCHAR(6)
,   @PRINT_FILE_URL             AS VARCHAR(500)
,	@IMAGE_FILE_URL             AS VARCHAR(500)
,	@MEMO                       AS VARCHAR(500) = ''
,	@EDGE_YORN                  AS CHAR(1)  = 'N'
,   @EDGE_COLOR                 AS NVARCHAR(30) = ''

AS
BEGIN



INSERT INTO OUTSOURCING_ORDER_MST   
(
        ORDER_STATUS_CODE     
    ,   ORDER_TYPE_CODE   
	,	ORDER_SUB_TYPE_CODE   
    ,   ORDER_SEQ              
    ,   SITE_TYPE_CODE     
    ,   ERP_PART_TYPE_CODE
    ,   CARD_CODE                   
    ,   ORDER_NAME                  
    ,   ORDER_QTY                   
    ,   PAPER_TYPE_NAME             
    ,   PAPER_SIZE                  
    ,   PAGES_PER_SHEET_VALUE       
    ,   PRINT_LOSS_VALUE            
    ,   BOTH_SIDE_YORN              
    ,   OSI_YORN                    
    ,   CUTOUT_YORN                 
    ,   GLOSSY_YORN                 
    ,   PRESS_YORN                  
    ,   FOIL_TYPE_NAME              
    ,   LASER_CUT_YORN              
    ,   REQUESTOR_NAME              
    ,   COMPANY_TYPE_CODE           
    ,   DELIVERY_TYPE_CODE
    ,   PRINT_FILE_URL    
	,	IMAGE_FILE_URL        
    ,   MEMO
    ,   EDGE_YORN
    ,   EDGE_COLOR  
)                                   
                                    
VALUES  
(
        @ORDER_STATUS_CODE      
    ,   '110002'
	,	@ORDER_SUB_TYPE_CODE
    ,   CASE WHEN @ORDER_SEQ = 0 THEN null ELSE @ORDER_SEQ END
    ,   @SITE_TYPE_CODE
    ,   '111099'
    ,   @CARD_CODE              
    ,   @ORDER_NAME             
    ,   @ORDER_QTY              
    ,   @PAPER_TYPE_NAME        
    ,   @PAPER_SIZE             
    ,   @PAGES_PER_SHEET_VALUE  
    ,   @PRINT_LOSS_VALUE       
    ,   @BOTH_SIDE_YORN       
    ,   @OSI_YORN             
    ,   @CUTOUT_YORN          
    ,   @GLOSSY_YORN          
    ,   @PRESS_YORN           
    ,   @FOIL_TYPE_NAME       
    ,   @LASER_CUT_YORN       
    ,   @REQUESTOR_NAME         
    ,   @COMPANY_TYPE_CODE
    ,   @DELIVERY_TYPE_CODE
    ,   @PRINT_FILE_URL
	,	@IMAGE_FILE_URL
    ,   @MEMO
    ,   @EDGE_YORN
    ,   @EDGE_COLOR  
)



END

GO
