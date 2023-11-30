IF OBJECT_ID (N'dbo.SP_SELECT_ORDER_ADDRESS_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_ORDER_ADDRESS_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SELECT_ORDER_ADDRESS_TEST]
/***************************************************************
작성자	:	표수현
작성일	:	2022-03-10
DESCRIPTION	:	인쇄완료된 전체 주문건의 배송지

- ACPERNM : 수하인명 
- ACPERTEL : 수하인전화번호 
- ACPERCPNO : 수하인휴대전화번호 
- ACPERZIPCD : 수하인우편번호 
- ACPERADR : 수하인주소 (기본주소 + 상세주소
GDSNM : 상품명 CUSMSGCONT : 고객메세지내용 
SELECT TOP 100 *  FROM CUSTOM_SAMPLE_ORDER WHERE 
SPECIAL LOGIC	:

******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
	@GUBUN int = 1, -- 1.청첩장 / 2.샘플 / 3.부가상품 
	@ORDER_SEQ int 
AS
	
	IF @GUBUN =  1 BEGIN 

			SELECT	
					ID = B.ID, 
					DELIVERY_METHOD = B.DELIVERY_METHOD, 
					ZIPCODE = B.ZIP, -- 수하인우편번호
					ZIPCODE_LENGTH = LEN(B.ZIP), -- 수하인우편번호자리수 
					[ADDRESS] = B.ADDR  + ' ' + B.ADDR_DETAIL -- 수하인주소 (기본주소 + 상세주소)
			FROM	CUSTOM_ORDER A JOIN  
					DELIVERY_INFO B ON A.ORDER_SEQ = B.ORDER_SEQ JOIN  
					--DELIVERY_INFO_DELCODE C ON B.ID = C.DELIVERY_ID JOIN  
					COMPANY D ON A.COMPANY_SEQ = D .COMPANY_SEQ  
			WHERE	A.ORDER_SEQ = @ORDER_SEQ --AND
					--(B.DELIVERY_CODE_NUM IS NULL OR B.DELIVERY_CODE_NUM = '')

	END ELSE IF @GUBUN = 2 BEGIN

			SELECT	ZIPCODE = A.MEMBER_ZIP, -- 수하인우편번호
					ZIPCODE_LENGTH = LEN(A.MEMBER_ZIP), -- 수하인우편번호자리수 
					[ADDRESS] = A.MEMBER_ADDRESS  + ' ' + A.MEMBER_ADDRESS_DETAIL -- 수하인주소 (기본주소 + 상세주소)
			FROM     CUSTOM_SAMPLE_ORDER A JOIN  
					COMPANY B ON A.COMPANY_SEQ = B.COMPANY_SEQ  
			WHERE	A.SAMPLE_ORDER_SEQ = @ORDER_SEQ

	END ELSE BEGIN 


			SELECT	STATUS_SEQ = A.STATUS_SEQ,
					ZIPCODE = A.RECV_ZIP, -- 수하인우편번호
					ZIPCODE_LENGTH = LEN(A.RECV_ZIP), -- 수하인우편번호자리수 
					[ADDRESS] = A.RECV_ADDRESS  + ' ' + A.RECV_ADDRESS_DETAIL -- 수하인주소 (기본주소 + 상세주소)
			FROM     CUSTOM_ETC_ORDER A INNER JOIN  
					COMPANY B ON A.COMPANY_SEQ = B.COMPANY_SEQ  
			WHERE  A.ORDER_SEQ = @ORDER_SEQ


	END 
GO
