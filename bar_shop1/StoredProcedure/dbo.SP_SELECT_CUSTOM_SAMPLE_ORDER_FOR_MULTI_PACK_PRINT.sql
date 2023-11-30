IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_MULTI_PACK_PRINT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_MULTI_PACK_PRINT
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

/*

EXEC SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_MULTI_PACK_PRINT 1365100

*/

CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_SAMPLE_ORDER_FOR_MULTI_PACK_PRINT]
	@P_SAMPLE_ORDER_SEQ AS INT
AS
BEGIN
    
	SET NOCOUNT ON;

	SELECT  CSO.COMPANY_SEQ 
        ,   CSO.SALES_GUBUN 
        ,   CSO.MEMBER_NAME 
        ,   ISNULL(CAST(CSO.MEMBER_FAX AS VARCHAR(50)), '') AS MEMBER_FAX
        ,   ISNULL(CAST(CSO.MULTI_PACK_SEQ AS VARCHAR(50)), '') AS MULTI_PACK_SEQ
        ,   ISNULL(CAST(CSO.MULTI_PACK_SUB_SEQ AS VARCHAR(50)), '') AS MULTI_PACK_SUB_SEQ
        ,   ISNULL((SELECT CAST(MAX(MULTI_PACK_SUB_SEQ) AS VARCHAR(50)) FROM CUSTOM_SAMPLE_ORDER WHERE LEFT(MEMBER_FAX, 14) = LEFT(CSO.MEMBER_FAX, 14)), '') AS MAX_MULTI_PACK_SUB_SEQ 
        ,   CASE 
                    WHEN CSO.SALES_GUBUN = 'SB' THEN '1644-0708' 
                    WHEN CSO.SALES_GUBUN = 'SA' THEN '1644-9713' 
                    WHEN CSO.SALES_GUBUN = 'ST' THEN '1644-7998' 
                    WHEN CSO.SALES_GUBUN = 'SS' THEN '1644-8796' 
                    ELSE '1644-0708' 
            END AS CALL_CENTER_NUMBER 
        ,   CASE 
                    WHEN CSO.SALES_GUBUN = 'SB' THEN '바른손카드' 
                    WHEN CSO.SALES_GUBUN = 'SA' THEN '비핸즈카드' 
                    WHEN CSO.SALES_GUBUN = 'ST' THEN '더카드' 
                    WHEN CSO.SALES_GUBUN = 'SS' THEN '프리미어' 
                    ELSE '1644-0708' 
            END AS SITE_NAME
		,   CASE 
                    WHEN CSO.SALES_GUBUN = 'SB' THEN '' 
                    WHEN CSO.SALES_GUBUN = 'SA' THEN '' 
                    WHEN CSO.SALES_GUBUN = 'ST' THEN '' 
                    WHEN CSO.SALES_GUBUN = 'SS' THEN '※ 프리미어페이퍼 제품은 위의 제작 과정과 상이하니 꼭 사이트에서 일정 확인 부탁드립니다.' 
                    ELSE '' 
            END AS SITE_ETC_MESSAGE
		,   CASE 
                    WHEN CSO.SALES_GUBUN = 'SB' THEN '바른손카드 고객센터 1644-0708 www.barunsoncard.com' 
                    WHEN CSO.SALES_GUBUN = 'SA' THEN '비핸즈카드 고객센터 1644-9713 www.bhandscard.com' 
                    WHEN CSO.SALES_GUBUN = 'ST' THEN '더카드 고객센터 1644-7998 www.thecard.com' 
                    WHEN CSO.SALES_GUBUN = 'SS' THEN '프리미어페이퍼 고객센터 1644-8796 www.premierpaper.co.kr' 
                    ELSE '' 
            END AS SITE_INFO_MESSAGE
		,   CASE 
                    WHEN CSO.SALES_GUBUN = 'SB' THEN 'Z:\Sasik_Work\card_img\logo_barunsoncard.jpg' 
                    WHEN CSO.SALES_GUBUN = 'SA' THEN 'Z:\Sasik_Work\card_img\logo_bhandscard.jpg' 
                    WHEN CSO.SALES_GUBUN = 'ST' THEN 'Z:\Sasik_Work\card_img\logo_thecard.jpg' 
                    WHEN CSO.SALES_GUBUN = 'SS' THEN 'Z:\Sasik_Work\card_img\logo_premierpaper.jpg' 
                    ELSE 'Z:\Sasik_Work\card_img\logo_barunsoncard.jpg' 
            END AS SITE_LOGO_IMAGE_FULL_PATH
    FROM    CUSTOM_SAMPLE_ORDER CSO 
    WHERE   SAMPLE_ORDER_SEQ = @P_SAMPLE_ORDER_SEQ
    
END
GO
