IF OBJECT_ID (N'dbo.SP_INSERT_S4_MD_CHOICE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_S4_MD_CHOICE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_INSERT_S4_MD_CHOICE]
    @MD_SEQ					AS VARCHAR(10)
,   @SEQ					AS VARCHAR(10)
,   @IMAGE_URL				AS VARCHAR(500)
,   @MD_TITLE				AS VARCHAR(500)
,   @MD_CONTENT				AS VARCHAR(1000)
,   @MD_DESC				AS VARCHAR(500)
,   @LINK_URL				AS VARCHAR(200)
,   @LINK_TARGET			AS VARCHAR(50)
,   @START_DATE				AS VARCHAR(10)
,   @END_DATE				AS VARCHAR(10)
,   @VIEW_DIV				AS VARCHAR(1)
,   @JEHU_VIEW_DIV			AS VARCHAR(1)
,   @EVENT_OPEN_YORN		AS VARCHAR(1)
,   @SORTING_NUM			AS VARCHAR(10)
,   @SNS_SHARE_YORN			AS CHAR(1)
,   @SNS_SHARE_IMAGE_URL	AS VARCHAR(500)
	AS
BEGIN
    
    IF @START_DATE = ''
        BEGIN
            SET @START_DATE = NULL
        END
    IF @END_DATE = ''
        BEGIN
            SET @END_DATE = NULL
        END
    IF @SORTING_NUM = ''
        BEGIN
            SET @SORTING_NUM = 1
        END
        
    IF @SEQ <> ''
        BEGIN
            
            UPDATE  S4_MD_CHOICE
            SET     IMGFILE_PATH            = @IMAGE_URL
                ,   MD_TITLE                = @MD_TITLE
                ,   MD_CONTENT              = @MD_CONTENT
                ,   MD_DESC                 = @MD_DESC
                ,   LINK_URL                = @LINK_URL
                ,   LINK_TARGET             = @LINK_TARGET
                ,   START_DATE              = @START_DATE
                ,   END_DATE                = @END_DATE
                ,   VIEW_DIV                = @VIEW_DIV
                ,   JEHU_VIEW_DIV           = @JEHU_VIEW_DIV
                ,   EVENT_OPEN_YORN         = @EVENT_OPEN_YORN
                ,   SORTING_NUM             = @SORTING_NUM
				,	SNS_SHARE_YORN			= @SNS_SHARE_YORN
				,	SNS_SHARE_IMAGE_URL		= @SNS_SHARE_IMAGE_URL
            WHERE   1 = 1
            AND     MD_SEQ = @MD_SEQ
            AND     SEQ = @SEQ

        END
    ELSE
        BEGIN
            
            INSERT INTO S4_MD_CHOICE (
                    MD_SEQ, IMGFILE_PATH, MD_TITLE, MD_CONTENT, MD_DESC, LINK_URL, LINK_TARGET, START_DATE, END_DATE
                ,   VIEW_DIV, JEHU_VIEW_DIV, EVENT_OPEN_YORN, SORTING_NUM
                ,   CARD_SEQ, CARD_TEXT, CUSTOM_IMG, CLICK_COUNT
				,	SNS_SHARE_YORN, SNS_SHARE_IMAGE_URL
            )

            VALUES (
                    @MD_SEQ, @IMAGE_URL, @MD_TITLE, @MD_CONTENT, @MD_DESC, @LINK_URL, @LINK_TARGET, @START_DATE, @END_DATE
                ,   @VIEW_DIV, @JEHU_VIEW_DIV, @EVENT_OPEN_YORN, @SORTING_NUM
                ,   NULL, '', '', 0
				,	@SNS_SHARE_YORN, @SNS_SHARE_IMAGE_URL
            )

        END

END
GO
