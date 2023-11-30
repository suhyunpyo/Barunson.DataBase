IF OBJECT_ID (N'dbo.SP_INSERT_CELEMO_COUPON_EVENT1', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_CELEMO_COUPON_EVENT1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2017-03-10
-- Description:	셀레모 꿀 떨어지는 이벤트

-- EXEC 회원아이디
-- EXEC dbo.SP_INSERT_CELEMO_COUPON_EVENT1 's5guest'
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_CELEMO_COUPON_EVENT1]
	@UID		AS VARCHAR(50)
AS
BEGIN
	
	DECLARE  @MEMBER_SEQ    AS INT
	DECLARE  @OPEN_QUERY    AS NVARCHAR(4000)
	DECLARE  @COUPON_CNT	AS INT
	DECLARE  @COUPON_CODE   AS NVARCHAR(50)

	SET @COUPON_CODE = 'BRSCELEMO2017';

	SELECT	@COUPON_CNT = count(*)
	FROM	S4_MyCoupon
	WHERE	UID = @UID AND COUPON_CODE = @COUPON_CODE;

	IF @COUPON_CNT = 0 
		BEGIN
			INSERT INTO S4_MyCoupon (COUPON_CODE, UID, COMPANY_SEQ, isMyYN, END_DATE) VALUES (@COUPON_CODE, @UID, 5001, 'Y', DATEADD(month,1,GETDATE()))
	END

	-- 회원 MEMBER_SEQ 검색
	SET @OPEN_QUERY = 'SELECT @temp = member_seq FROM OPENQUERY(CELEMO,''SELECT member_seq FROM fm_member WHERE userid='''''+@UID+''''''')'
	EXEC sp_executesql  @OPEN_QUERY, N'@temp INT output', @temp = @MEMBER_SEQ output
	
	-- 발급된 쿠폰이 있는 지 검색
	IF @MEMBER_SEQ IS NOT NULL
	BEGIN	

		SET @OPEN_QUERY = 'SELECT @temp = cnt FROM OPENQUERY(CELEMO, ''SELECT count(download_seq) as cnt FROM fm_download WHERE member_seq='+CONVERT(CHAR(10), @MEMBER_SEQ)+' and coupon_seq = 70'')';
		EXEC sp_executesql  @OPEN_QUERY, N'@temp INT output', @temp = @COUPON_CNT output
		
		-- 쿠폰발급
		IF @COUPON_CNT = 0 
		BEGIN
			-- 베스트 TEN제품 할인쿠폰 coupon_seq : 70 
			INSERT OPENQUERY(CELEMO,'SELECT
member_seq,coupon_seq,type,offline_type,offline_emoney,coupon_name,coupon_desc,sale_type,percent_goods_sale,max_percent_goods_sale,shipping_type,max_percent_shipping_sale,won_shipping_sale,issue_type,issue_goods_type,issue_category_type,issue_startdate,issue_enddate,duplication_use,limit_goods_price,use_status,use_date,regist_date,offline_input_serialnumber,coupon_point,coupon_same_time,salescost_admin,salescost_provider,provider_list,use_type,sale_agent,sale_payment,sale_referer,sale_referer_item,sale_referer_type,down_year,cart_option_seq FROM fm_download') VALUES (CONVERT(CHAR(10), @MEMBER_SEQ),70,'order','random','0','베스트 TEN제품 할인쿠폰','베스트 TEN제품 할인쿠폰','won',null,null,'free',0,'0','issue','all','all',GETDATE(),DateAdd("m",1,GETDATE()),'0','0','unused','',GETDATE(),'','','N',100,0,'','online','a','a','a','','a',0,-1);

			-- 본사상품 한정상품 적용
			DECLARE		@DOWNLOAD_SEQ				AS INT
			SET @OPEN_QUERY = 'SELECT @temp = download_seq FROM OPENQUERY(CELEMO,''SELECT download_seq FROM fm_download WHERE member_seq='+CONVERT(CHAR(10), @MEMBER_SEQ)+' AND coupon_seq = 70'')'
			EXEC sp_executesql  @OPEN_QUERY, N'@temp INT output', @temp = @DOWNLOAD_SEQ output

			IF @DOWNLOAD_SEQ <> 0
			BEGIN
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,2005, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1990, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1989, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1988, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1987, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1986, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1985, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1984, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1983, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1982, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1981, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1980, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1974, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1957, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1956, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1955, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1954, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1953, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1952, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1950, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1927, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1926, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1925, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1923, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1704, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1702, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1598, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1583, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1582, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1580, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1579, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1578, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1576, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1491, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1490, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1489, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1488, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1486, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1485, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1483, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1482, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1481, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1479, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1478, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1477, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1476, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1474, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1473, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1472, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1471, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1468, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1447, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1446, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1444, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1443, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1442, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1441, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1439, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1438, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1437, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1435, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1434, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1426, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1425, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1423, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1422, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1421, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1420, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1419, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1299, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1297, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1296, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1294, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1293, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1289, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1284, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1281, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1280, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1279, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1278, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1161, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1146, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1145, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1105, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1087, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1084, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1082, 'issue');									
				INSERT OPENQUERY(CELEMO,'SELECT download_seq, goods_seq, type FROM fm_download_issuegoods') VALUES (@DOWNLOAD_SEQ,1081, 'issue');									

			END
		END
	END
	
END
GO
