IF OBJECT_ID (N'dbo.sp_S2BestRanking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2BestRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE         PROC [dbo].[sp_S2BestRanking]
AS
	Declare 	@card_seq integer	
	Declare @company_seq integer
	Declare	@cnt	integer
	Declare	@rank	integer
	Declare @Gubun char(1)
	Declare @gubun_data varchar(10)


	set @gubun_data=convert(varchar(10),getdate(),21)
	
	delete from BestRanking_New where Gubun_data = @gubun_data
	
--주간 주문 수량.(30위 안의 데이타는 BestRanking_new 테이블에 저장, S2_salessite.ranking_w 업데이트)
	set @Gubun = '0'
	set @company_seq=5001
	while (@company_seq<=5005)
	begin
		set @rank = 0
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT card_seq, sum(order_count) as cnt
			FROM
			custom_order
			WHERE company_seq = @company_seq and DATEDIFF(dd,src_send_date,getdate())>0 and DATEDIFF(dd,src_send_date,getdate())<=7 and status_seq=15 and order_Type in ('1','6','7')
			group by sales_gubun,card_seq
			order by cnt desc
		OPEN item_cursor
	
		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			-- 30 위 안에 들 경우 별도 테이블에 저장
			if @rank <=30
				insert into BestRanking_New(company_seq,rank,card_seq,cnt,gubun,gubun_data) values(@company_seq,@rank,@card_seq,@cnt,@Gubun,@gubun_data)

			-- 주간 랭킹 저장
			if @company_seq=5001
			update s2_cardsalessite set ranking_w=@rank where card_seq=@card_seq AND company_seq = @company_seq
	
			FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor
		set @company_seq = @company_seq + 1
	end

--월간 주문 수량.(30위 안의 데이타는 BestRanking_new 테이블에 저장, S2_salessite.ranking_m 업데이트)
	set @Gubun = '1'
	set @company_seq=5001
	while (@company_seq<=5005)
	begin

		set @rank = 0
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT card_seq, sum(order_count) as cnt
			FROM
			custom_order 
			WHERE  company_seq=@company_seq and DATEDIFF(dd,src_send_date,getdate())>0 and DATEDIFF(dd,src_send_date,getdate())<=30 and status_seq=15  and order_Type in ('1','6','7')
			group by card_seq
			order by cnt desc
		OPEN item_cursor
	
		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			if @rank <= 30 
				insert into BestRanking_New(company_seq,rank,card_seq,cnt,gubun,gubun_data) values(@company_seq,@rank,@card_seq,@cnt,@Gubun,@gubun_data)
			if @company_seq=5001
			update s2_cardsalessite set ranking_m=@rank where card_seq=@card_seq AND company_seq = @company_seq
	
			FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor
		set @company_seq = @company_seq + 1
	end
	
	
	
--누적 주문(바른손카드에 해당)(30위 데이타까지만 가져와 BestRanking_new 테이블에 저장)
	set @rank = 0
	set @Gubun = '3'
	set @company_seq = 5001
	DECLARE item_cursor CURSOR
	FOR 		
		SELECT top 30 card_seq, sum(order_count) as cnt
		FROM
		custom_order 
		WHERE  company_seq=@company_seq and status_seq=15  and order_Type in ('1','6','7')
		group by card_seq
		order by cnt desc
	OPEN item_cursor

	FETCH NEXT FROM item_cursor INTO @card_seq,@cnt

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @rank = @rank + 1
		insert into BestRanking_New(company_seq,rank,card_seq,cnt,gubun,gubun_data) values(@company_seq,@rank,@card_seq,@cnt,@Gubun,@gubun_data)
		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt

	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor
	set @company_seq = @company_seq + 1

--월간 샘플 주문(30위 데이타까지만 가져와 BestRanking_new 테이블에 저장)
	set @Gubun = '2'
	
	set @company_seq=5001
	while (@company_seq<=5005)
	begin
		set @rank = 0
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 30 B.card_seq, count(B.card_seq) as cnt
			FROM
			custom_sample_order A inner join custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq
			WHERE  company_seq=@company_seq and DATEDIFF(dd,delivery_date,getdate())>0 and DATEDIFF(dd,delivery_date,getdate())<=30 and status_seq=12 
			group by card_seq
			order by cnt desc
		OPEN item_cursor
	
	
		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			insert into BestRanking_New(company_seq,rank,card_seq,cnt,gubun,gubun_data) values(@company_seq,@rank,@card_seq,@cnt,@Gubun,@gubun_data)
	
			FETCH NEXT FROM item_cursor INTO @card_seq,@cnt

		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor
		set @company_seq = @company_seq + 1
	end



--이용후기(30위 데이타까지만 가져와 BestRanking_new 테이블에 저장)
	set @Gubun = '4'
	
	set @company_seq=5001
	while (@company_seq<=5005)
	begin
		set @rank = 0
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 30 card_seq, count(card_seq) as cnt
			FROM
			S2_UserComment 
			WHERE  company_seq=@company_seq 
			group by card_seq
			order by cnt desc
		OPEN item_cursor
	
	
		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			insert into BestRanking_New(company_seq,rank,card_seq,cnt,gubun,gubun_data) values(@company_seq,@rank,@card_seq,@cnt,@Gubun,@gubun_data)
	
			FETCH NEXT FROM item_cursor INTO @card_seq,@cnt

		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor
		set @company_seq = @company_seq + 1
	end




--순위변동 Update 구문입니다.	--이상민 20100421
--###################################################################################################################################################
--drop table #RankChangeTemp

SELECT ISNULL(A.company_seq, 0) AS Company_seq
	, A.Gubun
	, A.Rank
	, A.Card_Seq
	, C.Card_name
	, CASE WHEN B.Rank IS NULL THEN 'NEW'
			WHEN A.Rank - B.Rank < 0 THEN 'UP'
			WHEN A.Rank - B.Rank > 0 THEN 'DOWN'
		ELSE 'BLANK' END AS RankChangeGubun
	, CASE WHEN B.Rank IS NULL THEN ''
			WHEN A.Rank - B.Rank < 0 THEN CONVERT(VARCHAR(10), B.Rank - A.Rank) 
			WHEN A.Rank - B.Rank > 0 THEN CONVERT(VARCHAR(10), A.Rank - B.Rank) 
		ELSE '' END AS RankChangeNo
INTO #RankChangeTemp
FROM BestRanking_New A
LEFT JOIN BestRanking_New B ON ISNULL(A.company_seq, 0) = ISNULL(B.company_seq, 0)  AND A.Gubun = B.Gubun
	AND CONVERT(VARCHAR(10), DATEADD(DD, -1, A.Gubun_data), 126) = B.Gubun_data
	AND A.Card_Seq = B.Card_Seq
JOIN S2_Card C on A.card_seq = C.card_seq
WHERE A.Gubun_data = @gubun_data
ORDER BY ISNULL(A.company_seq, 0), A.Gubun, A.Rank


UPDATE BestRanking_New
SET RankChangeGubun = B.RankChangeGubun
	, RankChangeNo = B.RankChangeNo
FROM BestRanking_New A
JOIN #RankChangeTemp B ON ISNULL(A.company_seq, 0) = ISNULL(B.company_seq, 0)  AND A.Gubun = B.Gubun AND A.Rank = B.Rank
WHERE A.Gubun_data = @gubun_data

--###################################################################################################################################################

GO
