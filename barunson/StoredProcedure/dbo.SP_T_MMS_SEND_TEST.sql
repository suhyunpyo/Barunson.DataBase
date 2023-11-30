IF OBJECT_ID (N'dbo.SP_T_MMS_SEND_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_MMS_SEND_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_MMS_SEND_TEST]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	모바일 초대장 MMS 전송
SPECIAL LOGIC	: SP_T_MMS_SEND 111, '01022276303','16440708' 

UPDATE TB_INVITATION_DETAIL
	SET MMS_SEND_YN = NULL
 SELECT MMS_SEND_YN = ISNULL(C.MMS_SEND_YN, 'N'),
		INVITATION_ID = C.INVITATION_ID
 FROM	TB_ORDER A INNER JOIN 
		TB_INVITATION B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
		TB_INVITATION_DETAIL C ON B.INVITATION_ID = C.INVITATION_ID 

 WHERE A.ORDER_ID = 398 
	
	UPDATE TB_INVITATION_DETAIL
	SET MMS_SEND_YN = NULL
	WHERE INVITATION_ID = 444

	SELECT * FROM TB_INVITATION_DETAIL
	WHERE INVITATION_URL = 'CDFSD' 


		SELECT PRODUCT_TYPE_CODE= F.CODE, 
		GROOMNAME = GROOM_NAME, 
		BRIDENAME=  BRIDE_NAME,
		IMG_URL = 'HTTPS://BARUNSONMCARD.COM/' + E.MAIN_IMAGE_URL--INVITATION_URL
	FROM TB_ORDER A INNER JOIN 
		 TB_INVITATION B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
		 TB_INVITATION_DETAIL C ON B.INVITATION_ID = C.INVITATION_ID INNER JOIN 
		 TB_ORDER_PRODUCT D ON A.ORDER_ID = D.ORDER_ID  INNER JOIN 
		 TB_PRODUCT E ON D.PRODUCT_ID = E.PRODUCT_ID  INNER JOIN 
		 TB_COMMON_CODE F ON E.PRODUCT_CATEGORY_CODE = F.CODE

	WHERE A.ORDER_ID = 398
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @ORDER_ID INT,
 @RECV_PNUM  VARCHAR(20),  -- 보내는 핸드폰번호 
 @SEND_PNUM  VARCHAR(20)  -- 16440708
 --@MSG   VARCHAR(160),  
-- @IMG_URL VARCHAR(MAX)  
  
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

/*청첩장 / 초대장 여부에 따라 제목이 달라지는거 같음
 EX - 	청첩장 - > SQL = "SELECT GROOMNAME , BRIDENAME FROM MCARD_INVITATIONWEDDING WHERE INVITATIONID = " & INVITATIONID
 GROOMNAME & "♡" & BRIDENAME & "의  모바일청첩장입니다."

초대장 ->  "SELECT GROUPNAME FROM MCARD_INVITATIONPARTY WHERE INVITATIONID = " & INVITATIONID
 GROUPNAME & " 모바일초대장 입니다."*/

 DECLARE @MMS_SEND_YN CHAR(1)
 DECLARE @INVITATION_ID INT

 SELECT @MMS_SEND_YN = ISNULL(C.MMS_SEND_YN, 'N'),
		@INVITATION_ID = C.INVITATION_ID
 FROM	TB_ORDER A INNER JOIN 
		TB_INVITATION B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
		TB_INVITATION_DETAIL C ON B.INVITATION_ID = C.INVITATION_ID 
 WHERE A.ORDER_ID = @ORDER_ID 

 IF @MMS_SEND_YN = 'N' BEGIN 
  
	-- SMS전송여부값 저장 필요할거 같음...
	DECLARE @PRODUCT_TYPE_CODE VARCHAR(10) 
	DECLARE @GROOMNAME VARCHAR(20)
	DECLARE @BRIDENAME VARCHAR(20)
	DECLARE @MSG VARCHAR(MAX) 
	DECLARE @INVITATION_URL VARCHAR(MAX)  
	DECLARE @MAIN_IMG_URL VARCHAR(MAX)  

	SELECT @PRODUCT_TYPE_CODE= F.CODE, 
		@GROOMNAME = GROOM_NAME, 
		@BRIDENAME=  BRIDE_NAME,
		@INVITATION_URL = 'https://barunsonmcard.com/m/' + C.INVITATION_URL,
		@MAIN_IMG_URL = 'http://barunsonmcard.com' + E.MAIN_IMAGE_URL
	FROM TB_ORDER A INNER JOIN 
		 TB_INVITATION B ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
		 TB_INVITATION_DETAIL C ON B.INVITATION_ID = C.INVITATION_ID INNER JOIN 
		 TB_ORDER_PRODUCT D ON A.ORDER_ID = D.ORDER_ID  INNER JOIN 
		 TB_PRODUCT E ON D.PRODUCT_ID = E.PRODUCT_ID  INNER JOIN 
		 TB_COMMON_CODE F ON E.PRODUCT_CATEGORY_CODE = F.CODE
	WHERE A.ORDER_ID = @ORDER_ID


	IF @PRODUCT_TYPE_CODE = 'PCC01' BEGIN 
		SET @MSG = /*@IMG_URL + '  ' + */@GROOMNAME + ' ' + @BRIDENAME + '♡ 의  모바일청첩장입니다.' + '  ' + @INVITATION_URL
	END ELSE BEGIN 
		SET @MSG = /*@IMG_URL + '  ' + */@GROOMNAME + ' 모바일청첩장입니다.' + '  ' + @INVITATION_URL
	END 

	
	SELECT @MSG = C.Invitation_Title + CHAR(13) + CHAR(10) + @INVITATION_URL,
		   @MAIN_IMG_URL = 'https://barunsonmcard.com' + C.SNS_IMAGE_URL
	FROM	TB_ORDER A INNER JOIN  
			TB_INVITATION B ON A.ORDER_ID = B.ORDER_ID INNER JOIN  
			TB_INVITATION_DETAIL C ON B.INVITATION_ID= C.INVITATION_ID
	WHERE A.ORDER_ID = @ORDER_ID


--SELECT SEND_PNUM   = @SEND_PNUM 
--SELECT RECV_PNUM  =  @RECV_PNUM


--SELECT MSG  =   @MSG
 --SET @MAIN_IMG_URL = 'HTTP://MCARD.BARUNNFAMILY.COM/PHOTOS/202010/ST3021030/MMSCARD.JPG'
 SET @MAIN_IMG_URL = 'https://barunsonmcard.com/upload/invitation/210825/111/e77473a8-c7a1-4c2d-bf34-f220f3c25b7b.jpg'
--SET @MAIN_IMG_URL = 'https://barunsonmcard.com/upload/invitation/210825/111/6037ff5d-6e10-4908-bb43-389b476ae23b.png'

SELECT MAIN_IMG_URL   =  @MAIN_IMG_URL

	--EXEC BAR_SHOP1.DBO.SP_EXEC_SMS_OR_MMS_SEND @SEND_PNUM, @RECV_PNUM, @MSG, '', '', '고객 사용', '모바일초대장 핸드폰으로 주소 보내기 - SP_DACOMMMS', '', 1, @MAIN_IMG_URL 



	--return

	EXEC BAR_SHOP1.DBO.SP_EXEC_SMS_OR_MMS_SEND @SEND_PNUM, @RECV_PNUM, '모바일초대장', @MSG, '', '고객 사용', '모바일초대장 핸드폰으로 주소 보내기 - SP_DACOMMMS', '', 1, @MAIN_IMG_URL

	--EXEC BAR_SHOP1.DBO.SP_EXEC_SMS_OR_MMS_SEND '16440708', '01022276303', '모바일초대장', 'HTTPS://BARUNSONMCARD.COM/UPLOAD/TEMPLATE/MC1205/CFE5F176-2D74-4E09-B026-1F5D17E1D70B.PNG  박기준 한소영♡ 의  모바일청첩장입니다.', '', '고객 사용', '모바일초대장 핸드폰으로 주소 보내기 - SP_DACOMMMS', '', 1


	UPDATE TB_INVITATION_DETAIL
	SET MMS_SEND_YN = 'Y'
	WHERE INVITATION_ID = @INVITATION_ID

	SELECT RESULT = 'T' 	

  END  ELSE BEGIN 

	SELECT RESULT = 'F' 	

  END 
	
	--EXEC BAR_SHOP1.DBO.SP_EXEC_SMS_OR_MMS_SEND '16440708', '010-9484-4697', '모바일초대장_기존',
	--'HTTP://MCARD.BARUNNFAMILY.COM/PHOTOS/202010/ST3021030/MMSCARD.JPG  박기준 한소영♡ 의  모바일청첩장입니다.', '', '고객 사용', '모바일초대장 핸드폰으로 주소 보내기 - SP_DACOMMMS', '', 1, 'HTTP://MCARD.BARUNNFAMILY.COM/PHOTOS/202010/ST3021030/MMSCARD.JPG'
	
	
	
	--EXEC BAR_SHOP1.DBO.SP_EXEC_SMS_OR_MMS_SEND '16440708', '01022276303', '모바일초대장_신', '박기준 한소영♡ 의  모바일청첩장입니다.', '', 
	--'고객 사용', '모바일초대장 핸드폰으로 주소 보내기 - SP_DACOMMMS', '', 1, 'HTTP://BARUNSONMCARD.COM/UPLOAD/TEMPLATE/MC1205/CFE5F176-2D74-4E09-B026-1F5D17E1D70B.PNG'
GO
