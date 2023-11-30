IF OBJECT_ID (N'dbo.SP_EXEC_DELIVERY_RECEIPT_FOR_CJ_NEW_API_VER2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_DELIVERY_RECEIPT_FOR_CJ_NEW_API_VER2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

    EXECUTE ('BEGIN SELECT CUST_ID FROM V_RCPT_BHANDS010 END;') AT CJ_OPENDB

    SELECT * FROM OPENQUERY(CJ_OPENDB, 'SELECT * FROM V_RCPT_BHANDS010 WHERE CUST_ID = ''30184122'' order by rcpt_ymd desc')
    SELECT * FROM OPENQUERY(CJ_OPENDBT, 'SELECT * FROM V_RCPT_BHANDS010')

    EXEC [SP_EXEC_DELIVERY_RECEIPT_FOR_CJ] '2016-08-24', '2016-08-26'

    SELECT * FROM OPENQUERY(CJ_OPENDBT,'SELECT fc_mscm_telnum_splt(''123-4567-8901'',1) FROM V_RCPT_BHANDS010')

    EXEC SP_EXEC_DELIVERY_RECEIPT_FOR_CJ CONVERT(VARCHAR(10), GETDATE(), 120), CONVERT(VARCHAR(10), GETDATE() + 1, 120)
*/
CREATE PROCEDURE [dbo].[SP_EXEC_DELIVERY_RECEIPT_FOR_CJ_NEW_API_VER2] 
  @START_DATE AS VARCHAR(10)
,  @END_DATE AS VARCHAR(10)
AS
BEGIN

	DECLARE @CUST_ID			VARCHAR(10),   
			@RCPT_YMD			VARCHAR(8),   
			@RCPT_DV			VARCHAR(2),   
			@WORK_DV_CD			VARCHAR(2),   
			@REQ_DV_CD          VARCHAR(2),  
			@MPCK_KEY			VARCHAR(100),   
			@MPCK_SEQ			INT,   
			@CAL_DV_CD			VARCHAR(2),   
			@FRT_DV_CD			VARCHAR(2),   
			@CNTR_ITEM_CD       VARCHAR(2),  
			@BOX_TYPE_CD        VARCHAR(2), 
			@BOX_QTY            VARCHAR(2),   
			@SENDR_NM           VARCHAR(100),   
			@SENDR_TEL_NO1      VARCHAR(4),   
			@SENDR_TEL_NO2      VARCHAR(4),   
			@SENDR_TEL_NO3      VARCHAR(4),  
			@SENDR_ZIP_NO       VARCHAR(6),  
			@SENDR_ADDR         VARCHAR(100),  
			@SENDR_DETAIL_ADDR  VARCHAR(100),   
			@RCVR_NM			VARCHAR(100),   
			@RCVR_TEL_NO1		VARCHAR(4), 
			@RCVR_TEL_NO2		VARCHAR(4),   
			@RCVR_TEL_NO3       VARCHAR(4),  
			@RCVR_CELL_NO1      VARCHAR(4), 
			@RCVR_CELL_NO2      VARCHAR(4), 
			@RCVR_CELL_NO3      VARCHAR(4),  
			@RCVR_ZIP_NO        VARCHAR(6),  
			@RCVR_ADDR          VARCHAR(100), 
			@RCVR_DETAIL_ADDR   VARCHAR(100),  
			@ORDRR_NM			VARCHAR(100),  
			@ORDRR_TEL_NO1		VARCHAR(4),  
			@ORDRR_TEL_NO2		VARCHAR(4),  
			@ORDRR_TEL_NO3		VARCHAR(4), 
			@ORDRR_CELL_NO1		VARCHAR(4), 
			@ORDRR_CELL_NO2		VARCHAR(4), 
			@ORDRR_CELL_NO3		VARCHAR(4), 
			@ORDRR_ZIP_NO		VARCHAR(6),
			@ORDRR_ADDR			VARCHAR(100),   
			@ORDRR_DETAIL_ADDR	VARCHAR(100),

			@INVC_NO			VARCHAR(20),   
			@PRT_ST				VARCHAR(3),   
			@GDS_NM				VARCHAR(250),   
			@DLV_DV				VARCHAR(2),   
			@EMP_ID				VARCHAR(10),

			@ORDER_SEQ          VARCHAR(20),  
			@ORDER_TABLE_NAME   VARCHAR(50),   
			@DELIVERY_MSG		NVARCHAR(200),   
			@DELIVERY_SEQ		INT,

			@RESULT_CODE		VARCHAR(4),
			@RESULT_MSG			NVARCHAR(500),   
			@ERROR_MSG			NVARCHAR(500),   
			@ERROR_DESC			NVARCHAR(500), 
			@BUSEONAME			VARCHAR(20) --추가 
	
	SET @ORDER_SEQ = ''
	SET @BUSEONAME	= '' --추가 
	SET	@DELIVERY_SEQ = 1

	SET	@CUST_ID = '30184122' -- 거래코드
	SET @EMP_ID = 'BHANDS'                                  -- DB 접속계정 대문자
	SET @INVC_NO = ''                                        -- 송장번호
	SET @RCPT_YMD = CONVERT(VARCHAR(8), GETDATE() - 1, 112)       
	SET @RCPT_DV = '01'                                      -- 01 : 일반, 02 : 반품
	SET @WORK_DV_CD = '01'                                      -- 01 : 일반, 02 : 교환, 03 : A/S
	SET @REQ_DV_CD = '01'                                      -- 01 : 요청, 02 : 취소
	SET @MPCK_KEY = @RCPT_YMD + '_' + @CUST_ID + '_'          -- 자체출력사 : YYYYMMDD_고객ID_운송장번호
	SET @MPCK_SEQ = 1                                         -- 합포장 처리 건수
	SET @CAL_DV_CD = '01'                                      -- 01 : 계약 운임, 02 : 자료 운임
	SET @FRT_DV_CD = '03'                                      -- 01 : 선불, 02 : 착불, 03 : 신용
	SET @CNTR_ITEM_CD = '01'                                      -- 01 : 일반품목
	SET @BOX_TYPE_CD = '01'                                      -- 01 : 극소, 02 : 소, 03 : 중, 04 : 대, 05 : 특대
	SET @BOX_QTY = 1

	SET @SENDR_NM = '바른컴퍼니(파주)'                           -- 회사명
	SET @SENDR_TEL_NO1 = '02'                                      
	SET @SENDR_TEL_NO2 = '1644'
	SET @SENDR_TEL_NO3 = '0708'
	SET @SENDR_ZIP_NO = '413120'
	SET @SENDR_ADDR = '경기도 파주시 회동길'
	SET @SENDR_DETAIL_ADDR = '219 (주)바른컴퍼니'

	SET @RCVR_NM = ''   
	SET @RCVR_TEL_NO1 = ''                
	SET @RCVR_TEL_NO2 = ''
	SET @RCVR_TEL_NO3 = ''
	SET @RCVR_CELL_NO1 = ''                
	SET @RCVR_CELL_NO2 = ''
	SET @RCVR_CELL_NO3 = ''
	SET @RCVR_ZIP_NO = ''
	SET @RCVR_ADDR = ''
	SET @RCVR_DETAIL_ADDR = ''

	SET @ORDRR_NM = ''    
	SET @ORDRR_TEL_NO1 = ''                
	SET @ORDRR_TEL_NO2 = ''
	SET @ORDRR_TEL_NO3 = ''
	SET @ORDRR_CELL_NO1 = ''                
	SET @ORDRR_CELL_NO2 = ''
	SET @ORDRR_CELL_NO3 = ''
	SET @ORDRR_ZIP_NO = ''
	SET @ORDRR_ADDR = ''
	SET @ORDRR_DETAIL_ADDR  = ''
                           
	SET @PRT_ST = '02' -- 01 : 미출력, 02 : 선출력, 03 : 선발번
	SET @GDS_NM = '상품명' -- 상품명
	SET @DLV_DV = '01' -- 택배 : '01', 중량물(설치물류) : '02', 중량물(비설치물류) : '03'


BEGIN TRY

    DECLARE DELIVERY_CURSOR CURSOR LOCAL FOR

	 SELECT ORDER_SEQ = A.ORDER_SEQ,
			DELIVERY_CODE =  A.DELIVERY_CODE,
			ORDER_TABLE_NAME =  A.ORDER_TABLE_NAME,
			RECV_NAME = A.RECV_NAME,
			--RECV_ZIP = A.RECV_ZIP,
			RECV_ZIP =  CASE WHEN ISNULL(A.RECV_ZIP,'') = ''  
						 THEN '111111'
						 ELSE A.RECV_ZIP
						END,  
			RECV_ADDR = A.RECV_ADDR,
			RECV_ADDR_DETAIL =  CASE WHEN REPLACE(ISNULL(A.RECV_ADDR_DETAIL, ''), ' ', '') = '' THEN '.' ELSE A.RECV_ADDR_DETAIL END ,
			RECV_PHONE_NO1 = dbo.fn_GetIdxDataLikeSplit(A.RECV_PHONE, 1, '-') ,
			RECV_PHONE_NO2 = dbo.fn_GetIdxDataLikeSplit(A.RECV_PHONE, 2, '-'),
			RECV_PHONE_NO3 = dbo.fn_GetIdxDataLikeSplit(A.RECV_PHONE, 3, '-') ,
			RECV_HPHONE_NO1 = dbo.fn_GetIdxDataLikeSplit(A.RECV_HPHONE, 1, '-'),
			RECV_HPHONE_NO2 = dbo.fn_GetIdxDataLikeSplit(A.RECV_HPHONE, 2, '-'),
			RECV_HPHONE_NO3 = dbo.fn_GetIdxDataLikeSplit(A.RECV_HPHONE, 3, '-') ,
			MPCK_KEY = CONVERT(VARCHAR(8), isnull(A.SEND_DATE, getdate()), 112) + '_' + @CUST_ID + '_' + A.DELIVERY_CODE + '_1_' + CAST(A.DELIVERY_SEQ AS VARCHAR(10)) ,
			DELIVERY_MSG = A.DELIVERY_MSG,
			PROD_NAME = CASE WHEN A.ORDER_TABLE_NAME = 'CUSTOM_ORDER' THEN '청첩장'
							 WHEN A.ORDER_TABLE_NAME = 'CUSTOM_SAMPLE_ORDER' THEN '샘플'
							 WHEN A.ORDER_TABLE_NAME = 'CUSTOM_ETC_ORDER' THEN '부가 상품'
							 ELSE '기타 상품'
						END,
			SEND_DATE = CONVERT(VARCHAR(8), isnull(A.SEND_DATE, getdate()), 112) ,
			DELIVERY_SEQ = A.DELIVERY_SEQ,	
			BUSEONAME = CASE WHEN B.ERP_PARTCODE = '110' THEN '바른손카드' 
							WHEN B.ERP_PARTCODE = '230' THEN '비핸즈카드' 
							WHEN B.ERP_PARTCODE = '130' THEN '프리미어페이퍼' 
							WHEN B.ERP_PARTCODE = '140' THEN '더카드' 
							WHEN B.ERP_PARTCODE = '340' THEN '직매장' 
							WHEN B.ERP_PARTCODE = '365' OR B.ERP_PARTCODE = '366' THEN '웨딩제휴' 
							WHEN B.ERP_PARTCODE = '390' THEN '제휴영업' 
							WHEN B.ERP_PARTCODE = '410' THEN '해외영업' 
							WHEN B.ERP_PARTCODE = '340-1' THEN '직매장' 
							WHEN B.ERP_PARTCODE IS NULL AND B.SALES_GUBUN = 'P' THEN '직매장'   
							WHEN B.ERP_PARTCODE IS NULL AND B.SALES_GUBUN = 'Q' THEN '직매장(대리점영업)'   
							WHEN B.ERP_PARTCODE = '240' THEN '디얼디어' 
						 ELSE '' END
	FROM    VW_DELIVERY_MST A INNER JOIN COMPANY B
			on A.COMPANY_SEQ = B.COMPANY_SEQ
	WHERE   1 = 1
	--AND A.ORDER_SEQ = @ORDER_SEQ
	AND     A.SEND_DATE >= @START_DATE + ' 00:00:00'
	AND     A.SEND_DATE < @END_DATE + ' 00:00:00'
	AND     A.DELIVERY_CODE IS NOT NULL
	AND     A.DELIVERY_CODE <> ''
	AND     A.ISHJ = '0'

    OPEN DELIVERY_CURSOR;

    FETCH NEXT FROM DELIVERY_CURSOR 
    INTO    @ORDER_SEQ,   
			@INVC_NO,   
			@ORDER_TABLE_NAME, 
			@RCVR_NM,
			@RCVR_ZIP_NO,
			@RCVR_ADDR, 
			@RCVR_DETAIL_ADDR, 
			@RCVR_TEL_NO1, 
			@RCVR_TEL_NO2, 
			@RCVR_TEL_NO3, 
			@RCVR_CELL_NO1, 
			@RCVR_CELL_NO2, 
			@RCVR_CELL_NO3,
			@MPCK_KEY,
			@DELIVERY_MSG, 
			@GDS_NM, 
			@RCPT_YMD, 
			@DELIVERY_SEQ,
			@BUSEONAME
    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        BEGIN TRY
            
            SET @ORDRR_NM           = @RCVR_NM         
            SET @ORDRR_TEL_NO1      = @RCVR_TEL_NO1    
            SET @ORDRR_TEL_NO2      = @RCVR_TEL_NO2    
            SET @ORDRR_TEL_NO3  = @RCVR_TEL_NO3    
            SET @ORDRR_CELL_NO1     = @RCVR_CELL_NO1   
            SET @ORDRR_CELL_NO2     = @RCVR_CELL_NO2   
            SET @ORDRR_CELL_NO3     = @RCVR_CELL_NO3   
            SET @ORDRR_ZIP_NO       = @RCVR_ZIP_NO     
            SET @ORDRR_ADDR         = @RCVR_ADDR       
            SET @ORDRR_DETAIL_ADDR  = @RCVR_DETAIL_ADDR

         

            SELECT 
                    CUST_ID = @CUST_ID,   
				 RCPT_YMD = @RCPT_YMD,
                 CUST_USE_NO = @ORDER_SEQ, 
				 RCPT_DV = @RCPT_DV, 
				 WORK_DV_CD = @WORK_DV_CD,
				 REQ_DV_CD = @REQ_DV_CD, 
				 MPCK_KEY = @MPCK_KEY,
				 MPCK_SEQ = 1, 
				 CAL_DV_CD = @CAL_DV_CD,
				 FRT_DV_CD = @FRT_DV_CD,
				 CNTR_ITEM_CD = @CNTR_ITEM_CD,
				 BOX_TYPE_CD = @BOX_TYPE_CD, 
				 BOX_QTY = 1,
				 FRT = 0, 
				 CUST_MGMT_DLCM_CD = @CUST_ID, 
				 SENDR_NM = @SENDR_NM, 
				 SENDR_TEL_NO1 = @SENDR_TEL_NO1,
				 SENDR_TEL_NO2 = @SENDR_TEL_NO2,
				 SENDR_TEL_NO3 = @SENDR_TEL_NO3,
				 SENDR_CELL_NO1 = '', 
				 SENDR_CELL_NO2 = '',
				 SENDR_CELL_NO3 = '', 
				 SENDR_SAFE_NO1 = '', 
				 SENDR_SAFE_NO2 = '',
				 SENDR_SAFE_NO3 = '',
				 SENDR_ZIP_NO = @SENDR_ZIP_NO,
				 SENDR_ADDR = @SENDR_ADDR,
				 SENDR_DETAIL_ADDR = @SENDR_DETAIL_ADDR,
				 RCVR_NM = @RCVR_NM,
				 RCVR_TEL_NO1 = @RCVR_TEL_NO1,
				 RCVR_TEL_NO2 = @RCVR_TEL_NO2,
				 RCVR_TEL_NO3 = @RCVR_TEL_NO3,
				 RCVR_CELL_NO1 = @RCVR_CELL_NO1,
				 RCVR_CELL_NO2 = @RCVR_CELL_NO2,
				 RCVR_CELL_NO3 = @RCVR_CELL_NO3,
				 RCVR_SAFE_NO1 = '',
				 RCVR_SAFE_NO2 = '',
				 RCVR_SAFE_NO3 = '',
				 RCVR_ZIP_NO = @RCVR_ZIP_NO,
				 RCVR_ADDR = @RCVR_ADDR, 
				 RCVR_DETAIL_ADDR = @RCVR_DETAIL_ADDR,
				 ORDRR_NM = @ORDRR_NM, 
				 ORDRR_TEL_NO1 = @ORDRR_TEL_NO1,
				 ORDRR_TEL_NO2 = @ORDRR_TEL_NO2,
				 ORDRR_TEL_NO3 = @ORDRR_TEL_NO3,
				 ORDRR_CELL_NO1 = '',
				 ORDRR_CELL_NO2 = '',
				 ORDRR_CELL_NO3 = '',
				 ORDRR_SAFE_NO1 = '',
				 ORDRR_SAFE_NO2 = '',
				 ORDRR_SAFE_NO3 = '',
				 ORDRR_ZIP_NO = @ORDRR_ZIP_NO,
				 ORDRR_ADDR = @ORDRR_ADDR, 
				 ORDRR_DETAIL_ADDR = @ORDRR_DETAIL_ADDR, 
				 INVC_NO = @INVC_NO,
				 ORI_INVC_NO = '',
				 ORI_ORD_NO = '',
				 COLCT_EXPCT_YMD =  '',
				 COLCT_EXPCT_HOUR = '',
				 SHIP_EXPCT_YMD =  '',
				 SHIP_EXPCT_HOUR =  '',
				 PRT_ST = @PRT_ST,
				 ARTICLE_AMT = NULL,
				 REMARK_1 = @DELIVERY_MSG,
				 REMARK_2 = '',
				 REMARK_3 = '',
				 COD_YN =  '',
				 GDS_CD = '',    
				 GDS_NM = @GDS_NM,
				 GDS_QTY = NULL,
				 UNIT_CD = '',
				 UNIT_NM =  '',
				 GDS_AMT =  NULL,
				 ETC_1 =   @BUSEONAME --ETC1  
				,ETC_2 =   '', 
				 ETC_3 =  '', 
				 ETC_4 =   '',
				 ETC_5 =  '',
				 DLV_DV =  @DLV_DV, 
				 RCPT_ERR_YN = 'N',
				 RCPT_ERR_MSG = '',
				 EAI_PRGS_ST = '01',
				 EAI_ERR_MSG = '',
				 REG_EMP_ID = @EMP_ID,
				 REG_DTIME = GETDATE(),
				 MODI_EMP_ID = @EMP_ID,
				 MODI_DTIME = GETDATE(),
				 ORDER_TABLE_NAME = @ORDER_TABLE_NAME



            --IF @ORDER_TABLE_NAME = 'CUSTOM_ORDER' 
            --    BEGIN
                
            --        UPDATE  DELIVERY_INFO_DELCODE
            --        SET     ISHJ = '1'
            --        WHERE   ORDER_SEQ = @ORDER_SEQ
            --        AND     DELIVERY_CODE_NUM = @INVC_NO

            --    END
            --ELSE IF @ORDER_TABLE_NAME = 'CUSTOM_SAMPLE_ORDER' 
            --    BEGIN
                
            --        UPDATE  CUSTOM_SAMPLE_ORDER
            --        SET     ISHJ = '1'
            --        WHERE   SAMPLE_ORDER_SEQ = @ORDER_SEQ
            --        AND     DELIVERY_CODE_NUM = @INVC_NO

            --    END
            --ELSE IF @ORDER_TABLE_NAME = 'CUSTOM_ETC_ORDER' 
            --    BEGIN
                
            --        UPDATE  CUSTOM_ETC_ORDER
            --        SET     ISHJ = '1'
            --        WHERE   ORDER_SEQ = @ORDER_SEQ
            --        AND     DELIVERY_CODE = @INVC_NO

      --    END


            
            --SET @RESULT_CODE = '0000'
            --SET @RESULT_MSG  = '전송 완료'
            
            --/* 로그 기록 */
            --EXEC SP_INSERT_DELIVERY_SEND_LOG @ORDER_SEQ, @ORDER_TABLE_NAME, @INVC_NO, @RESULT_CODE, @RESULT_MSG, '', ''            

        END TRY

        BEGIN CATCH
            
            --SET @RESULT_CODE = '2001'
            --SET @RESULT_MSG  = '전송 에러'
            --SET @ERROR_MSG = CONVERT(NVARCHAR(500), ERROR_MESSAGE())

            --SET @ERROR_DESC = CONVERT(NVARCHAR(500)
            --                    , 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
            --                      ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
            --                      ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
            --                      ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
            --                      ', Line ' + CONVERT(varchar(5), ERROR_LINE())
            --                    )

            --/* 로그 기록 */
            --EXEC SP_INSERT_DELIVERY_SEND_LOG @ORDER_SEQ, @ORDER_TABLE_NAME, @INVC_NO, @RESULT_CODE, @RESULT_MSG, @ERROR_MSG, @ERROR_DESC



        END CATCH



        FETCH NEXT FROM DELIVERY_CURSOR 
        INTO    @ORDER_SEQ, 
				@INVC_NO, 
				@ORDER_TABLE_NAME,
				@RCVR_NM,
				@RCVR_ZIP_NO, 
				@RCVR_ADDR, 
				@RCVR_DETAIL_ADDR, 
				@RCVR_TEL_NO1, 
				@RCVR_TEL_NO2, 
				@RCVR_TEL_NO3, 
				@RCVR_CELL_NO1,
				@RCVR_CELL_NO2,
				@RCVR_CELL_NO3,
				@MPCK_KEY,
				@DELIVERY_MSG,
				@GDS_NM, 
				@RCPT_YMD, 
				@DELIVERY_SEQ, 
				@BUSEONAME --추가 
    END
	
    CLOSE DELIVERY_CURSOR;
    DEALLOCATE DELIVERY_CURSOR;

END TRY

BEGIN CATCH
    
    --SET @RESULT_CODE = '3001'
    --SET @RESULT_MSG  = '커서 에러'
    --SET @ERROR_MSG = CONVERT(NVARCHAR(500), ERROR_MESSAGE())

    --SET @ERROR_DESC = CONVERT(NVARCHAR(500)
    --                    , 'Error ' + CONVERT(varchar(50), ERROR_NUMBER()) +
    --                      ', Severity ' + CONVERT(varchar(5), ERROR_SEVERITY()) +
    --                      ', State ' + CONVERT(varchar(5), ERROR_STATE()) + 
    --          ', Procedure ' + ISNULL(ERROR_PROCEDURE(), '-') + 
    --                      ', Line ' + CONVERT(varchar(5), ERROR_LINE())
    --                  )

    --/* 로그 기록 */
    --EXEC SP_INSERT_DELIVERY_SEND_LOG '', '', '', @RESULT_CODE, @RESULT_MSG, @ERROR_MSG, @ERROR_DESC

END CATCH
 

END

GO
