IF OBJECT_ID (N'dbo.up_backend_company_edit', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_company_edit
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:29    21:46]  JJH: 
	관련페이지 : coop_admin/A_Info/coop_info.asp
	내용	   : 제휴사정보 수정
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_company_edit]
	@JOB_KIND		varchar(20)
,	@COMPANY_SEQ		int
,	@COMPANY_NAME	varchar(100)
,	@COMPANY_NUM		varchar(100)
,	@LOGIN_ID		varchar(100)
,	@PASSWD		varchar(100)
,	@BOSS_NM		varchar(100)
,	@BOSS_TEL_NO		varchar(100)
,	@UP_TAE		varchar(100)
,	@FAX_NO		varchar(100)
,	@KIND			varchar(100)
,	@E_MAIL			varchar(100)
,	@ZIP_CODE		varchar(100)
,	@FRONT_ADDR		varchar(100)
,	@BACK_ADDR		varchar(100)
,	@MNG_NM		varchar(100)
,	@MNG_E_MAIL		varchar(100)
,	@MNG_TEL_NO		varchar(100)
,	@MNG_HP_NO		varchar(100)
,	@ACC_NM		varchar(100)
,	@ACC_E_MAIL		varchar(100)
,	@ACC_TEL_NO		varchar(100)
,	@ACC_HP_NO		varchar(100)
,	@CORP_EXP		varchar(1000)
,	@BANK_NM		varchar(100)
,	@ACCOUNT_NO		varchar(100)
,	@JAEHU_KIND		varchar(100)
,	@ADMIN_ID		varchar(100)
,	@STAT 			varchar(2)
as
	
IF @JOB_KIND = 'ADD'
	BEGIN
		INSERT INTO dbo.COMPANY(COMPANY_NAME
					,COMPANY_NUM
					,LOGIN_ID
					,PASSWD
					,BOSS_NM
					,BOSS_TEL_NO
					,UP_TAE
					,FAX_NO
					,KIND
					,E_MAIL
					,ZIP_CODE
					,FRONT_ADDR
					,BACK_ADDR
					,MNG_NM
					,MNG_E_MAIL
					,MNG_TEL_NO
					,MNG_HP_NO
					,ACC_NM
					,ACC_E_MAIL
					,ACC_TEL_NO
					,ACC_HP_NO
					,CORP_EXP
					,BANK_NM
					,ACCOUNT_NO
					,JAEHU_KIND
					,REG_ID
					,STATUS)
			VALUES(@COMPANY_NAME
					,@COMPANY_NUM
					,@LOGIN_ID
					,@PASSWD
					,@BOSS_NM
					,@BOSS_TEL_NO
					,@UP_TAE
					,@FAX_NO
					,@KIND
					,@E_MAIL
					,@ZIP_CODE
					,@FRONT_ADDR
					,@BACK_ADDR
					,@MNG_NM
					,@MNG_E_MAIL
					,@MNG_TEL_NO
					,@MNG_HP_NO
					,@ACC_NM
					,@ACC_E_MAIL
					,@ACC_TEL_NO
					,@ACC_HP_NO
					,@CORP_EXP
					,@BANK_NM
					,@ACCOUNT_NO
					,@JAEHU_KIND
					,@ADMIN_ID
					,'S1')
	END
IF @JOB_KIND = 'UPDATE'
	BEGIN
		UPDATE  dbo.COMPANY SET 
					COMPANY_NAME	= @COMPANY_NAME
					,COMPANY_NUM	= @COMPANY_NUM
					,LOGIN_ID	= @LOGIN_ID
					,PASSWD	= @PASSWD
					,BOSS_NM	= @BOSS_NM
					,BOSS_TEL_NO	= @BOSS_TEL_NO
					,UP_TAE		= @UP_TAE
					,FAX_NO		= @FAX_NO
					,KIND		= @KIND
					,E_MAIL		= @E_MAIL
					,ZIP_CODE	= @ZIP_CODE
					,FRONT_ADDR	= @FRONT_ADDR
					,BACK_ADDR	= @BACK_ADDR
					,MNG_NM	= @MNG_NM
					,MNG_E_MAIL	= @MNG_E_MAIL
					,MNG_TEL_NO	= @MNG_TEL_NO
					,MNG_HP_NO	= @MNG_HP_NO
					,ACC_NM	= @ACC_NM
					,ACC_E_MAIL	= @ACC_E_MAIL
					,ACC_TEL_NO	= @ACC_TEL_NO
					,ACC_HP_NO	= @ACC_HP_NO
					,CORP_EXP	= @CORP_EXP
					,BANK_NM	= @BANK_NM
					,ACCOUNT_NO	= @ACCOUNT_NO
					,JAEHU_KIND	= @JAEHU_KIND
					,CHG_ID		= @ADMIN_ID
					,CHG_DT	= GETDATE()
		WHERE  COMPANY_SEQ = @COMPANY_SEQ
	END
IF @JOB_KIND = 'STAT'
	BEGIN
		UPDATE  dbo.COMPANY SET 
					STATUS	= @STAT
		WHERE  COMPANY_SEQ = @COMPANY_SEQ
	END

GO
