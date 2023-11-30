IF OBJECT_ID (N'dbo.OB_ADM_LOGIN_CONFIG_SP', N'P') IS NOT NULL DROP PROCEDURE dbo.OB_ADM_LOGIN_CONFIG_SP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OB_ADM_LOGIN_CONFIG_SP]
@actiontype 	varchar(15),
@admId	varchar(20),
@admPw	varchar(20),
@outPut	varchar(20) output

AS    
/********************************************************************/
/*                 아웃바운드 리뉴얼          */
/********************************************************************/
/*  1. 시 스 템 명 : 아웃바운드
 *  2. 단위 업무명 : 
 *  3. 파  일  JOB : 관리자 로그인 계정 조회
 *  4. 파  일   ID :  OB_ADM_LOGIN_CONFIG_SP
 *  5. 구       분 : Stored Procedure
 *  6. 관련TABLE명 : 관리자 계정 테이블(GCAMP_ADMIN_T)
 *  7. 작  성  자  : 진나영
 *  8. 작  성  일  : 2006.07.01
 *  9. 주의  사항  :
 *10. Parameter : 	   				
 *  	@actiontype  	: 호출 구분값
 *  	@admId	: 아이디	
 *  	@admPw   	: 패스워드
 *  	@outPut		:                       
 * 11. 수정  사항(일자,수정자,수정이유 기술)
 *     1)
 *     2)
 ********************************************************************/
Set NoCount On
DECLARE @chkId 		int,
	  @chkPw	int,
	  @reVal		varchar(20)	 
--관리자 로그인 Check
IF @actiontype = 'loginChk'	
	BEGIN 
		SET @chkId = 0
		--아이디체크
		SELECT @chkId = count(1) 
		FROM DBO.COMPANY 
		WHERE login_id = @admId 
		
		IF @chkId = 1
			BEGIN
			--패스워드 체크
			SELECT @chkPw = count(1)
			FROM DBO.COMPANY
			WHERE login_id = @admId 
			             AND passwd = @admPw

			IF @chkPw =  1
				BEGIN

				select login_id,company_name,passwd,company_seq,jaehu_kind,status				

				--SELECT admId,admNm,admPw,admGrade,admStatus,admDept
				FROM COMPANY
				WHERE login_id = @admId

				SET @reVal = 'success'
				
				END
			ELSE
				BEGIN
				SET @reVal = 'notPass'
				END

			END
		ELSE
			BEGIN
			SET @reVal = 'noId'
			END
		
		print @reVal						
		Set @outPut = isnull(@reVal,'notChk')
	END
--관리자 아이디 중복성 체크
IF @actiontype = 'gaipIdChk'
	BEGIN
		SET @chkId = 0
		
		SELECT @chkId = count(1)
		FROM DBO.COMPANY
		WHERE login_id = @admId 

		IF @chkId = 0
			SET @reVal = 'notExist'
		ELSE
			SET @reVal = 'Exist'

		SET @outPut = isnull(@reVal,'error')
	END
GO
