IF OBJECT_ID (N'dbo.SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_NEW]
/***************************************************************
작성자	:	표수현
작성일	:	2022-11-22
DESCRIPTION	:	CJ API 연동 방식 변동으로 인한 송장번호 건별 저장 
SPECIAL LOGIC	: 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @INVC_NO AS VARCHAR(12)
AS
BEGIN
    
    SET NOCOUNT ON;

	DECLARE @CODESEQ AS NUMERIC(11, 0)
    DECLARE @END_NUM AS NUMERIC(11, 0)
    DECLARE @DELCODE_SEQ AS INT

	SELECT @CODESEQ =  CAST(LEFT(@INVC_NO,LEN(@INVC_NO) - 1 ) AS NUMERIC(11)) 

    BEGIN
	    /* 데이터 이관에 대한 DELCODE_SEQ IDENTIY 속성 해제에 따른 ID 증가 값 설정이 변경됨 : 자동증가 -> MAX + 1 */
        SELECT @DELCODE_SEQ = MAX(DELCODE_SEQ) + 1 FROM CJ_DELCODE;

        INSERT INTO CJ_DELCODE (DELCODE_SEQ, CODESEQ, CODE, ISUSE, IS_USE, API_YN)
        VALUES (@DELCODE_SEQ, @CODESEQ, @INVC_NO, 0, 0, 'Y')


    END   

END
GO
