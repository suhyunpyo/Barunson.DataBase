USE [bar_shop1]
GO

IF OBJECT_ID (N'dbo.Up_Custom_Order_Review_Count_Create', N'P') IS NOT NULL DROP PROCEDURE dbo.Up_Custom_Order_Review_Count_Create
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김광호
-- Create date: 2023-08-21
-- Description:	상품, 샘플 리뷰 수 집계 생성, 실행 일자에서 6개월 전 데이터 재생성
-- =============================================
CREATE PROCEDURE dbo.Up_Custom_Order_Review_Count_Create
	 @fdate smalldatetime = null
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	IF @fdate is null
	BEGIN
		Set @fdate = DATEADD(MONTH, -6, DATEADD(month, DATEDIFF(month, 0, Getdate()), 0) ) -- 6개월 전부터 시작 
	END
	--날짜는 1일로만 
	IF DATEPART(day, @fdate) <> 1
	BEGIN
		Set @fdate = DATEADD(month, DATEDIFF(month, 0, @fdate), 0)
	End

	--From, To. Last Date
	Declare @tdate smalldatetime, @ldate smalldatetime
	
	Set @tdate = DATEADD(MONTH, 1, @fdate)
	Set @ldate = Getdate()

	WHILE @fdate < @ldate
	Begin
		PRINT @fdate;

		-- 상품 이용 후기, 스코어
		MERGE INTO Custom_Order_Review_Count AS t
		USING (select	company_seq, card_seq, count(*) as OrderReviewCount, sum(score) as OrderScore 
				from 	S2_UserComment
				Where	isDP = '1'
				And		reg_date >= @fdate And reg_date < @tdate
				Group by company_seq, card_seq) as s
		ON (t.CompaySeq = s.company_seq and t.CardSeq = s.card_seq and t.SumDate = @fdate)
		WHEN MATCHED THEN
		UPDATE SET t.OrderReviewCount = s.OrderReviewCount, t.OrderScore = s.OrderScore
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(CompaySeq, CardSeq, SumDate, OrderReviewCount, SampleReviewCount, RealSampleReviewCount, OrderScore, SampleScore, RealSampleScore) 
		VALUES(s.company_seq, s.card_seq, @fdate, s.OrderReviewCount, 0, 0, s.OrderScore, 0, 0)
		;
		-- 샘플리뷰: 카드가 포함된 모든 리뷰수, 승인상태
		MERGE INTO Custom_Order_Review_Count AS t
		USING (Select A.ER_COMPANY_SEQ, B.Card_Seq,  Count(*) as SampleReviewCount, Sum(A.ER_Review_Star) as SampleScore
				From S4_EVENT_REVIEW as A
					Inner Join CUSTOM_SAMPLE_ORDER_ITEM as B on A.ER_Order_Seq = B.SAMPLE_ORDER_SEQ
				Where  a.ER_Regdate >= @fdate
				And	a.ER_Regdate < @tdate
				And	a.ER_TYPE = 0 AND a.ER_STATUS = 1 AND a.ER_VIEW = 0 
				Group by A.ER_COMPANY_SEQ, B.Card_Seq
			) as s
		ON (t.CompaySeq = s.ER_Company_Seq and t.CardSeq = s.Card_Seq and t.SumDate = @fdate)
		WHEN MATCHED THEN
		UPDATE SET t.SampleReviewCount = s.SampleReviewCount, t.SampleScore = s.SampleScore
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(CompaySeq, CardSeq, SumDate, OrderReviewCount, SampleReviewCount, RealSampleReviewCount, OrderScore, SampleScore, RealSampleScore) VALUES(s.ER_Company_Seq, s.Card_Seq, @fdate, 0, s.SampleReviewCount, 0, 0, s.SampleScore, 0)
		;
		-- 샘플리뷰: 일치하는카드의 리뷰수, 승인상태
		MERGE INTO Custom_Order_Review_Count AS t
		USING (Select A.ER_COMPANY_SEQ, A.ER_Card_Seq,  Count(*) as RealSampleReviewCount, Sum(A.ER_Review_Star) as RealSampleScore
				From S4_EVENT_REVIEW as A
				Where  a.ER_Regdate >= @fdate
				And	a.ER_Regdate < @tdate
				And	a.ER_TYPE = 0 AND a.ER_STATUS = 1 AND a.ER_VIEW = 0 
				Group by A.ER_COMPANY_SEQ, A.ER_Card_Seq
			) as s
		ON (t.CompaySeq = s.ER_Company_Seq and t.CardSeq = s.ER_Card_Seq and t.SumDate = @fdate)
		WHEN MATCHED THEN
		UPDATE SET t.RealSampleReviewCount = s.RealSampleReviewCount, t.RealSampleScore = s.RealSampleScore
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(CompaySeq, CardSeq, SumDate, OrderReviewCount, SampleReviewCount, RealSampleReviewCount, OrderScore, SampleScore, RealSampleScore) VALUES(s.ER_Company_Seq, s.ER_Card_Seq, @fdate, 0, 0, s.RealSampleReviewCount,0,0,s.RealSampleScore)
		;
		
		Set @fdate = @tdate;
		Set @tdate = DATEADD(MONTH, 1, @fdate)
	End

END
GO
