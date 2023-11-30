IF OBJECT_ID (N'dbo.SP_CHG_ENV_CODE_PRIC', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CHG_ENV_CODE_PRIC
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		정혜련
-- Create date: 2021-04-05
-- Description:	장형봉투 변경 (임시)

--1) 2009SV → 2010SV_N
--2009SV_B1 → 2010SV_N_B1
--2009SV_B2 → 2010SV_N_B2

--2) 2110SV → 2010SV_N
--2110SV_B1 → 2010SV_N_B1
--2110SV_B2 → 2010SV_N_B2

--3) 2010LV → 2010LV_N
--2010LV_B1 → 2010LV_N_B1
--2010LV_B2 → 2010LV_N_B2

--4) 2009WH → 2010WH_N
--2009WH_B1 → 2010WH_N_B1
--2009WH_B2 → 2010WH_N_B2

--5) 2010WH → 2010WH_N
--2010WH_B1 → 2010WH_N_B1
--2010WH_B2 → 2010WH_N_B2

--2009SV, 2010SV, 2110SV, 2010LV 해당 코드로 주문접수되고있어,
--2010SV_N, 2010LV_N 변경된 코드로 주문들어올 수 있도록 요청 (+디자인봉투 추가)
 
-- EXEC 쿠폰타입, 회원아이디, 사이트코드
-- EXEC SP_CHG_ENV_CODE_PRIC 3133469


--37142	Z	2010WH
-- EXEC SP_CHG_ENV_CODE_PRIC 3116772

-- 2022.03.17 사용안해도 되지 않나?
-- =============================================

CREATE PROCEDURE [dbo].[SP_CHG_ENV_CODE_PRIC]
	@ORDER_SEQ		AS INT
AS
BEGIN
	
	DECLARE		@P_PRINT_COUNT		AS	INT = 0
	DECLARE		@FLOW			AS	INT = 0 
	DECLARE		@ITEM_CNT		AS	INT = 0
	DECLARE		@ITEM_P_CNT		AS	INT = 0
	
	DECLARE		@ENV_SEQ		AS INT 
	DECLARE		@ENV_P_SEQ		AS INT 
	DECLARE		@P_ID			AS INT 
	DECLARE		@SUM_PRINT_P	AS INT
	DECLARE		@SUM_PRINT		AS INT
	DECLARE		@item_env_cnt	AS INT 
	DECLARE		@MEM_CARD_CODE AS CHAR(6) 	

	IF EXISTS ( 
		select top 1 order_Seq 
		from custom_order_item ci, s2_Card s
		where ci.card_Seq = s.card_seq 
		and ci.order_Seq =  @ORDER_SEQ 
		and s.card_code in ('2009SV','2009SV_B1' ,'2009SV_B2','2110SV','2110SV_B1','2110SV_B2','2010LV','2010LV_B1','2009WH','2009WH_B1','2009WH_B2','2010WH','2010WH_B1','2010WH_B2')
		)  
	BEGIN                     
		SET @FLOW = 1  
	END  
	ELSE  
	BEGIN                     
		SET @FLOW = 0
	END 


	IF @FLOW = 1 
	BEGIN
	
		SELECT TOP 1 @MEM_CARD_CODE =  LEFT(S.CARD_CODE,6) 
		FROM CUSTOM_ORDER_ITEM CI, S2_CARD S WHERE CI.CARD_SEQ = S.CARD_SEQ AND ORDER_SEQ = @ORDER_SEQ AND ITEM_TYPE ='E'
		
		-- 로그 남기기
		insert into CHG_ENV_log (order_seq, card_code, chg_date) values (@order_seq, @MEM_CARD_CODE, getdate())


		IF @MEM_CARD_CODE = '2009SV' 
			begin
				 -- 2009SV (37090) → 2010SV_N (38206)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38206 WHERE order_Seq = @order_seq AND card_seq = 37090 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38206 WHERE order_Seq = @order_seq AND card_seq = 37090 AND print_type ='E'

				 -- 2009SV_B1 (37749) → 2010SV_N_B1 (38196)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38196 WHERE order_Seq = @order_seq AND card_seq = 37749 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38196 WHERE order_Seq = @order_seq AND card_seq = 37749 AND print_type ='E'

				 -- 2009SV_B2 (37750) → 2010SV_N_B2 (38199)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38199 WHERE order_Seq = @order_seq AND card_seq = 37750 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38199 WHERE order_Seq = @order_seq AND card_seq = 37750 AND print_type ='E'
			
			END 
		/*
		ELSE IF @MEM_CARD_CODE = '2110SV' 
			BEGIN
			 
				--2) 2110SV (38206) → 2010SV_N (36840)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38206 WHERE order_Seq = @order_seq AND card_seq = 36840 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38206 WHERE order_Seq = @order_seq AND card_seq = 36840 AND print_type ='E'
				--2110SV_B1 (38196) → 2010SV_N_B1 (37755)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38196 WHERE order_Seq = @order_seq AND card_seq = 37755 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38196 WHERE order_Seq = @order_seq AND card_seq = 37755 AND print_type ='E'

				--2110SV_B2 (37756) → 2010SV_N_B2 (38199)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38199 WHERE order_Seq = @order_seq AND card_seq = 37756 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38199 WHERE order_Seq = @order_seq AND card_seq = 37756 AND print_type ='E'
			END
		*/
		ELSE IF @MEM_CARD_CODE = '2010LV' 
			BEGIN		
				--3) 2010LV (37260) → 2010LV_N (38208)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38208 WHERE order_Seq = @order_seq AND card_seq = 37260 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38208 WHERE order_Seq = @order_seq AND card_seq = 37260 AND print_type ='E'

				--2010LV_B1 (37753) → 2010LV_N_B1 (38214)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38214 WHERE order_Seq = @order_seq AND card_seq = 37753 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38214 WHERE order_Seq = @order_seq AND card_seq = 37753 AND print_type ='E'

				--2010LV_B2 (37754) → 2010LV_N_B2 (38215)
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38215 WHERE order_Seq = @order_seq AND card_seq = 37754 AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38215 WHERE order_Seq = @order_seq AND card_seq = 37754 AND print_type ='E'
		----------------------------------------------------------------------------
			END 
		
		ELSE IF @MEM_CARD_CODE = '2009WH'  OR  @MEM_CARD_CODE = '2010WH'
			BEGIN
				--4) 2009WH (37140) → 2010WH_N (38205)
				--2009WH_B1 (37744) → 2010WH_N_B1 (38211)
				--2009WH_B2 (37745) → 2010WH_N_B2 (38213)

				--5) 2010WH (37142) → 2010WH_N (38205)
				--2010WH_B1 (37751) → 2010WH_N_B1 (38211)
				--2010WH_B2 (37752) → 2010WH_N_B2 (38213)
				
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38205 WHERE order_Seq = @order_seq AND card_seq IN ( 37140, 37142) AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38205 WHERE order_Seq = @order_seq AND card_seq IN ( 37140, 37142) AND print_type ='E'
				
				----------
				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38211 WHERE order_Seq = @order_seq AND card_seq IN ( 37744, 37751) AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38211 WHERE order_Seq = @order_seq AND card_seq IN ( 37744, 37751) AND print_type ='E'
				----------

				UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = 38213 WHERE order_Seq = @order_seq AND card_seq IN ( 37745, 37752) AND item_type ='E'

				UPDATE custom_order_plist SET CARD_SEQ = 38213 WHERE order_Seq = @order_seq AND card_seq IN ( 37745, 37752) AND print_type ='E'
			END 
	END
END
GO
