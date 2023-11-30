IF OBJECT_ID (N'dbo.SP_SELECT_USER_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_USER_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- EXEC [SP_SELECT_CHOAN_DELAY_RATE] '2013-12-01', '2013-12-31', 'Y'

CREATE PROCEDURE [dbo].[SP_SELECT_USER_LIST]
	@p_start_date AS VARCHAR(10)
,	@p_end_date AS VARCHAR(10)
,   @p_order_type AS CHAR(1)

AS
BEGIN

select distinct  A.SITE_DIV
  , CASE SITE_DIV WHEN 'SB' THEN '바른손카드'
      WHEN 'SS' THEN '프리미어페이퍼'
      WHEN 'H' THEN '프리미어 제휴'
      WHEN 'SA' THEN '비핸즈카드'
      WHEN 'B' THEN '비핸즈 제휴'
      WHEN 'ST' THEN '더카드'
    ELSE '기타' END AS SITE_DIV_NAME
  , A.reg_date
  , A.uid
  , A.uname
  , A.HPHONE
  , ISNULL(A.wedd_year, '')+'-'+RIGHT('0' + ISNULL(A.wedd_month, ''), 2)+'-'+RIGHT('0' + ISNULL(A.wedd_day, ''), 2) AS WEDD_DAY
  , CASE WHEN ISNULL(B.seq, 0) = 0 THEN 'N' ELSE 'Y' END AS 마케팅동의여부
  , A.chk_sms
  ,address
  , birth
from (
   SELECT  uid, pwd, uname, umail, DupInfo, ConnInfo, ISNULL(wedd_year, '') AS WEDD_YEAR,
         RIGHT('0' + ISNULL(wedd_month, ''), 2) AS WEDD_MONTH, RIGHT('0' + ISNULL(wedd_day, ''), 2)
         AS WEDD_DAY, site_div, chk_sms, chk_mailservice,
         hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE,
         phone1 + '-' + phone2 + '-' + phone3 AS PHONE, zip1 + '-' + zip2 AS ZIPCODE, isJehu, zip1, zip2,
         address, addr_detail, INTEGRATION_MEMBER_YORN, USE_YORN, reg_date, birth
   FROM     dbo.S2_UserInfo
   WHERE chk_sms = 'Y'
   UNION ALL
   SELECT  uid, pwd, uname, umail, DupInfo, ConnInfo, ISNULL(wedd_year, '') AS WEDD_YEAR,
         RIGHT('0' + ISNULL(wedd_month, ''), 2) AS WEDD_MONTH, RIGHT('0' + ISNULL(wedd_day, ''), 2)
         AS WEDD_DAY, site_div, chk_sms, chk_mailservice,
         hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE,
         phone1 + '-' + phone2 + '-' + phone3 AS PHONE, zip1 + '-' + zip2 AS ZIPCODE, isJehu, zip1, zip2,
         address, addr_detail, INTEGRATION_MEMBER_YORN, USE_YORN, reg_date, birth
   FROM     dbo.S2_UserInfo_BHands
   WHERE chk_sms = 'Y'
   UNION ALL
   SELECT  uid, pwd, uname, umail, DupInfo, ConnInfo, ISNULL(wedd_year, '') AS WEDD_YEAR,
         RIGHT('0' + ISNULL(wedd_month, ''), 2) AS WEDD_MONTH, RIGHT('0' + ISNULL(wedd_day, ''), 2)
         AS WEDD_DAY, site_div, chk_sms, chk_mailservice,
         hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE,
         phone1 + '-' + phone2 + '-' + phone3 AS PHONE, zip1 + '-' + zip2 AS ZIPCODE, isJehu, zip1, zip2,
         address, addr_detail, INTEGRATION_MEMBER_YORN, USE_YORN, reg_date, birth
   FROM     dbo.S2_UserInfo_TheCard
   WHERE site_div = 'ST'
   AND chk_sms = 'Y'
) A
 LEFT OUTER JOIN s4_event_raina AS B   
	ON A.uid = B.uid 
	and b.event_div = 'MKevent'
 WHERE 1 = 1
  AND   CASE 
				WHEN @p_order_type = 'WED' THEN A.wedd_year+'-'+A.wedd_month+'-'+A.wedd_day 
				WHEN @p_order_type = 'REG' THEN A.reg_date
				ELSE ''
		END between '' + @p_start_date  and '' + @p_end_date

/*
 AND (CASE WHEN @p_order_type = 'WED' THEN  A.wedd_year+'-'+A.wedd_month+'-'+A.wedd_day  
      ELSE A.reg_date
	  END  between '' + @p_start_date  and '' + @p_end_date )
*/
-- CASE @p_order_type WHEN 'WED' THEN
-- AND (A.wedd_year+'-'+A.wedd_month+'-'+A.wedd_day  between  '2015-10-01'  and  '2015-10-10' )
-- ELSE
-- AND (A.reg_date  between  '2015-10-01'  and  '2015-10-10' )
-- END 

  --AND site_div = 'SB' 
 ORDER BY site_div , SITE_DIV_NAME

 
END


GO
