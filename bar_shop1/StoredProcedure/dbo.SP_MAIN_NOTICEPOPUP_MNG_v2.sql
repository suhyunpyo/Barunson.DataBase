IF OBJECT_ID (N'dbo.SP_MAIN_NOTICEPOPUP_MNG_v2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_MAIN_NOTICEPOPUP_MNG_v2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
Main banner (기간설정 포함)  
EXEC [SP_MAIN_NOTICEPOPUP_MNG] 'SB', 'MOBILE'  

<통합관리자>
-- PC : 전시 & 이벤트 체크여부 확인
-- MOBILE : 전시 & 새창 체크여부 확인

*/  
  
CREATE PROCEDURE [dbo].[SP_MAIN_NOTICEPOPUP_MNG_v2]  
    @SITE_GUBUN AS VARCHAR(2)  
,   @INFOLW_GUBUN AS VARCHAR(10) 

 AS  
BEGIN  
   
 SET NOCOUNT ON;  

 DECLARE @MD_SEQ AS INT
 
 IF @SITE_GUBUN  = 'SB'
    BEGIN  
     SET @MD_SEQ =  796      
    END  	 
ELSE IF @SITE_GUBUN  = 'SA' 
    BEGIN  
     SET @MD_SEQ =  797      
    END  
ELSE IF @SITE_GUBUN  = 'SS' 
    BEGIN  
     SET @MD_SEQ =  798      
    END 
ELSE IF @SITE_GUBUN  = 'B' 
    BEGIN  
     SET @MD_SEQ =  799      
    END 
	
					
IF @INFOLW_GUBUN = 'PC'
	BEGIN
	
		SELECT top 2 imgfile_path, link_url  from S4_MD_Choice 
			WHERE md_Seq = @MD_SEQ 
			and view_div='Y'  and event_open_yorn ='Y' 
			and start_Date <=  CONVERT(CHAR(19), getdate(), 23) 
			and end_Date >= CONVERT(CHAR(19), getdate(), 23) 
			order by seq 
	
	END	    


ELSE IF @INFOLW_GUBUN = 'MOBILE' 
	BEGIN
		SELECT TOP 1 card_text, md_title  from S4_MD_Choice 
			WHERE md_Seq = @MD_SEQ 
			and view_div='Y'  and LINK_TARGET ='_blank'
			and start_Date <=  CONVERT(CHAR(19), getdate(), 23) 
			and end_Date >= CONVERT(CHAR(19), getdate(), 23) 
			order by seq 	
	END
    
END 
GO
