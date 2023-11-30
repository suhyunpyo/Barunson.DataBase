IF OBJECT_ID (N'dbo.up_front_Getcardcommand', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_Getcardcommand
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	작성정보   : [2003:07:24    13:29]  JJH: 
	관련페이지 : wedd_after_note_view.asp
	내용	   : 상품별 이용후기 보기
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_front_Getcardcommand]
	@CMT_SEQ		INT	
as
	SELECT CUC.CMT_SEQ
		,CUC.MEMBER_NAME
		,CUC.COMMENT
		,CUC.CARD_SEQ
		,CUC.SCORE
		,CONVERT(VARCHAR(10),CUC.WEDD_DT,120) AS WEDD_DT
		,CUC.WEDD_PLACE
		,CUC.TRAVEL_PLACE
		,CUC.TITLE
		,CD.CARD_TITLE
		,CD.CARD_NAME
			FROM Ewedd_After_Note CUC , ewed_CARD_INFO CD WHERE CUC.CMT_SEQ = @CMT_SEQ
							and	CUC.CARD_SEQ = CD.CARD_SEQ
GO
