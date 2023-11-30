IF OBJECT_ID (N'dbo.C_spOrderOptionList', N'P') IS NOT NULL DROP PROCEDURE dbo.C_spOrderOptionList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[C_spOrderOptionList]   
	@Gubun VARCHAR(4)
    , @OrderSeq INT
AS    

-- EXEC C_spOrderOptionList 'LIST', 3042349
 -- EXEC C_spOrderOptionList 'SUM', 3042349
 
--select LiningJaebon_price, option_price, * from custom_order where order_seq = 2912539


--	jebon_price			: 카드제본비
--	envinsert_price		: 봉투제본비
--	LiningJaebon_price	: 라이닝제본비
--	option_price		: 인쇄판비
--	sasik_price			: 사식수수료
--	print_price			: 칼라인쇄
--	embo_price			: 엠보인쇄
--	cont_price			: 칼라내지
--	moneyenv_price		: 돈봉투
--	EnvSpecial_Price	: 스페셜봉투
--	pocket_price		: 포켓카드
--	perfume_price		: 향기서비스
--	laser_price			: 레이저컷비
-- envpremium_price		: 프리미엄봉투인쇄


 IF ( @Gubun = 'LIST' )
 BEGIN
		--서비스 금액
		select @OrderSeq AS id
			, 'SERVICE' AS ItemGubun	--서비스품목
			, CASE ServiceGroup 
				WHEN 'jebon_price' THEN '카드제본비' 
				WHEN 'envinsert_price' THEN '봉투제본비' 
				WHEN 'LiningJaebon_price' THEN '라이닝제본비' 
				WHEN 'option_price' THEN '인쇄판비' 
				WHEN 'sasik_price' THEN '사식수수료' 
				WHEN 'print_price' THEN '칼라인쇄' 
				WHEN 'embo_price' THEN '엠보인쇄' 
				WHEN 'cont_price' THEN '칼라내지' 
				WHEN 'EnvSpecial_Price' THEN '스페셜봉투' 
				WHEN 'perfume_price' THEN '향기서비스' 
				WHEN 'laser_price' THEN '레이저컷비' 
				WHEN 'envpremium_price' THEN '프리미엄봉투인쇄'
				ELSE '기타' END AS Code_value
			, ServiceGroup  AS Card_Code
			, vPrice AS SaleAmnt
			, NULL AS ItemCount
			, NULL AS ItemPrice	
			, '' AS Item_Type
			, '' AS Card_seq	
			
			, CASE ServiceGroup 
				WHEN 'jebon_price' THEN '11'  --'카드제본비' 
				WHEN 'envinsert_price' THEN '13'  --'봉투제본비' 
				WHEN 'option_price' THEN '15'	--'인쇄판비' 
				WHEN 'perfume_price' THEN '31'	--'향기서비스' 
				WHEN 'EnvSpecial_Price' THEN '33'	--'스페셜봉투' 
				WHEN 'embo_price' THEN '35'		--'엠보인쇄' 
				WHEN 'cont_price' THEN '37'	--'칼라내지' 
				WHEN 'print_price' THEN '39'	--'칼라인쇄' 
				WHEN 'sasik_price' THEN '41'		--'사식수수료' 
				WHEN 'LiningJaebon_price' THEN '91'--'라이닝제본비'
				WHEN 'laser_price' THEN '93'	--'레이저컷비' 
				WHEN 'envpremium_price' THEN '94'
				ELSE '97' END AS SortNo
		from ( 
				SELECT order_seq
					, ISNULL(jebon_price, 0) AS jebon_price
					, ISNULL(envinsert_price, 0) AS envinsert_price
					, ISNULL(LiningJaebon_price, 0) AS LiningJaebon_price
					, ISNULL(option_price, 0) AS option_price
					, ISNULL(sasik_price, 0) AS sasik_price
					, ISNULL(print_price, 0) AS print_price
					, ISNULL(embo_price, 0) AS embo_price
					, ISNULL(cont_price, 0) AS cont_price
					, ISNULL(EnvSpecial_Price, 0) AS EnvSpecial_Price
					, ISNULL(perfume_price, 0) AS perfume_price
					, ISNULL(laser_price, 0) AS laser_price
					, ISNULL(envpremium_price,0) AS envpremium_price

					--, ISNULL(moneyenv_price, 0) AS moneyenv_price
				FROM custom_order 
				WHERE order_seq = @OrderSeq
		) A
		UNPIVOT (
			vPrice FOR ServiceGroup IN (jebon_price, envinsert_price, LiningJaebon_price, option_price, sasik_price, print_price, embo_price, cont_price, EnvSpecial_Price,perfume_price, laser_price, envpremium_price)
		) AS UNP

		UNION ALL
		SELECT A.id
			, 'ADDITION' AS ItemGubun	--추가상품
			, M.code_value
			, I.Card_Code 
			, ISNULL(A.item_count, 0) * ISNULL(A.item_sale_price, 0) AS SaleAmnt
			, ISNULL(A.item_count, 0) AS ItemCount
			, ISNULL(A.item_sale_price, 0) AS ItemPrice
			, A.item_type
			, A.card_seq 
			, CASE M.code_value 
				WHEN '방명록' THEN '21'
				WHEN '메모리북' THEN '23'
				WHEN '실링스티커' THEN '25'	
				WHEN '프리저브드 플라워' THEN '26'
				WHEN '돈봉투' THEN '27'
				WHEN '사은품' THEN '28'
				WHEn '마스킹 테이프' THEN '29'
				ELSE '99' END AS SortNo
		FROM custom_order_item A 
		JOIN S2_Card I ON A.card_seq = I.Card_Seq 
		LEFT JOIN manage_code M ON I.Card_Div= M.code AND M.code_type = 'card_div'
		--JOIN manage_code M ON A.item_type = M.code AND M.code_type = 'item_type'
		WHERE order_seq = @OrderSeq
			AND A.item_type NOT IN ( 'C', 'I', 'E', 'P', 'F', 'S', 'H' ,'B')
			--AND A.item_type in ( 'A', 'R', 'X', 'L', 'V', 'H', 'A', 'M', 'T', 'W', 'K', 'Z') 

		ORDER BY SortNo, ItemGubun DESC, code_value, Card_Code


