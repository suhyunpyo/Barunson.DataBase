IF OBJECT_ID (N'dbo.SP_EXEC_HAKSUL_DIGITAL_SEND_MEMO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_HAKSUL_DIGITAL_SEND_MEMO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EXEC_HAKSUL_DIGITAL_SEND_MEMO]
        @p_order_cnt AS INT
    ,   @p_type AS INT
AS
BEGIN

DECLARE @message AS NVARCHAR(100)

    IF @p_type = 0
    BEGIN
	    SET @message = '[비핸즈카드]디지탈청첩장 학술' + CONVERT(varchar(10), @p_order_cnt) + '건발주'

	    EXEC sp_DacomSMS '010-9942-0290', '16440708', @message
	    --EXEC sp_DacomSMS '010-8207-2207', '16440708', @message
	    EXEC sp_DacomSMS '010-9288-6346', '16440708', @message

        -- 박혜진
        EXEC sp_DacomSMS '010-8899-4924', '16440708', @message
    END

    ELSE IF @p_type = 1
    BEGIN
    	SET @message = '[비핸즈카드]디지탈청첩장 위피오디' + CONVERT(varchar(10), @p_order_cnt) + '건발주'

        -- 박혜진
        EXEC sp_DacomSMS '010-8899-4924', '16440708', @message

        -- 위피오디 김상일 부장
        EXEC sp_DacomSMS '010-7104-5279', '16440708', @message
    END

    --ELSE IF @p_type = 2
    --BEGIN
     --SET @message = '[비핸즈카드]디지탈청첩장 위피오디' + CONVERT(varchar(10), @p_order_cnt) + '건발주'

     --   -- 김민정
	    --EXEC sp_DacomSMS '010-8858-6590', '16440708', @message

     --   -- 박혜진
     --   EXEC sp_DacomSMS '010-8899-4924', '16440708', @message

     --   -- 위피오디 김상일 부장
     --   EXEC sp_DacomSMS '010-7104-5279', '16440708', @message
    --END

END
GO
