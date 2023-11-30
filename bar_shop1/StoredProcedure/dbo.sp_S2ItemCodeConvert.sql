IF OBJECT_ID (N'dbo.sp_S2ItemCodeConvert', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2ItemCodeConvert
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE Proc [dbo].[sp_S2ItemCodeConvert] 
	@state as varchar(10)   --update, insert
AS


--#########################################################################
--1.S2_Card 
--#########################################################################
--1.1 Insert 
INSERT INTO S2_Card
(CardBrand,Card_Code,Card_Div,Card_Name,CardSet_Price,Card_Price,Card_WSize,Card_HSize)
	SELECT 
		CardBrand = LEFT(brand,1),
		card_code = item_Code,
		Card_Div = 'A01',
		Card_Name = name,
		CardSet_Price = price,
		Card_Price = price_1,
		Card_WSize = Case
						When size is not null Then Left(size,3)
						Else null
					 End ,
		Card_HSize = Case
						When size is not null Then Right(size,3)
						Else null
					 End		
	FROM S2_product a LEFT JOIN S2_Card  b ON a.Item_Code = b.Card_Code
	WHERE b.Card_Code is null
	
	UNION
	
	SELECT 
		CardBrand = 'Z',
		Card_code = item_Code,
		Card_Div = Case
					 When gubun = '내지' Then 'A02'
					 When gubun = '부속' Then 'A05'
					 When gubun = 'item_info1' Then 'A03' --인사말카드
					 When gubun = 'item_map' Then 'A04' --약도카드
					 When gubun = '봉투' Then 'B01'
					 When gubun = '라이닝' Then 'B02'
					 When gubun = '미니청첩장' Then 'C03'
					 When gubun = '식권' Then 
						Case 
							When sex = 'M' Then 'C01'
							When sex = 'F' Then 'C02'
						End	
					 When gubun = '스티커' Then 'C04'
				   End,
		Card_Name = null,
		CardSet_Price = null,
		Card_Price = price,
		Card_WSize = Case
						When size is not null Then Left(size,3)
						Else null
					 End ,
		Card_HSize = Case
						When size is not null Then Right(size,3)
						Else null
					 End		
	FROM S2_Acc a LEFT JOIN S2_Card  b ON a.Item_Code = b.Card_Code
	WHERE b.Card_Code is null


--1.2 Update
UPDATE S2_Card
Set CardBrand = a.CardBrand,
    Card_Code = a.Card_Code,
    Card_Div = a.Card_Div,
    Card_Name = a.Card_Name,
    CardSet_Price = a.CardSet_Price,
    Card_Price = a.Card_Price,
    Card_WSize = a.Card_WSize,
    Card_HSize = a.Card_HSize
FROM 
	S2_Card a JOIN 
	(
	SELECT 
		CardBrand = LEFT(brand,1),
		card_code = item_Code,
		Card_Div = 'A01',
		Card_Name = name,
		CardSet_Price = price,
		Card_Price = price_1,
		Card_WSize = Case
						When size is not null Then Left(size,3)
						Else null
					 End ,
		Card_HSize = Case
						When size is not null Then Right(size,3)
						Else null
					 End		
	FROM S2_product
	UNION
	SELECT 
		CardBrand = 'Z',
		Card_code = item_Code,
		Card_Div = Case
					 When gubun = '내지' Then 'A02'
					 When gubun = '부속' Then 'A04'
					 When gubun = '봉투' Then 'B01'
					 When gubun = '라이닝' Then 'B02'
					 When gubun = '미니청첩장' Then 'C03'
					 When gubun = '식권' Then 
						Case 
							When sex = 'M' Then 'C01'
							When sex = 'F' Then 'C02'
						End	
					 When gubun = '스티커' Then 'C04'
					 
				   End,
		Card_Name = null,
		CardSet_Price = null,
		Card_Price = price,
		Card_WSize = Case
						When size is not null Then Left(size,3)
						Else null
					 End ,
		Card_HSize = Case
						When size is not null Then Right(size,3)
						Else null
					 End		
	FROM S2_Acc ) as b ON a.Card_Code = b.Card_Code 



--#########################################################################
--2.S2_CardDetail 
--#########################################################################
--2.1 INSERT
INSERT INTO S2_CardDetail
(Card_Seq,Env_Seq,Env_GroupSeq,InPaper_Seq,InPaper_GroupSeq,Acc1_Seq,Acc1_GroupSeq,Acc2_Seq,Acc2_GroupSeq,MapCard_Seq,
  MapCard_GroupSeq,GreetingCard_Seq,GreetingCard_GroupSeq,
  Lining_Seq, Lining_GroupSeq,Card_Content,Card_Shape,
  Card_Folding,Card_PrintMethod,Card_Material,Card_PrintOffice,Minimum_Count,Unit_Count)
	SELECT 
		Card_Seq              = b.Card_Seq,
		Env_Seq               = (SELECT IsNull(Card_Seq,0) FROM S2_Card WHERE Card_Code = a.env),
		Env_GroupSeq          = (SELECT IsNull(CardItemGroup_Seq,0) FROM S2_CardItemGroupInfo WHERE CardItemGroup = a.env_gr),
		InPaper_Seq            = (SELECT IsNull(Card_Seq,0) FROM S2_Card WHERE Card_Code = a.inp),
		InPaper_GroupSeq       = (SELECT IsNull(CardItemGroup_Seq,0) FROM S2_CardItemGroupInfo WHERE CardItemGroup = a.inp_gr),
		Acc1_Seq              = (SELECT IsNull(Card_Seq,0) FROM S2_Card WHERE Card_Code = a.acc1),
		Acc1_GroupSeq         = (SELECT IsNull(CardItemGroup_Seq,0) FROM S2_CardItemGroupInfo WHERE CardItemGroup = a.acc1_gr),
		Acc2_Seq              = (SELECT IsNull(Card_Seq,0) FROM S2_Card WHERE Card_Code = a.acc2),
		Acc2_GroupSeq         = (SELECT IsNull(CardItemGroup_Seq,0) FROM S2_CardItemGroupInfo WHERE CardItemGroup = a.acc2_gr),
		MapCard_Seq           = (SELECT IsNull(Card_Seq,0) FROM S2_Card WHERE Card_Code = a.item_map),
		MapCard_GroupSeq      = null,
		GreetingCard_Seq      = (SELECT IsNull(Card_Seq,0) FROM S2_Card WHERE Card_Code = a.item_info1),
		GreetingCard_GroupSeq = null,
		Lining_Seq            = (SELECT IsNull(Card_Seq,0) FROM S2_Card WHERE Card_Code = a.lining),
		Lining_GroupSeq       = (SELECT IsNull(CardItemGroup_Seq,0) FROM S2_CardItemGroupInfo WHERE CardItemGroup = a.lining_gr),
		Card_Content          = a.comment,
		Card_Shape            = null,
		Card_Folding          = a.folding,
		Card_PrintMethod      = null,
		Card_Material         = a.mat,
		Card_PrintOffice      = null,
		Minimum_Count         = null,
		Unit_Count            = null
	FROM S2_product a JOIN S2_Card b ON a.Item_Code = b.card_code 
					  LEFT JOIN S2_CardDetail c ON b.Card_Seq = c.Card_Seq 
	WHERE c.Card_Seq is null


--2.1 UPDATE
UPDATE S2_CardDetail
SET Card_Seq              = b.Card_Seq,
	Env_Seq               = (SELECT Card_Seq FROM S2_Card WHERE Card_Code = c.env),
	Env_GroupSeq          = (SELECT CardItemGroup_Seq FROM S2_CardItemGroupInfo WHERE CardItemGroup = c.env_gr),
	InPaper_Seq            = (SELECT Card_Seq FROM S2_Card WHERE Card_Code = c.inp),
	InPaper_GroupSeq       = (SELECT CardItemGroup_Seq FROM S2_CardItemGroupInfo WHERE CardItemGroup = c.inp_gr),
	Acc1_Seq              = (SELECT Card_Seq FROM S2_Card WHERE Card_Code = c.acc1),
	Acc1_GroupSeq         = (SELECT CardItemGroup_Seq FROM S2_CardItemGroupInfo WHERE CardItemGroup = c.acc1_gr),
	Acc2_Seq              = (SELECT Card_Seq FROM S2_Card WHERE Card_Code = c.acc2),
	Acc2_GroupSeq         = (SELECT CardItemGroup_Seq FROM S2_CardItemGroupInfo WHERE CardItemGroup = c.acc2_gr),
	MapCard_Seq           = (SELECT Card_Seq FROM S2_Card WHERE Card_Code = c.item_map),
	MapCard_GroupSeq      = null,
	GreetingCard_Seq      = (SELECT Card_Seq FROM S2_Card WHERE Card_Code = c.item_info1),
	GreetingCard_GroupSeq = null,
	Lining_Seq            = (SELECT Card_Seq FROM S2_Card WHERE Card_Code = c.lining),
	Lining_GroupSeq       = (SELECT CardItemGroup_Seq FROM S2_CardItemGroupInfo WHERE CardItemGroup = c.lining_gr),
	Card_Content          = c.comment,
	Card_Shape            = null,
	Card_Folding          = null,
	Card_PrintMethod      = null,
	Card_Material         = c.mat,
	Card_PrintOffice      = null,
	Minimum_Count          = null,
	Unit_Count            = null
FROM 
	S2_CardDetail a JOIN S2_Card b ON a.Card_Seq = b.Card_Seq
	JOIN S2_product c ON b.Card_Code = c.Item_Code 


--#########################################################################
--3.S2_CardOption 
--#########################################################################	
--3.1 INSERT
INSERT INTO S2_CardOption
(Card_Seq,IsEmbo,IsEmboColor,IsQuick,
 --IsColorPrint ,
 IsHandmade,
 --IsHanji, 
 IsInpaper, IsJaebon, IsEnvInsert, IsSample, IsOutsideInitial,PrintMethod,IsAdd)
	SELECT 
		Card_Seq        = b.Card_Seq,
		IsEmbo          = Case 
							When a.option_5 = '유료' Then '1'
							When a.option_5 = '무료' Then '2'
							Else '0'
						  End, 
		IsEmboColor     = Case
							When a.option_6 = '진회색' Then 'A'
							When a.option_6 = '짙은밤색' Then 'D'
							When a.option_6 = '회색' Then 'G'
							When a.option_6 = 'black' Then 'B'
							Else 'S' --선택
						  End, 	 
						
		IsQuick         = Case
							When a.option_10 = 'Yes' Then '1'
							Else '0' 
						  End, 
		--IsColorPrint    = option_2, dldl;
		IsHandmade      =  Case 
							When a.option_4 = '유료' Then '1'
							When a.option_4 = '무료' Then '2'
							Else '0'
						  End, 
		--IsHanji         =, 
		IsInpaper       =  Case 
							When a.option_3 = '유료' Then '1'
							When a.option_3 = '무료' Then '2'
							Else '0'
						  End,  
		IsJaebon        =  Case 
							When a.option_2 = '유료' Then '1'
							When a.option_2 = '무료' Then '2'
							Else '0'
						  End,  
		IsEnvInsert     =  Case 
							When a.option_1 = '유료' Then '1'
							When a.option_1 = '무료' Then '2'
							Else '0'
						  End, 
		IsSample        =  Case 
							When a.option_5 = 'Yes' Then '1'
							Else '0'
						  End, 
		IsOutsideInitial = Case 
							When a.option_4 = '유료' Then '1'
							When a.option_4 = '무료' Then '2'
							Else '0'
						  End, 
		PrintMethod     = Case
							When a.option_8 = '마스터' Then   'MNN'
							When a.option_8 = '마스터(내부)' Then 'MNN' 
							When a.option_8 = '마스터인쇄' Then  'MNN'
							When a.option_8 = '먹박(외부)' Then  'BYN'
							When a.option_8 = '무광금박' Then 'GNN'
							When a.option_8 = '무광은박' Then 'SNN'
							When a.option_8 = '무광은박(외부)' Then 'SNN' 
							When a.option_8 = '무박.형압' Then 'NNY'
							When a.option_8 = '무박형압(외부)' Then 'NNY' 
							When a.option_8 = '무은/무금(외부)' Then  'XXX'
							When a.option_8 = '송진(내부)' Then 'EBN'
							When a.option_8 = '송진(dark brown)' Then 'EDN' 
							When a.option_8 = '송진(silver)' Then  'ESN'
							When a.option_8 = '은박(외부)' Then 'SNN'
							When a.option_8 = '은박형압(외부)' Then 'SNY' 
						  End ,				  
		IsAdd           = Case 
							When a.option_11 = 'Yes' Then '1'
							Else '0'
						  End
	FROM S2_product a JOIN S2_Card b ON a.Item_Code = b.card_code 
					  LEFT JOIN S2_CardOption c ON b.Card_Seq = c.Card_Seq
	WHERE c.Card_Seq is null				  






--3.2 UPDATE
UPDATE S2_CardOption
SET		
		Card_Seq        = b.Card_Seq,
		IsEmbo          = Case 
							When c.option_5 = '유료' Then '1'
							When c.option_5 = '무료' Then '2'
							Else '0'
						  End, 
		IsEmboColor     = Case
							When c.option_6 = '진회색' Then 'A'
							When c.option_6 = '짙은밤색' Then 'D'
							When c.option_6 = '회색' Then 'G'
							When c.option_6 = 'black' Then 'B'
							Else 'S' --선택
						  End, 	 
						
		IsQuick         = Case
							When c.option_10 = 'Yes' Then '1'
							Else '0' 
						  End, 
		--IsColorPrint    = option_2, dldl;
		IsHandmade      =  Case 
							When c.option_4 = '유료' Then '1'
							When c.option_4 = '무료' Then '2'
							Else '0'
						  End, 
		--IsHanji         =, 
		IsInpaper       =  Case 
							When c.option_3 = '유료' Then '1'
							When c.option_3 = '무료' Then '2'
							Else '0'
						  End,  
		IsJaebon        =  Case 
							When c.option_2 = '유료' Then '1'
							When c.option_2 = '무료' Then '2'
							Else '0'
						  End,  
		IsEnvInsert     =  Case 
							When c.option_1 = '유료' Then '1'
							When c.option_1 = '무료' Then '2'
							Else '0'
						  End, 
		IsSample        =  Case 
							When c.option_5 = 'Yes' Then '1'
							Else '0'
						  End, 
		IsOutsideInitial = Case 
							When c.option_4 = '유료' Then '1'
							When c.option_4 = '무료' Then '2'
							Else '0'
						  End, 
		PrintMethod     = Case
							When c.option_8 = '마스터' Then   'MNN'
							When c.option_8 = '마스터(내부)' Then 'MNN' 
							When c.option_8 = '마스터인쇄' Then  'MNN'
							When c.option_8 = '먹박(외부)' Then  'BYN'
							When c.option_8 = '무광금박' Then 'GNN'
							When c.option_8 = '무광은박' Then 'SNN'
							When c.option_8 = '무광은박(외부)' Then 'SNN' 
							When c.option_8 = '무박.형압' Then 'NNY'
							When c.option_8 = '무박형압(외부)' Then 'NNY' 
							When c.option_8 = '무은/무금(외부)' Then  'XXX'
							When c.option_8 = '송진(내부)' Then 'EBN'
							When c.option_8 = '송진(dark brown)' Then 'EDN' 
							When c.option_8 = '송진(silver)' Then  'ESN'
							When c.option_8 = '은박(외부)' Then 'SNN'
							When C.option_8 = '은박형압(외부)' Then 'SNY' 
						  End ,				  
		IsAdd           = Case 
							When c.option_11 = 'Yes' Then '1'
							Else '0'
						  End
FROM S2_CardOption a JOIN S2_Card b ON a.Card_Seq = b.Card_Seq
					 JOIN S2_Product c ON b.Card_Code = c.Item_Code
				  

--#########################################################################
--3.S2_CardStyle
--#########################################################################	
INSERT INTO S2_CardStyle
(Card_Seq,CardStyle_Seq)

	SELECT 
	b.card_seq,		   
	CardStyle_Seq =  Case --더카드용 느낌
						When Style_1 = 1 Then 1 --화려한
						When Style_1 = 2 Then 2--심플한
						When Style_1 = 3 Then 3 --순수한
						When Style_1 = 4 Then 4 --모던한
						When Style_1 = 5 Then 5 --동양적인
						When Style_1 = 6 Then 6 --감각적인
					    Else null
					 End 
	FROM S2_product a JOIN S2_Card b ON a.Item_Code = b.Card_Code 
					  LEFT JOIN S2_CardStyle c ON b.Card_Seq = c.Card_Seq
	WHERE IsNull(Style_1,0) > 0 and c.Card_Seq is null
	
	UNION
	
	SELECT 
	b.card_seq,		   
	Style_9 =  Case --개별 느낌
					When brand = 'B' Then
						Case
							When Style_9 = 1 Then  13 --modern&traditional
							When Style_9 = 2 Then  14--elegant noblesse
							When Style_9 = 3 Then  15--sweet pure
							When Style_9 = 4 Then  16--romantic flower
							When Style_9 = 5 Then  17--trendy chic
							Else null
						End
					When brand = 'W' Then
						Case
							When Style_9 = 1 Then  36 --전통스타일
							When Style_9 = 2 Then  37 --모던스타일
							When Style_9 = 3 Then  38 --로맨틱스타일
							When Style_9 = 4 Then  39 --심플스타일
							When Style_9 = 5 Then  40 --큐트스타일
							Else null
						End
					When brand = 'S' Then
						Case
							When Style_9 = 1 Then  57 --luxury initial
							When Style_9 = 2 Then  58 --modern classic
							When Style_9 = 3 Then  59 --romantic flower
							When Style_9 = 4 Then  60 --oriental tradition
							Else null
						End	
					When brand = 'P' Then
						Case
							When Style_9 = 1 Then  25 --우아하고 세련된
							When Style_9 = 2 Then  26 --여성스럽고 감성적인
							When Style_9 = 3 Then  27 --독특하고 감각적인
							When Style_9 = 4 Then  28 --톡톡튀고 스타일리쉬한
							When Style_9 = 5 Then  29 --럭셔리한
							Else null
						End		
					When brand = 'H' Then
						Case
							When Style_9 = 1 Then  46 --모던스타일
							When Style_9 = 2 Then  47 --로맨틱스타일
							When Style_9 = 3 Then  48 --남다른개성
							When Style_9 = 4 Then  49 --부모님이선호하는
							When Style_9 = 5 Then  50 --착한가격높은품질
							When Style_9 = 6 Then  51 --보편적으로사랑받는
							Else null
						End		
						
					Else null
			   End 	
	FROM S2_product a JOIN S2_Card b ON a.Item_Code = b.Card_Code 
					  LEFT JOIN S2_CardStyle c ON b.Card_Seq = c.Card_Seq
	WHERE IsNull(Style_9,0) > 0 and c.Card_Seq is null
	
	
		

INSERT INTO S2_CardStyle
(Card_Seq,CardStyle_Seq)	
	
	SELECT Card_Seq,Card_Style_Seq FROM (
		SELECT 
		Item_Code,Card_Style_Seq =  7 --더카드용 리본 및 띠지				
		FROM S2_product  WHERE Style_3 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,Style_4 = 8 --더카드용오브제			
		FROM S2_product   WHERE Style_4 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,Style_5 =  9
		FROM S2_product WHERE Style_5 = 'Yes'
		 
		UNION
		
		SELECT 
		Item_Code,Style_6 =  10 --더카드용 이니셜 및 타이포					
		FROM S2_product  WHERE Style_6 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,Style_7 = 11
		FROM S2_product   WHERE Style_7 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code, Style_8 = 12
		FROM S2_product  WHERE Style_8 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,
		Style_10 =  Case 
						When brand = 'B' Then  18
						When brand = 'P' Then  30
						When brand = 'W' Then  41 
						When brand = 'H' Then  52
						When brand = 'S' Then  61
						Else null
				   End 
		FROM S2_product  WHERE Style_10 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,
		Style_11 =  Case 
						When brand = 'B' Then  19
						When brand = 'P' Then  31
						When brand = 'W' Then  42 
						When brand = 'H' Then  53
						When brand = 'S' Then  62
						Else null
				   End 
		FROM S2_product  WHERE Style_11 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,
		Style_12 =  Case 
						When brand = 'B' Then  20
						When brand = 'P' Then  32
						When brand = 'W' Then  43 
						When brand = 'H' Then  54
						When brand = 'S' Then  63
						Else null
				   End 
		FROM S2_product  WHERE Style_12 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,
		Style_13 =  Case 
						When brand = 'B' Then  21
						When brand = 'P' Then  33
						When brand = 'W' Then  44 
						When brand = 'H' Then  55
						When brand = 'S' Then  64
						Else null
				   End 
		FROM S2_product  WHERE Style_13 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,
		Style_14 =  Case 
						When brand = 'B' Then  22
						When brand = 'P' Then  34
						When brand = 'W' Then  45 
						When brand = 'H' Then  56
						Else null
				   End 
		FROM S2_product  WHERE Style_14 = 'Yes'
		
		
		UNION
		
		SELECT 
		Item_Code,
		Style_15 =  Case 
						When brand = 'B' Then  23
						When brand = 'P' Then  35
						Else null
				   End 
		FROM S2_product  WHERE Style_15 = 'Yes'
		
		UNION
		
		SELECT 
		Item_Code,
		Style_16 =  Case 
						When brand = 'B' Then  24
						When brand = 'P' Then  36
						Else null
				   End 
		FROM S2_product  WHERE Style_16 = 'Yes'
	) a JOIN  S2_Card b ON a.Item_Code = b.Card_Code 	
		
	
	
--#########################################################################
--4.S2_CardDiscount
--#########################################################################		
INSERT INTO S2_CardDiscount	
	(CardDiscount_Seq, MinCount, MaxCount, Discount_Rate)	
	
	SELECT price_code = Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End 
						, 50 as mincount , 99 as maxcount , p_50*100 as discount
	FROM  S2_price_code
	UNION
	SELECT price_code = Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
					, 100, 149, p_100*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 150, 199, p_150*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 200, 249, p_200*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 250, 299, p_250*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 300, 349, p_300*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 350, 399, p_350*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 400, 449, p_400*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 450, 499, p_450*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 500, 549, p_500*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 550, 599, p_550*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 600, 649, p_600*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 650, 699, p_650*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 700, 749, p_700*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End	
						, 800, 899, p_800*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 900, 999, p_900*100
	FROM  S2_price_code
	UNION
	SELECT price_code= Case
							When price_code = 'B_code1' Then 1
							When price_code = 'B_code2' Then 2
							When price_code = 'W_code1' Then 3
							When price_code = 'P_code1' Then 4
							When price_code = 'H_code1' Then 5
							When price_code = 'S_code1' Then 6
						End
						, 1000, 10000, p_1000*100
	FROM  S2_price_code
	
	
	
	
--#########################################################################
--4.S2_CardSalesSite
--#########################################################################	
INSERT INTO S2_CardSalesSite	
	(Card_Seq, CardDiscount_Seq, Company_Seq, IsDisplay, IsNew)
	
	SELECT b.card_seq, c.CardDiscount_Seq, Case
											 When Left(a.brand,1) = 'B' Then 5001
											 When Left(a.brand,1) = 'W' Then 5002
											 When Left(a.brand,1) = 'S' Then 5003
											 When Left(a.brand,1) = 'H' Then 5004
											 When Left(a.brand,1) = 'P' Then 5005
											 
										   End	,1,0
	FROM S2_product a JOIN S2_Card b ON a.Item_Code = b.card_code
	JOIN S2_CardDiscountInfo c ON  a.discount = c.cardDiscount_code
	
	

--#########################################################################
--5.S2_CardImage
--#########################################################################		
INSERT INTO S2_CardImage
	(Card_Seq,CardImage_WSize,CardImage_HSize,CardImage_FileName,CardImage_Div)
	
	SELECT b.Card_Seq, CardImage_Wsize,CardImage_Hsize, CardImage_Name,CardImage_Div
	FROM S2_ProductImage a JOIN S2_Card  b ON a.Card_Code = b.Card_Code


--#########################################################################
--5.S2_CardItemGroup
--#########################################################################	
INSERT INTO S2_CardItemGroup
(CardItemGroup_Seq,Card_Seq)

	SELECT b.CardItemGroup_Seq, c.Card_Seq
	FROM S2_Accgr a JOIN S2_CardItemGroupInfo b ON a.gr_name = b.CardItemGroup
	     JOIN S2_Card c ON a.Item_Code = c.Card_Code
	     
	
	
	
--#########################################################################
--6.S2_CardKind
--#########################################################################	
INSERT INTO S2_CardKind
(Card_Seq,CardKind_Seq)
	SELECT 
		b.card_seq,a.gubun

	FROM  (
			SELECT item_Code,1 as gubun FROM S2_product WHERE gubun_1 = 'Yes'
			UNION
			SELECT  item_Code,2  FROM S2_product WHERE gubun_2 = 'Yes'
			UNION
			SELECT  item_Code,3 FROM S2_product WHERE gubun_3 = 'Yes'
			UNION
			SELECT  item_Code,4 FROM S2_product WHERE gubun_4 = 'Yes'
			UNION
			SELECT  item_Code,5 FROM S2_product WHERE gubun_5 = 'Yes'
			UNION
			SELECT  item_Code,6 FROM S2_product WHERE gubun_6 = 'Yes'
			UNION
			SELECT  item_Code,7 FROM S2_product WHERE gubun_7 = 'Yes'
			UNION
			SELECT  item_Code,8 FROM S2_product WHERE gubun_8 = 'Yes'
			UNION
			SELECT  item_Code,9 FROM S2_product WHERE gubun_9 = 'Yes'

		   ) a  JOIN S2_Card  b ON a.Item_Code = b.Card_Code
GO