END
ELSE IF( @Gubun = 'SUM' )
BEGIN

	SELECT order_seq
		, ISNULL(jebon_price, 0)		--카드제본비
			+ ISNULL(envinsert_price, 0)	--봉투제본비
			+ ISNULL(LiningJaebon_price, 0) --라이닝제본비
			+ ISNULL(option_price, 0)	--인쇄판비
			+ ISNULL(sasik_price, 0)	--사식수수료
			+ ISNULL(print_price, 0)	--칼라인쇄 
			+ ISNULL(embo_price, 0) 	--엠보인쇄
			+ ISNULL(cont_price, 0) 	--칼라내지
			+ ISNULL(EnvSpecial_Price, 0) 	--스페셜봉투
			+ ISNULL(perfume_price, 0) 	--향기서비스
			+ ISNULL(laser_price, 0) 	--레이저컷비
			+ ISNULL(envpremium_price,0)	--프리미엄봉투 인쇄비
			+ ISNULL(guestbook_price, 0) 	--방명록 (item_type = 'L')
			+ ISNULL(moneyenv_price, 0) 	--돈봉투 (item_type = 'K')
			+ ISNULL(sealing_sticker_price, 0) 	--실링스티커 (item_type = 'T')
			+ ISNULL(flower_price, 0) 	--플라워 (item_type = 'W')
			+ ISNULL(MemoryBook_Price, 0) 	--메모리북 (item_type = 'X')
			+ ISNULL(ribbon_price, 0) 	--쉬폰리본 (item_type = 'R')
			+ ISNULL(pocket_price, 0) 	--포켓카드
			+ ISNULL(paperCover_price, 0) 	--페이퍼커버 (item_type = 'U')
			+ ISNULL(AddPrice, 0) 	--기타제품금액 (item_type = 'Z')
			+ ISNULL(Mask_Price, 0) 	--마스크 (item_type = 'J')
			+ ISNULL(MaskingTape_price, 0) 	--마스킹테이프 (item_type = '5')
		AS AddSaleSumAmnt
	FROM custom_order 
	WHERE order_seq = @OrderSeq

END

--'select * from manage_code where code_type = 'item_type'

--sasik_price
--print_price
--embo_price	isEmbo	cboEmbo
--cont_price	isColorInpaper


--MemoryBook_Price :메모리북
--flower_price	:플라워
--MaskingTape_price : 마스킹테이프
--sealing_sticker_price
--AddPrice

GO
