IF OBJECT_ID (N'dbo.SP_WEDDING_COUPON_SMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_WEDDING_COUPON_SMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================================================================================================
-- Description:	식전영상 잔여 쿠폰여부
-- =============================================================================================================================
CREATE PROCEDURE [dbo].[SP_WEDDING_COUPON_SMS] 
AS
BEGIN

	DECLARE @couponCnt1 INT -- 바른손
	DECLARE @couponCnt2 INT -- 비핸즈
	DECLARE @couponCnt3 INT -- 더카드
	DECLARE @couponCnt4 INT -- 프리미어
	DECLARE @couponCnt5 INT -- 제휴

	DECLARE @couponCnt6 INT -- 바른손 웨딩초대영상 쿠폰
	DECLARE @couponCnt7 INT -- 프페 웨딩초대영상 쿠폰
	DECLARE @couponCnt8 INT -- 제휴 감사영상 쿠폰


	DECLARE @couponCnt9 INT -- 바른손 감사영상 쿠폰
	DECLARE @couponCnt10 INT -- 비핸즈 감사영상 쿠폰
	DECLARE @couponCnt11 INT -- 더카드 감사영상 쿠폰
	DECLARE @couponCnt12 INT -- 프리미어 감사영상 쿠폰

	DECLARE @SMS_NUM AS VARCHAR(200);		--SMS전송 번호

	DECLARE @TMP_SMS_NUM AS VARCHAR(200);	--실제저장변수
	DECLARE @STR_SMS_NUM AS VARCHAR(200);	--반복문사용변수
	DECLARE @splitStr AS VARCHAR(1);		--문자열구분자(|)
	DECLARE @DEST_INFO AS VARCHAR(100)	
	
	SET @SMS_NUM			= '010-9487-2411|010-3755-9609|010-0000-0000'; -- 강은지|이선주
	SET @splitStr			= '|';
	SET @STR_SMS_NUM		= @SMS_NUM;

	SET NOCOUNT ON;

		--★잔여 식전영상 쿠폰수(필메이커로 변경) ★--

		-- 바른손 --
		select  @couponCnt1 = COUNT(*) from COUPON_DETAIL where COUPON_mst_SEQ = 301 and DOWNLOAD_ACTIVE_YN ='Y'
	
		-- 프리미어 --
		select  @couponCnt4 = COUNT(*) from COUPON_DETAIL  where COUPON_mst_SEQ = 291 and DOWNLOAD_ACTIVE_YN ='Y'

		-- 제휴--
		Select  @couponCnt5 = count(coupon_code) 
		From S4_COUPON Where coupon_type_code = '114008' and isYN = 'Y' and reg_date >= '2021-04-12'

		-- 바른손 웨딩초대 --
		select  @couponCnt6 = COUNT(*) from COUPON_DETAIL  where COUPON_mst_SEQ = 304 and DOWNLOAD_ACTIVE_YN ='Y'

		-- 프리미어 웨딩초대 --
		select  @couponCnt7 = COUNT(*) from COUPON_DETAIL  where COUPON_mst_SEQ = 292 and DOWNLOAD_ACTIVE_YN ='Y'

		-- 제휴 감사쿠폰 --
		Select  @couponCnt8 = count(coupon_code) From S4_COUPON Where coupon_type_code = '114013' and isYN = 'Y' 
		
		-- 바른손 --
		select  @couponCnt9 = COUNT(*) from COUPON_DETAIL where COUPON_mst_SEQ = 627 and DOWNLOAD_ACTIVE_YN ='Y'

		-- 프리미어 --
		select  @couponCnt12 = COUNT(*) from COUPON_DETAIL  where COUPON_mst_SEQ = 626 and DOWNLOAD_ACTIVE_YN ='Y'


		----★문자전송 --------------------------------------------------------------------------------------------------------------------------

		--바른손
		if (@couponCnt1 < 150 )
			BEGIN

				WHILE CharIndex(@splitStr, @SMS_NUM, 0) > 0
					BEGIN
						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[확인요망]바른손 : 식전영상쿠폰 등록하세요.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

					END

			END



		if (@couponCnt6 < 150 )
			BEGIN

				WHILE CharIndex(@splitStr, @SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[확인요망]바른손 : 웨딩초대영상쿠폰 등록하세요.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

					END

			END
			

		--바른손 감사영상
		if (@couponCnt9 < 150 )
			BEGIN

				WHILE CharIndex(@splitStr, @SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[확인요망]바른손 : 감사영상쿠폰 등록하세요.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
					END

			END		
	
		
		--프리미어
		if (@couponCnt4 < 100)
			BEGIN

				WHILE CharIndex(@splitStr, @SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[확인요망]프리미어 : 식전영상쿠폰 등록하세요.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
					END

			END

		--프리미어 웨딩초대영상 쿠폰
		if (@couponCnt7 < 100)
			BEGIN

				WHILE CharIndex(@splitStr, @SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[확인요망]프리미어 : 웨딩초대영상쿠폰 등록하세요.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
					END

			END


		if (@couponCnt12 < 100)
			BEGIN

				WHILE CharIndex(@splitStr, @SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[확인요망]프리미어 : 웨딩초대영상쿠폰 등록하세요.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
					END

			END


		--제휴
		if (@couponCnt5 < 150)
			BEGIN

				WHILE CharIndex(@splitStr, @SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[확인요망]바른손몰 : 식전영상쿠폰 등록하세요.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

					END

			END


		if (@couponCnt8 < 150)
			BEGIN

				WHILE CharIndex(@splitStr, @SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))

						SET @DEST_INFO = 'AA^' + @TMP_SMS_NUM

						EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[확인요망]바른손몰 : 감사영상쿠폰 등록하세요.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

					END

			END


	SET NOCOUNT OFF;

END
GO
