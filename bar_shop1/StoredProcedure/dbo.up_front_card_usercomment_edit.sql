IF OBJECT_ID (N'dbo.up_front_card_usercomment_edit', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_card_usercomment_edit
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	작성정보   : [2003:07:24    13:29]  JJH: 
	관련페이지 : wedd_after_note_edit.asp
	내용	   : 상품별 이용후기 등록/편집
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_front_card_usercomment_edit]
	@KIND			VARCHAR(10)
	,@CMT_SEQ		INT
	,@MEMBER_UID	VARCHAR(20)
	,@MEMBER_NAME	VARCHAR(20)
	,@COMMENT		VARCHAR(4000)
	,@CARD_SEQ		INT
	,@SCORE		INT
	,@WEDD_DT		DATETIME
	,@WEDD_PLACE	VARCHAR(100)
	,@TRAVEL_PLACE	VARCHAR(100)
	,@TITLE		VARCHAR(100)
as
IF @KIND = 'ADD'
	BEGIN
		INSERT INTO Ewedd_After_Note(MEMBER_UID
						,MEMBER_NAME
						,COMMENT
						,REGDATE
						,CARD_SEQ
						,SCORE
						,DIV
						,WEDD_DT
						,WEDD_PLACE
						,TRAVEL_PLACE
						,TITLE)
			VALUES(			@MEMBER_UID
						,@MEMBER_NAME
						,@COMMENT
						,GETDATE()
						,@CARD_SEQ
						,@SCORE
						,'1'
						,@WEDD_DT
						,@WEDD_PLACE
						,@TRAVEL_PLACE
						,@TITLE)
	END
ELSE IF @KIND = 'UPDATE'
	BEGIN
		UPDATE Ewedd_After_Note 
			SET
				COMMENT	= @COMMENT
				,SCORE		= @SCORE
				,WEDD_DT	= @WEDD_DT
				,WEDD_PLACE	= @WEDD_PLACE
				,TRAVEL_PLACE	= @TRAVEL_PLACE
				,TITLE		= @TITLE
			WHERE  CMT_SEQ = @CMT_SEQ
	END
GO
