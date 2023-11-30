IF OBJECT_ID (N'dbo.SP_SELECT_CHOAN_CORELDRAW_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CHOAN_CORELDRAW_ITEM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SELECT_CHOAN_CORELDRAW_ITEM]
@TYPE_NAME AS NVARCHAR(50)
AS
BEGIN

    IF @TYPE_NAME = 'CALENDAR' 
    BEGIN

        SELECT  COCC.*, CCI.CORELDRAW_FILENAME, CCI.CORELDRAW_SEQ, CCI.CORELDRAW_TYPE_CODE
        FROM    CHOAN_CORELDRAW_ITEM CCI                                     
        JOIN    CHOAN_OBJECT_COMMON_CODE COCC ON CCI.OBJ_CODE = COCC.OBJ_CODE
        WHERE   CCI.CORELDRAW_TYPE_CODE = @TYPE_NAME     

    END

    ELSE
    BEGIN
        
        SELECT  '' AS OBJ_SEQ
            ,   '' AS GROUP_NAME
            ,   '' AS OBJ_CODE_NAME
            ,   '' AS OBJ_CODE
            ,   '' AS OBJ_DESC
            ,   '' AS USE_YORN
            ,   CORELDRAW_FILENAME
        FROM    CHOAN_CORELDRAW_ITEM
        WHERE   CORELDRAW_TYPE_CODE = @TYPE_NAME

    END

END
GO
