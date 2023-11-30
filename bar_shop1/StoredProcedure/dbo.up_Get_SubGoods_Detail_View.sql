IF OBJECT_ID (N'dbo.up_Get_SubGoods_Detail_View', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Get_SubGoods_Detail_View
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-07
-- Description:	부가제품 상세 정보
-- =============================================
CREATE PROCEDURE [dbo].[up_Get_SubGoods_Detail_View]
	-- Add the parameters for the stored procedure here
	-- 제품 상세 정보 --
	@card_seq INT, --= 33499
	@company_seq INT --= 5007 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	
	SELECT 
		 A.isjumun				--0	
		,B.cardbrand			--1
		,B.card_div				--2
		,B.card_code			--3
		,B.card_name			--4
		,B.cardset_price		--5	
		,B.card_price			--6
		,B.cardfactory_price	--7
		,C.acc1_seq				--8
		,C.acc2_seq				--9
		,C.acc1_groupseq		--10	
		,C.acc2_groupseq		--11	
		,ISNULL(C.card_text, '') AS card_text		--12
		,ISNULL(C.card_content, '') AS card_content	--13
        ,A.isSummary AS isSummary  -- 14
        ,B.Card_WSize AS Card_WSize
        ,B.Card_HSize AS Card_HSize
	FROM 
		s2_cardsalessite A 
		INNER JOIN s2_card B ON A.card_seq = B.card_seq 
		left outer JOIN s2_carddetail C ON A.card_seq = C.card_seq 
	WHERE 
		A.card_seq = @card_seq 
		AND A.company_seq = @company_seq
END
GO
