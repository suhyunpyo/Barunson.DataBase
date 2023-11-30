IF OBJECT_ID (N'dbo.sp_S2ItemCodeConvert_Test', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2ItemCodeConvert_Test
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[sp_S2ItemCodeConvert_Test] 
	@state as varchar(10)   --update, insert
AS


--begin tran 
--	EXEC sp_S2ItemCodeConvert_Test 'insert'
--rollback


--2010.01.23 ItemCodeConvert 테스트SP  이상민



--##################################################################################################################################################
--0.참조하는 테이블을 먼저 INSERT 함.(S2_CardItemGroupInfo, S2_CardDiscountInfo
--##################################################################################################################################################	

--S2_CardItemGroupInfo  초기화후 INSERT
DELETE FROM S2_CardItemGroupInfo
DBCC CHECKIDENT ( S2_CardItemGroupInfo, RESEED, 0)

--아이템 그룹 구분 (E:봉투그룹, I:속지그룹, S:스티커그룹, L:라이닝 그룹, M:약도카드그룹, A:액세사리그룹, G:내지카드그룹)
INSERT INTO S2_CardItemGroupInfo( CardItemGroup, CardItemGroup_Div )
SELECT DISTINCT gr_Name, CASE gubun when '봉투' then 'E' when '리본' then 'R' when '라이닝' then 'L' WHEN '속지' THEN 'E' WHEN '부속' THEN 'A' WHEN '약도카드' THEN 'M' END 
FROM S2_Accgr ORDER BY gr_name


--S2_CardDiscountInfo  초기화후 INSERT
DELETE FROM S2_CardDiscountInfo
DBCC CHECKIDENT ( S2_CardDiscountInfo, RESEED, 0)

INSERT INTO S2_CardDiscountInfo( CardDiscount_Code, CardDiscount_Div )
SELECT DISTINCT price_code, brand 
FROM S2_price_code order by price_code




--##################################################################################################################################################
--1.S2_Card 
--##################################################################################################################################################

--제품 구분 (A01:카드, A02:내지, A03:내지카드,A04:약도카드,A05:부속품,A06:리본(부속품2),B01:봉투, B02:봉투라이닝, C01:신랑식권, C02:신부신권, C03:미니청첩장,C04:스티커, C05:사은품)
--select * from S2_Acc where gubun = '부속'  and Item_code like '%R'

--update S2_Acc 
--set gubun = '리본'
--where gubun = '부속'  and Item_code like '%R'



SELECT LEFT(A.brand,1) AS CardBrand
	, A.Item_Code AS Card_Code
	, ISNULL(A.Item_Code, A.Item_Code) AS Card_ERPCode
	, 'A01' AS Card_Div
	, A.Name AS Card_Name
	, ISNULL(A.price, 0) AS CardSet_Price
	, ISNULL(A.price_1, 0) AS Card_Price
	, REPLACE(REPLACE(LEFT(REPLACE(A.size, ' ', ''), 3), '*', ''), 'x', '') AS Card_WSize
	, REPLACE(REPLACE(RIGHT(REPLACE(A.size, ' ', ''), 3), '*', ''), 'x', '') AS Card_HSize
	, B.Card_Code AS Card_Code_Product
	, B.Card_Seq AS Card_Seq
INTO #S2_Card
FROM S2_product A
LEFT JOIN S2_Card B ON A.Item_Code = B.Card_Code AND B.Card_Div = 'A01'
UNION ALL
SELECT 'Z' AS CardBrand
	, A.item_Code AS Card_Code
	, ISNULL(A.Erp_code, A.Item_Code) AS Card_ERPCode
		, Case A.gubun WHEN '속지' Then 'A02'
				 WHEN '인사말카드' THEN 'A03'	--내지카드	
				 WHEN '약도카드' THEN 'A04'
				 When '부속' Then 'A05'
				 When '리본' Then 'A06'
				 When '봉투' Then 'B01'
				 When '라이닝' Then 'B02'
 				 When '식권' Then Case When sex = 'M' Then 'C01'
										When sex = 'F' Then 'C02'	End
				 When '미니청첩장' Then 'C03'
				 When '스티커' Then 'C04'
				 WHEN '사은품' THEN 'C05'
			   End AS Card_Div	
	, CASE WHEN  B.card_div='C05' THEN ISNULL(B.Card_Name, B.Card_Code) ELSE C.Name END
	, 0 AS CardSet_Price
	, ISNULL(A.price, 0) AS Card_Price
	, REPLACE(REPLACE(LEFT(REPLACE(A.size, ' ', ''), 3), '*', ''), 'x', '') AS Card_WSize
	, REPLACE(REPLACE(RIGHT(REPLACE(A.size, ' ', ''), 3), '*', ''), 'x', '') AS Card_HSize
	, B.Card_Code AS Card_Code_Product
	, B.Card_Seq AS Card_Seq
FROM S2_Acc A
LEFT JOIN S2_Card B ON A.Item_Code = B.Card_Code AND B.Card_Div <> 'A01'
LEFT JOIN S2_Accgr C ON A.Item_Code = C.Item_Code 


--기존 데이터 UPDATE
UPDATE S2_Card
SET CardBrand	= B.CardBrand
	, Card_Code	= B.Card_Code
	, Card_ERPCode = B.Card_ERPCode
	, Card_Div = B.Card_Div
	, Card_Name = B.Card_Name
	, CardSet_Price = B.CardSet_Price
	, Card_Price = B.Card_Price
	, Card_WSize = B.Card_WSize
	, Card_HSize = B.Card_HSize
FROM S2_Card A
JOIN #S2_Card B ON A.Card_Seq = B.Card_Seq


--신규 데이터 INSERT
INSERT INTO S2_Card ( CardBrand, Card_Code, Card_ERPCode, Card_Div, Card_Name, CardSet_Price, Card_Price, Card_WSize, Card_HSize)
SELECT A.CardBrand, A.Card_Code, A.Card_ERPCode, A.Card_Div, A.Card_Name, A.CardSet_Price, A.Card_Price, A.Card_WSize, A.Card_HSize
FROM #S2_Card A
LEFT JOIN S2_Card B ON A.Card_Code = B.Card_Code 
WHERE B.Card_Seq IS NULL



--S2_Card.Card_Image  업데이트
--S2_CardImage 테이블에서 160사이즈 가지고 와서 업데이트
UPDATE S2_Card
SET Card_Image = B.CardImage_FileName
FROM S2_Card A
JOIN S2_CardImage B ON A.Card_Seq = B.Card_Seq AND CardImage_WSize = 160 AND CardImage_HSize = 160
WHERE ISNULL(A.Card_Image, '') <> ISNULL(B.CardImage_FileName, '' )










--SELECT Card_Code, count(*)
--From S2_Card
--group by Card_Code
--having count(*) > 1


--##################################################################################################################################################
--2.S2_CardDetail 
--##################################################################################################################################################

		
SELECT B.Card_Seq	--카드 시퀀스No
	, ISNULL(C.Card_Seq, 0) AS Env_Seq	--기본봉투
	, ISNULL(D.CardItemGroup_Seq, 0) AS Env_GroupSeq	--봉투그룹
	, ISNULL(E.Card_Seq, 0) AS InPaper_Seq		--내지
	, ISNULL(F.CardItemGroup_Seq, 0) AS InPaper_GroupSeq	--내지그룹
	, ISNULL(G.Card_Seq, 0) AS Acc1_Seq	--기본부속1
	, ISNULL(H.CardItemGroup_Seq, 0) AS Acc1_GroupSeq	--기본부속1 그룹
	, ISNULL(I.Card_Seq, 0) AS Acc2_Seq	--기본부속2
	, ISNULL(J.CardItemGroup_Seq, 0) AS Acc2_GroupSeq	--기본부속2 그룹
	, ISNULL(K.Card_Seq, 0) AS MapCard_Seq	--약도카드
	, NULL AS MapCard_GroupSeq		
	, ISNULL(L.Card_Seq, 0) AS GreetingCard_Seq	--카드구성1
	, NULL AS GreetingCard_GroupSeq
	, ISNULL(M.Card_Seq, 0) AS Lining_Seq	--기본라이닝
	, ISNULL(N.CardItemGroup_Seq, 0) AS Lining_GroupSeq		--라이닝그룹
	, A.comment AS Card_Content		--상품설명
	, NULL AS Card_Shape
	, A.folding AS Card_Folding		--접는방식
	, NULL AS Card_PrintMethod
	, A.mat AS Card_Material		--카드재질
	, NULL AS Card_PrintOffice		
	, A.option_14 AS Minimum_Count			--option_14
	, A.option_15 AS Unit_Count			--option_15
INTO #S2_CardDetail
FROM S2_product A
JOIN S2_Card B ON A.Item_Code = B.card_code AND B.Card_Div = 'A01'
LEFT JOIN S2_Card C ON A.env = C.Card_Code
LEFT JOIN S2_CardItemGroupInfo D ON A.env_gr = D.CardItemGroup
LEFT JOIN S2_Card E ON A.inp = E.Card_Code
LEFT JOIN S2_CardItemGroupInfo F ON A.inp_gr = F.CardItemGroup
LEFT JOIN S2_Card G ON A.acc1 = G.Card_Code
LEFT JOIN S2_CardItemGroupInfo H ON A.acc1_gr = H.CardItemGroup
LEFT JOIN S2_Card I ON A.acc2 = I.Card_Code
LEFT JOIN S2_CardItemGroupInfo J ON A.acc2_gr = J.CardItemGroup
LEFT JOIN S2_Card K ON A.item_map = K.Card_Code
LEFT JOIN S2_Card L ON A.item_info1 = L.Card_Code
LEFT JOIN S2_Card M ON A.lining = M.Card_Code
LEFT JOIN S2_CardItemGroupInfo N ON A.lining_gr = N.CardItemGroup



--기존 데이터 UPDATE
UPDATE S2_CardDetail
SET Card_Seq = B.Card_Seq
	, Env_Seq = B.Env_Seq
	, Env_GroupSeq = B.Env_GroupSeq
	, InPaper_Seq = B.InPaper_Seq
	, InPaper_GroupSeq = B.InPaper_GroupSeq
	, Acc1_Seq = B.Acc1_Seq
	, Acc1_GroupSeq = B.Acc1_GroupSeq
	, Acc2_Seq = B.Acc2_Seq
	, Acc2_GroupSeq = B.Acc2_GroupSeq
	, MapCard_Seq = B.MapCard_Seq
	, MapCard_GroupSeq = B.MapCard_GroupSeq
	, GreetingCard_Seq = B.GreetingCard_Seq
	, GreetingCard_GroupSeq = B.GreetingCard_GroupSeq
	, Lining_Seq = B.Lining_Seq
	, Lining_GroupSeq = B.Lining_GroupSeq
	, Card_Content = B.Card_Content
	, Card_Shape = B.Card_Shape
	, Card_Folding = B.Card_Folding
	, Card_PrintMethod = B.Card_PrintMethod
	, Card_Material = B.Card_Material
	, Card_PrintOffice = B.Card_PrintOffice
	, Minimum_Count = B.Minimum_Count
	, Unit_Count = B.Unit_Count
FROM S2_CardDetail A
JOIN #S2_CardDetail B ON A.Card_Seq = B.Card_Seq 



--신규 데이터 INSERT
INSERT INTO S2_CardDetail 
( 	Card_Seq
	, Env_Seq, Env_GroupSeq
	, InPaper_Seq, InPaper_GroupSeq
	, Acc1_Seq, Acc1_GroupSeq, Acc2_Seq, Acc2_GroupSeq
	, MapCard_Seq, MapCard_GroupSeq
	, GreetingCard_Seq, GreetingCard_GroupSeq
	, Lining_Seq, Lining_GroupSeq
	, Card_Content, Card_Shape
	, Card_Folding, Card_PrintMethod
	, Card_Material, Card_PrintOffice
	, Minimum_Count, Unit_Count 
) 
SELECT A.Card_Seq
	, A.Env_Seq, A.Env_GroupSeq
	, A.InPaper_Seq, A.InPaper_GroupSeq
	, A.Acc1_Seq, A.Acc1_GroupSeq, A.Acc2_Seq, A.Acc2_GroupSeq
	, A.MapCard_Seq, A.MapCard_GroupSeq
	, A.GreetingCard_Seq, A.GreetingCard_GroupSeq
	, A.Lining_Seq, A.Lining_GroupSeq
	, A.Card_Content, A.Card_Shape
	, A.Card_Folding, A.Card_PrintMethod
	, A.Card_Material, A.Card_PrintOffice
	, A.Minimum_Count, A.Unit_Count 
FROM #S2_CardDetail A
LEFT JOIN S2_CardDetail B ON A.Card_Seq = B.Card_Seq 
WHERE B.Card_Seq IS NULL





--##################################################################################################################################################
--3.S2_CardOption 
--##################################################################################################################################################	




SELECT B.Card_Seq
	, CASE A.option_5 WHEN '유료' THEN '1' WHEN '무료' THEN '2' ELSE '0' END	AS IsEmbo
	, CASE A.option_6 WHEN '진회색' THEN '2' WHEN '짙은밤색' THEN '8' WHEN '회색' THEN '7' WHEN 'black' THEN '1' WHEN '선택' THEN '0' ELSE NULL END	AS IsEmboColor
	, CASE A.option_10 WHEN 'Yes' THEN '1' ELSE '0' END AS IsQuick
	, CASE A.option_4 WHEN '유료' THEN '1' WHEN '무료' THEN '2' ELSE '0' END AS IsHandmade
	, CASE A.option_2 WHEN '유료' THEN '1' WHEN '무료' THEN '2' ELSE '0' END AS IsInpaper	--속지접착
	, CASE A.option_3 WHEN '유료' THEN '1' WHEN '무료' THEN '2' ELSE '0' END AS IsJaebon	--속지삽입
	, CASE A.option_1 WHEN '유료' THEN '1' WHEN '무료' THEN '2' ELSE '0' END AS IsEnvInsert
	, CASE A.option_9 WHEN 'Yes' THEN '1' ELSE '0' END AS IsSample
	, CASE A.option_7 WHEN '유료' THEN '1' WHEN '무료' THEN '2' ELSE '0' END AS IsOutsideInitial
	, CASE WHEN A.option_8 IN ( '마스터', '마스터(내부)', '마스터인쇄' ) THEN 'MNN' 
			WHEN A.option_8 IN ('먹박(외부)') THEN 'BYN' 
			WHEN A.option_8 IN ('무광금박') THEN 'GNN' 
			WHEN A.option_8 IN ('무광은박', '무광은박(외부)') THEN 'SNN' 
			WHEN A.option_8 IN ('무박,형압', '무박형압(외부)') THEN 'NNY' 
			WHEN A.option_8 IN ('무은/무금(외부)') THEN 'XXX' 
			WHEN A.option_8 IN ('송진(내부)') THEN 'EBN' 
			WHEN A.option_8 IN ('송진(dark brown)') THEN 'EDN' 
			WHEN A.option_8 IN ('송진(silver)') THEN 'ESN' 
			WHEN A.option_8 IN ('은박(외부)', '은박형압(외부)') THEN 'SNY' 
		END AS PrintMethod
	, CASE A.option_11 WHEN 'Yes' THEN '1' ELSE '0' END AS IsAdd	
	
	, CASE A.jumun_1 WHEN 'Yes' THEN '1' ELSE '0' END AS IsUsrImg1
	, CASE A.jumun_2 WHEN 'Yes' THEN '1' ELSE '0' END AS IsUsrImg2
	, CASE A.jumun_3 WHEN 'Yes' THEN '1' ELSE '0' END AS IsUsrImg3
	, A.jumun_4 AS IsUsrComment	
INTO #S2_CardOption
FROM S2_product A 
JOIN S2_Card B ON A.Item_Code = B.card_code AND B.Card_Div = 'A01'



--기존 데이터 UPDATE
UPDATE S2_CardOption
SET	Card_Seq = B.Card_Seq
	, IsEmbo = B.IsEmbo
	, IsEmboColor = B.IsEmboColor
	, IsQuick = B.IsQuick
	, IsHandmade = B.IsHandmade
	, IsInpaper = B.IsInpaper
	, IsJaebon = B.IsJaebon
	, IsEnvInsert = B.IsEnvInsert
	, IsSample = B.IsSample
	, IsOutsideInitial = B.IsOutsideInitial
	, PrintMethod = B.PrintMethod
	, IsAdd = B.IsAdd
	, IsUsrImg1 = B.IsUsrImg1
	, IsUsrImg2 = B.IsUsrImg2
	, IsUsrImg3 = B.IsUsrImg3
	, IsUsrComment = B.IsUsrComment
FROM S2_CardOption A 
JOIN #S2_CardOption B ON A.Card_Seq = B.Card_Seq




--신규 데이터 INSERT
INSERT INTO S2_CardOption ( Card_Seq, IsEmbo, IsEmboColor,IsQuick, IsHandmade, IsInpaper, IsJaebon, IsEnvInsert, IsSample, IsOutsideInitial, PrintMethod, IsAdd, IsUsrImg1, IsUsrImg2, IsUsrImg3, IsUsrComment )
SELECT A.Card_Seq, A.IsEmbo, A.IsEmboColor, A.IsQuick, A.IsHandmade, A.IsInpaper, A.IsJaebon, A.IsEnvInsert, A.IsSample, A.IsOutsideInitial, A.PrintMethod, A.IsAdd, A.IsUsrImg1, A.IsUsrImg2, A.IsUsrImg3, A.IsUsrComment
FROM #S2_CardOption A 
LEFT JOIN S2_CardOption B ON A.Card_Seq = B.Card_Seq 
WHERE B.Card_Seq IS NULL




--##################################################################################################################################################
--4.S2_CardStyle
--##################################################################################################################################################	

-- drop table #CardStyleGubun
-- delete from #CardStyleGubun



CREATE TABLE   #CardStyleGubun   (
	Brand NCHAR(1) NOT NULL
	, Style_9     int  NULL 
	, CardStyle_Seq     int  NULL  
 )


--더카드용 느낌
-- Style_1 : 1(화려한), 2(심플한), 3(순수한), 4(모던한), 5(동양적인), 6(감각적인) 
  
INSERT INTO #CardStyleGubun
		  SELECT 'B' AS Brand, 1 AS Style_9, 13 AS CardStyle_Seq --modern&traditional
UNION ALL SELECT 'B' AS Brand, 2 AS Style_9, 14 AS CardStyle_Seq --elegant noblesse
UNION ALL SELECT 'B' AS Brand, 3 AS Style_9, 15 AS CardStyle_Seq --sweet pure
UNION ALL SELECT 'B' AS Brand, 4 AS Style_9, 16 AS CardStyle_Seq --romantic flower
UNION ALL SELECT 'B' AS Brand, 5 AS Style_9, 17 AS CardStyle_Seq --trendy chic
		 
UNION ALL SELECT 'W' AS Brand, 1 AS Style_9, 36 AS CardStyle_Seq --전통스타일
UNION ALL SELECT 'W' AS Brand, 2 AS Style_9, 37 AS CardStyle_Seq --모던스타일
UNION ALL SELECT 'W' AS Brand, 3 AS Style_9, 38 AS CardStyle_Seq --로맨틱스타일
UNION ALL SELECT 'W' AS Brand, 4 AS Style_9, 39 AS CardStyle_Seq --심플스타일
UNION ALL SELECT 'W' AS Brand, 5 AS Style_9, 40 AS CardStyle_Seq --큐트스타일
		 
UNION ALL SELECT 'S' AS Brand, 1 AS Style_9, 57 AS CardStyle_Seq --luxury initial
UNION ALL SELECT 'S' AS Brand, 2 AS Style_9, 58 AS CardStyle_Seq --modern classic
UNION ALL SELECT 'S' AS Brand, 3 AS Style_9, 59 AS CardStyle_Seq --romantic flower
UNION ALL SELECT 'S' AS Brand, 4 AS Style_9, 60 AS CardStyle_Seq --oriental tradition
		 
UNION ALL SELECT 'P' AS Brand, 1 AS Style_9, 25 AS CardStyle_Seq --우아하고 세련된
UNION ALL SELECT 'P' AS Brand, 2 AS Style_9, 26 AS CardStyle_Seq --여성스럽고 감성적인
UNION ALL SELECT 'P' AS Brand, 3 AS Style_9, 27 AS CardStyle_Seq --독특하고 감각적인
UNION ALL SELECT 'P' AS Brand, 4 AS Style_9, 28 AS CardStyle_Seq --톡톡튀고 스타일리쉬한
UNION ALL SELECT 'P' AS Brand, 5 AS Style_9, 29 AS CardStyle_Seq --럭셔리한
		 
UNION ALL SELECT 'H' AS Brand, 1 AS Style_9, 46 AS CardStyle_Seq --모던스타일
UNION ALL SELECT 'H' AS Brand, 2 AS Style_9, 47 AS CardStyle_Seq --로맨틱스타일
UNION ALL SELECT 'H' AS Brand, 3 AS Style_9, 48 AS CardStyle_Seq --남다른개성
UNION ALL SELECT 'H' AS Brand, 4 AS Style_9, 49 AS CardStyle_Seq --부모님이선호하는
UNION ALL SELECT 'H' AS Brand, 5 AS Style_9, 50 AS CardStyle_Seq --착한가격높은품질
UNION ALL SELECT 'H' AS Brand, 6 AS Style_9, 51 AS CardStyle_Seq --보편적으로사랑받는


--Delete후 Insert함
DELETE FROM S2_CardStyle 


INSERT INTO S2_CardStyle (Card_Seq, CardStyle_Seq)
SELECT B.card_seq
	, CASE Style_1 WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 3 THEN 3 WHEN 4 THEN 4 WHEN 5 THEN 5 WHEN 6 THEN 6 ELSE NULL END CardStyle_Seq 
FROM S2_product A 
JOIN S2_Card B ON A.Item_Code = B.Card_Code AND B.Card_Div = 'A01'
WHERE IsNull(Style_1,0) > 0		--더카드용_느낌
UNION ALL
SELECT B.Card_Seq
	, D.CardStyle_Seq
FROM S2_product A
JOIN S2_Card B ON A.Item_Code = B.Card_Code 
LEFT JOIN #CardStyleGubun D ON LEFT(LTRIM(A.Brand), 1) = LEFT(LTRIM(D.Brand), 1) AND A.Style_9 = D.Style_9
WHERE IsNull(A.Style_9,0) > 0	--개별느낌


INSERT INTO S2_CardStyle ( Card_Seq, CardStyle_Seq )
SELECT B.Card_Seq, A.CardStyle_Seq
FROM ( 
				SELECT Item_Code, 7 AS CardStyle_Seq  FROM S2_product  WHERE Style_3 = 'Yes'  --더카드용 리본 및 띠지	
	UNION ALL	SELECT Item_Code, 8 AS CardStyle_Seq  FROM S2_product  WHERE Style_4 = 'Yes' --더카드용오브제		
	UNION ALL	SELECT Item_Code, 9 AS CardStyle_Seq  FROM S2_product  WHERE Style_5 = 'Yes' --더카드용_포토
	UNION ALL	SELECT Item_Code, 10 AS CardStyle_Seq FROM S2_product  WHERE Style_6 = 'Yes' --더카드용_이니셜 및 타이포
	UNION ALL	SELECT Item_Code, 11 AS CardStyle_Seq FROM S2_product  WHERE Style_7 = 'Yes' --더카드용_조각 양각 가공
	UNION ALL	SELECT Item_Code, 12 AS CardStyle_Seq FROM S2_product  WHERE Style_8 = 'Yes'	--더카드용_금색용지

	UNION ALL	SELECT Item_Code, CASE LEFT(LTRIM(brand), 1) WHEN 'B' THEN 18 WHEN 'P' THEN 30 WHEN 'W' THEN 41 WHEN 'H' THEN 52 WHEN 'S' THEN 61 ELSE NULL END AS CardStyle_Seq FROM S2_product  WHERE Style_10 = 'Yes'
	UNION ALL	SELECT Item_Code, CASE LEFT(LTRIM(brand), 1) WHEN 'B' THEN 19 WHEN 'P' THEN 31 WHEN 'W' THEN 42 WHEN 'H' THEN 53 WHEN 'S' THEN 62 ELSE NULL END AS CardStyle_Seq FROM S2_product  WHERE Style_11 = 'Yes'
	UNION ALL	SELECT Item_Code, CASE LEFT(LTRIM(brand), 1) WHEN 'B' THEN 20 WHEN 'P' THEN 32 WHEN 'W' THEN 43 WHEN 'H' THEN 54 WHEN 'S' THEN 63 ELSE NULL END AS CardStyle_Seq FROM S2_product  WHERE Style_12 = 'Yes'
	UNION ALL	SELECT Item_Code, CASE LEFT(LTRIM(brand), 1) WHEN 'B' THEN 21 WHEN 'P' THEN 33 WHEN 'W' THEN 44 WHEN 'H' THEN 55 WHEN 'S' THEN 64 ELSE NULL END AS CardStyle_Seq FROM S2_product  WHERE Style_13 = 'Yes'
	UNION ALL	SELECT Item_Code, CASE LEFT(LTRIM(brand), 1) WHEN 'B' THEN 22 WHEN 'P' THEN 34 WHEN 'W' THEN 45 WHEN 'H' THEN 56 ELSE NULL END AS CardStyle_Seq FROM S2_product  WHERE Style_14 = 'Yes'
	UNION ALL	SELECT Item_Code, CASE LEFT(LTRIM(brand), 1) WHEN 'B' THEN 23 WHEN 'P' THEN 35 ELSE NULL END AS CardStyle_Seq FROM S2_product  WHERE Style_15 = 'Yes'
	UNION ALL	SELECT Item_Code, CASE LEFT(LTRIM(brand), 1) WHEN 'B' THEN 24 WHEN 'P' THEN 36 ELSE NULL END AS CardStyle_Seq FROM S2_product  WHERE Style_16 = 'Yes'
) A 
JOIN  S2_Card B ON A.Item_Code = B.Card_Code AND B.Card_Div = 'A01'
ORDER BY  B.Card_Seq, A.CardStyle_Seq
		

--임시로 수동으로 입력하기로 함-20100127 BEGIN 

--부티크
INSERT INTO S2_CardStyle
SELECT '65', Card_seq FROM S2_Card 
WHERE Card_Code IN ( 'P0301', 'P0302', 'P0303', 'P0304', 'P0305', 'P0306', 'P0307', 'P0308', 'P0309', 'P0310', 'P0311', 'P0312', 'P0313', 'P0314', 'P0315', 'P0316', 'P0331', 'P0342', 'P0343' )

--퍼퓸
INSERT INTO S2_CardStyle
SELECT '68', Card_seq FROM S2_Card 
WHERE Card_Code IN ( 'P0318', 'P0319', 'P0320', 'P0321', 'P0322', 'P0323', 'P0326', 'P0327', 'P0329', 'P0332', 'P0333', 'P0334' )

--롤리팝
INSERT INTO S2_CardStyle
SELECT '66', Card_seq FROM S2_Card 
WHERE Card_Code IN ( 'P0336', 'P0337', 'P0338', 'P0339', 'P0340', 'P0341')

--포토그래피
INSERT INTO S2_CardStyle
SELECT '67', Card_seq FROM S2_Card 
WHERE Card_Code IN ( 'P0344', 'P0345', 'P0346', 'P0347', 'P0348', 'P0349', 'P0350', 'P0351', 'P0352', 'P0353')

--스타일x
--'P0354', 'P0355', 'P0356', 'P0357'

--아트
INSERT INTO S2_CardStyle
SELECT '69', Card_seq FROM S2_Card 
WHERE Card_Code IN ( 'P0363', 'P0364', 'P0365', 'P0366', 'P0367', 'P0368', 'P0369', 'P0370')

--임시로 수동으로 입력하기로 함-20100127 END 

		
--SELECT * FROM S2_CardStyle  
--ORDER BY  Card_Seq, CardStyle_Seq


--##################################################################################################################################################
--5.S2_CardDiscount
--##################################################################################################################################################	

	--drop table #price_code_Gubun

	--SELECT price_code
	--	, Case When price_code = 'B_code1' Then 1
	--			When price_code = 'B_code2' Then 2
	--			When price_code = 'W_code1' Then 3
	--			When price_code = 'P_code1' Then 4
	--			When price_code = 'H_code1' Then 5
	--			When price_code = 'S_code1' Then 6
	--			When price_code = 'H_code2' Then 7
	--			When price_code = 'W_code2' Then 8
	--		End AS price_codeGubun
	--INTO #price_code_Gubun
	--FROM  S2_price_code



	DELETE FROM S2_CardDiscount
		
	INSERT INTO S2_CardDiscount	(CardDiscount_Seq, MinCount, MaxCount, Discount_Rate)	
	SELECT B.CardDiscount_Seq, A.mincount, A.maxcount, A.discount
	FROM (
		SELECT A.price_code, 50 as mincount , 99 as maxcount , p_50*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 100 as mincount , 149 as maxcount , p_100*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 150 as mincount , 199 as maxcount , p_150*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 200 as mincount , 249 as maxcount , p_200*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 250 as mincount , 299 as maxcount , p_250*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 300 as mincount , 349 as maxcount , p_300*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 350 as mincount , 399 as maxcount , p_350*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 400 as mincount , 449 as maxcount , p_400*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 450 as mincount , 499 as maxcount , p_450*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 500 as mincount , 549 as maxcount , p_500*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 550 as mincount , 599 as maxcount , p_550*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 600 as mincount , 649 as maxcount , p_600*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 650 as mincount , 699 as maxcount , p_650*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 700 as mincount , 749 as maxcount , p_700*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 800 as mincount , 899 as maxcount , p_800*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 900 as mincount , 999 as maxcount , p_900*100 as discount	FROM  S2_price_code A	UNION ALL
		SELECT A.price_code, 1000 as mincount , 10000 as maxcount , p_1000*100 as discount	FROM  S2_price_code A	
	) A
	LEFT JOIN S2_CardDiscountInfo B ON A.price_code = B.CardDiscount_Code 
	
	
 --INSERT INTO S2_CardDiscountInfo VALUES ( 'H_code2', 'H')
 --INSERT INTO S2_CardDiscountInfo VALUES ( 'W_code2', 'W')

	
--##################################################################################################################################################
--6.S2_CardSalesSite
--##################################################################################################################################################	


--당분간 임시로 랭크데이터 입력.20100203
select A.Card_Seq, B.Card_Code, A.Ranking 
INTO #S2_CardSort
from S2_CardSalesSite A
JOIN S2_Card B ON A.Card_seq = B.Card_Seq
order by B.Card_Code, A.Card_seq



DELETE FROM S2_CardSalesSite

INSERT INTO S2_CardSalesSite (Card_Seq, CardDiscount_Seq, Company_Seq, IsDisplay, IsNew)
SELECT b.card_seq
	, c.CardDiscount_Seq
	, Case When Left(a.brand,1) = 'B' Then 5001
			When Left(a.brand,1) = 'W' Then 5002
			When Left(a.brand,1) = 'S' Then 5003
			When Left(a.brand,1) = 'H' Then 5004
			When Left(a.brand,1) = 'P' Then 5005
		End	AS Company_Seq
	, CASE a.option_13 WHEN 'YES' THEN 1 ELSE 0 END AS IsDisplay	--전시 여부  (0:전시내림, 1:전시, 2:일시품절)
	, CASE a.option_12 WHEN 'YES' THEN 1 ELSE 0 END AS IsNew	--신상품 여부 Yes:1
	--, 1 AS IsJumun --주문가능여부 (0:모든판매불가, 1:모든판매가능,2:추가주문및 결제 가능, 3:원주문 가능, 4:추가주문 가능)
FROM S2_product a 
JOIN S2_Card b ON a.Item_Code = b.card_code
JOIN S2_CardDiscountInfo c ON  a.discount = c.cardDiscount_code
UNION ALL
SELECT b.card_seq
	, NULL AS CardDiscount_Seq
	, Case When Left(a.brand,1) = 'B' Then 5001
			When Left(a.brand,1) = 'W' Then 5002
			When Left(a.brand,1) = 'S' Then 5003
			When Left(a.brand,1) = 'H' Then 5004
			When Left(a.brand,1) = 'P' Then 5005
		End	AS Company_Seq
	, '1' AS IsDisplay
	, '0' AS IsNew
FROM S2_Acc a 
JOIN S2_Card b ON a.Item_Code = b.card_code
WHERE ISNULL(RTRIM(a.brand), '') <> '' --AND gubun in ( '식권', '미니청첩장' ) 


--김수경 과장 식권세트 Insert 구문.
INSERT INTO S2_CardSalesSite ( Card_Seq, Company_Seq )
SELECT Card_seq, SUBSTRING(Card_Code, 3, 4) AS Company_seq from s2_card where card_div='C06' order by card_code


--select * from s2_cardsalessite where card_Seq in (select card_seq from s2_card where card_div='C06') order by Company_seq



-- 랭크 업데이트
UPDATE S2_CardSalesSite 
Set Ranking = c.Ranking
FROM S2_CardSalesSite a 
JOIN S2_Card b ON a.Card_seq = b.Card_Seq
JOIN #S2_CardSort  c ON b.Card_code = c.Card_Code



--select * from S2_CardDiscount WHERE CardDiscount_seq = 6
--select * from S2_CardSalesSite order by Card_seq





--##################################################################################################################################################
--7.S2_CardImage
--##################################################################################################################################################		

--SELECT * FROM S2_CardImage
--SELECT * FROM S2_ProductImage

delete from S2_CardImage
DBCC CHECKIDENT ( S2_CardImage, RESEED, 0)


UPDATE S2_CardImage
SET Card_Seq = B.Card_Seq
	, CardImage_WSize = C.CardImage_WSize
	, CardImage_HSize = C.CardImage_HSize
	, CardImage_FileName = C.CardImage_Name
	, CardImage_DIV = C.CardImage_DIV
FROM S2_CardImage A
JOIN S2_Card B ON A.Card_Seq = B.Card_Seq
JOIN S2_ProductImage C ON B.Card_Code = C.Card_Code AND A.CardImage_FileName = C.CardImage_Name



INSERT INTO S2_CardImage ( Card_Seq, CardImage_WSize, CardImage_HSize, CardImage_FileName, CardImage_Div )
SELECT B.Card_Seq, A.CardImage_Wsize, A.CardImage_Hsize, A.CardImage_Name, A.CardImage_Div
FROM S2_ProductImage A 
JOIN S2_Card  B ON A.Card_Code = B.Card_Code
LEFT JOIN S2_CardImage C ON B.Card_Seq = C.Card_Seq AND C.CardImage_FileName = A.CardImage_Name
WHERE C.CardImage_FileName IS NULL







--##################################################################################################################################################
--8.S2_CardItemGroup
--##################################################################################################################################################	


DELETE FROM S2_CardItemGroup

INSERT INTO S2_CardItemGroup (CardItemGroup_Seq, Card_Seq )
SELECT b.CardItemGroup_Seq
	, c.Card_Seq
FROM S2_Accgr a 
JOIN S2_CardItemGroupInfo b ON a.gr_name = b.CardItemGroup
JOIN S2_Card c ON a.Item_Code = c.Card_Code AND C.Card_Div <> 'A01'


--select * from S2_Card where Card_seq IN ( select Card_seq from  S2_CardItemGroup )
--select * from S2_Card where Card_Code IN ( select Item_code from  S2_Accgr )
	
	
	
--##################################################################################################################################################
--9.S2_CardKind
--##################################################################################################################################################	

DELETE FROM S2_CardKind 

INSERT INTO S2_CardKind ( Card_Seq, CardKind_Seq )
SELECT B.card_seq, A.gubun
FROM  (
	SELECT Item_Code, 1 as gubun FROM S2_product WHERE ISNULL(gubun_1, '') ='Yes' UNION ALL
	SELECT Item_Code, 2 as gubun FROM S2_product WHERE ISNULL(gubun_2, '') ='Yes' UNION ALL
	SELECT Item_Code, 3 as gubun FROM S2_product WHERE ISNULL(gubun_3, '') ='Yes' UNION ALL
	SELECT Item_Code, 4 as gubun FROM S2_product WHERE ISNULL(gubun_4, '') ='Yes' UNION ALL
	SELECT Item_Code, 5 as gubun FROM S2_product WHERE ISNULL(gubun_5, '') ='Yes' UNION ALL
	SELECT Item_Code, 6 as gubun FROM S2_product WHERE ISNULL(gubun_6, '') ='Yes' UNION ALL
	SELECT Item_Code, 7 as gubun FROM S2_product WHERE ISNULL(gubun_7, '') ='Yes' UNION ALL
	SELECT Item_Code, 8 as gubun FROM S2_product WHERE ISNULL(gubun_8, '') ='Yes' UNION ALL
	SELECT Item_Code, 9 as gubun FROM S2_product WHERE ISNULL(gubun_9, '') ='Yes' UNION ALL
	SELECT Item_Code, 10 as gubun FROM S2_product WHERE ISNULL(gubun_10, '') ='Yes' 
) A
JOIN S2_Card B ON A.Item_Code = B.Card_Code







--###############################################################################################
--김수경 과장요청 BEGIN
--###############################################################################################

--감사장 스티커 안보이게
update S2_cardsalessite set isJumun='0' ,isDisplay='0' where card_seq = 32480

-- 엠보인쇄 색상 NULL을 0으로 치환
update S2_CardOption set isEmboColor='0' where isEmboColor is null

--한지답례장은 스티커 옵션 주문 안되게 업데이트.
update S2_CardOption set isSticker='0' where card_seq in (30664,30665,30666,30667)

-- -- --------------------------------------------------------------------------------
-- 사은품 이미지 업데이트
update s2_Card set card_image='5001Gift1_160.jpg' where card_seq = 32438
update s2_Card set card_image='5001Gift2_160.jpg' where card_seq = 32450
update s2_Card set card_image='5002GiftAll_160.jpg' where card_seq = 32474
update s2_Card set card_image='5002Gift_160.jpg' where card_seq = 32475
update s2_Card set card_image='5004GiftAll_160.jpg' where card_seq = 32473
update s2_Card set card_image='5004Gift_160.jpg' where card_seq = 32309
update s2_Card set card_image='5005Gift_160.jpg' where card_seq = 32308


--###############################################################################################
--김수경 과장요청 END
--###############################################################################################






DROP TABLE #S2_Card
DROP TABLE #S2_CardDetail
DROP TABLE #S2_CardOption
DROP TABLE #CardStyleGubun
--DROP TABLE #price_code_Gubun

GO
