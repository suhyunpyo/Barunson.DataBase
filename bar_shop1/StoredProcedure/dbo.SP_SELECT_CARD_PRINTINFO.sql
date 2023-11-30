IF OBJECT_ID (N'dbo.SP_SELECT_CARD_PRINTINFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CARD_PRINTINFO
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
CREATE PROCEDURE [dbo].[SP_SELECT_CARD_PRINTINFO]
    @CARD_CODE AS VARCHAR(20)
,   @PRINT_TYPE AS VARCHAR(10)
AS
BEGIN



    SELECT  ID
        ,   ISNULL(blank_space              ,   0)  AS blank_space 
        ,   ISNULL(print_sizeW              ,   0)  AS print_sizeW
        ,   ISNULL(print_sizeH              ,   0)  AS print_sizeH
        ,   ISNULL(print_group              ,   '') AS print_group
        ,   ISNULL(isDigital                ,   0)  AS isDigital
        ,   ISNULL(rotate                   ,   0)  AS rotate
        ,   ISNULL(print_panW               ,   0)  AS print_panW
        ,   ISNULL(print_panH               ,   0)  AS print_panH
        ,   ISNULL(offset_top               ,   0)  AS offset_top
        ,   ISNULL(offset_left              ,   0)  AS offset_left
        ,   ISNULL(offset_midW              ,   0)  AS offset_midW
        ,   ISNULL(offset_midH              ,   0)  AS offset_midH
        ,   ISNULL(isBarcode                ,   0)  AS isBarcode
        ,   ISNULL(backimg_offset_top       ,   0)  AS backimg_offset_top
        ,   ISNULL(backimg_offset_left      ,   0)  AS backimg_offset_left
        ,   ISNULL(backimg_offset_midW      ,   0)  AS backimg_offset_midW
        ,   ISNULL(backimg_offset_midH      ,   0)  AS backimg_offset_midH
        ,   ISNULL(isBackImg                ,   0)  AS isBackImg
        ,   ISNULL(isDPrint                 ,   0)  AS isDPrint
        ,   ISNULL(BOTH_SIDE_YORN           ,   'N')  AS BOTH_SIDE_YORN
        ,   ISNULL(rotate_type              ,   '') AS rotate_type
        ,   ISNULL(printer_group            ,   0)  AS printer_group
        ,   ISNULL(F_blank_space            ,   0)  AS F_blank_space
        ,   ISNULL(F_print_sizeW            ,   0)  AS F_print_sizeW
        ,   ISNULL(F_print_sizeH            ,   0)  AS F_print_sizeH
        ,   ISNULL(F_print_group            ,   '') AS F_print_group
        ,   ISNULL(F_isDigital              ,   0)  AS F_isDigital
        ,   ISNULL(F_rotate                 ,   0)  AS F_rotate
        ,   ISNULL(F_print_panW             ,   0)  AS F_print_panW
        ,   ISNULL(F_print_panH             ,   0)  AS F_print_panH
        ,   ISNULL(F_offset_top             ,   0)  AS F_offset_top
        ,   ISNULL(F_offset_left            ,   0)  AS F_offset_left
        ,   ISNULL(F_offset_midW            ,   0)  AS F_offset_midW
        ,   ISNULL(F_offset_midH            ,   0)  AS F_offset_midH
        ,   ISNULL(F_isBarcode              ,   0)  AS F_isBarcode
        ,   ISNULL(F_backimg_offset_top     ,   0)  AS F_backimg_offset_top
        ,   ISNULL(F_backimg_offset_left    ,   0)  AS F_backimg_offset_left
        ,   ISNULL(F_backimg_offset_midW    ,   0)  AS F_backimg_offset_midW
        ,   ISNULL(F_backimg_offset_midH    ,   0)  AS F_backimg_offset_midH
        ,   ISNULL(F_isBackImg              ,   0)  AS F_isBackImg
        ,   ISNULL(F_isDPrint               ,   0)  AS F_isDPrint
        ,   ISNULL(F_rotate_type            ,   '') AS F_rotate_type
        ,   ISNULL(F_printer_group          ,   0)  AS F_printer_group
    FROM    CARD_PRINTINFO
    WHERE   CARD_CODE = @CARD_CODE
    AND     PRINT_TYPE = @PRINT_TYPE



END
GO
