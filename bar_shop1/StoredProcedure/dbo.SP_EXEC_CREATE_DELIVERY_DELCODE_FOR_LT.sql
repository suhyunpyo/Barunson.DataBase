IF OBJECT_ID (N'dbo.SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_LT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_LT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_LT]
/***************************************************************
작성자	:	표수현
작성일	:	2022-03-15
DESCRIPTION	:	롯데택배 송장번호 생성
SPECIAL LOGIC	: 운송장구조 : 총 12자리 => 앞의 11자리는 연번으로 증가하는 숫자/마지막 1자는 패리티 숫자.
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
    @P_START_NUM AS NUMERIC(11, 0),   
	@P_END_NUM AS NUMERIC(11, 0)
AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @START_NUM AS NUMERIC(11, 0)
    DECLARE @END_NUM AS NUMERIC(11, 0)
    DECLARE @CHECK_DIGIT AS INT
	DECLARE @DELCODE_SEQ AS INT

    SET @START_NUM = @P_START_NUM
    SET @END_NUM = @P_END_NUM

    WHILE @START_NUM <= @END_NUM
    BEGIN
	 
		SET @CHECK_DIGIT = @START_NUM % 7

        INSERT INTO LT_DELCODE (CODESEQ, CODE, ISUSE, IS_USE)
        VALUES (@START_NUM, CAST(@START_NUM AS VARCHAR(11)) + CAST(@CHECK_DIGIT AS VARCHAR(1)), 0, 0)

        SET @START_NUM = @START_NUM + 1

    END   

END
GO
