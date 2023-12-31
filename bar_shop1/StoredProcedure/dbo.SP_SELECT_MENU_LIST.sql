IF OBJECT_ID (N'dbo.SP_SELECT_MENU_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_MENU_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
  
SELECT * FROM INTEGRATION_ADMIN_MENU  
EXEC SP_SELECT_MENU_LIST 86  
  
*/  
CREATE PROCEDURE [dbo].[SP_SELECT_MENU_LIST]    
@p_admin_code AS varchar(20)    
AS    
BEGIN    
     
WITH MENU_CTE (MENU_SEQ, PMENU_SEQ, MENU_TITLE, DEPTH, LINK, FOLDER_YORN, PUBLIC_YORN, SORT, FONTAWESOME   )     
AS    
(    
 SELECT MENU_SEQ, PMENU_SEQ, MENU_TITLE, DEPTH, LINK, FOLDER_YORN, PUBLIC_YORN
  , CONVERT(VARCHAR(10), SORT_NUM) AS SORT, FONT_AWESOME  AS FONTAWESOME
 FROM INTEGRATION_ADMIN_MENU     
 WHERE PMENU_SEQ IS NULL    
     
 UNION ALL    
     
 SELECT A.MENU_SEQ, A.PMENU_SEQ, A.MENU_TITLE, A.DEPTH, A.LINK, A.FOLDER_YORN, A.PUBLIC_YORN    
  , CONVERT(VARCHAR(10), B.SORT + '_' + CONVERT(VARCHAR(10), A.SORT_NUM)) AS SORT, FONT_AWESOME  AS FONTAWESOME
 FROM INTEGRATION_ADMIN_MENU A JOIN     
   MENU_CTE B ON A.PMENU_SEQ = B.MENU_SEQ    
)    
    
SELECT A.MENU_SEQ   AS MenuSeq 
 , ISNULL(A.PMENU_SEQ, '') AS PMenuSeq    
 , A.MENU_TITLE    AS MenuTitle
 , A.DEPTH    
 , A.LINK    
 , A.FOLDER_YORN    AS FolderYorN
 , A.PUBLIC_YORN    AS PublicYorN
 , A.SORT    
 , FONTAWESOME
FROM MENU_CTE A LEFT JOIN     
  (     
   SELECT A.MENU_SEQ, A.USE_YORN    
   FROM INTEGRATION_ADMIN_MENU_AUTH A JOIN     
     S2_AdminList B ON A.USER_SEQ = B.seq  
   WHERE A.USE_YORN = 'Y'    
   AND  A.USER_SEQ IN (Select seq from S2_AdminList where admin_id = @p_admin_code )  
  ) B ON A.MENU_SEQ = B.MENU_SEQ    
    
WHERE A.PUBLIC_YORN = 'Y'     
OR  (A.PUBLIC_YORN = 'N' AND B.USE_YORN = 'Y')    
    
ORDER BY A.SORT ASC    
    
END 
GO
