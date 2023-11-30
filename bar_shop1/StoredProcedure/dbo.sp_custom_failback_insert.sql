IF OBJECT_ID (N'dbo.sp_custom_failback_insert', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_custom_failback_insert
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_custom_failback_insert]
    @p_client_msg_key int
  , @p_mt_report_code_ib char(4)
AS

DECLARE     @V_LEN                  INT                     /* 문자길이 */
    ,       @V_MT_PR                INT                     /* ata_mmt_tran의 primary key */
    ,       @V_MT_REFKEY            VARCHAR(20)             /* payment code(부서별로 정산시 입력) */
    ,       @V_SUBJECT              VARCHAR(40)             /* 제목 */
    ,       @V_CONTENT              VARCHAR(4000)           /* 내용 */
    ,       @V_CALLBACK             VARCHAR(25)             /* 발신자 */
    ,       @V_RECIPIENT_NUM        VARCHAR(25)             /* 수신자 */
    ,       @V_COMPANY_SEQ          INT                     /* COMPANY_SEQ */
    ,       @V_SALES_GUBUN          VARCHAR(2)              /* SALES_GUBUN */

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)
	  , @SiteType VARCHAR(6)


    -- 결과코드 성공 이외의 건만 재 전송
    IF @p_mt_report_code_ib <> '1000'

        BEGIN        
            
            SELECT      @V_LEN = DATALENGTH(CONTENT)
                ,       @V_MT_PR = MT_PR
                ,       @V_MT_REFKEY = MT_REFKEY
                ,       @V_SUBJECT = SUBJECT
                ,       @V_CONTENT = CONTENT
                ,       @V_CALLBACK = CALLBACK
                ,       @V_RECIPIENT_NUM = RECIPIENT_NUM
                ,       @V_SALES_GUBUN = ETC_TEXT_1
                ,       @V_COMPANY_SEQ = ETC_NUM_1
            FROM        ATA_MMT_TRAN
            WHERE       MT_PR = @p_client_msg_key;

			SET @V_RECIPIENT_NUM = 'AA^'+@V_RECIPIENT_NUM

			SET @SiteType = CASE 
				WHEN @V_COMPANY_SEQ = 5001 THEN 'SB' 
				WHEN @V_COMPANY_SEQ = 5003 THEN 'SS' 
				WHEN @V_COMPANY_SEQ = 5006 THEN 'SA' 
				WHEN @V_COMPANY_SEQ = 5007 THEN 'ST' 
				ELSE 'B'
			END


	        IF (@V_LEN <= 80)      /* 80 글자 이하 SMS */
		        BEGIN
					
					EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @V_CONTENT, '', @V_CALLBACK, 1, @V_RECIPIENT_NUM, 0, '', 0, @SiteType, '', '비즈톡실패', 'sp_custom_failback_insert', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

		        END

	        ELSE                 /* 80 글자 이상 MMS */
		        BEGIN

					EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, @V_SUBJECT, @V_CONTENT, '', @V_CALLBACK, 1, @V_RECIPIENT_NUM, 0, '', 0, @SiteType, '', '비즈톡실패', 'sp_custom_failback_insert', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

		        END       
        END 
RETURN
GO
