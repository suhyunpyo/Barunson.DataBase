IF OBJECT_ID (N'dbo.SP_BENEFIT_BANNER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BENEFIT_BANNER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		엄예지
-- Create date: 2016.09.21
-- Description:	S2_MANAGER : MD전시관리>비핸즈카드>[메인]2016메인리뉴얼>[메인]혜택배너
-- =============================================
CREATE PROCEDURE [dbo].[SP_BENEFIT_BANNER]

	@COMPANY_SEQ	INT,
	@R_GB			VARCHAR(3),			--NEW:신규 , MOD:수정
	@SEQ			INT,				--글seq		
	@GB_H			VARCHAR(10),		--선택한 타입 = 변경할 타입
	@B_TYPE			VARCHAR(10),		--타입(L1/M1/S1...)	
	@B_TYPE_NO		INT,				--1:진행 2:대기 3:대체
	@DISPLAY_YN		VARCHAR(1),			--전시유무(Y:전시 N:비전시)
	@EVENT_S_DT		VARCHAR(10),		--이벤트 시작일
	@EVENT_E_DT		VARCHAR(10),		--이벤트 종료일
	@MAIN_TITLE		NVARCHAR(100),		--메인 타이틀(제목)
	@SUB_TITLE		NVARCHAR(100),		--서브 타이틀(내용)
	@PAGE_URL		NVARCHAR(100),		--페이지 연결URL
	@B_IMG			VARCHAR(255),		--배너이미지
	@B_BACK_COLOR	VARCHAR(10),		--배경 컬러코드
	@WING_IMG		VARCHAR(255),		--윙배너 이미지
	@WING_YN		VARCHAR(1),			--윙배너노출
	@BAND_YN		VARCHAR(1),			--밴드형배너 노출
	@NEW_BLANK_YN	VARCHAR(1),			--새창띄움
	@JEHU_YN		VARCHAR(1),			--제휴배너
	--@END_YN			VARCHAR(1),			--종료유무(Y:종료 N:미종료)
	--@REPLACE_YN     VARCHAR(1),			--대체유무(Y:대체 N:미대체)
	@ALWAYS_YN		VARCHAR(1),			--상시노출(Y:상시 N)
	@CREATED_UID	VARCHAR(50),		--생성자
	@UPDATED_UID	VARCHAR(50),		--수정자

	@returnValue		INT				OUTPUT,	
	@returnMessage		VARCHAR(255)	OUTPUT

AS
BEGIN

	DECLARE @CNT		INT
	DECLARE @B_IMG_C	VARCHAR(255)	--수정시 기존 저장된 배너이미지 경로
	DECLARE @WING_IMG_C	VARCHAR(255)	--수정시 기존 저장된 윙이미지 경로

	
	DECLARE @R_SEQ		VARCHAR(255)    --등록된 타입의SEQ
	DECLARE @R_SEQ_C	VARCHAR(255)	--수정하는 타입의SEQ



	SET NOCOUNT ON;

	SET @returnValue = 0;
	SET @returnMessage = '등록되었습니다.';

	SET @CNT = 0;




	BEGIN TRY
		BEGIN TRAN TR_BENEFIT_BANNER_INFO

			if @B_TYPE_NO <> 3	--대체배너는 무관
			BEGIN
				--동일한 타입 배너 등록 시 
				SELECT @CNT = COUNT(*)
				FROM BENEFIT_BANNER
				WHERE B_TYPE = @GB_H
				AND END_YN = 'N'
				AND B_TYPE_NO IN (1,2)
				AND B_TYPE_NO <> @B_TYPE_NO
				AND COMPANY_SEQ = @COMPANY_SEQ
				AND ((@EVENT_S_DT BETWEEN EVENT_S_DT AND EVENT_E_DT) OR (@EVENT_E_DT BETWEEN EVENT_S_DT AND EVENT_E_DT))

				IF @CNT <> 0
					BEGIN
						SET @returnValue	= 2;
						SET @returnMessage	= '해당기간에 진행하는 이벤트가 이미 등록되어 있습니다.\n확인 후 다시 입력해 주세요.';
					END
			END

				--윙배너 등록 최대 4개
				IF @WING_YN = 'Y'
					BEGIN
					
						select @CNT = count(*)
						from BENEFIT_BANNER
						where WING_YN = 'Y'
						AND B_TYPE_NO = @B_TYPE_NO
						and B_TYPE <> @B_TYPE
						AND END_YN = 'N'
						AND COMPANY_SEQ = @COMPANY_SEQ


						IF @CNT >= 4
							BEGIN
								SET @returnValue	= 3;
								SET @returnMessage	= '윙배너는 최대 4개까지 선택 가능합니다.';
							END

					END


				--밴드형배너 등록 최대 1개
				IF @BAND_YN = 'Y'
					BEGIN
						select @CNT = count(*)
						from BENEFIT_BANNER
						where BAND_YN = 'Y'
						AND B_TYPE_NO = @B_TYPE_NO
						and B_TYPE <> @B_TYPE
						AND END_YN = 'N'
						AND COMPANY_SEQ = @COMPANY_SEQ


						IF @CNT >= 1
							BEGIN
								SET @returnValue	= 4;
								SET @returnMessage	= '밴드형 배너는 하나만 선택 가능합니다.';
							END
					END
			



			IF @returnValue = 0	
				BEGIN
						--신규등록
						if @R_GB = 'NEW'
							BEGIN

								INSERT INTO BENEFIT_BANNER(COMPANY_SEQ
														   , B_TYPE
														   , B_TYPE_NO
														   , DISPLAY_YN
														   , EVENT_S_DT
														   , EVENT_E_DT
														   , MAIN_TITLE
														   , SUB_TITLE
														   , PAGE_URL
														   , B_IMG
														   , B_BACK_COLOR
														   , WING_IMG
														   , WING_YN
														   , BAND_YN
														   , NEW_BLANK_YN
														   , JEHU_YN
														   , ALWAYS_YN
														   , CREATED_DATE
														   , CREATED_UID)
									VALUES(@COMPANY_SEQ 
											, @B_TYPE  
											, @B_TYPE_NO 
											, @DISPLAY_YN 
											, @EVENT_S_DT 
											, @EVENT_E_DT 
											, @MAIN_TITLE 
											, @SUB_TITLE 
											, @PAGE_URL 
											, @B_IMG  
											, @B_BACK_COLOR 
											, @WING_IMG 
											, @WING_YN 
											, @BAND_YN 
											, @NEW_BLANK_YN 
											, @JEHU_YN  
											, @ALWAYS_YN 
											, getdate()
											, @CREATED_UID )
							END




						if @R_GB = 'MOD'
							BEGIN
								SELECT @CNT = COUNT(*) 
								FROM BENEFIT_BANNER
								WHERE B_TYPE = @B_TYPE
								AND B_TYPE_NO = @B_TYPE_NO
								AND COMPANY_SEQ = @COMPANY_SEQ

								IF @CNT = 0
									BEGIN
										SET @returnValue	= 1;
										SET @returnMessage	= '수정정보가 맞지 않습니다. 시스템팀에 문의해 주세요.';
									END

								ELSE
									BEGIN

										SELECT @B_IMG_C = B_IMG
											  ,@WING_IMG_C = WING_IMG
										FROM BENEFIT_BANNER
										WHERE B_TYPE = @B_TYPE
										AND B_TYPE_NO = @B_TYPE_NO
										AND COMPANY_SEQ = @COMPANY_SEQ

										--배너이미지경로
										IF @B_IMG = '' OR @B_IMG IS NULL
											BEGIN
												SET @B_IMG = @B_IMG_C
											END

										--윙배너이미지경로
										IF @WING_IMG = '' OR @WING_IMG IS NULL
											BEGIN
												SET @WING_IMG = @WING_IMG_C
											END


										--기본정보 업데이트
										UPDATE BENEFIT_BANNER SET 
											  B_TYPE		= @B_TYPE  
											, B_TYPE_NO		= @B_TYPE_NO 
											, DISPLAY_YN	= @DISPLAY_YN 
											, EVENT_S_DT	= @EVENT_S_DT 
											, EVENT_E_DT	= @EVENT_E_DT 
											, MAIN_TITLE	= @MAIN_TITLE 
											, SUB_TITLE		= @SUB_TITLE 
											, PAGE_URL		= @PAGE_URL 
											, B_IMG			= @B_IMG  
											, B_BACK_COLOR	= @B_BACK_COLOR
											, WING_IMG		= @WING_IMG
											, WING_YN		= @WING_YN
											, BAND_YN		= @BAND_YN
											, NEW_BLANK_YN	= @NEW_BLANK_YN
											, JEHU_YN		= @JEHU_YN
											, ALWAYS_YN		= @ALWAYS_YN
											, UPDATED_DATE	= GETDATE()
											, UPDATED_UID   = @UPDATED_UID
										WHERE B_TYPE = @B_TYPE
										AND B_TYPE_NO = @B_TYPE_NO
										AND COMPANY_SEQ = @COMPANY_SEQ 

							
										SET @returnMessage = '수정되었습니다.';
							
									END

							END





						--타입변경 업데이트
						--선택한 타입과 등록(수정)할 타입이 다를 때 
						--print '1=' + @B_TYPE + ', ' + @GB_H;

						IF @B_TYPE <> @GB_H
							BEGIN

								SELECT @CNT = COUNT(B_TYPE)
								FROM BENEFIT_BANNER
								WHERE B_TYPE = @GB_H
								AND COMPANY_SEQ = @COMPANY_SEQ

								--PRINT @CNT;

								IF @CNT > 0 
									BEGIN

										--수정데이터 타입변경:임의 A로 저장
										UPDATE BENEFIT_BANNER SET 
											B_TYPE = 'A'
											, UPDATED_DATE	= GETDATE()
											, UPDATED_UID   = @UPDATED_UID
										WHERE B_TYPE = @B_TYPE
										AND COMPANY_SEQ = @COMPANY_SEQ
							

										--기존데이터 타입변경
										UPDATE BENEFIT_BANNER SET 
											B_TYPE = @B_TYPE
											, UPDATED_DATE	= GETDATE()
											, UPDATED_UID   = @UPDATED_UID
										WHERE B_TYPE = @GB_H
										AND COMPANY_SEQ = @COMPANY_SEQ

										--수정데이터 타입변경
										UPDATE BENEFIT_BANNER SET 
											B_TYPE = @GB_H
											, UPDATED_DATE	= GETDATE()
											, UPDATED_UID   = @UPDATED_UID
										WHERE B_TYPE = 'A'
										AND COMPANY_SEQ = @COMPANY_SEQ

							
									END
									
							END

				END
			
			



		--★------------------------------------------------------------------------------------------------------------------------------------

			IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRAN TR_BENEFIT_BANNER_INFO

					SET @returnValue = ERROR_NUMBER()
					SET @returnMessage = @returnMessage + ERROR_MESSAGE()
					

				END
			ELSE
				BEGIN
					IF @returnValue = 0 
						BEGIN						
							COMMIT TRAN TR_BENEFIT_BANNER_INFO
						END
					ELSE
						BEGIN
							ROLLBACK TRAN TR_BENEFIT_BANNER_INFO

							--SET @returnValue = @returnMessage
							--SET @returnMessage = @returnMessage 
								
						END				 
				END

	END TRY

	BEGIN CATCH
		BEGIN
			ROLLBACK TRAN TR_BENEFIT_BANNER_INFO
		END
	END CATCH

END
GO
