IF OBJECT_ID (N'dbo.up_select_thankcard_order_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thankcard_order_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조창연
-- Create date: 2015-01-08
-- Description:	답례장 주문 정보 및 할인율 
-- TEST : up_select_thankcard_order_info 35539, 5007
-- =============================================
CREATE PROCEDURE [dbo].[up_select_thankcard_order_info]
	
	@card_seq		int,
	@company_seq	int

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	

	SELECT   B.card_Code	--0
			,B.card_name	--1
			,B.card_image	--2
			,B.CardSet_Price	--3
			,A.isJumun	--4
			,C.env_seq	--5
			,C.Env_GroupSeq	--6
			,C.Acc1_seq		--7
			,C.Acc1_GroupSeq	--8
			,C.Lining_seq	--9	
			,C.Lining_Groupseq	--10	
			,C.Unit_Count --11
			,C.Minimum_Count --12
			,ISNULL(D.isDigitalColor, '0') AS isDigitalColor --13
			,D.DigitalColor	--14
			,D.isEnvSpecial --15
			,D.isHanji	--16
			,D.isEmbo AS card_embo	--17
			,D.isEmboColor AS card_embocolor	--18
			,D.isInpaper	--19
			,D.isJaebon		--20
			,D.isHandmade	--21
			,D.isEnvInsert	--22
			,D.isUsrComment --23
			,D.isEnvSpecial --24
			,ISNULL(D.option_img1, '') AS option_img1	--25
			,ISNULL(D.option_img2, '') AS option_img2	--26
			,D.IsAdd	--27
			,(SELECT MAX(CardKind_Seq) FROM S2_CardKind WHERE Card_Seq = @card_seq) AS CardKind_Seq 	--28
			,D.isPutGiveCard --29
	FROM S2_CardSalesSite A
	INNER JOIN S2_Card B ON A.card_seq = B.card_seq
	INNER JOIN S2_CardDetail C ON A.card_seq = C.card_seq
	INNER JOIN S2_CardOption D ON A.card_seq = D.card_seq
	--INNER JOIN S2_CardKind AS E ON A.Card_Seq = E.Card_Seq
	WHERE A.card_seq = @card_seq 
	  AND A.company_seq = @company_seq
	  
  
  
END



GO
