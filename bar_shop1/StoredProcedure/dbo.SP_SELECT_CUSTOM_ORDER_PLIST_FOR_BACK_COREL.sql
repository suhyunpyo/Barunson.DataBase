IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_ORDER_PLIST_FOR_BACK_COREL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_ORDER_PLIST_FOR_BACK_COREL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
 EXEC SP_SELECT_CUSTOM_ORDER_PLIST_FOR_BACK_COREL 2553613, 8262919  
 EXEC SP_SELECT_CUSTOM_ORDER_PLIST_FOR_BACK_COREL 2901873, 0


 select * from custom_order_plist where order_seq = 2901873


update custom_order_plist set print_count =0 where order_seq = 2901873 and id =9909005
update custom_order_plist set print_count =50 , isNotPrint = 0 where order_seq = 2901873 and id =9909005


*/  
  
CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_ORDER_PLIST_FOR_BACK_COREL]  
    @P_ORDER_SEQ AS INT  
,   @P_PAGE_NAME AS INT = 0  
AS  
BEGIN  
   
    --CS업무 #5353 [디얼디어] 주문시 신랑신부 봉투 인쇄 안함에 백봉투 주문인데 초안 작성 진행
	--초안생성 시 인쇄판(custom_order_plist)의 인쇄수량(print_count)이 0 인경우 인쇄안함(isNotPrint : 1)으로 변경.
	
	SET NOCOUNT ON 
		UPDATE custom_order_plist SET isNotPrint = 1 
		WHERE order_seq = @P_ORDER_SEQ
		AND print_count = 0 
		AND isNotPrint = 0 -- 0: 인쇄 / 1: 인쇄안함
	SET NOCOUNT OFF
	
    SELECT  A.ID  
        ,   A.PRINT_TYPE  
        ,   A.ISFPRINT  
        ,   A.ISNOTPRINT  
        ,   A.CARD_SEQ  
        ,   A.TITLE  
        ,   A.ETC_COMMENT  
        ,   ISNULL(A.UP_ID,0) AS UP_ID  
        ,   B.OLD_CODE AS OLD_CARD_CODE  
        ,   ISNULL(A.ENV_ZIP,'000000') AS DIFF_CODE 

        ,   CASE 
			WHEN A.PRINT_TYPE IN ('C', 'P','I') AND B.ERP_CODE IN (SELECT ERP_CODE FROM S2_CardCorelTemplateInfo)  
                 THEN B.OLD_CODE  
			/* 공통내지 조건 추가 20210827 */
			WHEN A.PRINT_TYPE = 'G' OR (A.PRINT_TYPE = 'I' and (select count(1) from HardCodingList where HardUse = 'Y' and HardID = 'SHARE_IN_PAPER' AND HardCode = B.card_code) > 0) THEN (select card_code from s2_card where card_seq = o.card_seq)
            ELSE B.ERP_CODE  
            END AS CARD_CODE  
        
        ,   ISNULL(
                (
                    SELECT  ISNULL(AUTO_CHOAN_REGISTER_YORN, 'N')
                    FROM    CARD_COREL 
                    WHERE   CARD_CODE = (
                                            CASE WHEN A.PRINT_TYPE IN ('C', 'P') AND B.ERP_CODE IN ( SELECT ERP_CODE FROM S2_CardCorelTemplateInfo )  
                                                 THEN B.OLD_CODE  
                                            ELSE B.ERP_CODE  
                                            END
                                        )
                ), 'N') AS AUTO_CHOAN_REGISTER_YORN
        ,   ISNULL(A.EnvSpecialType, '') AS EnvSpecialType
		, B.FPrint_YORN
		, O.order_type
    FROM    CUSTOM_ORDER_PLIST A   
    INNER JOIN S2_CARDVIEWN B ON A.CARD_SEQ = B.CARD_SEQ  
	INNER JOIN CUSTOM_ORDER O ON A.ORDER_SEQ = O.ORDER_SEQ
    WHERE   1 = 1  
    AND     A.ORDER_SEQ = @P_ORDER_SEQ  
    AND     A.ISNOTPRINT <> '1'  
    AND     A.PRINT_COUNT > 0  
    AND     (@P_PAGE_NAME = 0 OR A.ID = @P_PAGE_NAME)  

    ORDER BY A.ID ASC  
  
END
GO
