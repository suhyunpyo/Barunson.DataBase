IF OBJECT_ID (N'dbo.SP_ERROR_SMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ERROR_SMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Author:		엄예지
-- Create date: 2016.06.21
-- Description:	시스템 경고 메세지 문자 전송[월~금:18:00~24:00 , 토,일:09:00~24:00]
--                ㄴ 샘플 주문이 1시간 이내 1건도 접수 안 될 경우  and
--                ㄴ 정상 주문이 1시간 이내 1건도 접수 안 될 경우
--                  --> 쇼핑몰 바른손,더카드,제휴,비핸즈,프리미어 합산해서 1시간내 1건이라도 주문이 없는 경우
--              대상자 - 원덕규(010-8934-4814), 박경희(010-9254-2100), 박동혁(010-5090-4010)
--              배치일정 : 08:50~ 1시간단위

--              2016.07.29 수정사항 : 요일, 시간 상관없이 무조건 보냄
--                                    배치일정- 종일  
--              2016.11.08 수정사항 : 김용재 제외
-- =============================================================================================================================
CREATE PROCEDURE [dbo].[SP_ERROR_SMS] 
AS
BEGIN

	DECLARE @SAMPLE_ORDER_GB_BHANDS AS VARCHAR(1);	--샘플주문:비핸즈
	DECLARE @SAMPLE_ORDER_GB_BARUNN AS VARCHAR(1);	--샘플주문:바른손
	DECLARE @SAMPLE_ORDER_GB_PREMIER AS VARCHAR(1);	--샘플주문:프리미어
	DECLARE @SAMPLE_ORDER_GB_THECARD AS VARCHAR(1);	--샘플주문:더카드
	DECLARE @SAMPLE_ORDER_GB_JEHU AS VARCHAR(1);	--샘플주문:제휴

	DECLARE @ORDER_GB_BHANDS AS VARCHAR(1);		--카드주문:비핸즈
	DECLARE @ORDER_GB_BARUNN AS VARCHAR(1);		--카드주문:바른손
	DECLARE @ORDER_GB_PREMIER AS VARCHAR(1);	--카드주문:프리미어
	DECLARE @ORDER_GB_THECARD AS VARCHAR(1);	--카드주문:더카드
	DECLARE @ORDER_GB_JEHU AS VARCHAR(1);		--카드주문:제휴


	DECLARE @LOGIN_GB_BHANDS AS VARCHAR(1);		--로그인
	DECLARE @LOGIN_GB_BARUNN AS VARCHAR(1);		--로그인
	DECLARE @LOGIN_GB_PREMIER AS VARCHAR(1);	--로그인
	DECLARE @LOGIN_GB_THECARD AS VARCHAR(1);	--로그인
	DECLARE @LOGIN_GB_JEHU AS VARCHAR(1);		--로그인


	DECLARE @REGIST_GB_BHANDS AS VARCHAR(1);		--가입
	DECLARE @REGIST_GB_BARUNN AS VARCHAR(1);		--가입
	DECLARE @REGIST_GB_PREMIER AS VARCHAR(1);		--가입
	DECLARE @REGIST_GB_THECARD AS VARCHAR(1);		--가입
	DECLARE @REGIST_GB_JEHU AS VARCHAR(1);		--가입


	DECLARE @weekends AS VARCHAR(1);		--주말(토/일)
	DECLARE @current_GB AS VARCHAR(2);		--현재시간이 전송시간인지 확인
	DECLARE @SMS_SEND_GB AS VARCHAR(1);		--SMS전송여부

	DECLARE @SMS_MSG_F_BHANDS AS VARCHAR(80);		--SMS전송 문구-샘플/카드
	DECLARE @SMS_MSG_F_BARUNN AS VARCHAR(80);		--SMS전송 문구-샘플/카드
	DECLARE @SMS_MSG_F_PREMIER AS VARCHAR(80);		--SMS전송 문구-샘플/카드
	DECLARE @SMS_MSG_F_THECARD AS VARCHAR(80);		--SMS전송 문구-샘플/카드
	DECLARE @SMS_MSG_F_JEHU AS VARCHAR(80);			--SMS전송 문구-샘플/카드


	DECLARE @SMS_MSG_L_BHANDS AS VARCHAR(80);		--SMS전송 문구-로그인
	DECLARE @SMS_MSG_L_BARUNN AS VARCHAR(80);		--SMS전송 문구-로그인
	DECLARE @SMS_MSG_L_PREMIER AS VARCHAR(80);		--SMS전송 문구-로그인
	DECLARE @SMS_MSG_L_THECARD AS VARCHAR(80);		--SMS전송 문구-로그인
	DECLARE @SMS_MSG_L_JEHU AS VARCHAR(80);			--SMS전송 문구-로그인


	DECLARE @SMS_MSG_R_BHANDS AS VARCHAR(80);		--SMS전송 문구-회원가입
	DECLARE @SMS_MSG_R_BARUNN AS VARCHAR(80);		--SMS전송 문구-회원가입
	DECLARE @SMS_MSG_R_PREMIER AS VARCHAR(80);		--SMS전송 문구-회원가입
	DECLARE @SMS_MSG_R_THECARD AS VARCHAR(80);		--SMS전송 문구-회원가입
	DECLARE @SMS_MSG_R_JEHU AS VARCHAR(80);			--SMS전송 문구-회원가입

	DECLARE @SMS_NUM AS VARCHAR(200);		--SMS전송 번호

	DECLARE @TMP_SMS_NUM AS VARCHAR(200);	--실제저장변수
	DECLARE @STR_SMS_NUM AS VARCHAR(200);	--반복문사용변수
	DECLARE @splitStr AS VARCHAR(1);		--문자열구분자(|)
		
	----------------------------------------------------------------------------------------------------
	-- Declare Block
	----------------------------------------------------------------------------------------------------									
	DECLARE @DEST_INFO     VARCHAR(50)
	      , @SCHEDULE_TYPE INT
	      , @RESERVATION_DATE	VARCHAR(14)	

    SET @RESERVATION_DATE = REPLACE(REPLACE(REPLACE(CONVERT(varchar(19), CONVERT(datetime, DATEADD(mi, 1, GETDATE()), 112), 126), '-',''), 'T', ''),':', '');
	SET @SCHEDULE_TYPE = 1	--예약전송
   
	SET @SAMPLE_ORDER_GB_BHANDS	= 'N';
	SET @SAMPLE_ORDER_GB_BARUNN	= 'N';
	SET @SAMPLE_ORDER_GB_PREMIER	= 'N';
	SET @SAMPLE_ORDER_GB_THECARD	= 'N';
	SET @SAMPLE_ORDER_GB_JEHU	= 'N';

	SET @ORDER_GB_BHANDS			= 'N';
	SET @ORDER_GB_BARUNN			= 'N';
	SET @ORDER_GB_PREMIER			= 'N';
	SET @ORDER_GB_THECARD			= 'N';
	SET @ORDER_GB_JEHU				= 'N';

	SET @LOGIN_GB_BHANDS			= 'N';
	SET @LOGIN_GB_BARUNN 			= 'N';
	SET @LOGIN_GB_PREMIER			= 'N';
	SET @LOGIN_GB_THECARD			= 'N';
	SET @LOGIN_GB_JEHU				= 'N';

	SET @REGIST_GB_BHANDS			= 'N';
	SET @REGIST_GB_BARUNN			= 'N';
	SET @REGIST_GB_PREMIER			= 'N';
	SET @REGIST_GB_THECARD			= 'N';
	SET @REGIST_GB_JEHU				= 'N';

	SET @SMS_SEND_GB		= 'N';
	
	SET @SMS_NUM			= '010-8934-4814|010-9254-2100|010-9484-4697|010-9179-0094|010-4531-8283|010-4934-9760|010-9070-5120|010-5090-4010|010-9686-0690|010-2816-6353|';
	--SET @SMS_NUM			= '010-9484-4697|010-2674-7880|';
	
	SET @splitStr			= '|';
	SET @STR_SMS_NUM		= @SMS_NUM;

	SET @SMS_MSG_F_BHANDS			= '[확인요망]비핸즈 : 2시간동안 주문건이 존재하지 않습니다.';	--샘플/카드 주문
	SET @SMS_MSG_F_BARUNN			= '[확인요망]바른손 : 2시간동안 주문건이 존재하지 않습니다.';	--샘플/카드 주문
	SET @SMS_MSG_F_PREMIER			= '[확인요망]프리미어 : 2시간동안 주문건이 존재하지 않습니다.';	--샘플/카드 주문
	SET @SMS_MSG_F_THECARD			= '[확인요망]더카드 : 2시간동안 주문건이 존재하지 않습니다.';	--샘플/카드 주문
	SET @SMS_MSG_F_JEHU				= '[확인요망]제휴 : 2시간동안 주문건이 존재하지 않습니다.';	--샘플/카드 주문

	SET @SMS_MSG_L_BHANDS			= '[확인요망]비핸즈 : 2시간동안 로그인이 없습니다.';				--로그인
	SET @SMS_MSG_L_BARUNN			= '[확인요망]바른손 : 2시간동안 로그인이 없습니다.';				--로그인
	SET @SMS_MSG_L_PREMIER			= '[확인요망]프리미어 : 2시간동안 로그인이 없습니다.';				--로그인
	SET @SMS_MSG_L_THECARD			= '[확인요망]더카드 : 2시간동안 로그인이 없습니다.';				--로그인
	SET @SMS_MSG_L_JEHU				= '[확인요망]제휴 : 2시간동안 로그인이 없습니다.';				--로그인

	SET @SMS_MSG_R_BHANDS			= '[확인요망]비핸즈 : 2시간동안 회원가입이 없습니다.';			--회원가입
	SET @SMS_MSG_R_BARUNN			= '[확인요망]바른손 : 2시간동안 회원가입이 없습니다.';			--회원가입
	SET @SMS_MSG_R_PREMIER			= '[확인요망]프리미어 : 2시간동안 회원가입이 없습니다.';			--회원가입
	SET @SMS_MSG_R_THECARD			= '[확인요망]더카드 : 2시간동안 회원가입이 없습니다.';			--회원가입
	SET @SMS_MSG_R_JEHU				= '[확인요망]제휴 : 2시간동안 회원가입이 없습니다.';			--회원가입



	SET NOCOUNT ON;

		--★샘플주문건수★--
		SELECT @SAMPLE_ORDER_GB_BHANDS = isnull((SELECT /*비핸즈-샘플주문건수 1시간전*/ TOP 1 CASE WHEN DATEDIFF(mi  , request_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
											FROM CUSTOM_SAMPLE_ORDER cs
											WHERE request_date >=  dateadd(hh, -2, GETDATE())
											AND SALES_GUBUN = 'SA'
											ORDER BY request_date DESC) ,'Y')


		SELECT @SAMPLE_ORDER_GB_BARUNN = isnull((SELECT /*바른손-샘플주문건수 1시간전*/ TOP 1 CASE WHEN DATEDIFF(mi  , request_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
											FROM CUSTOM_SAMPLE_ORDER cs
											WHERE request_date >=  dateadd(hh, -2, GETDATE())
											AND SALES_GUBUN = 'SB'
											ORDER BY request_date DESC) ,'Y')


		SELECT @SAMPLE_ORDER_GB_PREMIER = isnull((SELECT /*프리미어-샘플주문건수 1시간전*/ TOP 1 CASE WHEN DATEDIFF(mi  , request_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
											FROM CUSTOM_SAMPLE_ORDER cs
											WHERE request_date >=  dateadd(hh, -2, GETDATE())
											AND SALES_GUBUN = 'SS'
											ORDER BY request_date DESC) ,'Y')


		SELECT @SAMPLE_ORDER_GB_THECARD = isnull((SELECT /*더카드-샘플주문건수 1시간전*/ TOP 1 CASE WHEN DATEDIFF(mi  , request_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
											FROM CUSTOM_SAMPLE_ORDER cs
											WHERE request_date >=  dateadd(hh, -2, GETDATE())
											AND SALES_GUBUN = 'ST'
											ORDER BY request_date DESC) ,'Y')


		

		SELECT @SAMPLE_ORDER_GB_JEHU = isnull((SELECT /*제휴-샘플주문건수 1시간전*/ TOP 1 CASE WHEN DATEDIFF(mi  , request_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
											FROM CUSTOM_SAMPLE_ORDER cs
											WHERE request_date >=  dateadd(hh, -2, GETDATE())
											AND SALES_GUBUN IN ('B','C','H')
											ORDER BY request_date DESC) ,'Y')





		--★카드주문건수★--
		SELECT @ORDER_GB_BHANDS =  isnull((SELECT /*카드주문건수 1시간전*/ top 1 CASE WHEN DATEDIFF(mi  , order_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									FROM CUSTOM_ORDER co
									WHERE order_date >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN = 'SA'
									ORDER BY order_date DESC) ,'Y')



		SELECT @ORDER_GB_BARUNN =  isnull((SELECT /*카드주문건수 1시간전*/ top 1 CASE WHEN DATEDIFF(mi  , order_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									FROM CUSTOM_ORDER co
									WHERE order_date >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN = 'SB'
									ORDER BY order_date DESC) ,'Y')


		SELECT @ORDER_GB_PREMIER =  isnull((SELECT /*카드주문건수 1시간전*/ top 1 CASE WHEN DATEDIFF(mi  , order_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									FROM CUSTOM_ORDER co
									WHERE order_date >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN = 'SS'
									ORDER BY order_date DESC) ,'Y')



		SELECT @ORDER_GB_THECARD =  isnull((SELECT /*카드주문건수 1시간전*/ top 1 CASE WHEN DATEDIFF(mi  , order_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									FROM CUSTOM_ORDER co
									WHERE order_date >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN = 'ST'
									ORDER BY order_date DESC) ,'Y')



		SELECT @ORDER_GB_JEHU =  isnull((SELECT /*카드주문건수 1시간전*/ top 1 CASE WHEN DATEDIFF(mi  , order_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									FROM CUSTOM_ORDER co
									WHERE order_date >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN IN ('B','C','H')
									ORDER BY order_date DESC) ,'Y')





		--★로그인★--
		SELECT @LOGIN_GB_BHANDS = isnull((select /*로그인 2시간전*/ top 1 CASE WHEN DATEDIFF(mi  , regdate , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from S4_LOGINIPINFO
									where regdate >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN = 'SA'
									ORDER BY regdate DESC) ,'Y')



		SELECT @LOGIN_GB_BARUNN = isnull((select /*로그인 2시간전*/ top 1 CASE WHEN DATEDIFF(mi  , regdate , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from S4_LOGINIPINFO
									where regdate >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN = 'SB'
									ORDER BY regdate DESC) ,'Y')


		SELECT @LOGIN_GB_PREMIER = isnull((select /*로그인 2시간전*/ top 1 CASE WHEN DATEDIFF(mi  , regdate , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from S4_LOGINIPINFO
									where regdate >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN = 'SS'
									ORDER BY regdate DESC) ,'Y')


		SELECT @LOGIN_GB_THECARD = isnull((select /*로그인 2시간전*/ top 1 CASE WHEN DATEDIFF(mi  , regdate , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from S4_LOGINIPINFO
									where regdate >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN = 'ST'
									ORDER BY regdate DESC) ,'Y')


		SELECT @LOGIN_GB_JEHU = isnull((select /*로그인 2시간전*/ top 1 CASE WHEN DATEDIFF(mi  , regdate , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from S4_LOGINIPINFO
									where regdate >= dateadd(hh, -2, GETDATE())
									AND SALES_GUBUN IN ('B','C','H')
									ORDER BY regdate DESC) ,'Y')



	
		--★회원가입★--
		SELECT @REGIST_GB_BHANDS = isnull((select /*회원가입 2시간전*/top 1 CASE WHEN DATEDIFF(mi  , reg_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from vw_user_info
									where reg_date >= dateadd(hh, -2, GETDATE())
									AND site_div = 'SA'
									ORDER BY reg_date DESC) ,'Y')



		SELECT @REGIST_GB_BARUNN = isnull((select /*회원가입 2시간전*/top 1 CASE WHEN DATEDIFF(mi  , reg_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from vw_user_info
									where reg_date >= dateadd(hh, -2, GETDATE())
									AND site_div = 'SB'
									ORDER BY reg_date DESC) ,'Y')



		SELECT @REGIST_GB_PREMIER = isnull((select /*회원가입 2시간전*/top 1 CASE WHEN DATEDIFF(mi  , reg_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from vw_user_info
									where reg_date >= dateadd(hh, -2, GETDATE())
									AND site_div = 'SS'
									ORDER BY reg_date DESC) ,'Y')



		SELECT @REGIST_GB_THECARD = isnull((select /*회원가입 2시간전*/top 1 CASE WHEN DATEDIFF(mi  , reg_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from vw_user_info
									where reg_date >= dateadd(hh, -2, GETDATE())
									AND site_div = 'ST'
									ORDER BY reg_date DESC) ,'Y')


		SELECT @REGIST_GB_JEHU = isnull((select /*회원가입 2시간전*/top 1 CASE WHEN DATEDIFF(mi  , reg_date , GETDATE()) > 120 THEN 'Y' ELSE 'N' END
									from vw_user_info
									where reg_date >= dateadd(hh, -2, GETDATE())
									AND site_div IN ('B','C','H')
									ORDER BY reg_date DESC) ,'Y')


		
		SET @SMS_SEND_GB = 'Y';


		--PRINT '@SMS_SEND_GB=' + @SMS_SEND_GB
		--PRINT '@SAMPLE_ORDER_GB=' + @SAMPLE_ORDER_GB
		--PRINT '@ORDER_GB=' + @ORDER_GB

		----★문자전송 : 샘플/카드주문--------------------------------------------------------------------------------------------------------------------------

		--비핸즈
		
		if @SMS_SEND_GB = 'Y' and (@SAMPLE_ORDER_GB_BHANDS = 'Y' and @ORDER_GB_BHANDS = 'Y')
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_F_BHANDS)
						*/

						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_F_BHANDS, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
									
					END

			END


		
		--바른손
		if @SMS_SEND_GB = 'Y' and (@SAMPLE_ORDER_GB_BARUNN = 'Y' and @ORDER_GB_BARUNN = 'Y')
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_F_BARUNN)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_F_BARUNN, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
								
					END

			END


		--프리미어
		if @SMS_SEND_GB = 'Y' and (@SAMPLE_ORDER_GB_PREMIER = 'Y' and @ORDER_GB_PREMIER = 'Y')
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_F_PREMIER)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_F_PREMIER, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
						
					END

			END


		--더카드
		if @SMS_SEND_GB = 'Y' and (@SAMPLE_ORDER_GB_THECARD = 'Y' and @ORDER_GB_THECARD = 'Y')
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_F_THECARD)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_F_THECARD, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
									
					END

			END

	
		if @SMS_SEND_GB = 'Y' and (@SAMPLE_ORDER_GB_JEHU = 'Y' and @ORDER_GB_JEHU = 'Y')
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_F_JEHU)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_F_JEHU, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
															
					END

			END
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------








		----★문자전송 : 로그인--------------------------------------------------------------------------------------------------------------------------

		--비핸즈
		if @SMS_SEND_GB = 'Y' and @LOGIN_GB_BHANDS = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_L_BHANDS)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_L_BHANDS, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
									
					END

			END




		--바른손
		if @SMS_SEND_GB = 'Y' and @LOGIN_GB_BARUNN = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_L_BARUNN)
						*/									
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_L_BARUNN, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
						

					END

			END


		if @SMS_SEND_GB = 'Y' and @LOGIN_GB_PREMIER = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_L_PREMIER)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_L_PREMIER, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
							
					END

			END

	
		if @SMS_SEND_GB = 'Y' and @LOGIN_GB_THECARD = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_L_THECARD)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_L_THECARD, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
						
					END

			END


		if @SMS_SEND_GB = 'Y' and @LOGIN_GB_JEHU = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_L_JEHU)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_L_JEHU, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
						
					END

			END
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------


		----★문자전송 : 회원가입--------------------------------------------------------------------------------------------------------------------------

		--비핸즈
		if @SMS_SEND_GB = 'Y' and @REGIST_GB_BHANDS = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_R_BHANDS)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_R_BHANDS, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
							
					END

			END


		--바른손
		if @SMS_SEND_GB = 'Y' and @REGIST_GB_BARUNN = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_R_BARUNN)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_R_BARUNN, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
							
					END

			END

		--프리미어
		if @SMS_SEND_GB = 'Y' and @REGIST_GB_PREMIER = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_R_PREMIER)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_R_PREMIER, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
							
					END

			END


		--더카드
		if @SMS_SEND_GB = 'Y' and @REGIST_GB_THECARD = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_R_THECARD)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_R_THECARD, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
							
					END

			END

		--제휴
		if @SMS_SEND_GB = 'Y' and @REGIST_GB_JEHU = 'Y' 
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						--PRINT '1-' + @TMP_SMS_NUM

						/*
						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , @SMS_MSG_R_JEHU)
						*/
						----------------------------------------------------------------------------------
						-- KT
						----------------------------------------------------------------------------------
						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM
												
						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, '', @SMS_MSG_R_JEHU, @RESERVATION_DATE, '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
							
					END

			END
		
		---------------------------------------------------------------------------------------------------------------------------------------------------------



	SET NOCOUNT OFF;

END
GO
