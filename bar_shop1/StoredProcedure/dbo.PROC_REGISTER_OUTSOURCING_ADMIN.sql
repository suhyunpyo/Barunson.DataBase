IF OBJECT_ID (N'dbo.PROC_REGISTER_OUTSOURCING_ADMIN', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_REGISTER_OUTSOURCING_ADMIN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select * from manage_code
where code_type = 'etcprod'
and use_yorn = 'Y'
and code <> 'V'
--and parent_id = 0
order by code


select max(seq) + 1 from manage_code where code_type = 'etcprod'

EXEC PROC_REGISTER_OUTSOURCING_ADMIN 'gift_cl', 'cl12345!', '청소연구소', 'ZH'

*/


CREATE PROCEDURE [dbo].[PROC_REGISTER_OUTSOURCING_ADMIN]  (
	@P_ADMIN_ID VARCHAR(50),
	@P_ADMIN_PASSWD VARCHAR(20),
	@P_ADMIN_NAME VARCHAR(50),
	@P_CODE VARCHAR(10)
)
AS

BEGIN

DECLARE @T_CHECK_CODE INT = 0,
	@T_RESULT INT = 1,
	@T_RESULT_MSG VARCHAR(100) = '',
	@T_COMPANY_TYPE_CODE VARCHAR(10),
	@T_PARENT_ID INT



	IF @P_ADMIN_ID IS NULL OR LEN(@P_ADMIN_ID) = 0 
		OR @P_ADMIN_PASSWD IS NULL OR LEN(@P_ADMIN_PASSWD) = 0
		OR @P_ADMIN_NAME IS NULL OR LEN(@P_ADMIN_NAME) = 0
		OR @P_CODE IS NULL OR LEN(@P_CODE) = 0
	BEGIN
		SET @T_RESULT = 0
		SET @T_RESULT_MSG = '파라메터를 입력해주세요.'
		GOTO PROC_EXIT
	END

	SET @T_CHECK_CODE = (
		select COUNT(1) from manage_code
		where code_type = 'etcprod'
		and use_yorn = 'Y'
		and code <> 'V'
		and parent_id = 0
		AND CODE = @P_CODE
	)


	IF @T_CHECK_CODE > 0 
	BEGIN
		SET @T_RESULT = 0
		SET @T_RESULT_MSG = '이미 등록된 코드('+@P_CODE+')입니다.'
		GOTO PROC_EXIT
	END


	SET @T_CHECK_CODE = (
		select COUNT(1) from ADMIN_LST
		where ADMIN_ID = @P_ADMIN_ID
	)

	IF @T_CHECK_CODE > 0 
	BEGIN
		SET @T_RESULT = 0
		SET @T_RESULT_MSG = '이미 등록된 ID('+@P_ADMIN_ID+')입니다.'
		GOTO PROC_EXIT
	END


	SET @T_COMPANY_TYPE_CODE = CONVERT(VARCHAR, (SELECT MAX(COMPANY_TYPE_CODE) + 1 FROM ADMIN_LST))

	BEGIN TRAN

		insert into ADMIN_LST ( 
			ADMIN_ID, 
			ADMIN_PASSWD, 
			ADMIN_NAME, 
			CMS_ID, 
			CMS_NUM, 
			ADMIN_PHONE, 
			ADMIN_EMAIL, 
			COMPANY_TYPE, 
			COMPANY_SEQ, 
			COMPANY_GUBUN, 
			ADMIN_LEVEL, 
			isDesigner,
			isDown, 
			isAlba, 
			isCS, 
			isDeveloper, 
			NState, 
			adLevel, 
			isPackingSMS, 
			COMPANY_TYPE_CODE, 
			isViewNoticeYN 
		)
		select 
			TOP 1
			@P_ADMIN_ID , 
			@P_ADMIN_PASSWD, 
			REPLACE(REPLACE(@P_ADMIN_NAME,'(','_'),')','_'), 
			CMS_ID, 
			CMS_NUM, 
			ADMIN_PHONE, 
			ADMIN_EMAIL, 
			COMPANY_TYPE, 
			COMPANY_SEQ, 
			COMPANY_GUBUN, 
			ADMIN_LEVEL, 
			isDesigner, 
			isDown, 
			isAlba, 
			isCS, 
			isDeveloper, 
			NState, 
			adLevel, 
			isPackingSMS, 
			@T_COMPANY_TYPE_CODE, 
			isViewNoticeYN
		from ADMIN_LST 
		where COMPANY_TYPE_CODE is not null 
			and adLevel = 11 


		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			SET @T_RESULT = 0
			SET @T_RESULT_MSG = '등록중 오류 발생(1)'
			GOTO PROC_EXIT
		END -- IF @@ERROR <> 0


		INSERT INTO MANAGE_CODE (
			CODE_TYPE, 
			CODE, 
			CODE_VALUE, 
			ETC1, 
			SEQ, 
			USE_YORN, 
			parent_id
		) VALUES (
			'etcprod', 
			@P_CODE, 
			REPLACE(REPLACE(@P_ADMIN_NAME,'(','_'),')','_'), 
			@T_COMPANY_TYPE_CODE,
			(select max(seq) + 1 from manage_code where code_type = 'etcprod'),
			'Y',
			0
		)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			SET @T_RESULT = 0
			SET @T_RESULT_MSG = '등록중 오류 발생(2)'
			GOTO PROC_EXIT
		END -- IF @@ERROR <> 0

		SET @T_PARENT_ID = (SELECT @@IDENTITY)

		INSERT INTO MANAGE_CODE (
			CODE_TYPE, 
			CODE, 
			CODE_VALUE, 
			SEQ, 
			USE_YORN, 
			parent_id
		) VALUES (
			'etcprod', 
			@P_CODE+'1', 
			REPLACE(REPLACE(@P_ADMIN_NAME,'(','_'),')','_'), 
			(select max(seq) + 1 from manage_code where code_type = 'etcprod'),
			'Y',
			@T_PARENT_ID
		)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			SET @T_RESULT = 0
			SET @T_RESULT_MSG = '등록중 오류 발생(3)'
			GOTO PROC_EXIT
		END -- IF @@ERROR <> 0

	END -- TRAN

	COMMIT

	SELECT 1 RESULT, '정상 등록 되었습니다.' MSG

	PROC_EXIT: 
	SELECT @T_RESULT RESULT, @T_RESULT_MSG MSG

GO
