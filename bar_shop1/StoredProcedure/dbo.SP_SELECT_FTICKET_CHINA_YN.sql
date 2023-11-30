IF OBJECT_ID (N'dbo.SP_SELECT_FTICKET_CHINA_YN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_FTICKET_CHINA_YN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SELECT_FTICKET_CHINA_YN]
/***************************************************************
작성자	:	표수현
작성일	:	2022-10-15
DESCRIPTION	:	식권을 한국으로 할지 중국할지 판단
SP_SELECT_FTICKET_CHINA_YN '플라워 리스', 'A'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @FTICKET_NM VARCHAR(100),
 @TYPE	VARCHAR(1) = 'A'
	
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @중국코드여부 INT = 0 

	IF @TYPE = 'A' BEGIN --성인식권 
					
					SELECT @중국코드여부 = SUM(CHARINDEX('_C',CARD_CODE)) 
					FROM DBO.S2_CARD WHERE CARD_NAME= @FTICKET_NM AND CARD_DIV IN ('C01','C02') 

					 IF @FTICKET_NM = '플라워 리스' BEGIN 
						
						SELECT CARD_SEQ,CARDSET_PRICE,CARD_PRICE,CARD_NAME 
						FROM	S2_CARD 
						WHERE	CARD_NAME = @FTICKET_NM AND 
								CARD_DIV IN ('C01','C02') AND 
								CARD_SEQ IN (36151, 36152)  
						ORDER BY CARD_DIV

					END ELSE BEGIN 
							IF @중국코드여부 > 0 BEGIN 
										SELECT CARD_NAME, CARD_SEQ,CARDSET_PRICE,CARD_PRICE, CARD_CODE 
										FROM S2_CARD 
										WHERE	CARD_NAME= @FTICKET_NM AND 
												CARD_DIV IN ('C01','C02') AND 
												CARD_CODE  LIKE ('%_C%')
										ORDER BY CARD_DIV 
							END ELSE BEGIN  
										SELECT CARD_NAME, CARD_SEQ,CARDSET_PRICE,CARD_PRICE 
										FROM S2_CARD 
										WHERE	CARD_NAME= @FTICKET_NM AND 
												CARD_DIV IN ('C01','C02') 
										ORDER BY CARD_DIV  
							END  
					END 
	 END ELSE BEGIN
		
					SELECT @중국코드여부 = SUM(CHARINDEX('_C',CARD_CODE))
					FROM S2_CARD WHERE CARD_NAME = @FTICKET_NM AND CARD_DIV IN ('C09','C10') 

					IF @중국코드여부 > 0 BEGIN 
								SELECT CARD_NAME, CARD_SEQ,CARDSET_PRICE,CARD_PRICE, CARD_CODE 
								FROM S2_CARD 
								WHERE	CARD_NAME = @FTICKET_NM AND 
										CARD_DIV IN ('C09','C10') AND 
										CARD_CODE  LIKE ('%_C%') 
								ORDER BY CARD_DIV 
					END ELSE BEGIN  
								SELECT CARD_NAME, CARD_SEQ,CARDSET_PRICE,CARD_PRICE 
								FROM S2_CARD 
								WHERE	CARD_NAME = @FTICKET_NM AND 
										CARD_DIV IN ('C09','C10') 
								ORDER BY CARD_DIV  
					END    
		END 
 END
		
GO
