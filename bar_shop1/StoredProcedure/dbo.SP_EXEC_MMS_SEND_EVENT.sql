IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************

2016-07-01	정혜련
service
	SB : 바른손카드
	SA : 비핸즈
	SS : 프리미어페이퍼
	ST : 더카드
	B  : 바른손몰

table
jehu_send_mms (
	service		varchar(2)	not null
	, phone_num	varchar(15)	not null
	, send_Dt	varchar(8)	not null
	, send_chk	varchar(1)	not null

EXEC [SP_EXEC_MMS_SEND_EVENT] 1, '20181031','1700'

*********************************************************/
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_EVENT]
		@LMS_SEQ INT
	,	@SEND_DT VARCHAR(8)
	,	@SEND_TIME VARCHAR(4)
AS
BEGIN

	/****** 20201123 표수현 추가 START ****/
	DECLARE	@ErrNum   INT          
		  , @ErrSev   INT          
		  , @ErrState INT          
		  , @ErrProc  VARCHAR(50)  
		  , @ErrLine  INT          
		  , @ErrMsg   VARCHAR(2000)
	/****** 20201123 표수현 추가 END ****/

    DECLARE @TIME AS VARCHAR(10)
    DECLARE @Today_Dt AS VARCHAR(8)

	SET @TIME = ' '+SUBSTRING(@SEND_TIME,1,2)+':'+SUBSTRING(@SEND_TIME,3,2)+':00';

	DECLARE @MMS_MSG VARCHAR(MAX)
	DECLARE @MMS_SUBJECT VARCHAR(50)

	SELECT @MMS_SUBJECT = lms_subject , @MMS_MSG = content
	FROM EVENT_LMS_CONTENT
	WHERE SEQ = @LMS_SEQ

	--커서를 이용하여 해당되는 고객정보를 얻는다.
	DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD
	FOR

		SELECT CONVERT(CHAR(10), CONVERT(DATETIME, @SEND_DT), 23) + @TIME AS SEND_DATE, SERVICE, PHONE_NUM, ETC_INFO
		FROM JEHU_SEND_MMS
		WHERE SEND_DT = @SEND_DT
		AND SEND_CHK ='N'


	OPEN cur_AutoInsert_For_Order

	DECLARE @MMS_DATE VARCHAR(100)
	DECLARE @PHONE_NUM VARCHAR(100)
	DECLARE @U_ID VARCHAR(100)
	DECLARE @SERVICE VARCHAR(4)
	DECLARE @ETC_INFO VARCHAR(50)
	DECLARE @MMS_PHONE VARCHAR(50)

	FETCH NEXT FROM cur_AutoInsert_For_Order INTO @MMS_DATE, @SERVICE,  @PHONE_NUM,  @ETC_INFO

	WHILE @@FETCH_STATUS = 0

	BEGIN
						
			IF @SERVICE = 'SB'
				BEGIN			
					SET @MMS_PHONE		= '1644-0708'
				END

			ELSE IF @SERVICE = 'SA'
				BEGIN			
					SET @MMS_PHONE		= '1644-9713'
				END


			ELSE IF @SERVICE = 'ST'
				BEGIN
				
					SET @MMS_PHONE		= '1644-7998'
				END
			ELSE IF @SERVICE = 'B'
				BEGIN			
					SET @MMS_PHONE		= '1644-7413'
				END
			ELSE
				BEGIN			
					SET @MMS_PHONE		= '1644-8796'
				END


	BEGIN
		SET @MMS_MSG = Replace(@MMS_MSG , '{ETC_INFO}' , @ETC_INFO);
	end
		
			--MMS 전송

			
		/* 2020-11-23 KT 문자 서비스 작업 변경 */
		SET @PHONE_NUM = '^' + @PHONE_NUM
       EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MMS_MSG, '', @MMS_PHONE, 1, @PHONE_NUM, 0, '', 0, @SERVICE, '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT


			--INSERT INTO invtmng.MMS_MSG(subject, phone, callback, status, reqdate, msg, TYPE)
			--VALUES (  @MMS_SUBJECT
			--		, @PHONE_NUM
			--		, @MMS_PHONE
			--		, '0'
			--		, @MMS_DATE
			--		, @MMS_MSG
			--		, '0' )

			update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE and  phone_num =  @PHONE_NUM

			
		FETCH NEXT FROM cur_AutoInsert_For_Order INTO  @MMS_DATE, @SERVICE,  @PHONE_NUM, @ETC_INFO
	END

	CLOSE cur_AutoInsert_For_Order
	DEALLOCATE cur_AutoInsert_For_Order
END

GO
