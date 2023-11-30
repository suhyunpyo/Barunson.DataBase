IF OBJECT_ID (N'dbo.SP_SELECT_S4_MD_CHOICE_LIST_V2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S4_MD_CHOICE_LIST_V2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
비핸즈 Main banner (기간설정 포함)  
EXEC SP_SELECT_S4_MD_CHOICE_LIST_V2 380, 'Y'  
*/  
  
CREATE PROCEDURE [dbo].[SP_SELECT_S4_MD_CHOICE_LIST_V2]  
    @MD_SEQ AS INT  
,   @EVENT_OPEN_YORN AS VARCHAR(1) = ''  
,   @VIEW_DIV AS VARCHAR(1) = ''  
,   @JEHU_VIEW_DIV AS VARCHAR(1) = ''  
,   @VIEW_CNT_DIV AS VARCHAR(1) = '' --비핸즈>청첩장메뉴에서 메인대배너리스트 랜덤으로 1개 사용하기 위함  
 AS  
BEGIN  
   
 SET NOCOUNT ON;  
 DECLARE @strQuery NVARCHAR(MAX);  
 DECLARE @parmDefinition_itm NVARCHAR(500)    
  
  
 set @parmDefinition_itm = N'@IN_MD_SEQ INT ,@IN_EVENT_OPEN_YORN VARCHAR(1) ,@IN_VIEW_DIV VARCHAR(1) ,@IN_JEHU_VIEW_DIV VARCHAR(1)'  
  
 SET @strQuery = N''   
    SET @strQuery = @strQuery + 'SELECT  ROW_NUMBER() OVER(ORDER BY SORTING_NUM ASC) AS ROW_NUM             '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   SEQ                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   MD_SEQ                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   SORTING_NUM                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   CARD_SEQ                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   CARD_TEXT                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   ISNULL(MD_TITLE, '''') AS MD_TITLE                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   ISNULL(MD_CONTENT, '''') AS MD_CONTENT                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   ISNULL(MD_DESC, '''') AS MD_DESC                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   replace(ISNULL(IMGFILE_PATH, '''') , ''http://'',''https://'' ) AS IMGFILE_PATH               '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   CUSTOM_IMG                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   ISNULL(LINK_URL, '''') AS LINK_URL                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   LOWER(CASE WHEN UPPER(LINK_TARGET) = ''_SELF'' THEN ''_SELF'' ELSE ''_BLANK'' END) AS LINK_TARGET         '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   CLICK_COUNT                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   VIEW_DIV                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   JEHU_VIEW_DIV                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   EVENT_OPEN_YORN                  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   ADMIN_ID                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   REG_DATE                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   RECOM_NUM                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   ISNULL(CONVERT(VARCHAR(10), START_DATE, 120), '''') AS START_DATE            '+char(13) + char(10)  
 SET @strQuery = @strQuery + '        ,   ISNULL(CONVERT(VARCHAR(10), END_DATE, 120), '''') AS END_DATE             '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  , ISNULL(SNS_SHARE_YORN, ''N'') AS SNS_SHARE_YORN              '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  , ISNULL(SNS_SHARE_IMAGE_URL, '''') AS SNS_SHARE_IMAGE_URL             '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  ,   count(*)over() MAIN_BIG_B_CNT  '+char(13) + char(10)   
 SET @strQuery = @strQuery + '    FROM    S4_MD_CHOICE                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    WHERE   1 = 1                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND     MD_SEQ = @IN_MD_SEQ                  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND                         '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            (CASE WHEN @IN_EVENT_OPEN_YORN IN ( ''Y'' , ''N'' ) THEN EVENT_OPEN_YORN ELSE '''' END)           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            =                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '       (CASE WHEN @IN_EVENT_OPEN_YORN IN ( ''Y'' , ''N'' ) THEN @IN_EVENT_OPEN_YORN ELSE '''' END)          '+char(13) + char(10)  
 SET @strQuery = @strQuery + '                      '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND     (CASE WHEN @IN_VIEW_DIV IN ( ''Y'' , ''N'' ) THEN VIEW_DIV ELSE '''' END)            '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            =                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            (CASE WHEN @IN_VIEW_DIV IN ( ''Y'' , ''N'' ) THEN @IN_VIEW_DIV ELSE '''' END)            '+char(13) + char(10)  
 SET @strQuery = @strQuery + '                      '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND     (CASE WHEN @IN_JEHU_VIEW_DIV IN ( ''Y'' , ''N'' ) THEN JEHU_VIEW_DIV ELSE '''' END)           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            =                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            (CASE WHEN @IN_JEHU_VIEW_DIV IN ( ''Y'' , ''N'' ) THEN @IN_JEHU_VIEW_DIV ELSE '''' END)    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '                      '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND     (CASE WHEN @IN_EVENT_OPEN_YORN = ( ''Y'' ) THEN CAST(CONVERT(VARCHAR(8), START_DATE, 112) AS NUMERIC) ELSE 0 END)  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            <=                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            (CASE WHEN @IN_EVENT_OPEN_YORN = ( ''Y'' ) THEN CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC) ELSE 0 END)   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '                      '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND     (CASE WHEN @IN_EVENT_OPEN_YORN = ( ''Y'' ) THEN CAST(CONVERT(VARCHAR(8), END_DATE, 112) AS NUMERIC) ELSE 0 END)    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            >=                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            (CASE WHEN @IN_EVENT_OPEN_YORN = ( ''Y'' ) THEN CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC) ELSE 0 END)   '+char(13) + char(10)  
   
   
 if @VIEW_CNT_DIV = 'Y'  
  BEGIN  
   SET @strQuery = @strQuery + 'ORDER BY NEWID()'+char(13) + char(10)  
  END  
 ELSE  
  BEGIN  
   SET @strQuery = @strQuery + 'ORDER BY SORTING_NUM ASC'+char(13) + char(10)  
  END  
  
   
  
 PRINT CAST(@strQuery AS TEXT)  
 exec sp_executesql @strQuery  ,@parmDefinition_itm, @MD_SEQ ,@EVENT_OPEN_YORN ,@VIEW_DIV ,@JEHU_VIEW_DIV  
      
  
 SET NOCOUNT OFF;  
  
END  
GO
