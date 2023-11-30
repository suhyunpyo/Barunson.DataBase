IF OBJECT_ID (N'dbo.sp_TiaraRanking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_TiaraRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select * from TiaraBestRanking where gubun='PC'
--exec sp_TiaraRanking 
CREATE    PROC [dbo].[sp_TiaraRanking]
	
AS

    SET NOCOUNT ON
	
	DELETE TiaraBestRanking
	
	-- Weekly 구매랭킹	
	INSERT TiaraBestRanking 
		SELECT TOP 20  a.card_seq,getdate(), count(*) as cnt, 'WB' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(ww,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
		GROUP BY a.card_seq
		ORDER BY cnt DESC 

	 --월간구매
	INSERT TiaraBestRanking	
		SELECT TOP 20  a.card_seq,getdate(), count(*) as cnt, 'MB' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
		GROUP BY a.card_seq
		ORDER BY cnt DESC

	--샘플구매
	INSERT INTO  TiaraBestRanking	
		SELECT TOP 20  c.card_seq,getdate(), count(*) as cnt, 'SB' as gubun
		FROM
		custom_sample_order a JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
		JOIN card c ON b.card_seq = c.card_seq 
		WHERE a.sales_gubun = 'A' and DATEDIFF(mm,delivery_date,getdate()) = 1   and display_yes_or_no='1'  and c.is100='1' 
		GROUP BY c.card_seq
		ORDER BY cnt DESC

	--이용후기
	INSERT INTO  TiaraBestRanking	
		SELECT TOP 20  card_seq,getdate(), count(*) as cnt, 'RB' as gubun
		FROM
		card_user_commnet
		WHERE sales_gubun = 'A' and DATEDIFF(mm,regdate,getdate()) = 1   
		GROUP BY card_seq
		ORDER BY cnt DESC
	

   --여성베스트
   INSERT INTO  TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'SF' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		JOIN tiara_member c ON a.member_id = c.uid 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' and c.sex ='F'
		GROUP BY a.card_seq
		ORDER BY cnt DESC 
   
   --남성베스트
   INSERT INTO  TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'SM' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		JOIN tiara_member c ON a.member_id = c.uid 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' and c.sex ='M'
		GROUP BY a.card_seq
		ORDER BY cnt DESC 
   
   
  -- --20대베스트		
  -- INSERT INTO  TiaraBestRanking	
		--SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'AA' as gubun
		--FROM
		--custom_order a JOIN card b ON a.card_seq = b.card_seq 
		--JOIN tiara_member c ON a.member_id = c.uid 
		--WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
		--	  and (Year(getdate()) - Cast(Left(birth,4) as integer))/10 = 2
		--GROUP BY a.card_seq
		--ORDER BY cnt DESC 	
	

  -- --30대베스트		
  -- INSERT INTO  TiaraBestRanking	
		--SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'AB' as gubun
		--FROM
		--custom_order a JOIN card b ON a.card_seq = b.card_seq 
		--JOIN tiara_member c ON a.member_id = c.uid 
		--WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
		--	  and (Year(getdate()) - Cast(Left(birth,4) as integer))/10 = 3
		--GROUP BY a.card_seq
		--ORDER BY cnt DESC 	

  -- --40대베스트		
  -- INSERT INTO  TiaraBestRanking	
		--SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'AC' as gubun
		--FROM
		--custom_order a JOIN card b ON a.card_seq = b.card_seq 
		--JOIN tiara_member c ON a.member_id = c.uid 
		--WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
		--	  and (Year(getdate()) - Cast(Left(birth,4) as integer))/10 = 4
		--GROUP BY a.card_seq
		--ORDER BY cnt DESC 	

  -- --50대베스트		
  -- INSERT INTO  TiaraBestRanking	
		--SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'AD' as gubun
		--FROM
		--custom_order a JOIN card b ON a.card_seq = b.card_seq 
		--JOIN tiara_member c ON a.member_id = c.uid 
		--WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
		--	  and (Year(getdate()) - Cast(Left(birth,4) as integer))/10 = 5
		--GROUP BY a.card_seq
		--ORDER BY cnt DESC 	

	--가격대 (300~600원)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'PA' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and card_price_customer between '300' and '699'
		GROUP BY a.card_seq
		ORDER BY cnt DESC
	
	--가격대 (700~1000원)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'PB' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and card_price_customer between '700' and '1099'
		GROUP BY a.card_seq
		ORDER BY cnt DESC
		
	--가격대 (1100~1400원)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'PC' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and card_price_customer between '1100' and '1499'
		GROUP BY a.card_seq
		ORDER BY cnt DESC	
		
		
	--가격대 (1500원 이상)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'PD' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and card_price_customer >= '1500' 
		GROUP BY a.card_seq
		ORDER BY cnt DESC	
		
	--브랜드별 (티아라,유사미디자인스)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'BA' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and b.company in (13,15)
		GROUP BY a.card_seq
		ORDER BY cnt DESC			
		
	--브랜드별 (바른손카드)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'BB' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and b.company = 1
		GROUP BY a.card_seq
		ORDER BY cnt DESC		
		
	
	--브랜드별 (위시메이드)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'BD' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and b.company = 2
		GROUP BY a.card_seq
		ORDER BY cnt DESC	
		
	--브랜드별 (해피카드)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'BE' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and b.company = 8
		GROUP BY a.card_seq
		ORDER BY cnt DESC		
	
	
	--브랜드별 (스튜디오진,벨라피오레)
	INSERT TiaraBestRanking	
		SELECT TOP 10  a.card_seq,getdate(), count(*) as cnt, 'BF' as gubun
		FROM
		custom_order a JOIN card b ON a.card_seq = b.card_seq 
		WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
			  and b.company in (12,14)
		GROUP BY a.card_seq
		ORDER BY cnt DESC	
			
    SET NOCOUNT OFF
GO
