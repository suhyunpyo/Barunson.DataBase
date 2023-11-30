IF OBJECT_ID (N'dbo.SP_INSERT_FREE_GIFT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_FREE_GIFT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
#5086 or #5116  <--검색시 수정 부분 확인 가능
--3013675
--BH0601
--1.사은품제거
delete from CUSTOM_ORDER_Item where order_seq = 3013675 and item_type IN ('H','Z')

select * from CUSTOM_ORDER_ITEM where card_seq in('37869','37861')
select * from S2_CARD_FREE_GIFT where card_seq in('37869','37861')

delete from CUSTOM_ORDER_ITEM where card_seq in('37869','37861')
update S2_CARD_FREE_GIFT set qty = 200 where card_seq = 37869
update  S2_CARD_FREE_GIFT set qty = 300 where card_seq = 37861

--2.사은품발급
SP_INSERT_FREE_GIFT 3013675

--3.테스트결과 조회
select order_seq,item_type,(select code_value from manage_code where code = item_type and code_type = 'item_type' ) item_type_name
,item_count,item_sale_price,item_count*item_sale_price total_price,a.card_seq,b.card_name,b.Card_Code, a.memo1
from CUSTOM_ORDER_Item a inner join S2_Card b ON a.card_seq = b.card_seq
where order_seq = 3013675
select order_total_price from CUSTOM_ORDER where order_seq = 3013675

update CUSTOM_ORDER set SETTLE_PRICE = 402400 where order_seq = 3013675

update CUSTOM_ORDER set member_id = 'thdxowjd' where order_seq = 3013675
update CUSTOM_ORDER set member_id = 's4guest' where order_seq = 3013675

update CUSTOM_ORDER set status_seq = 0 where order_seq = 3013675

*/    
    
CREATE PROCEDURE [dbo].[SP_INSERT_FREE_GIFT]    
    @ORDER_SEQ                  AS INT    
    
AS    
BEGIN    
    
DECLARE @FREE_GIFT_SEQ AS INT = 0    
DECLARE @FREE_GIFT_CARD_SEQ AS INT = 0    
DECLARE @FREE_GIFT_ITEM_TYPE AS VARCHAR(2) = ''    
DECLARE @TOTAL_QTY AS INT = 0    
DECLARE @COMPANY_SEQ AS INT = 0    
DECLARE @UID AS VARCHAR(50) = ''    
DECLARE @FREE_GIFT_TARGET_YORN AS CHAR(1) = ''    
DECLARE @LIMIT_DELIVERY_REGION_STR AS VARCHAR(500) = ''    
DECLARE @LIMIT_DELIVERY_GU_STR AS VARCHAR(500) = ''    
DECLARE @LIMIT_CARD_BRAND AS VARCHAR(50) = ''  
DECLARE @LIMIT_ORDER_COUNT AS INT = 0    
DECLARE @ORDER_CARD_SEQ AS INT    
DECLARE @ITEM_COUNT AS INT -- custom_order_item 몇개씩 지급할것인가     
DECLARE @MAX_CNT AS INT = 0    
DECLARE @i AS INT = 1    
    
DECLARE @EVENT_REPLY_CNT AS INT = 0    
DECLARE @SALES_GUBUN AS VARCHAR(50) = ''    
DECLARE @MEMBER_ID AS VARCHAR(50) = ''    
DECLARE @FLOW AS INT = 0;    
DECLARE @ORDER_CNT AS INT = 0   
-- 향기카드 이벤트 추가로직    
-- 해당 주문건에대해서 사이트정보를 얻어온다.    
SELECT  
 @SALES_GUBUN = SALES_GUBUN
,@MEMBER_ID   = MEMBER_ID    
FROM CUSTOM_ORDER    
WHERE ORDER_SEQ = @ORDER_SEQ    

/*
1.구매 증정 이벤트 개수 판단
1)이벤트 마스터 정보(S2_CARD_FREE_GIFT)에서 시작일/종료일/진행/잔여갯수
2)주문정보(CUSTOM_ORDER) 기주문/추가주문 제외 /특정 주문 가격 이상만 대상으로 / 특정 주문 수량 이상만 대상으로
*/
SELECT @MAX_CNT = ISNULL(COUNT(*), 0)    
FROM S2_CARD_FREE_GIFT SCFG    
JOIN CUSTOM_ORDER CO ON CO.SALES_GUBUN IN (SELECT value FROM dbo.[ufn_SplitTable] (SCFG.SALES_GUBUN, '|'))    
--특정계정 기간 제약 제외 처리
AND SCFG.START_DATE <= GETDATE()
AND SCFG.END_DATE >= GETDATE() 
--AND SCFG.FREE_GIFT_SEQ NOT IN ('114')
AND SCFG.USE_YORN = 'Y'    
AND SCFG.QTY > 0    
AND (SCFG.LIMIT_ORDER_TYPE_STR = '' or CHARINDEX(CO.ORDER_TYPE, SCFG.LIMIT_ORDER_TYPE_STR, 1 ) > 0)  --1|6|7 청첩장인지 확인
WHERE  1 = 1    
AND CO.ORDER_SEQ = @ORDER_SEQ    
AND CO.UP_ORDER_SEQ IS NULL  --기주문/추가주문 제외
AND ISNULL(SCFG.LIMIT_ORDER_PRICE, 0) <= ISNULL(CO.SETTLE_PRICE, 0) --특정 주문 가격 이상만 대상으로
AND ISNULL(SCFG.LIMIT_ORDER_COUNT, 0) <= ISNULL(CO.ORDER_COUNT, 0) --특정 주문 수량 이상만 대상으로
    
/*
2.구매증정이벤트 개수만큼 반복
*/
WHILE @i <= @MAX_CNT    
BEGIN    
    
    SELECT  
		@FREE_GIFT_SEQ              = A.FREE_GIFT_SEQ    
	,   @FREE_GIFT_CARD_SEQ         = A.FREE_GIFT_CARD_SEQ    
	,   @UID                        = A.UID    
	,   @LIMIT_DELIVERY_REGION_STR  = A.LIMIT_DELIVERY_REGION_STR    
	,   @LIMIT_DELIVERY_GU_STR		= A.LIMIT_DELIVERY_GU_STR    
	,   @FREE_GIFT_ITEM_TYPE        = A.FREE_GIFT_ITEM_TYPE    
	,   @LIMIT_CARD_BRAND           = A.LIMIT_CARD_BRAND    
	,   @ORDER_CARD_SEQ             = A.CARD_SEQ    
	,   @ITEM_COUNT     = A.ITEM_COUNT  
	,	@LIMIT_ORDER_COUNT   = A.LIMIT_ORDER_COUNT 
    FROM   (    
                SELECT  ROW_NUMBER() OVER(ORDER BY REG_DATE ASC) AS ROWNUM    
                    ,   ISNULL(SCFG.FREE_GIFT_SEQ, 0) AS FREE_GIFT_SEQ    
                    ,   ISNULL(SCFG.CARD_SEQ, 0) AS FREE_GIFT_CARD_SEQ    
                    ,   ISNULL(CO.MEMBER_ID, '') AS UID    
                    ,   ISNULL(SCFG.LIMIT_DELIVERY_REGION_STR, '') AS LIMIT_DELIVERY_REGION_STR    
                    ,   ISNULL(SCFG.LIMIT_DELIVERY_GU_STR, '') AS LIMIT_DELIVERY_GU_STR    
                    ,   ISNULL(SCFG.ITEM_TYPE, '') AS FREE_GIFT_ITEM_TYPE    
                    ,   ISNULL(SCFG.LIMIT_CARD_BRAND, '') AS LIMIT_CARD_BRAND    
                    ,   ISNULL(CO.CARD_SEQ, 0) AS CARD_SEQ  
					,   ITEM_COUNT AS ITEM_COUNT  
					,   ISNULL(SCFG.LIMIT_ORDER_COUNT, 0) AS LIMIT_ORDER_COUNT      
				FROM S2_CARD_FREE_GIFT SCFG    
				JOIN CUSTOM_ORDER CO     
				ON CO.SALES_GUBUN IN (SELECT value FROM dbo.[ufn_SplitTable] (SCFG.SALES_GUBUN, '|'))    
				--특정계정 기간 제약 제외 처리
				AND SCFG.START_DATE <= GETDATE()
				AND SCFG.END_DATE >= GETDATE()   
				--AND SCFG.FREE_GIFT_SEQ <> '114'
				AND     SCFG.USE_YORN = 'Y'   
				AND     SCFG.QTY > 0    
				AND (SCFG.LIMIT_ORDER_TYPE_STR = '' or CHARINDEX(CO.ORDER_TYPE, SCFG.LIMIT_ORDER_TYPE_STR, 1 ) > 0)  
                WHERE   1 = 1    
                AND     CO.ORDER_SEQ = @ORDER_SEQ    
                AND     CO.UP_ORDER_SEQ IS NULL    
                AND     ISNULL(SCFG.LIMIT_ORDER_PRICE, 0) <= ISNULL(CO.SETTLE_PRICE, 0)    
                AND     ISNULL(SCFG.LIMIT_ORDER_COUNT, 0) <= ISNULL(CO.ORDER_COUNT, 0)    
            ) A    
    WHERE   A.ROWNUM = @i    
    
	--기존에 해당상품이 제공되지 않은 경우만
    IF NOT EXISTS(SELECT * FROM CUSTOM_ORDER_ITEM WHERE ORDER_SEQ = @ORDER_SEQ AND CARD_SEQ = @FREE_GIFT_CARD_SEQ)    
    BEGIN    
 
     
	--// 프페 : 르셀르 5만원 상품권
	IF @FREE_GIFT_SEQ = '120'  
		BEGIN  
			IF EXISTS (  
						SELECT TOP 1 A.ORDER_SEQ  
						FROM CUSTOM_ORDER A   
						WHERE A.ORDER_TYPE IN ( '1','6','7')   
						AND A.ORDER_SEQ = @ORDER_SEQ  
						AND A.SALES_GUBUN = 'SS'  
						AND A.ORDER_COUNT >= @LIMIT_ORDER_COUNT  
						AND UP_ORDER_SEQ IS NULL  
						AND card_seq in (select card_seq from S4_MD_Choice where md_seq = 935 )   
				)  
				BEGIN                 
					SET @FLOW = 0  
				END  
			ELSE  
				BEGIN                 
					SET @FLOW = 1
				END    
		END   
  	
	/*실링스티커(엔틱버건디) 사은품 #5086  start**********************************************/
	IF @FREE_GIFT_SEQ = '113'   
		BEGIN  
			IF EXISTS (  
					SELECT TOP 1 A.ORDER_SEQ  
					FROM CUSTOM_ORDER A   
					WHERE A.ORDER_TYPE IN ( '1','6','7')   
					AND A.ORDER_SEQ = @ORDER_SEQ  
					AND A.SALES_GUBUN = 'SS'  
					AND UP_ORDER_SEQ IS NULL  
					AND card_seq in (select card_seq from S4_MD_Choice where md_seq = 821 )   
					and a.order_total_price >= (SELECT ISNULL(LIMIT_ORDER_PRICE,0) FROM S2_CARD_FREE_GIFT WHERE FREE_GIFT_SEQ = @FREE_GIFT_SEQ)
				)  
				BEGIN                     
					SET @FLOW = 0
				END  
			ELSE  
				BEGIN                     
					SET @FLOW = 1  
				END    
		END 

	/*#5086  end *****************************************************************************/

	/*몰튼브라운 사은품 사은품 #5116  start**********************************************/
	
	IF @FREE_GIFT_SEQ = '114'   
		BEGIN  
			IF EXISTS (  
					SELECT TOP 1 A.ORDER_SEQ  
					FROM CUSTOM_ORDER A   
					WHERE A.ORDER_TYPE IN ( '1','6','7')   
					AND A.ORDER_SEQ = @ORDER_SEQ  
					AND A.SALES_GUBUN = 'SS'  
					AND UP_ORDER_SEQ IS NULL  
					and a.order_total_price >= (SELECT ISNULL(LIMIT_ORDER_PRICE,0) FROM S2_CARD_FREE_GIFT WHERE FREE_GIFT_SEQ = @FREE_GIFT_SEQ)
				)  
				BEGIN   
					/*
					IF EXISTS(
					SELECT TOP 1 ci.ORDER_SEQ  
					FROM custom_order_item ci, custom_order c 
					WHERE c.order_Seq = ci.order_seq 
					and c.order_seq = @ORDER_SEQ
					and ci.item_type = 'E' 
					and ci.memo1 = '디자인봉투' 
					and item_count > 0
					)
						BEGIN
							SET @FLOW = 0
						END
					ELSE
						BEGIN
							SET @FLOW = 1
						END
					*/
					SET @FLOW = 0
				END  
			ELSE  
				BEGIN                     
					SET @FLOW = 1  
				END    
		END 
	/*#5086  end *****************************************************************************/
  
	IF @FLOW = 0 -- 무조건 기본로직 태우기    
		BEGIN    
			SET @FREE_GIFT_TARGET_YORN = 'N'    
    
				/* 특정 카드에만 사은품이 지급 되는지 여부 */    
			IF EXISTS(SELECT TOP 1 CARD_SEQ FROM S2_CARD_FREE_GIFT_TARGET_CARD WHERE FREE_GIFT_SEQ = @FREE_GIFT_SEQ)    
				BEGIN    
                            
				IF  EXISTS  (    
					SELECT  TOP 1 SCFGTC.CARD_SEQ     
					FROM    S2_CARD_FREE_GIFT_TARGET_CARD SCFGTC    
					JOIN    CUSTOM_ORDER CO ON SCFGTC.CARD_SEQ = CO.CARD_SEQ    
					WHERE   1 = 1    
					AND     SCFGTC.FREE_GIFT_SEQ = @FREE_GIFT_SEQ    
					AND     CO.ORDER_SEQ = @ORDER_SEQ    
				)    
					BEGIN 
						SET @FREE_GIFT_TARGET_YORN = 'Y'    
					END
			ELSE 
				BEGIN                           
					SET @FREE_GIFT_TARGET_YORN = 'N'    
				END    
		END 
	ELSE    
		BEGIN                   
			SET @FREE_GIFT_TARGET_YORN = 'Y'    
		END    
    
    
    
	/* 특정 배송 지역에만 사은품이 지급 되는지 여부 */    
	IF @LIMIT_DELIVERY_REGION_STR <> ''    
		BEGIN    
			IF  NOT EXISTS  (    
				SELECT  TOP 1 *    
				FROM    DELIVERY_INFO    
				WHERE   1 = 1    
				AND     ORDER_SEQ = @ORDER_SEQ    
				AND     (    
				CHARINDEX(LEFT([dbo].[FN_CR_LF_TAB_SPACE_REMOVE](ADDR, 'Y', 'Y'), 2), @LIMIT_DELIVERY_REGION_STR, 1) > 0     
				OR  CHARINDEX([dbo].[FN_ZIPCODE_TO_REGION_NAME](ZIP), @LIMIT_DELIVERY_REGION_STR, 1) > 0     
			)    
			)  OR @FREE_GIFT_TARGET_YORN = 'N'    
    
				BEGIN    
					SET @FREE_GIFT_TARGET_YORN = 'N'    
					END    
				END    
    
			/* 특정 배송(구단위) 지역에만 사은품이 지급 되는지 여부 */    
			IF @LIMIT_DELIVERY_GU_STR <> ''    
				BEGIN    
				IF  NOT EXISTS  (    
				SELECT  TOP 1 *    
				FROM    DELIVERY_INFO    
				WHERE   1 = 1    
				AND     ORDER_SEQ = @ORDER_SEQ    
				AND     (    
					CHARINDEX(REPLACE(LEFT(ADDR,PATINDEX('%구%', ADDR)),' ',''), @LIMIT_DELIVERY_GU_STR, 1) > 0     
				)    
				)  
				OR @FREE_GIFT_TARGET_YORN = 'N'    
					BEGIN    
						SET @FREE_GIFT_TARGET_YORN = 'N'    
					END    
				END    
    
			/* 특정 브랜드에만 사은품이 지급 되는지 여부 */    
			IF @LIMIT_CARD_BRAND <> ''    
				BEGIN    
					IF NOT EXISTS  (    
					SELECT TOP 1 *    
					FROM S2_CARD    
					WHERE 1=1    
					AND CARD_SEQ = @ORDER_CARD_SEQ    
					AND CARDBRAND = @LIMIT_CARD_BRAND    
					) OR @FREE_GIFT_TARGET_YORN = 'N'    
						BEGIN    
							SET @FREE_GIFT_TARGET_YORN = 'N'    
						END    
				END    
    
    
	IF @FREE_GIFT_TARGET_YORN = 'Y'     
		BEGIN
			 INSERT INTO CUSTOM_ORDER_ITEM (ORDER_SEQ, CARD_SEQ, ITEM_TYPE, ITEM_COUNT, ITEM_PRICE, ITEM_SALE_PRICE, DISCOUNT_RATE, MEMO1, ADDNUM_PRICE)    
			 VALUES (@ORDER_SEQ, @FREE_GIFT_CARD_SEQ, @FREE_GIFT_ITEM_TYPE, @ITEM_COUNT, 0, 0, 0, '', 0)         

			 INSERT INTO S2_CARD_FREE_GIFT_LOG (FREE_GIFT_SEQ, CARD_SEQ, ORDER_SEQ, UID)    
			 VALUES (@FREE_GIFT_SEQ, @FREE_GIFT_CARD_SEQ, @ORDER_SEQ, @UID)

			 UPDATE  S2_CARD_FREE_GIFT    
			 SET     QTY = QTY - 1    
			 WHERE   FREE_GIFT_SEQ = @FREE_GIFT_SEQ    
		END    
    
		END  --기본로직FLOW    
    
    END --END    
    
    SET @i = @i + 1    
     
END    
    
    
END    

GO
