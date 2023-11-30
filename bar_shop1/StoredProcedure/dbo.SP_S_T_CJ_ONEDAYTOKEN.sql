IF OBJECT_ID (N'dbo.SP_S_T_CJ_ONEDAYTOKEN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_T_CJ_ONEDAYTOKEN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_T_CJ_ONEDAYTOKEN]   
/***************************************************************  
작성자 : 표수현  
작성일 :    
DESCRIPTION :발행 된 토큰의 만료시간 -> 해당 시간 30분전부터 해당시간까지 사이에 1Day 토큰 발행 요청시 토큰이 갱신 됨  
SPECIAL LOGIC :  [SP_S_T_CJ_ONEDAYTOKEN]  'S'  
******************************************************************  
MODIFICATION  
******************************************************************  
수정일           작업자                DESCRIPTION  
==================================================================  
******************************************************************/  
 @GUBUN CHAR(1) = 'S',  
 @TOKEN_NUM VARCHAR(200) = '',  
 @TOKEN_EXPRTN_DTM VARCHAR(20) = ''  
AS  
  
 SET NOCOUNT ON  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
 IF @GUBUN = 'S' BEGIN   
  
  
  DECLARE @토큰만료시간 DATETIME   
  
  SELECT @토큰만료시간 = DATEADD(MI,-30,( SELECT CAST(STUFF(STUFF(STUFF(MAX(TOKEN_EXPRTN_DTM), 9, 0, ' '), 12, 0, ':'), 15, 0, ':') AS DATETIME) ))   
  FROM DBO.CJ_ONEDAYTOKEN  
  
  IF @토큰만료시간 > GETDATE()  BEGIN    
  
  SELECT TOP 1 RETURNSTR = TOKEN_NUM  
  FROM DBO.CJ_ONEDAYTOKEN    
  ORDER BY TOKEN_EXPRTN_DTM  DESC  
  
  
  END ELSE BEGIN  --토근만료시간이 지난 경우 API 호출  
   
  SELECT RETURNSTR =  'API호출'  
   
  END   
  
 END ELSE BEGIN  --API 호출로 새로 갱신된 토큰을 DB에 저장  
   
 --DELETE FROM CJ_ONEDAYTOKEN  
  
 INSERT CJ_ONEDAYTOKEN(TOKEN_NUM, TOKEN_EXPRTN_DTM, REG_DATE)  
 VALUES (@TOKEN_NUM, @TOKEN_EXPRTN_DTM, GETDATE())  
  
 SELECT RETURNSTR = 'INSERT SUCCESS'  
  
 END   
GO
