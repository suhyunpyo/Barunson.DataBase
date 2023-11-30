IF OBJECT_ID (N'dbo.up_select_thankcard_env_print_type', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thankcard_env_print_type
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-20
-- Description:	답례장 주문 1 단계 - 봉투 인쇄 방식 설정
-- TEST : up_select_thankcard_env_print_type 33528
-- =============================================
CREATE PROCEDURE [dbo].[up_select_thankcard_env_print_type]
	
	@card_seq		int	

AS
BEGIN

	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	/*
	 -- 봉투 종류 정보 --	
	 env_groupseq > 0 이면 무조건 2개 이상이므로 드랍다운 노출, 
	                0이면 가로, 세로 여부 판별해야 함 ==> 봉투이름의 시작이 '가로' 또는 '세로'
	 다만, isHanji = 0 이면 가로, 세로의 설정값과 상관없이 무조건 봉투가 기본봉투만 노출된다.
	*/
	
	DECLARE @env_groupseq int
	DECLARE @env_seq int
	
	SELECT   @env_groupseq = env_groupseq
			,@env_seq = env_seq
	FROM S2_CardDetail
	WHERE card_seq = @card_seq	-- 카드의 card_seq

	
	IF @env_groupseq > 0
		
		BEGIN
			
			SELECT 
					 A.Card_Seq		
					,A.Card_Code
					,LEFT(A.Card_Name, 2) AS Card_Value
					,A.Card_Name
					--,'M' AS kind	-- Muliple					
			FROM S2_Card A 
			INNER JOIN S2_CardItemGroup B ON A.Card_Seq = B.Card_Seq
			WHERE B.CardItemGroup_Seq = @env_groupseq			  
			ORDER BY A.Card_Seq
	
		END 
	
	ELSE
		
		BEGIN
			
			SELECT   Card_Seq		
				    ,Card_Code
				    ,LEFT(Card_Name, 2) AS Card_Value
					,Card_Name
					--,'S' AS kind	-- Single
			FROM S2_Card
			WHERE card_seq = @env_seq --30981
	
		END	
	

END

GO
