IF OBJECT_ID (N'dbo.SP_CJ_DELEVERY_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CJ_DELEVERY_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CJ_DELEVERY_NEW]
/***************************************************************
작성자	:	표수현
작성일	:	2022-03-15
DESCRIPTION:	등록된 CJ송장번호 사용하기
사용 SP	:   PROC_CLOSECOPYBAESONG -- 원고마감관리 
			PROC_CLOSECOPY_CANCEL -- 원고마감관리(수정사항 없음)
			PROC_DELCODEADDPACKING -- 무게검증포장처리 
			PROC_DELCODEADD -- 메인인쇄정보 
			PROC_CLOSESAMPLE_NEW -- 샘플주문관리

사용검증 안된SP :	PROC_DELCODEADD1 
					PROC_DELCODEADD2 
					PROC_CLOSECOPY 
					PROC_CLOSECOPY_TEST (수정안함)
					PROC_CLOSEETC -- 시즌주문관리 
					PROC_CLOSESAMPLE  
SPECIAL LOGIC	: 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @SP_NAME						VARCHAR(MAX), --INSERT 테이블
 @ORDER_SEQ_LIST				VARCHAR(8000), --주문번호
 @DEL_ID						INT,		   --DELIVERY_INFO.ID
 @DELIVERY_COMPANY_SHORT_NAME	VARCHAR(10),   --택배사명
 @CODE							VARCHAR(20) OUTPUT	-- 송장번호
	--,@RETURNVALUE					INT				OUTPUT
	--,@RETURNMESSAGE					VARCHAR(255)	OUTPUT

AS
BEGIN	
	
	DECLARE @ID BIGINT				-- 송장SEQ
	DECLARE @CODESEQ BIGINT
	DECLARE @DEL_CODE INT

	--@ORDER_SEQ_LIST이 여러개일때 사용하는 변수
	DECLARE @TMP_SEQ VARCHAR(8000)	--실제저장변수
	DECLARE @STR_SEQ VARCHAR(8000)	--반복문사용변수

	DECLARE @ORDER_SEQ INT

	--DECLARE @DEL_CODE VARCHAR(12)	
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED	
	SET NOCOUNT ON
	SET LOCK_TIMEOUT 10000

	IF CHARINDEX('CUSTOM_SAMPLE_ORDER|', @SP_NAME) = 0 AND CHARINDEX('DEARDEER_SAMPLE_ORDER|', @SP_NAME) = 0 BEGIN
			--SET @ORDER_SEQ	= @ORDER_SEQ_LIST
			SET @ORDER_SEQ	= CONVERT(INT,@ORDER_SEQ_LIST)
		END

	SET @STR_SEQ = ''
	IF @ORDER_SEQ_LIST <> '' 
		BEGIN
			SET @STR_SEQ = @ORDER_SEQ_LIST + ',' --구분자 , 로 구분하기 위해 마지막에 넣어줌
		END


	--DECLARE @RETURNMESSAGE VARCHAR(MAX);
	--SET @RETURNVALUE = 0
	--SET @RETURNMESSAGE = '';


	BEGIN TRY
		BEGIN TRAN TR_DELIVERY_INFO

			--★-------------------------------------------------------------------------------------------------------------------------------------
			
			--PROC_CLOSESAMPLE_NEW(샘플주문관리)에서 호출시 사용
			IF CHARINDEX('CUSTOM_SAMPLE_ORDER|', @SP_NAME) > 0 BEGIN		

					WHILE CHARINDEX(',', @STR_SEQ, 0) > 0 BEGIN
								
							SET @TMP_SEQ	=  SUBSTRING(@STR_SEQ,1,CHARINDEX(',',@STR_SEQ)-1)
							SET @STR_SEQ	=  SUBSTRING(@STR_SEQ,CHARINDEX(',',@STR_SEQ)+LEN(','),LEN(@STR_SEQ))

							SELECT TOP 1 @DEL_CODE =  DELCODE_SEQ ,	@CODE = CODE , @CODESEQ = CODESEQ
							FROM LT_DELCODE WITH (HOLDLOCK, ROWLOCK, XLOCK)
							WHERE ISUSE='2' 
							ORDER BY CODESEQ



							/* 카드준비중 처리를 할때에, 이미 카드 준비중 처리를 했거나, 송장번호가 발행된 주문건은 제외 한다. */
							/* 작업자의 실수로 카드준비중 처리를 여러번 하면서, 기존 송장번호가 사라지는 현상 때문에 보안함 */
							/* 2017-02-23 - BY CHATOY */
							IF EXISTS (SELECT * FROM CUSTOM_SAMPLE_ORDER WHERE SAMPLE_ORDER_SEQ = @TMP_SEQ AND STATUS_SEQ < 10 AND ISNULL(DELIVERY_CODE_NUM, '') = '')
								BEGIN
									
									UPDATE	LT_DELCODE WITH (ROWLOCK, XLOCK)
									SET		ISUSE='1' 				
									WHERE	DELCODE_SEQ = @DEL_CODE
									AND		CODESEQ = @CODESEQ

									UPDATE  CUSTOM_SAMPLE_ORDER
									SET     DELIVERY_COM		= @DELIVERY_COMPANY_SHORT_NAME
										,   DELIVERY_CODE_NUM	= @CODE
										,   STATUS_SEQ			= 10
										,   PREPARE_DATE		= GETDATE()
									FROM    CUSTOM_SAMPLE_ORDER A
									WHERE	A.SAMPLE_ORDER_SEQ = @TMP_SEQ
										
									-- 샘플발송 알림톡
                                    -- 2018-07-10부터 발송완료시 빠른손에서 직접 실행
									--EXEC SP_SAMPLE_BIZTALK_PROC @TMP_SEQ, '샘플발송완료'
								END


							/* 특정 구간대의 DELIVERY_CODE_NUM의 사용된 내역이 사라지는 것을 추적하기 위해서 LOG를 남김 17.02.23 - BY CHATOY */
							--INSERT INTO LT_DELCODE_USAGE_LOG (DELCODE_SEQ, CODESEQ, DELIVERY_CODE_NUM, SP_NAME, ORDER_SEQ, DELIVERY_ID)
							--SELECT	@DEL_CODE, @CODESEQ, @CODE, @SP_NAME, @TMP_SEQ, NULL

					END
			END

            IF CHARINDEX('DEARDEER_SAMPLE_ORDER|', @SP_NAME) > 0 BEGIN		

					WHILE CHARINDEX(',', @STR_SEQ, 0) > 0 BEGIN
								
						SET @TMP_SEQ	=  SUBSTRING(@STR_SEQ,1,CHARINDEX(',',@STR_SEQ)-1)
						SET @STR_SEQ	=  SUBSTRING(@STR_SEQ,CHARINDEX(',',@STR_SEQ)+LEN(','),LEN(@STR_SEQ))

						SELECT TOP 1 @DEL_CODE =  DELCODE_SEQ ,	@CODE = CODE , @CODESEQ = CODESEQ
						FROM LT_DELCODE WITH (HOLDLOCK, ROWLOCK, XLOCK)
						WHERE ISUSE='2' 
						ORDER BY CODESEQ

						IF EXISTS (SELECT * FROM DEARDEER_SAMPLE_ORDER_MST WHERE DEARDEER_SAMPLE_ORDER_MST_SEQ = @TMP_SEQ AND STATUS_SEQ < 10 AND ISNULL(TRACKING_NUMBER, '') = '')
							BEGIN
							
								UPDATE	LT_DELCODE WITH (ROWLOCK, XLOCK)
								SET		ISUSE='1' 				
								WHERE	DELCODE_SEQ = @DEL_CODE
								AND		CODESEQ = @CODESEQ

								UPDATE  DEARDEER_SAMPLE_ORDER_MST
								SET     DELIVERY_COMPANY_CODE   = @DELIVERY_COMPANY_SHORT_NAME
									,   TRACKING_NUMBER	        = @CODE
									,   STATUS_SEQ			    = 10
									,   PREPARE_DATE		    = GETDATE()
								FROM    DEARDEER_SAMPLE_ORDER_MST A
								WHERE	A.DEARDEER_SAMPLE_ORDER_MST_SEQ = @TMP_SEQ
									
							END


						/* 특정 구간대의 DELIVERY_CODE_NUM의 사용된 내역이 사라지는 것을 추적하기 위해서 LOG를 남김 17.02.23 - BY CHATOY */
						INSERT INTO LT_DELCODE_USAGE_LOG (DELCODE_SEQ, CODESEQ, DELIVERY_CODE_NUM, SP_NAME, ORDER_SEQ, DELIVERY_ID)
						SELECT	@DEL_CODE, @CODESEQ, @CODE, @SP_NAME, @TMP_SEQ, NULL

					END
			END ELSE BEGIN	 

					-- PROC_DELCODEADDPACKING / PROC_DELCODEADD /PROC_CLOSECOPYBAESONG /
				
					-- 사용하지 않은 송장번호 1개를 추출 
					SELECT TOP 1 @DEL_CODE =  DELCODE_SEQ ,	@CODE = CODE , @CODESEQ = CODESEQ
					FROM LT_DELCODE WITH (HOLDLOCK, ROWLOCK, XLOCK)
					WHERE ISUSE='0' 
					ORDER BY CODESEQ

					--공통업데이트
					UPDATE	LT_DELCODE WITH (ROWLOCK, XLOCK)
					SET		ISUSE='1' 				
					WHERE	DELCODE_SEQ = @DEL_CODE AND		
							CODESEQ = @CODESEQ


					IF CHARINDEX('DELIVERY_INFO|', @SP_NAME) > 0 BEGIN

						UPDATE  DELIVERY_INFO 
						SET     DELIVERY_COM = @DELIVERY_COMPANY_SHORT_NAME
							,   DELIVERY_CODE_NUM = @CODE 
						WHERE   ID = @DEL_ID

					END
					
					--(샘플주문관리 제외)
					IF CHARINDEX('DELIVERY_INFO_DELCODE|', @SP_NAME) > 0 BEGIN

						IF @ORDER_SEQ <> '' BEGIN
								INSERT INTO DELIVERY_INFO_DELCODE (ORDER_SEQ, DELIVERY_ID, DELIVERY_CODE_NUM, DELIVERY_COM) 
								VALUES (@ORDER_SEQ, @DEL_ID, @CODE, @DELIVERY_COMPANY_SHORT_NAME)
						END
					
					END


					--[PROC_CLOSEETC]에서 사용
					IF CHARINDEX('CUSTOM_ETC_ORDER|', @SP_NAME) > 0 BEGIN
							IF @ORDER_SEQ <> '' BEGIN
							select 3
										UPDATE  CUSTOM_ETC_ORDER 
										SET     DELIVERY_COM = @DELIVERY_COMPANY_SHORT_NAME
											,   DELIVERY_CODE = @DEL_CODE
											,   STATUS_SEQ = 10
											,   PREPARE_DATE = GETDATE() 
										WHERE   ORDER_SEQ = @ORDER_SEQ
							END
					
					END



					/* 특정 구간대의 DELIVERY_CODE_NUM의 사용된 내역이 사라지는 것을 추적하기 위해서 LOG를 남김 17.02.23 - BY CHATOY */
					INSERT INTO LT_DELCODE_USAGE_LOG (DELCODE_SEQ, CODESEQ, DELIVERY_CODE_NUM, SP_NAME, ORDER_SEQ, DELIVERY_ID)
					SELECT	@DEL_CODE, @CODESEQ, @CODE, @SP_NAME, ISNULL((SELECT ORDER_SEQ FROM DELIVERY_INFO WHERE ID = @DEL_ID), @ORDER_SEQ), @DEL_ID

				END


			--★------------------------------------------------------------------------------------------------------------------------------------

			IF @@ERROR <> 0
				BEGIN
					--SET @RETURNVALUE = ERROR_NUMBER()
					--SET @RETURNMESSAGE = @RETURNMESSAGE + ERROR_MESSAGE()
					ROLLBACK TRAN TR_DELIVERY_INFO

					IF CHARINDEX('CUSTOM_SAMPLE_ORDER|', @SP_NAME) = 0
						BEGIN
						
							INSERT INTO LOG_MST (GUID, SITE, LOCATION, SUB_LOCATION, LOG_TYPE_NAME, MSG, USER_ID)
							VALUES (CONVERT(VARCHAR(36), NEWID()), @SP_NAME, 'SP_CJ_DELEVERY', 'SP_CJ_DELEVERY / ERROR', 'SP', ERROR_MESSAGE(), CONVERT(VARCHAR(50) , @ORDER_SEQ))
						END

				END
			ELSE
				BEGIN
					COMMIT TRAN TR_DELIVERY_INFO

					--IF @RETURNVALUE <> 0 
					--	BEGIN
					--		ROLLBACK TRAN TR_DELIVERY_INFO
					--	END
					--ELSE
					--	BEGIN
					--		COMMIT TRAN TR_DELIVERY_INFO
					--	END
			
				END

	END TRY

	BEGIN CATCH
		BEGIN
			ROLLBACK TRAN TR_DELIVERY_INFO
			--SET @RETURNVALUE = ERROR_NUMBER()
			--SET @RETURNMESSAGE = @RETURNMESSAGE + ERROR_MESSAGE()

			--청첩장주문일때만 오류메시지 남김
			IF CHARINDEX('CUSTOM_SAMPLE_ORDER|', @SP_NAME) = 0
				BEGIN
					INSERT INTO LOG_MST (GUID, SITE, LOCATION, SUB_LOCATION, LOG_TYPE_NAME, MSG, USER_ID)
					VALUES (CONVERT(VARCHAR(36), NEWID()), @SP_NAME, 'SP_CJ_DELEVERY', 'SP_CJ_DELEVERY / BEGIN CATCH', 'SP', ERROR_MESSAGE(), CONVERT(VARCHAR(50) , @ORDER_SEQ))
				END
		END
	END CATCH

	
END
GO
