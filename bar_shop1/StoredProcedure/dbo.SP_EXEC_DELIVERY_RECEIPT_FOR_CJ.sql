IF OBJECT_ID (N'dbo.SP_EXEC_DELIVERY_RECEIPT_FOR_CJ', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_DELIVERY_RECEIPT_FOR_CJ
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

    EXECUTE ('BEGIN SELECT CUST_ID FROM V_RCPT_BHANDS010 END;') AT CJ_OPENDB

    SELECT * FROM OPENQUERY(CJ_OPENDBT, 'SELECT * FROM V_RCPT_BHANDS010 WHERE CUST_ID = ''30184122''')
    SELECT * FROM OPENQUERY(CJ_OPENDBT, 'SELECT * FROM V_RCPT_BHANDS010')

    EXEC [SP_EXEC_DELIVERY_RECEIPT_FOR_CJ] '2016-08-24', '2016-08-26'

    SELECT * FROM OPENQUERY(CJ_OPENDBT,'SELECT fc_mscm_telnum_splt(''123-4567-8901'',1) FROM V_RCPT_BHANDS010')

    EXEC SP_EXEC_DELIVERY_RECEIPT_FOR_CJ CONVERT(VARCHAR(10), GETDATE(), 120), CONVERT(VARCHAR(10), GETDATE() + 1, 120)
*/
CREATE PROCEDURE [dbo].[SP_EXEC_DELIVERY_RECEIPT_FOR_CJ]
    @START_DATE AS VARCHAR(10)
,   @END_DATE AS VARCHAR(10)
AS
BEGIN

DECLARE
            @CUST_ID                AS VARCHAR(10)
        ,   @RCPT_YMD               AS VARCHAR(8)
        ,   @RCPT_DV                AS VARCHAR(2)
        ,   @WORK_DV_CD             AS VARCHAR(2)
        ,   @REQ_DV_CD              AS VARCHAR(2)
        ,   @MPCK_KEY               AS VARCHAR(100)
        ,   @MPCK_SEQ               AS INT
        ,   @CAL_DV_CD              AS VARCHAR(2)
        ,   @FRT_DV_CD              AS VARCHAR(2)
        ,   @CNTR_ITEM_CD           AS VARCHAR(2)
        ,   @BOX_TYPE_CD            AS VARCHAR(2)
        ,   @BOX_QTY                AS VARCHAR(2)

        ,   @SENDR_NM               AS VARCHAR(100)
        ,   @SENDR_TEL_NO1          AS VARCHAR(4)
        ,   @SENDR_TEL_NO2          AS VARCHAR(4)
        ,   @SENDR_TEL_NO3          AS VARCHAR(4)
        ,   @SENDR_ZIP_NO           AS VARCHAR(6)
        ,   @SENDR_ADDR             AS VARCHAR(100)
        ,   @SENDR_DETAIL_ADDR      AS VARCHAR(100)

        ,   @RCVR_NM                AS VARCHAR(100)
        ,   @RCVR_TEL_NO1           AS VARCHAR(4)
        ,   @RCVR_TEL_NO2           AS VARCHAR(4)
        ,   @RCVR_TEL_NO3           AS VARCHAR(4)
        ,   @RCVR_CELL_NO1          AS VARCHAR(4)
        ,   @RCVR_CELL_NO2          AS VARCHAR(4)
        ,   @RCVR_CELL_NO3          AS VARCHAR(4)
        ,   @RCVR_ZIP_NO            AS VARCHAR(6)
        ,   @RCVR_ADDR              AS VARCHAR(100)
        ,   @RCVR_DETAIL_ADDR       AS VARCHAR(100)

        ,   @ORDRR_NM               AS VARCHAR(100)
        ,   @ORDRR_TEL_NO1          AS VARCHAR(4)
        ,   @ORDRR_TEL_NO2          AS VARCHAR(4)
        ,   @ORDRR_TEL_NO3          AS VARCHAR(4)
        ,   @ORDRR_CELL_NO1         AS VARCHAR(4)
        ,   @ORDRR_CELL_NO2         AS VARCHAR(4)
        ,   @ORDRR_CELL_NO3         AS VARCHAR(4)
        ,   @ORDRR_ZIP_NO           AS VARCHAR(6)
        ,   @ORDRR_ADDR             AS VARCHAR(100)
        ,   @ORDRR_DETAIL_ADDR      AS VARCHAR(100)

        ,   @INVC_NO                AS VARCHAR(20)
        ,   @PRT_ST                 AS VARCHAR(3)
        ,   @GDS_NM                 AS VARCHAR(250)
        ,   @DLV_DV                 AS VARCHAR(2)
        ,   @EMP_ID                 AS VARCHAR(10)

        ,   @ORDER_SEQ              AS VARCHAR(20)
        ,   @ORDER_TABLE_NAME       AS VARCHAR(50)
        ,   @DELIVERY_MSG           AS NVARCHAR(200)
        ,   @DELIVERY_SEQ           AS INT

        ,   @RESULT_CODE            AS VARCHAR(4)
        ,   @RESULT_MSG             AS NVARCHAR(500)
        ,   @ERROR_MSG              AS NVARCHAR(500)
        ,   @ERROR_DESC             AS NVARCHAR(500)

    SET @ORDER_SEQ          = ''
    SET @DELIVERY_SEQ       = 1



    SET @CUST_ID            = '30184122'                                -- 거래코드
    SET @EMP_ID             = 'BHANDS'                                  -- DB 접속계정 대문자
    SET @INVC_NO            = ''                                        -- 송장번호
    SET @RCPT_YMD           = CONVERT(VARCHAR(8), GETDATE() - 1, 112)       
    SET @RCPT_DV            = '01'                                      -- 01 : 일반, 02 : 반품
    SET @WORK_DV_CD         = '01'                                      -- 01 : 일반, 02 : 교환, 03 : A/S
    SET @REQ_DV_CD          = '01'                                      -- 01 : 요청, 02 : 취소
    SET @MPCK_KEY           = @RCPT_YMD + '_' + @CUST_ID + '_'          -- 자체출력사 : YYYYMMDD_고객ID_운송장번호
    SET @MPCK_SEQ           = 1                                         -- 합포장 처리 건수
    SET @CAL_DV_CD          = '01'                                      -- 01 : 계약 운임, 02 : 자료 운임
    SET @FRT_DV_CD          = '03'                                      -- 01 : 선불, 02 : 착불, 03 : 신용
    SET @CNTR_ITEM_CD       = '01'                                      -- 01 : 일반품목
    SET @BOX_TYPE_CD        = '01'                                      -- 01 : 극소, 02 : 소, 03 : 중, 04 : 대, 05 : 특대
    SET @BOX_QTY            = 1

    SET @SENDR_NM           = '바른컴퍼니(파주)'                           -- 회사명
    SET @SENDR_TEL_NO1      = '02'                                      
    SET @SENDR_TEL_NO2      = '1644'
    SET @SENDR_TEL_NO3      = '0708'
    SET @SENDR_ZIP_NO       = '413120'
    SET @SENDR_ADDR         = '경기도 파주시 회동길'
    SET @SENDR_DETAIL_ADDR  = '219 (주)바른컴퍼니'

    SET @RCVR_NM            = ''    
    SET @RCVR_TEL_NO1       = ''                
    SET @RCVR_TEL_NO2       = ''
    SET @RCVR_TEL_NO3       = ''
    SET @RCVR_CELL_NO1      = ''                
    SET @RCVR_CELL_NO2      = ''
    SET @RCVR_CELL_NO3      = ''
    SET @RCVR_ZIP_NO        = ''
    SET @RCVR_ADDR          = ''
    SET @RCVR_DETAIL_ADDR   = ''

    SET @ORDRR_NM           = ''    
    SET @ORDRR_TEL_NO1      = ''                
    SET @ORDRR_TEL_NO2      = ''
    SET @ORDRR_TEL_NO3      = ''
    SET @ORDRR_CELL_NO1     = ''                
    SET @ORDRR_CELL_NO2     = ''
    SET @ORDRR_CELL_NO3     = ''
    SET @ORDRR_ZIP_NO       = ''
    SET @ORDRR_ADDR         = ''
    SET @ORDRR_DETAIL_ADDR  = ''
                           
    SET @PRT_ST             = '02'                                      -- 01 : 미출력, 02 : 선출력, 03 : 선발번
    SET @GDS_NM             = '상품명'                                   -- 상품명
    SET @DLV_DV             = '01'                                      -- 택배 : '01', 중량물(설치물류) : '02', 중량물(비설치물류) : '03'




BEGIN TRY

    DECLARE DELIVERY_CURSOR CURSOR LOCAL FOR

    SELECT  ORDER_SEQ
        ,   DELIVERY_CODE
        ,   ORDER_TABLE_NAME
        ,   RECV_NAME
        ,   RECV_ZIP
        ,   RECV_ADDR
        ,   CASE WHEN REPLACE(ISNULL(RECV_ADDR_DETAIL, ''), ' ', '') = '' THEN '.' ELSE RECV_ADDR_DETAIL END AS RECV_ADDR_DETAIL
        ,   dbo.fn_GetIdxDataLikeSplit(RECV_PHONE, 1, '-') AS RECV_PHONE_NO1
        ,   dbo.fn_GetIdxDataLikeSplit(RECV_PHONE, 2, '-') AS RECV_PHONE_NO2
        ,   dbo.fn_GetIdxDataLikeSplit(RECV_PHONE, 3, '-') AS RECV_PHONE_NO3
        ,   dbo.fn_GetIdxDataLikeSplit(RECV_HPHONE, 1, '-') AS RECV_HPHONE_NO1
        ,   dbo.fn_GetIdxDataLikeSplit(RECV_HPHONE, 2, '-') AS RECV_HPHONE_NO2
        ,   dbo.fn_GetIdxDataLikeSplit(RECV_HPHONE, 3, '-') AS RECV_HPHONE_NO3
        ,   CONVERT(VARCHAR(8), SEND_DATE, 112) + '_' + @CUST_ID + '_' + DELIVERY_CODE + '_1_' + CAST(DELIVERY_SEQ AS VARCHAR(10)) AS MPCK_KEY
        ,   DELIVERY_MSG
        ,   CASE 
                    WHEN ORDER_TABLE_NAME = 'CUSTOM_ORDER' THEN '청첩장'
                    WHEN ORDER_TABLE_NAME = 'CUSTOM_SAMPLE_ORDER' THEN '샘플'
                    WHEN ORDER_TABLE_NAME = 'CUSTOM_ETC_ORDER' THEN '부가 상품'
                    ELSE '기타 상품'
            END AS PROD_NAME
        ,   CONVERT(VARCHAR(8), SEND_DATE, 112) AS SEND_DATE
        ,   DELIVERY_SEQ
    FROM    VW_DELIVERY_MST
    WHERE   1 = 1
    AND     SEND_DATE >= @START_DATE + ' 00:00:00'
    AND     SEND_DATE < @END_DATE + ' 00:00:00'
    AND     DELIVERY_CODE IS NOT NULL
    AND     DELIVERY_CODE <> ''
    AND     ISHJ = '0'










    
    OPEN DELIVERY_CURSOR;

    FETCH NEXT FROM DELIVERY_CURSOR 
    INTO    @ORDER_SEQ
        ,   @INVC_NO
        ,   @ORDER_TABLE_NAME  
        ,   @RCVR_NM         
        ,   @RCVR_ZIP_NO     
        ,   @RCVR_ADDR       
        ,   @RCVR_DETAIL_ADDR
        ,   @RCVR_TEL_NO1    
        ,   @RCVR_TEL_NO2    
        ,   @RCVR_TEL_NO3    
        ,   @RCVR_CELL_NO1   
        ,   @RCVR_CELL_NO2   
        ,   @RCVR_CELL_NO3   
        ,   @MPCK_KEY      
        ,   @DELIVERY_MSG
        ,   @GDS_NM
        ,   @RCPT_YMD
        ,   @DELIVERY_SEQ

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        BEGIN TRY
            
            SET @ORDRR_NM           = @RCVR_NM         
            SET @ORDRR_TEL_NO1      = @RCVR_TEL_NO1    
            SET @ORDRR_TEL_NO2      = @RCVR_TEL_NO2    
            SET @ORDRR_TEL_NO3      = @RCVR_TEL_NO3    
            SET @ORDRR_CELL_NO1     = @RCVR_CELL_NO1   
            SET @ORDRR_CELL_NO2     = @RCVR_CELL_NO2   
            SET @ORDRR_CELL_NO3     = @RCVR_CELL_NO3   
            SET @ORDRR_ZIP_NO       = @RCVR_ZIP_NO     
            SET @ORDRR_ADDR         = @RCVR_ADDR       
            SET @ORDRR_DETAIL_ADDR  = @RCVR_DETAIL_ADDR

            INSERT OPENQUERY 
            (
                    CJ_OPENDB
                ,   '
                        SELECT  CUST_ID
                            ,   RCPT_YMD
                            ,   CUST_USE_NO
                            ,   RCPT_DV
                            ,   WORK_DV_CD
                            ,   REQ_DV_CD
                            ,   MPCK_KEY
                            ,   MPCK_SEQ
                            ,   CAL_DV_CD
                            ,   FRT_DV_CD
                            ,   CNTR_ITEM_CD
                            ,   BOX_TYPE_CD
                            ,   BOX_QTY
                            ,   FRT
                            ,   CUST_MGMT_DLCM_CD

                            ,   SENDR_NM
                            ,   SENDR_TEL_NO1
                            ,   SENDR_TEL_NO2
                            ,   SENDR_TEL_NO3
                            ,   SENDR_CELL_NO1
                            ,   SENDR_CELL_NO2
                            ,   SENDR_CELL_NO3
                            ,   SENDR_SAFE_NO1
                            ,   SENDR_SAFE_NO2
                            ,   SENDR_SAFE_NO3
                            ,   SENDR_ZIP_NO
                            ,   SENDR_ADDR
                            ,   SENDR_DETAIL_ADDR

                            ,   RCVR_NM
                            ,   RCVR_TEL_NO1
                            ,   RCVR_TEL_NO2
                            ,   RCVR_TEL_NO3
                            ,   RCVR_CELL_NO1
                            ,   RCVR_CELL_NO2
                            ,   RCVR_CELL_NO3
                            ,   RCVR_SAFE_NO1
                            ,   RCVR_SAFE_NO2
                            ,   RCVR_SAFE_NO3
                            ,   RCVR_ZIP_NO
                            ,   RCVR_ADDR
                            ,   RCVR_DETAIL_ADDR

                            ,   ORDRR_NM
                            ,   ORDRR_TEL_NO1
                            ,   ORDRR_TEL_NO2
                            ,   ORDRR_TEL_NO3
                            ,   ORDRR_CELL_NO1
                            ,   ORDRR_CELL_NO2
                            ,   ORDRR_CELL_NO3
                            ,   ORDRR_SAFE_NO1
                            ,   ORDRR_SAFE_NO2
                            ,   ORDRR_SAFE_NO3
                            ,   ORDRR_ZIP_NO
                            ,   ORDRR_ADDR
                            ,   ORDRR_DETAIL_ADDR

                            ,   INVC_NO
                            ,   ORI_INVC_NO
                            ,   ORI_ORD_NO
                            ,   COLCT_EXPCT_YMD
                            ,   COLCT_EXPCT_HOUR
                            ,   SHIP_EXPCT_YMD
                            ,   SHIP_EXPCT_HOUR
                            ,   PRT_ST
                            ,   ARTICLE_AMT
                            ,   REMARK_1
                            ,   REMARK_2
                            ,   REMARK_3
                            ,   COD_YN
                            ,   GDS_CD
                            ,   GDS_NM
                            ,   GDS_QTY
                            ,   UNIT_CD
                            ,   UNIT_NM
                            ,   GDS_AMT
                            ,   ETC_1
                            ,   ETC_2
                            ,   ETC_3
                            ,   ETC_4
                            ,   ETC_5
                            ,   DLV_DV
                            ,   RCPT_ERR_YN
                            ,   RCPT_ERR_MSG
                            ,   EAI_PRGS_ST
                            ,   EAI_ERR_MSG
                            ,   REG_EMP_ID
                            ,   REG_DTIME
                            ,   MODI_EMP_ID
                            ,   MODI_DTIME

                        FROM    V_RCPT_BHANDS010
                    '
            )

            SELECT 
                    @CUST_ID
                ,   @RCPT_YMD
                ,   @ORDER_SEQ
                ,   @RCPT_DV
                ,   @WORK_DV_CD
                ,   @REQ_DV_CD
                ,   @MPCK_KEY
                ,   1
                ,   @CAL_DV_CD
                ,   @FRT_DV_CD
                ,   @CNTR_ITEM_CD
                ,   @BOX_TYPE_CD
                ,   1
                ,   0
                ,   @CUST_ID
        
                ,   @SENDR_NM
                ,   @SENDR_TEL_NO1
                ,   @SENDR_TEL_NO2
                ,   @SENDR_TEL_NO3
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   @SENDR_ZIP_NO
                ,   @SENDR_ADDR
                ,   @SENDR_DETAIL_ADDR

                ,   @RCVR_NM
                ,   @RCVR_TEL_NO1
                ,   @RCVR_TEL_NO2
                ,   @RCVR_TEL_NO3
                ,   @RCVR_CELL_NO1
                ,   @RCVR_CELL_NO2
                ,   @RCVR_CELL_NO3
                ,   ''
                ,   ''
                ,   ''
                ,   @RCVR_ZIP_NO
                ,   @RCVR_ADDR
                ,   @RCVR_DETAIL_ADDR

                ,   @ORDRR_NM     
                ,   @ORDRR_TEL_NO1
                ,   @ORDRR_TEL_NO2
                ,   @ORDRR_TEL_NO3
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   @ORDRR_ZIP_NO     
                ,   @ORDRR_ADDR       
                ,   @ORDRR_DETAIL_ADDR

                ,   @INVC_NO
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   @PRT_ST
                ,   NULL
                ,   @DELIVERY_MSG
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   @GDS_NM
                ,   NULL
                ,   ''
                ,   ''
                ,   NULL
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   ''
                ,   @DLV_DV
                ,   'N'
                ,   ''
                ,   '01'
                ,   ''
                ,   @EMP_ID
                ,   GETDATE()
                ,   @EMP_ID
                ,   GETDATE()



            IF @ORDER_TABLE_NAME = 'CUSTOM_ORDER' 
                BEGIN
                
                    UPDATE  DELIVERY_INFO_DELCODE
                    SET     ISHJ = '1'
                    WHERE   ORDER_SEQ = @ORDER_SEQ
                    AND     DELIVERY_CODE_NUM = @INVC_NO

                END
            ELSE IF @ORDER_TABLE_NAME = 'CUSTOM_SAMPLE_ORDER' 
                BEGIN
                
                    UPDATE  CUSTOM_SAMPLE_ORDER
                    SET     ISHJ = '1'
                    WHERE   SAMPLE_ORDER_SEQ = @ORDER_SEQ
                    AND     DELIVERY_CODE_NUM = @INVC_NO

                END
            ELSE IF @ORDER_TABLE_NAME = 'CUSTOM_ETC_ORDER' 
                BEGIN
                
                    UPDATE  CUSTOM_ETC_ORDER
                    SET     ISHJ = '1'
                    WHERE   ORDER_SEQ = @ORDER_SEQ
                    AND     DELIVERY_CODE = @INVC_NO

                END


            
            SET @RESULT_CODE = '0000'
            SET @RESULT_MSG  = '전송 완료'
            
            /* 로그 기록 */
            EXEC SP_INSERT_DELIVERY_SEND_LOG @ORDER_SEQ, @ORDER_TABLE_NAME, @INVC_NO, @RESULT_CODE, @RESULT_MSG, '', ''            

        END TRY

        BEGIN CATCH
            
            SET @RESULT_CODE = '2001'
            SET @RESULT_MSG  = '전송 에러'
            SET @ERROR_MSG = CONVERT(NVARCHAR(500), ERROR_MESSAGE())

            SET @ERROR_DESC = CONVERT(NVARCHAR(500)
                                , 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
                                  ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
                                  ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
                                  ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
                                  ', Line ' + CONVERT(varchar(5), ERROR_LINE())
                                )

            /* 로그 기록 */
            EXEC SP_INSERT_DELIVERY_SEND_LOG @ORDER_SEQ, @ORDER_TABLE_NAME, @INVC_NO, @RESULT_CODE, @RESULT_MSG, @ERROR_MSG, @ERROR_DESC



        END CATCH



        FETCH NEXT FROM DELIVERY_CURSOR 
        INTO    @ORDER_SEQ
            ,   @INVC_NO
            ,   @ORDER_TABLE_NAME  
            ,   @RCVR_NM         
            ,   @RCVR_ZIP_NO     
            ,   @RCVR_ADDR       
            ,   @RCVR_DETAIL_ADDR
            ,   @RCVR_TEL_NO1    
            ,   @RCVR_TEL_NO2    
            ,   @RCVR_TEL_NO3    
            ,   @RCVR_CELL_NO1   
            ,   @RCVR_CELL_NO2   
            ,   @RCVR_CELL_NO3   
            ,   @MPCK_KEY
            ,   @DELIVERY_MSG
            ,   @GDS_NM
            ,   @RCPT_YMD
            ,   @DELIVERY_SEQ
    END
	
    CLOSE DELIVERY_CURSOR;
    DEALLOCATE DELIVERY_CURSOR;

END TRY

BEGIN CATCH
    
    SET @RESULT_CODE = '3001'
    SET @RESULT_MSG  = '커서 에러'
    SET @ERROR_MSG = CONVERT(NVARCHAR(500), ERROR_MESSAGE())

    SET @ERROR_DESC = CONVERT(NVARCHAR(500)
                        , 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
                          ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
                          ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
                          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
                          ', Line ' + CONVERT(varchar(5), ERROR_LINE())
                      )

    /* 로그 기록 */
    EXEC SP_INSERT_DELIVERY_SEND_LOG '', '', '', @RESULT_CODE, @RESULT_MSG, @ERROR_MSG, @ERROR_DESC

END CATCH








    


/*

    * EXECUTE 방식 예제

*/

/*

DECLARE
            @CUST_ID AS VARCHAR(10)
        ,   @DATETIME AS DATETIME

SET @CUST_ID = '30184122'
SET @DATETIME = GETDATE()

EXECUTE (
            'BEGIN 
            INSERT INTO V_RCPT_BHANDS010
            (
                    CUST_ID
                ,   RCPT_YMD
                ,   CUST_USE_NO
                ,   RCPT_DV
                ,   WORK_DV_CD
                ,   REQ_DV_CD
                ,   MPCK_KEY
                ,   MPCK_SEQ
                ,   CAL_DV_CD
                ,   FRT_DV_CD
                ,   CNTR_ITEM_CD
                ,   BOX_TYPE_CD
                ,   BOX_QTY
                ,   FRT
                ,   CUST_MGMT_DLCM_CD
                ,   SENDR_NM
                ,   SENDR_TEL_NO1
                ,   SENDR_TEL_NO2
                ,   SENDR_TEL_NO3
                ,   SENDR_CELL_NO1
                ,   SENDR_CELL_NO2
                ,   SENDR_CELL_NO3
                ,   SENDR_SAFE_NO1
                ,   SENDR_SAFE_NO2
                ,   SENDR_SAFE_NO3
                ,   SENDR_ZIP_NO
                ,   SENDR_ADDR
                ,   SENDR_DETAIL_ADDR
                ,   RCVR_NM
                ,   RCVR_TEL_NO1
                ,   RCVR_TEL_NO2
                ,   RCVR_TEL_NO3
                ,   RCVR_CELL_NO1
                ,   RCVR_CELL_NO2
                ,   RCVR_CELL_NO3
                ,   RCVR_SAFE_NO1
                ,   RCVR_SAFE_NO2
                ,   RCVR_SAFE_NO3
                ,   RCVR_ZIP_NO
                ,   RCVR_ADDR
                ,   RCVR_DETAIL_ADDR
                ,   ORDRR_NM
                ,   ORDRR_TEL_NO1
                ,   ORDRR_TEL_NO2
                ,   ORDRR_TEL_NO3
                ,   ORDRR_CELL_NO1
                ,   ORDRR_CELL_NO2
                ,   ORDRR_CELL_NO3
                ,   ORDRR_SAFE_NO1
                ,   ORDRR_SAFE_NO2
                ,   ORDRR_SAFE_NO3
                ,   ORDRR_ZIP_NO
                ,   ORDRR_ADDR
                ,   ORDRR_DETAIL_ADDR
                ,   INVC_NO
                ,   ORI_INVC_NO
                ,   ORI_ORD_NO
                ,   COLCT_EXPCT_YMD
                ,   COLCT_EXPCT_HOUR
                ,   SHIP_EXPCT_YMD
                ,   SHIP_EXPCT_HOUR
                ,   PRT_ST
                ,   ARTICLE_AMT
                ,   REMARK_1
                ,   REMARK_2
                ,   REMARK_3
                ,   COD_YN
                ,   GDS_CD
                ,   GDS_NM
                ,   GDS_QTY
                ,   UNIT_CD
                ,   UNIT_NM
                ,   GDS_AMT
                ,   ETC_1
                ,   ETC_2
                ,   ETC_3
                ,   ETC_4
                ,   ETC_5
                ,   DLV_DV
                ,   RCPT_ERR_YN
                ,   RCPT_ERR_MSG
                ,   EAI_PRGS_ST
                ,   EAI_ERR_MSG
                ,   REG_EMP_ID
                ,   REG_DTIME
                ,   MODI_EMP_ID
                ,   MODI_DTIME
            )
            VALUES 
            (
                    ''30184122''
                ,   ''20150313''
                ,   ''13070516''
                ,   ''01''
                ,   ''01''
                ,   ''01''
                ,   ''1''
                ,   1
                ,   ''01''
                ,   ''03''
                ,   ''01''
                ,   ''02''
                ,   1
                ,   0
                ,   ''30184122''
                ,   ''송화인명''
                ,   fc_mscm_telnum_splt(?,1)
                ,   fc_mscm_telnum_splt(?,2)
                ,   fc_mscm_telnum_splt(?,3)
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''140871''
                ,   FC_KX_ADDR_SEPARATION(''ADDR_1'', ?)
                ,   FC_KX_ADDR_SEPARATION(''ADDR_2'', ?)
                ,   ''홍길동''
                ,   fc_mscm_telnum_splt(?,1)
                ,   fc_mscm_telnum_splt(?,2)
                ,   fc_mscm_telnum_splt(?,3)
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''220782''
                ,   ''강원도 원주시 봉산동 1201 삼익세라믹아파트''
                ,   ''000동 000호''
                ,   ''곽영신''
                ,   fc_mscm_telnum_splt(?,1)
                ,   fc_mscm_telnum_splt(?,2)
                ,   fc_mscm_telnum_splt(?,3)
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''301100112233''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''02''
                ,   NULL
                ,   ''배송메세지1''
                ,   ''배송메세지2''
                ,   ''배송메세지3''
                ,   ''''
                ,   ''''
                ,   ''상품명''
                ,   NULL
                ,   ''''
                ,   ''''
                ,   NULL
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''''
                ,   ''01''
                ,   ''N''
                ,   ''''
                ,   ''01''
                ,   ''''
                ,   ''BHANDS''
                ,   ''2015-07-16 10:41:00''
                ,   ''BHANDS''
                ,   ?
            ); END;
            ',
                    '123-4567-8901'
                ,   '123-4567-8901'
                ,   '123-4567-8901'
                
                ,   '서울시 용산구 한강로2가2-185 0000 2층 19호'
                ,   '서울시 용산구 한강로2가2-185 0000 2층 19호'

                ,   '123-4567-8901'
                ,   '123-4567-8901'
                ,   '123-4567-8901'

                ,   '123-4567-8901'
                ,   '123-4567-8901'
                ,   '123-4567-8901'

                ,   @DATETIME
        ) 
    AT CJ_OPENDBT;

*/



END
GO
