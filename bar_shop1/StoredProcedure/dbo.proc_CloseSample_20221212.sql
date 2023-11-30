IF OBJECT_ID (N'dbo.proc_CloseSample_20221212', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_CloseSample_20221212
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC PROC_CLOSESAMPLE_NEW '871810,871811,871812,871813,871814,871815'

UPDATE CUSTOM_SAMPLE_ORDER SET PREPARE_DATE = NULL, STATUS_SEQ = 4, DELIVERY_CODE_NUM = '' WHERE SAMPLE_ORDER_SEQ IN (871810,871811,871812,871813,871814,871815)

EXEC PROC_CLOSESAMPLE_NEW '1041847'

*/
CREATE PROCEDURE [dbo].[proc_CloseSample_20221212]
@P_ORDER_SEQ_LIST AS VARCHAR(8000)

AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @DELIVERY_COMPANY_SHORT_NAME AS VARCHAR(10)
	DECLARE @del_code varchar(100)
    SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'

    /* 2015-08-03 이후 CJ택배로 변경 */
    IF GETDATE() >= '2015-08-03 00:00:00'
        BEGIN
            
            SET @DELIVERY_COMPANY_SHORT_NAME = 'CJ'

        END
    ELSE
        BEGIN
            
            SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'

        END



    --DECLARE @ORDER_SEQ_TABLE TABLE
    --(
    --    SEQ         INT NOT NULL,
	   -- ORDER_SEQ   INT NOT NULL,
    --    IS_VAILD    INT NOT NULL,
    --    CODESEQ     BIGINT NULL,
    --    DEL_CODE    VARCHAR(12) NULL
    --)

    --/* ',' 기준으로 테이블로 분리 */
    --INSERT INTO @ORDER_SEQ_TABLE (SEQ, ORDER_SEQ, IS_VAILD)
    --SELECT ROW_NUMBER() OVER(ORDER BY value ASC), value, 0 FROM dbo.[ufn_SplitTable](@p_order_seq_list, ',')


    --/* 
    --    유효한것과 아닌것으로 분류
    --    IS_VAILD : [1 : 유효], [0 : 무효]
    --*/
    --UPDATE  @ORDER_SEQ_TABLE
    --SET     IS_VAILD = 1
    --WHERE   ORDER_SEQ IN (
    --    SELECT  A.SAMPLE_ORDER_SEQ
    --    FROM    CUSTOM_SAMPLE_ORDER A
    --    JOIN    @ORDER_SEQ_TABLE B ON A.SAMPLE_ORDER_SEQ = B.ORDER_SEQ
    --    LEFT JOIN CJ_ZIPCODE C ON A.MEMBER_ZIP = C.ZIP_NO
    --    WHERE   1 = 1
    --    AND     A.STATUS_SEQ IN ( 4 , 10 )
    --    AND     C.ZIP_NO IS NOT NULL
    --)
    


    --/* ZIPCODE 없는 주문건 주소 정제 */
    --BEGIN TRY
        
    --    DECLARE @C_ORDER_SEQ AS INT
    --    DECLARE @C_ADDRESS AS VARCHAR(1000)
    --    DECLARE @C_ZIPCODE AS VARCHAR(10)

    --    /* 주소 정제 테이블 */
    --    DECLARE @ADDRESS_REFINEMENT_TABLE TABLE
    --    (
        
    --            ZIPNUM              NVARCHAR(1000)
    --        ,   ZIPID               INT           
    --        ,   OLDADDRESS          NVARCHAR(1000)
    --        ,   OLDADDRESSDTL       NVARCHAR(1000)
    --        ,   NEWADDRESS          NVARCHAR(1000)
    --        ,   NEWADDRESSDTL       NVARCHAR(1000)
    --        ,   ETCADDR             NVARCHAR(1000)
    --        ,   SHORTADDR           NVARCHAR(1000)
    --        ,   CLSFADDR            NVARCHAR(1000)
    --        ,   CLLDLVBRNACD        NVARCHAR(1000)
    --        ,   CLLDLVBRANNM        NVARCHAR(1000)
    --        ,   CLLDLCBRANSHORTNM   NVARCHAR(1000)
    --        ,   CLLDLVEMPNUM        NVARCHAR(1000)
    --        ,   CLLDLVEMPNM         NVARCHAR(1000)
    --        ,   CLLDLVEMPNICKNM     NVARCHAR(1000)
    --        ,   CLSFCD              NVARCHAR(1000)
    --        ,   CLSFNM              NVARCHAR(1000)
    --        ,   SUBCLSFCD           NVARCHAR(1000)
    --        ,   RSPSDIV             NVARCHAR(1000)
    --        ,   NEWADDRYN           NVARCHAR(1000)
    --        ,   ERRORCD             NVARCHAR(1000)
    --        ,   ERRORMSG            NVARCHAR(1000)

    --    )

    --    DECLARE ORDER_SEQ_TABLE_CURSOR CURSOR LOCAL FOR

    --    SELECT  ORDER_SEQ
    --    FROM    @ORDER_SEQ_TABLE
    --    WHERE   IS_VAILD = 0

    --    OPEN ORDER_SEQ_TABLE_CURSOR;


    --    FETCH NEXT FROM ORDER_SEQ_TABLE_CURSOR 
    --    INTO    @C_ORDER_SEQ
    
    --    WHILE @@FETCH_STATUS = 0
    --    BEGIN
            

    --        SET @C_ADDRESS = ''
    --        SET @C_ZIPCODE = ''
    --        DELETE FROM @ADDRESS_REFINEMENT_TABLE

    --        SELECT  @C_ADDRESS = ISNULL(MEMBER_ADDRESS, '') + ' ' + ISNULL(MEMBER_ADDRESS_DETAIL, '')
    --            ,   @C_ZIPCODE = RTRIM(LTRIM(ISNULL(MEMBER_ZIP, '')))
    --        FROM    CUSTOM_SAMPLE_ORDER
    --        WHERE   SAMPLE_ORDER_SEQ = @C_ORDER_SEQ
            


    --        -- EXEC [SP_EXEC_DELIVERY_ADDRESS_REFINEMENT] @C_ADDRESS, @C_ZIPCODE



    --        INSERT INTO @ADDRESS_REFINEMENT_TABLE
    --        EXEC [SP_EXEC_DELIVERY_ADDRESS_REFINEMENT] @C_ADDRESS, @C_ZIPCODE

    --        SET @C_ZIPCODE = ''

    --        SELECT  @C_ZIPCODE = ART.ZIPNUM
    --        FROM    @ADDRESS_REFINEMENT_TABLE ART
    --        LEFT JOIN CJ_ZIPCODE CZ ON ART.ZIPNUM = CZ.ZIP_NO
    --        WHERE   ART.ZIPID <> -1
            
    --        IF @C_ZIPCODE <> '' 
    --            BEGIN
                    
    --                UPDATE  CUSTOM_SAMPLE_ORDER
    --                SET     MEMBER_ZIP = @C_ZIPCODE
    --                WHERE   SAMPLE_ORDER_SEQ = @C_ORDER_SEQ

    --                UPDATE  @ORDER_SEQ_TABLE
    --                SET     IS_VAILD = 1
    --                WHERE   ORDER_SEQ = @C_ORDER_SEQ

    --            END

    --        FETCH NEXT FROM ORDER_SEQ_TABLE_CURSOR 
    --        INTO    @C_ORDER_SEQ
    --    END
	
    --    CLOSE ORDER_SEQ_TABLE_CURSOR;
    --    DEALLOCATE ORDER_SEQ_TABLE_CURSOR;

    --END TRY
    --BEGIN CATCH
        
    --END CATCH



    --/* ISUSE : [0 : 사용안함], [1 : 사용함], [2 : 사용 대기] */
    --UPDATE  CJ_DELCODE 
    --SET     ISUSE = '2' 
    --WHERE   CODESEQ IN (
    --    SELECT  A.CODESEQ
    --    FROM    (
    --        SELECT  CODESEQ, ROW_NUMBER() OVER(ORDER BY CODESEQ ASC) AS ROWNUM
    --        FROM    CJ_DELCODE 
    --        WHERE   ISUSE = '0' 
    --    ) A
    --    WHERE   A.ROWNUM <= ISNULL((SELECT COUNT(*) FROM @ORDER_SEQ_TABLE WHERE IS_VAILD = 1), 0)
    --)

    

    --/* CODESEQ 할당 */
    --UPDATE  @ORDER_SEQ_TABLE
    --SET     CODESEQ = B.CODESEQ
    --    ,   DEL_CODE = B.CODE
    --FROM    @ORDER_SEQ_TABLE A
    --LEFT JOIN   (   
    --                SELECT  CODESEQ
    --                    ,   CODE
    --                    ,   ROW_NUMBER() OVER(ORDER BY CODESEQ ASC) ROWNUM
    --                FROM    CJ_DELCODE 
    --                WHERE   ISUSE = '2'
    --            ) B ON A.SEQ = B.ROWNUM
    --WHERE   A.IS_VAILD = 1

    

    --/* 할당된 CODESEQ의 ISUSE를 1로 업데이트 */
    --UPDATE  CJ_DELCODE
    --SET     ISUSE = '1'
    --FROM    CJ_DELCODE A
    --JOIN    @ORDER_SEQ_TABLE B ON A.CODESEQ = B.CODESEQ
    --WHERE   A.ISUSE = '2'
    --AND     B.IS_VAILD = 1
    
    --/* 혹시 사용안한게 있다면, 사용전으로 */
    --UPDATE  CJ_DELCODE
    --SET     ISUSE = '0'
    --FROM    CJ_DELCODE
    --WHERE   ISUSE = '2'



    --/* 실 테이블에 반영 */
    --UPDATE  CUSTOM_SAMPLE_ORDER
    --SET     DELIVERY_COM = @DELIVERY_COMPANY_SHORT_NAME
    --    ,   DELIVERY_CODE_NUM = B.DEL_CODE
    --    ,   STATUS_SEQ = 10
    --    ,   PREPARE_DATE = GETDATE()
    --FROM    CUSTOM_SAMPLE_ORDER A
    --JOIN    @ORDER_SEQ_TABLE B ON A.SAMPLE_ORDER_SEQ = B.ORDER_SEQ
    --WHERE   B.IS_VAILD = 1

	 EXEC [dbo].[SP_CJ_DELEVERY_20221212] 'CUSTOM_SAMPLE_ORDER|', @p_order_seq_list, 0, @DELIVERY_COMPANY_SHORT_NAME, @DEL_CODE OUTPUT

	-- EXEC [dbo].[SP_CJ_DELEVERY] 'CUSTOM_SAMPLE_ORDER|', @p_order_seq_list, 0, @DELIVERY_COMPANY_SHORT_NAME, @DEL_CODE OUTPUT


    /* HANJIN_ZIPCODE에 ZIPCODE가 없거나 STATUS_SEQ가 4가 아닌것들 */
    --SELECT  STUFF((

    --                SELECT	',' + CONVERT(VARCHAR(30), ORDER_SEQ)
	   --             FROM	@ORDER_SEQ_TABLE
	   --             WHERE	IS_VAILD = 0
	   --             ORDER BY ORDER_SEQ ASC
	   --             FOR XML PATH('')
    --        ), 1, 1, '') AS ERR_ORDER_SEQ
    --    ,   COUNT(*) AS ERR_ORDER_SEQ_CNT
    --    ,   ISNULL((SELECT COUNT(*) FROM @ORDER_SEQ_TABLE WHERE IS_VAILD = 1), 0) AS COMPLETE_ORDER_SEQ_CNT
    --FROM    @ORDER_SEQ_TABLE
    --WHERE	IS_VAILD = 0



END
GO
