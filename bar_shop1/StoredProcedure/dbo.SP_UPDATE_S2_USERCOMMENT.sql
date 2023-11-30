IF OBJECT_ID (N'dbo.SP_UPDATE_S2_USERCOMMENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_S2_USERCOMMENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_UPDATE_S2_USERCOMMENT]
	@CARD_SEQ       AS INT
,   @ORDER_SEQ      AS INT
,   @TITLE          AS VARCHAR(200)
,   @COMMENT        AS VARCHAR(MAX)
,   @SCORE          AS INT
,   @FILE_URL       AS VARCHAR(200)
,   @B_URL          AS VARCHAR(200)
,   @SEQ            AS INT
	
AS
BEGIN

	SET NOCOUNT ON;

    DECLARE @COMM_DIV AS VARCHAR(1) = 'P'

    -- P : Photo후기
    -- T : Text후기
    -- 이미지 태그가 있으면 Photo후기로 분류한다.
    BEGIN TRY
        SET @COMM_DIV = CASE 
                                WHEN (CAST(@COMMENT AS XML)).exist('//img') = 1 
                                THEN 'P' 
                                ELSE 'T' 
                        END
    END TRY
    BEGIN CATCH
        SET @COMM_DIV = CASE 
                                WHEN CHARINDEX('<IMG', UPPER(CAST(@COMMENT AS VARCHAR(MAX)))) > 0
                                THEN 'P'
                                ELSE 'T'
                        END
    END CATCH

    
	IF @COMM_DIV = 'T'
	BEGIN
		SET @COMM_DIV = CASE WHEN (SELECT COUNT(1) FROM S2_USERCOMMENT_PHOTO WHERE SEQ = @SEQ) > 0 THEN 'P' ELSE 'T' END
	END

    UPDATE  S2_USERCOMMENT 
    Set     CARD_SEQ = CASE WHEN @CARD_SEQ = 0 THEN CARD_SEQ ELSE @CARD_SEQ END
        ,   ORDER_SEQ = CASE WHEN @ORDER_SEQ = 0 THEN ORDER_SEQ ELSE @ORDER_SEQ END
        ,   TITLE = @TITLE
        ,   COMMENT = @COMMENT
        ,   SCORE = @SCORE
        --,   UPIMG = @FILE_URL
        ,   COMM_DIV = @COMM_DIV
        ,   B_URL = @B_URL
        ,   REG_DATE = GETDATE() 
    Where   SEQ = @SEQ

END

GO
