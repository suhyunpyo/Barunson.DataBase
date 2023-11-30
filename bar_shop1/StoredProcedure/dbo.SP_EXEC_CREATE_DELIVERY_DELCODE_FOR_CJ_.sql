IF OBJECT_ID (N'dbo.SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
    EXEC SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ 36100000000, 36100000010

    SELECT * FROM CJ_DELCODE

    2015-07-28 지급 30만건
    33501790718 ~ 33502090717

    2018-07-09 지급 30만건
    34609589001 ~ 34609889000

    EXEC SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_ 33501790718, 33502090717
	
	select len(33501790718)
	select len(385600636016)
	
	EXEC SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_ 385600636016, 385603036003


	EXEC SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_ 38560063601, 38560303600

*/
CREATE PROCEDURE [dbo].[SP_EXEC_CREATE_DELIVERY_DELCODE_FOR_CJ_]
    @P_START_NUM AS NUMERIC(11, 0)
,   @P_END_NUM AS NUMERIC(11, 0)
AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @START_NUM AS NUMERIC(11, 0)
    DECLARE @END_NUM AS NUMERIC(11, 0)
    DECLARE @CHECK_DIGIT AS INT
	DECLARE @i int = 0
    SET @START_NUM = @P_START_NUM
    SET @END_NUM = @P_END_NUM


    WHILE @START_NUM <= @END_NUM
    BEGIN
            
        SET @CHECK_DIGIT = RIGHT(@START_NUM, 9) % 7

		SELECT @START_NUM, CAST(@START_NUM AS VARCHAR(11)) + CAST(@CHECK_DIGIT AS VARCHAR(1)), len(@START_NUM),len(CAST(@START_NUM AS VARCHAR(11)) + CAST(@CHECK_DIGIT AS VARCHAR(1)))

        --INSERT INTO CJ_DELCODE (CODESEQ, CODE, ISUSE, IS_USE)
        --VALUES (@START_NUM, CAST(@START_NUM AS VARCHAR(12)) + CAST(@CHECK_DIGIT AS VARCHAR(1)), 0, 0)

		--select top 20  len(codeseq), len(code) from CJ_DELCODE  order by DELCODE_SEQ desc

        SET @START_NUM = @START_NUM + 1

		SET  @i =  @i + 1
    END   

	select @i
END








GO