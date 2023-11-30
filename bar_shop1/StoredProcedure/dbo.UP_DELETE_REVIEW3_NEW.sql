IF OBJECT_ID (N'dbo.UP_DELETE_REVIEW3_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_DELETE_REVIEW3_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************    
작성자  : 표수현    
  
작성일  : 2020-12-22    
  
DESCRIPTION : 샘플 후기 삭제

********************************************************************    
수정일   작업자  DESCRIPTION        
********************************************************************/ 
CREATE PROCEDURE [dbo].[UP_DELETE_REVIEW3_NEW]
	@ER_IDX	INT
AS
 BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DELETE S4_EVENT_REVIEW 
	WHERE ER_IDX = @ER_IDX

	DELETE S4_EVENT_REVIEWBEST 
	WHERE BEST_SEQ = @ER_IDX

	DELETE S4_EVENT_REVIEW_PHOTO 
	WHERE SEQ = @ER_IDX
			
			

END

GO
