IF OBJECT_ID (N'dbo.SP_UPDATE_OUTSOURCING_CUSTOM_ETC_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_OUTSOURCING_CUSTOM_ETC_ORDER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_UPDATE_OUTSOURCING_CUSTOM_ETC_ORDER]
    @P_OUTSOURCING_ORDER_SEQ      AS INT,
	@P_VALUE      AS VARCHAR(1000),
	@P_GUBUN      AS VARCHAR(3)
AS
BEGIN
	
	IF @P_GUBUN = 'M'
		BEGIN
			UPDATE CUSTOM_ETC_ORDER
			SET RESULT_INFO = @P_VALUE
			WHERE ORDER_SEQ = @P_OUTSOURCING_ORDER_SEQ
		END
	ELSE IF @P_GUBUN = 'D'
		BEGIN
			UPDATE CUSTOM_ETC_ORDER
			SET PRINT_DATE = CONVERT(DATETIME,ISNULL(@P_VALUE, '1753-01-01'))
			WHERE ORDER_SEQ = @P_OUTSOURCING_ORDER_SEQ
		END
--SELECT CONVERT(DATETIME,ISNULL('2017-01-06', '1975-01-01'))
END

GO
