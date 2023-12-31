USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_SETTLE_PRICE_SMS]    Script Date: 2023-10-11 오후 4:18:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************
-- SP Name       : SP_SEND_SMS_TO_DEVELOPERS
-- Author        : 변미정
-- Create date   : 2023-10-11
-- Description   : 개발 담당자에게 SMS발송
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_SEND_SMS_TO_DEVELOPERS] 
    @SMS_NUM AS VARCHAR(200) = NULL    --SMS전송 번호
   ,@SMS_MSG AS VARCHAR(200) = ''      --발송내용

AS

SET NOCOUNT ON
BEGIN
	DECLARE  @RESERVATION_DATE	VARCHAR(14)	
		
	IF ISNULL(@SMS_NUM,'') = '' BEGIN
        SET @SMS_NUM= '변미정^01093702902'; --변미정^01093702902|홍길동^01099999999 
    END

    SET @RESERVATION_DATE = REPLACE(REPLACE(REPLACE(CONVERT(varchar(19), CONVERT(datetime, DATEADD(mi, 1, GETDATE()), 112), 126), '-',''), 'T', ''),':', '');

	IF ISNULL(@SMS_MSG,'')<>'' BEGIN           							            
        EXEC dbo.PROC_SMS_MMS_SEND '', 0, '', @SMS_MSG, @RESERVATION_DATE, '16440708', 1, @SMS_NUM, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''            		
    END	

END
