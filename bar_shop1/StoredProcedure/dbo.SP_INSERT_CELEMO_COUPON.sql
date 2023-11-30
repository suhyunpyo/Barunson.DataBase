IF OBJECT_ID (N'dbo.SP_INSERT_CELEMO_COUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_CELEMO_COUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2017-02-03
-- Description:	셀레모 쿠폰 다운로드

-- EXEC 회원아이디
-- EXEC dbo.SP_INSERT_CELEMO_COUPON 's5guest', 5001
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_CELEMO_COUPON]
	@UID		AS VARCHAR(50)
	,@COMPANY_SEQ AS VARCHAR(50)
AS
BEGIN
	
	DECLARE  @MEMBER_SEQ    AS INT
	DECLARE  @OPEN_QUERY    AS NVARCHAR(4000)
	DECLARE  @COMPANY_STR   AS NVARCHAR(1000)

	--문자구분추가로직
	IF @COMPANY_SEQ = '5001'
		BEGIN
			SET @COMPANY_STR = '바른손'
		END 
	ELSE IF @COMPANY_SEQ = '5007'
		BEGIN
			SET @COMPANY_STR = '더카드'
		END 
	ELSE 
		BEGIN
			SET @COMPANY_STR = '비핸즈'
		END

	-- 회원 MEMBER_SEQ 검색
	SET @OPEN_QUERY = 'SELECT @temp = member_seq FROM OPENQUERY(CELEMO,''SELECT member_seq FROM fm_member WHERE userid='''''+@UID+''''''')'
	EXEC sp_executesql  @OPEN_QUERY, N'@temp INT output', @temp = @MEMBER_SEQ output
	
	-- 발급된 쿠폰이 있는 지 검색
	IF @MEMBER_SEQ IS NOT NULL
	BEGIN	

		DECLARE		@COUPON_CNT				AS INT

		SET @OPEN_QUERY = 'SELECT @temp = cnt FROM OPENQUERY(CELEMO, ''SELECT count(download_seq) as cnt FROM fm_download WHERE member_seq='+CONVERT(CHAR(10), @MEMBER_SEQ)+' and coupon_seq in (62,63)'')';
		EXEC sp_executesql  @OPEN_QUERY, N'@temp INT output', @temp = @COUPON_CNT output
		
		-- 쿠폰발급
		IF @COUPON_CNT = 0 
		BEGIN

			-- 5%특별할인쿠폰 coupon_seq : 63	
			INSERT OPENQUERY(CELEMO,'SELECT member_seq,coupon_seq,type,offline_type,offline_emoney,coupon_name,coupon_desc,sale_type,percent_goods_sale,max_percent_goods_sale,shipping_type,max_percent_shipping_sale,won_shipping_sale,issue_type,issue_goods_type,issue_category_type,issue_startdate,issue_enddate,duplication_use,limit_goods_price,use_status,use_date,regist_date,offline_input_serialnumber,coupon_point,coupon_same_time,salescost_admin,salescost_provider,provider_list,use_type,sale_agent,sale_payment,sale_referer,sale_referer_item,sale_referer_type,down_year,cart_option_seq FROM fm_download') VALUES (CONVERT(CHAR(10), @MEMBER_SEQ),63,'member','random','0','5%특별할인쿠폰','5%특별할인쿠폰','percent',5,'30000','free',0,'0','all','all','all',GETDATE(),DateAdd("m",1,GETDATE()),'1','100000','unused','',GETDATE(),'','','N',100,0,'','online','a','a','a','','a',0,-1);

			-- 본사상품 10% 특별할인 coupon_seq : 62 
			/*INSERT OPENQUERY(CELEMO,'SELECT
member_seq,coupon_seq,type,offline_type,offline_emoney,coupon_name,coupon_desc,sale_type,percent_goods_sale,max_percent_goods_sale,shipping_type,max_percent_shipping_sale,won_shipping_sale,issue_type,issue_goods_type,issue_category_type,issue_startdate,issue_enddate,duplication_use,limit_goods_price,use_status,use_date,regist_date,offline_input_serialnumber,coupon_point,coupon_same_time,salescost_admin,salescost_provider,provider_list,use_type,sale_agent,sale_payment,sale_referer,sale_referer_item,sale_referer_type,down_year,cart_option_seq FROM fm_download') VALUES (CONVERT(CHAR(10), @MEMBER_SEQ),62,'member','random','0','본사상품 10% 특별할인','본사상품 10% 특별할인','percent',10,'100000','free',0,'0','issue','all','all',GETDATE(),DateAdd("m",1,GETDATE()),'1','100000','unused','',GETDATE(),'','','N',100,0,'','online','a','a','a','','a',0,-1);

			-- 본사상품 한정상품 적용
			DECLARE		@DOWNLOAD_SEQ				AS INT
			SET @OPEN_QUERY = 'SELECT @temp = download_seq FROM OPENQUERY(CELEMO,''SELECT download_seq FROM fm_download WHERE member_seq='+CONVERT(CHAR(10), @MEMBER_SEQ)+' AND coupon_seq = 62'')'
			EXEC sp_executesql  @OPEN_QUERY, N'@temp INT output', @temp = @DOWNLOAD_SEQ output

			IF @DOWNLOAD_SEQ <> 0
			BEGIN
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1583, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1582, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1580, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1579, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1578, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1105, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1952, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1950, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1296, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1289, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1421, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1420, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1419, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1598, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1082, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1081, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1299, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1281, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1283, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1297, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1282, 'issue');
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ, 1284, 'issue');
			END */
			-- 문자메세지 전송
			DECLARE		@MSG							AS	VARCHAR(150) = ''
			DECLARE		@SUBJECT						AS	VARCHAR(50) = ''
			DECLARE		@USERPHONE						AS	VARCHAR(50) = ''

			SELECT	TOP 1 @USERPHONE = HPHONE
			FROM	VW_USER_INFO
			WHERE	UID = @UID

			SET	@SUBJECT	=	'[셀레모] 쿠폰이 발급되었습니다.'
			SET	@MSG		=	@COMPANY_STR + '에서 드리는 답례품 혜택' + CHAR(10)+ '▷ 전상품 5% 특별할인쿠폰' + CHAR(10) + ' 마이페이지 > 쿠폰보관함에서' + CHAR(10)+ ' 확인가능' + CHAR(10) +'http://www.celemo.co.kr';

			INSERT INTO invtmng.MMS_MSG(SUBJECT, PHONE, CALLBACK, STATUS, REQDATE, MSG, TYPE) VALUES (@SUBJECT, @USERPHONE, '1644-7998', '0', GETDATE(), @MSG, '0')

		END
	END
	
END
GO
