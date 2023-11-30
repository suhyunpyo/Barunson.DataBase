IF OBJECT_ID (N'dbo.SP_BIZTALK_CHECK_SMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BIZTALK_CHECK_SMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Create date: 2018.04.25
-- Description:	비즈톡 발송 확인 (매 시간 10개이상 데이터 존재시 문자발송)
-- SP_BIZTALK_CHECK_SMS
-- =============================================================================================================================
CREATE PROCEDURE [dbo].[SP_BIZTALK_CHECK_SMS] 
AS
BEGIN

	DECLARE @BIZTALK_Cnt INT 

	DECLARE @SMS_NUM AS VARCHAR(200);		--SMS전송 번호

	DECLARE @TMP_SMS_NUM AS VARCHAR(200);	--실제저장변수
	DECLARE @STR_SMS_NUM AS VARCHAR(200);	--반복문사용변수
	DECLARE @splitStr AS VARCHAR(1);		--문자열구분자(|)
		
	
	SET @SMS_NUM			= '010-9484-4697|010-2434-2185|'; -- 정혜련|이근한팀장님
	SET @splitStr			= '|';
	SET @STR_SMS_NUM		= @SMS_NUM;

	SET NOCOUNT ON;


		select  @BIZTALK_Cnt = COUNT(*) from ata_mmt_tran

		----★문자전송 --------------------------------------------------------------------------------------------------------------------------

		if (@BIZTALK_Cnt >= 50 )
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  'AA^' + SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						DECLARE @TR_MSG VARCHAR(4000) = CONVERT(VARCHAR(3), @BIZTALK_Cnt)+'[확인요망]비즈톡 서비스 오류'

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @TR_MSG, '', '16440708', 1, @TMP_SMS_NUM, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
						
						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , convert(varchar(3), @BIZTALK_Cnt)+'[확인요망]비즈톡 서비스 오류')
						*/
					END

			END


	SET NOCOUNT OFF;

END

/****** Object:  StoredProcedure [dbo].[SP_AUTHORIZATION_SMS]    Script Date: 2020-11-23 오후 2:37:37 ******/
SET ANSI_NULLS ON

/****** Object:  StoredProcedure [dbo].[SP_AUTHORIZATION_SMS]    Script Date: 2020-11-23 오후 5:24:32 ******/
SET ANSI_NULLS ON
GO
