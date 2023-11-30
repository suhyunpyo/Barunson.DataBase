IF OBJECT_ID (N'dbo.sp_BarunsonRanking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_BarunsonRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- 
-- select * from card where card_seq = 183
-- 
-- 
--  SELECT TOP 10 b.card_img_ms, a.card_seq, b.card_code, count(*) as cnt
-- 
-- 	    FROM
-- 	    custom_order a JOIN card b ON a.card_seq = b.card_seq 
-- 	    WHERE sales_gubun = 'W' and DATEDIFF(ww,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.card_kind ='1' and b.card_group='0'
-- 		 GROUP BY a.card_seq, b.card_code, b.card_img_ms
-- ORDER BY cnt DESC
-- 	


--exec sp_BarunsonRanking '1'

CREATE   PROC [dbo].[sp_BarunsonRanking]
	@Gubun as char(1)
AS

    SET NOCOUNT ON
	
    IF @Gubun = '1'  -- 주간구매	
	BEGIN
	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , b.card_img_ms, a.card_seq, b.card_code, count(*) as cnt
	    INTO #PastRank
	    FROM
	    custom_order a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE sales_gubun = 'W' and DATEDIFF(ww,src_send_date,getdate()) = 2   and display_yes_or_no='1' and  b.is100='1' 
	    GROUP BY a.card_seq, b.card_code, b.card_img_ms
	    ORDER BY cnt DESC
	
	
	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , b.card_img_ms,  a.card_seq, b.card_code, count(*) as cnt
	    INTO #Rank
	    FROM
	    custom_order a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE sales_gubun = 'W' and DATEDIFF(ww,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
	    GROUP BY a.card_seq, b.card_code, a.status_seq, b.card_img_ms
	    ORDER BY cnt DESC
	    
	    
	    INSERT INTO  BestRanking			
	  	    SELECT 'W' as sales_gubun,a.rank,a.card_seq,a.card_code,a.card_img_ms, a.cnt
			, Ranking =  Case
		             		When b.rank is null Then 'nnew'
				Else
					Case	    	
				              	When  a.rank = b.rank Then '-0'
						
	
						When a.rank > b.rank Then   'd' + CAST((a.rank-b.rank) as char(2)) --a.rank - b.rank   --순위 내려갔을 경우
						When a.rank < b.rank Then   'u' + CAST((b.rank-a.rank) as char(2)) --a.rank - b.rank   --순위 올라갔을 경우
						Else ''	 	
		
					End	
			       End,getdate(),1
		   FROM #Rank a LEFT JOIN #PastRank b ON a.card_seq = b.card_seq ORDER BY a.cnt DESC 		
		
	END

   ELSE IF @Gubun = '2'	--월간구매
	BEGIN
	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , b.card_img_ms, a.card_seq, b.card_code, count(*) as cnt
	    INTO #PastRank2
	    FROM
	    custom_order a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE sales_gubun = 'W' and DATEDIFF(mm,src_send_date,getdate()) = 2   and display_yes_or_no='1'  and  b.is100='1' 
	    GROUP BY a.card_seq, b.card_code, b.card_img_ms
	    ORDER BY cnt DESC
	
	
	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , b.card_img_ms,  a.card_seq, b.card_code, count(*) as cnt
	    INTO #Rank2
	    FROM
	    custom_order a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE sales_gubun = 'W' and DATEDIFF(mm,src_send_date,getdate()) = 1   and display_yes_or_no='1' and  b.is100='1' 
	    GROUP BY a.card_seq, b.card_code, a.status_seq, b.card_img_ms
	    ORDER BY cnt DESC

	
                  INSERT INTO  BestRanking	
  	    SELECT 'W' as sales_gubun,a.rank,a.card_seq,a.card_code,a.card_img_ms, a.cnt
		, Ranking =  Case
	             		When b.rank is null Then 'nnew'
			Else
				Case	    	
			              	When  a.rank = b.rank Then '-0'
					

					When a.rank > b.rank Then   'd' + CAST((a.rank-b.rank) as char(2)) --a.rank - b.rank   --순위 내려갔을 경우
					When a.rank < b.rank Then   'u' + CAST((b.rank-a.rank) as char(2)) --a.rank - b.rank   --순위 올라갔을 경우
					Else ''	 	
	
				End	
		       End,getdate(),2
	   FROM #Rank2 a LEFT JOIN #PastRank2 b ON a.card_seq = b.card_seq ORDER BY a.cnt DESC 

	END


   ELSE IF @Gubun = '3'	--샘플구매
	BEGIN

	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , c.card_img_ms, c.card_seq, c.card_code, count(*) as cnt
	    INTO #PastRank3
	    FROM
	    custom_sample_order a JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq 
	    JOIN card c ON b.card_seq = c.card_seq 
	    WHERE a.sales_gubun = 'W' and DATEDIFF(mm,delivery_date,getdate()) = 2   and display_yes_or_no='1'  and  c.is100='1' 
	    GROUP BY c.card_seq, c.card_code, c.card_img_ms
	    ORDER BY cnt DESC
	
	
	     SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , c.card_img_ms, c.card_seq, c.card_code, count(*) as cnt
	    INTO #Rank3
	    FROM
	    custom_sample_order a JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq
	    JOIN card c ON b.card_seq = c.card_seq 
	    WHERE a.sales_gubun = 'W' and DATEDIFF(mm,delivery_date,getdate()) = 1   and display_yes_or_no='1'  and c.is100='1' 
	    GROUP BY c.card_seq, c.card_code, c.card_img_ms
	    ORDER BY cnt DESC


	     INSERT INTO  BestRanking	
  	    SELECT 'W' as sales_gubun,a.rank,a.card_seq,a.card_code,a.card_img_ms, a.cnt
		, Ranking =  Case
	             		When b.rank is null Then 'nnew'
			Else
				Case	    	
			              	When  a.rank = b.rank Then '-0'
					

					When a.rank > b.rank Then   'd' + CAST((a.rank-b.rank) as char(2)) --a.rank - b.rank   --순위 내려갔을 경우
					When a.rank < b.rank Then   'u' + CAST((b.rank-a.rank) as char(2)) --a.rank - b.rank   --순위 올라갔을 경우
					Else ''	 	
	
				End	
		       End,getdate(),3
	   FROM #Rank3 a LEFT JOIN #PastRank3 b ON a.card_seq = b.card_seq ORDER BY a.cnt DESC 
	END

   ELSE IF @Gubun = '4'	 --찜카드
	BEGIN

	

	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , b.card_img_ms, b.card_seq, b.card_code, count(*) as cnt
	    INTO #PastRank4
	    FROM 
	    custom_private_choice a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE b.display_yes_or_no='1' and DATEDIFF(mm,regdate,getdate()) = 1 and b.is100='1' 
	    GROUP BY b.card_seq, b.card_code, b.card_img_ms
	    ORDER BY cnt DESC
	
	
	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , b.card_img_ms, b.card_seq, b.card_code, count(*) as cnt
	    INTO #Rank4
	    FROM 
	    custom_private_choice a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE b.display_yes_or_no='1' and DATEDIFF(mm,regdate,getdate()) = 2 and b.is100='1' 
	    GROUP BY b.card_seq, b.card_code, b.card_img_ms
	    ORDER BY cnt DESC



	     INSERT INTO  BestRanking	 	
  	    SELECT 'W' as sales_gubun,a.rank,a.card_seq,a.card_code,a.card_img_ms, a.cnt
		, Ranking =  Case
	             		When b.rank is null Then 'nnew'
			Else
				Case	    	
			              	When  a.rank = b.rank Then '-0'
					

					When a.rank > b.rank Then   'd' + CAST((a.rank-b.rank) as char(2)) --a.rank - b.rank   --순위 내려갔을 경우
					When a.rank < b.rank Then   'u' + CAST((b.rank-a.rank) as char(2)) --a.rank - b.rank   --순위 올라갔을 경우
					Else ''	 	
	
				End	
		       End,getdate(),4
	   FROM #Rank4 a LEFT JOIN #PastRank4 b ON a.card_seq = b.card_seq ORDER BY a.cnt DESC 
	END

   ELSE IF @Gubun = '5'	--이용후기


	BEGIN
	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , b.card_img_ms, a.card_seq, b.card_code, count(*) as cnt
	    INTO #PastRank5
	    FROM
	    card_user_commnet  a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE a.sales_gubun = 'W' and DATEDIFF(dd,regdate,getdate()) between 30 and 60  and b.display_yes_or_no='1' and b.is100='1' 
	    GROUP BY a.card_seq, b.card_code, b.card_img_ms
	    ORDER BY cnt DESC
	
	
	    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank , b.card_img_ms,  a.card_seq, b.card_code, count(*) as cnt
	    INTO #Rank5
	    FROM
	    card_user_commnet a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE a.sales_gubun = 'W' and DATEDIFF(dd,regdate,getdate()) <= 30  and b.display_yes_or_no='1' and b.is100='1' 
	     GROUP BY a.card_seq, b.card_code, b.card_img_ms
	    ORDER BY cnt DESC


	    INSERT INTO  BestRanking	
  	    SELECT 'W' as sales_gubun,a.rank,a.card_seq,a.card_code,a.card_img_ms, a.cnt
		, Ranking =  Case
	             		When b.rank is null Then 'nnew'
			Else
				Case	    	
			              	When  a.rank = b.rank Then '-0'
					

					When a.rank > b.rank Then   'd' + CAST((a.rank-b.rank) as char(2)) --a.rank - b.rank   --순위 내려갔을 경우
					When a.rank < b.rank Then   'u' + CAST((b.rank-a.rank) as char(2)) --a.rank - b.rank   --순위 올라갔을 경우
					Else ''	 	
	
				End	
		       End,getdate(),5
	   FROM #Rank5 a LEFT JOIN #PastRank5 b ON a.card_seq = b.card_seq ORDER BY a.cnt DESC 
	END   		
	

--     SELECT * FROM #PastRank    ORDER BY    cnt  DESC
--     SELECT * FROM #Rank    ORDER BY    cnt  DESC	
 

	
	

    SET NOCOUNT OFF



GO
