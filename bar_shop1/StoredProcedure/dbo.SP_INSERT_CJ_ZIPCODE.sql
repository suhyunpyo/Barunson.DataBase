IF OBJECT_ID (N'dbo.SP_INSERT_CJ_ZIPCODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_CJ_ZIPCODE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_INSERT_CJ_ZIPCODE

SELECT * FROM CJ_ZIPCODE

*/

CREATE PROCEDURE [dbo].[SP_INSERT_CJ_ZIPCODE]
AS
BEGIN



    DELETE FROM CJ_ZIPCODE

    INSERT INTO CJ_ZIPCODE (

            ZIP_NO
        ,   MAN_BRAN_ID
        ,   MAN_BRAN_NM
        ,   UP_BRAN_ID
        ,   UP_BRAN_NM
        ,   SIDO_ADDR
        ,   SKK_ADDR
        ,   DONG_ADDR
        ,   END_NO
        ,   SUB_END_NO
        ,   END_NM
        ,   CLDV_EMP_NM
        ,   FERRY_RGN_YN
        ,   AIR_RGN_YN
        ,   USE_YN
        ,   MODI_YMD
        ,   REG_EMP_ID
        ,   REG_DTIME
        ,   MODI_EMP_ID
        ,   MODI_DTIME

    )

    SELECT  
            ZIP_NO
        ,   MAN_BRAN_ID
        ,   MAN_BRAN_NM
        ,   UP_BRAN_ID
        ,   UP_BRAN_NM
        ,   SIDO_ADDR
        ,   SKK_ADDR
        ,   DONG_ADDR
        ,   END_NO
        ,   SUB_END_NO
        ,   END_NM
        ,   CLDV_EMP_NM
        ,   FERRY_RGN_YN
        ,   AIR_RGN_YN
        ,   USE_YN
        ,   MODI_YMD
        ,   REG_EMP_ID
        ,   REG_DTIME
        ,   MODI_EMP_ID
        ,   MODI_DTIME

    FROM OPENQUERY(CJ_OPENDB, ' SELECT * FROM TB_POST010 ')



    DELETE FROM HANJIN_ZIPCODE

    INSERT INTO HANJIN_ZIPCODE (ZIPCODE)
    SELECT ZIP_NO FROM CJ_ZIPCODE

END

GO
