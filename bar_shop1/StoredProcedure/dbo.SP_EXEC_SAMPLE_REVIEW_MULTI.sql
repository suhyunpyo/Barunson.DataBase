IF OBJECT_ID (N'dbo.SP_EXEC_SAMPLE_REVIEW_MULTI', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SAMPLE_REVIEW_MULTI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************************************************************
작성자		: 강찬용
작성일		: 2022-02-28
DESCRIPTION	: 
SPECIAL LOGIC	: 
URL			: 
EXEC		: 
*********************************************************************************************************************
MODIFICATION
*********************************************************************************************************************
수정일		작업자		요청자				DESCRIPTION
=====================================================================================================================
20220228	강찬용						    체크박스 다중선택 샘플리뷰 승인/쿠폰발급
*********************************************************************************************************************/ 
CREATE PROCEDURE [dbo].[SP_EXEC_SAMPLE_REVIEW_MULTI]  
    @P_IDX_GROUP    VARCHAR(1000),
    @P_STATUS   INT,
    @P_CANCEL_COMMENT   VARCHAR(200)

AS
    BEGIN

        SET NOCOUNT ON;

        DECLARE @PREV_STATUS AS INT,
                @COMPANY_SEQ AS INT,
                @USER_ID AS VARCHAR(50),
                @ER_TYPE AS INT,
                @HAND_HPHONE AS VARCHAR(50),
                @SITE_NAME AS VARCHAR(30),
                @CS_PHONE_NUMBER AS VARCHAR(20),
                @SMS_MSG AS VARCHAR(100),
                @SITE_TYPE AS VARCHAR(4)


        /* 20201123 추가 START */
        DECLARE	@ERRNUM INT,
                @ERRSEV INT, 
                @ERRSTATE INT, 
                @ERRPROC VARCHAR(50), 
                @ERRLINE INT, 
                @ERRMSG VARCHAR(2000)
        /* 20201123 추가 END */


        DECLARE @list varchar(8000)
        DECLARE @pos INT
        DECLARE @len INT
        DECLARE @P_IDX varchar(8000)

        SET @list = @P_IDX_GROUP + '|'

        set @pos = 0
        set @len = 0

        WHILE CHARINDEX('|', @list, @pos+1)>0
        BEGIN
            set @len = CHARINDEX('|', @list, @pos+1) - @pos
            set @P_IDX = SUBSTRING(@list, @pos, @len)
            
            
            --DO YOUR MAGIC HERE
            /*   
            ComapnySeq, Status, UserId, ErType 을 가져온다.   
            더카드 : S4_EVENT_REVIEW   .ER_STATUS  
            나머지 : S4_EVENT_REVIEW_STATUS .ERA_STATUS   
            */  
            SELECT	@COMPANY_SEQ = SER.ER_COMPANY_SEQ,     
                    @PREV_STATUS = CASE WHEN SER.ER_COMPANY_SEQ = 5007 THEN SER.ER_STATUS ELSE SERS.ERA_STATUS END,
                    @USER_ID = SER.ER_USERID,
                    @ER_TYPE = SER.ER_TYPE  
            FROM	S4_EVENT_REVIEW SER JOIN 
                    S4_EVENT_REVIEW_STATUS SERS ON SER.ER_IDX = SERS.ERA_ER_IDX  
            WHERE	1 = 1 AND
                    SER.ER_IDX = @P_IDX 

            /* 핸드폰 번호 셋팅 */  
            SET @HAND_HPHONE = ISNULL((SELECT TOP 1 HPHONE FROM VW_USER_INFO WHERE UID = @USER_ID), '')  

            SET @HAND_HPHONE = 'AA^'+@HAND_HPHONE

            SET @SITE_NAME = CASE WHEN @COMPANY_SEQ = 5001 THEN '바른손카드'   
                                WHEN @COMPANY_SEQ = 5006 THEN '비핸즈카드'   
                            ELSE '바른손몰'   
                            END  

            SET @CS_PHONE_NUMBER = CASE   
                    WHEN @COMPANY_SEQ = 5001 THEN '16440708'  
                    WHEN @COMPANY_SEQ = 5003 THEN '16448796'  
                    WHEN @COMPANY_SEQ = 5006 THEN '16449713'  
                    ELSE '16447413'   
                    END  
        
            SET @SITE_TYPE = CASE WHEN @COMPANY_SEQ = 5001 THEN 'SB'
                                WHEN @COMPANY_SEQ = 5003 THEN 'SS'
                                WHEN @COMPANY_SEQ = 5006 THEN 'SA'
                            ELSE 'B'
                            END
            /*   
            0 : 승인대기  
            1 : 승인완료  
            2 : 승인취소  
            승인완료 또는 승인취소에서 승인대기로 변경할 경우 승인취소로 강제로 지정한다.   
            */  
            SET @P_STATUS = CASE WHEN @PREV_STATUS IN (1, 2) AND @P_STATUS = 0 THEN 2 ELSE @P_STATUS END  

            /* 파라미터로 받아온 데이타로 업데이트 한다. */  
            UPDATE     S4_EVENT_REVIEW  
            SET       ER_STATUS       =   @P_STATUS  
            WHERE ER_IDX = @P_IDX  
        
            UPDATE      S4_EVENT_REVIEW_STATUS  
            SET         ERA_STATUS          =   @P_STATUS   
                    , ERA_COMMENT_CANCEL    =   @P_CANCEL_COMMENT
            WHERE ERA_ER_IDX = @P_IDX  

            /* 상태가 변경 되었을 경우에만 해당 로직을 태운다 */  
            IF @PREV_STATUS<>@P_STATUS 
          --      BEGIN  
            
                    DECLARE     @COUPON_CODE_1 AS VARCHAR(30)  
                        ,       @COUPON_CODE_2 AS VARCHAR(30)  
                        ,       @COUPON_CODE_3 AS VARCHAR(30)  
                        ,       @COUPON_CODE_4 AS VARCHAR(30)
            
                    /* 쿠폰 코드를 셋팅한다. */  
                    /*   
                        바/비 공통  
                        더카드는 블로그&카페 리뷰일 경우 쿠폰 3장 (ER_TYPE : 11)  
                                SNS 리뷰일 경우 쿠폰 1장 (ER_TYPE : 12)  
                    */  

                    SET @COUPON_CODE_1 = CASE   
                                                WHEN @COMPANY_SEQ = 5001 THEN 'AF2C-281A-4BFF-A4B3'  
                                                WHEN @COMPANY_SEQ = 5003 THEN 'PPSAM-' + LEFT(NEWID(), 13)  
                                                WHEN @COMPANY_SEQ = 5006 THEN 'AF2C-281A-4BFF-A4B3'  
                                                WHEN @COMPANY_SEQ = 5007 THEN (CASE WHEN @ER_TYPE = 11 THEN 'AE07-4FD4-42C9-9FA6' ELSE '54FB-A8C7-4433-AEAA' END)  
                                                ELSE 'BHCPSAMPLE20000_JEHU'  
                                            END  
                    SET @COUPON_CODE_2 = CASE   
                                                WHEN @COMPANY_SEQ = 5001 THEN 'FDF6-3497-42F8-B68A'  
                                                WHEN @COMPANY_SEQ = 5003 THEN ''  
                                                WHEN @COMPANY_SEQ = 5006 THEN 'FDF6-3497-42F8-B68A'  
                                                WHEN @COMPANY_SEQ = 5007 THEN 'F57B-20E4-4B64-BFFA'  
                                                ELSE 'BHCPSAMPLE30000_JEHU'  
                                            END  
                    SET @COUPON_CODE_3 = CASE   
                                                WHEN @COMPANY_SEQ = 5001 THEN '9F7A-D4A1-4860-8AA9'  
                                                WHEN @COMPANY_SEQ = 5003 THEN ''  
                                                WHEN @COMPANY_SEQ = 5006 THEN '9F7A-D4A1-4860-8AA9'  
                                                WHEN @COMPANY_SEQ = 5007 THEN 'F40C-DDEF-49FB-87CC'  
                                                ELSE 'BHCPSAMPLE40000_JEHU'  
                                            END  
			        SET @COUPON_CODE_4 = CASE   
			              WHEN @COMPANY_SEQ = 5001 THEN ''  
			              WHEN @COMPANY_SEQ = 5003 THEN ''  
			              WHEN @COMPANY_SEQ = 5006 THEN ''  
			              WHEN @COMPANY_SEQ = 5007 THEN ''  
			              ELSE 'BHCPSAMPLE50000_JEHU'  
			             END                                               

                        /* 승인완료일 경우 */  
                        IF @P_STATUS = 1  
                            BEGIN  

                                /* 쿠폰발급상태로 업데이트한다. */  
                                UPDATE S4_EVENT_REVIEW_STATUS  
                                SET  ERA_COUPON_STATUS = 1  
                                WHERE ERA_ER_IDX = @P_IDX  

                                /* 바른손카드, 비핸즈카드, 바른손몰, 더카드 */  
                                IF @COMPANY_SEQ NOT IN (5003)  
                                    BEGIN  
	                                    print @COMPANY_SEQ
                                        IF @COMPANY_SEQ = 5001  
                                            BEGIN  
                                                /*
                                                    - 1만원 쿠폰 : B47D-71F4-4745-B085 -- 1만원 쿠폰 없음
                                                    - 2만원 쿠폰 : 7B10-5AF7-43D6-B43A
                                                    - 3만원 쿠폰 : 9693-79AF-4F00-8967
                                                    - 4만원 쿠폰 : 7F2C-DFEB-4A47-8F00
													- 5만원 쿠폰 : 3D8F-C9DD-4B3C-981F
                                                */
                                               -- EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @USER_ID, 'B47D-71F4-4745-B085'  
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @USER_ID, '7B10-5AF7-43D6-B43A'  
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @USER_ID, '9693-79AF-4F00-8967' 
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @USER_ID, '7F2C-DFEB-4A47-8F00' 
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @USER_ID, '3D8F-C9DD-4B3C-981F' 
                                            END

                                        ELSE IF @COMPANY_SEQ = 5006  
                                            BEGIN  

                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SA', @USER_ID, @COUPON_CODE_1  
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SA', @USER_ID, @COUPON_CODE_2  
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SA', @USER_ID, @COUPON_CODE_3  
                                            END  
                                        ELSE IF @COMPANY_SEQ = 5007  
                                            BEGIN  

                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'ST', @USER_ID, 'D88C-ADFB-42BA-95FB'  
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'ST', @USER_ID, 'B4E5-5EFF-4C2F-AD25'  
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'ST', @USER_ID, 'D7FE-2AC3-4935-B0AD' 
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'ST', @USER_ID, '4BD6-FA79-4E12-9343' 
                                                EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'ST', @USER_ID, '167E-DE47-420D-8B46' 
                                            END
                                        ELSE  
                                            BEGIN  

                                                INSERT INTO S4_MYCOUPON (COUPON_CODE, UID, COMPANY_SEQ, END_DATE) VALUES (@COUPON_CODE_1, @USER_ID, @COMPANY_SEQ, LEFT(DATEADD(M,2,GETDATE()),10) )  
                                                INSERT INTO S4_MYCOUPON (COUPON_CODE, UID, COMPANY_SEQ, END_DATE) VALUES (@COUPON_CODE_2, @USER_ID, @COMPANY_SEQ, LEFT(DATEADD(M,2,GETDATE()),10) )  
                                                INSERT INTO S4_MYCOUPON (COUPON_CODE, UID, COMPANY_SEQ, END_DATE) VALUES (@COUPON_CODE_3, @USER_ID, @COMPANY_SEQ, LEFT(DATEADD(M,2,GETDATE()),10) )  
                                                INSERT INTO S4_MYCOUPON (COUPON_CODE, UID, COMPANY_SEQ, END_DATE) VALUES (@COUPON_CODE_4, @USER_ID, @COMPANY_SEQ, LEFT(DATEADD(M,2,GETDATE()),10) )

                                            END  
                                    END  

                                /* 프리미어페이퍼 */  
                                IF @COMPANY_SEQ = 5003  
                                    BEGIN  

                                        -- 2022-12-08 쿠폰 변경  
										EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SS', @USER_ID, 'A8E6-3E0F-430B-B89D'  -- [샘플후기작성] 청첩장 2만원 할인쿠폰
										EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SS', @USER_ID, '13A9-6A3D-4770-AF1A'  -- [샘플후기작성] 청첩장 3만원 할인쿠폰
										EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SS', @USER_ID, 'C848-4D7F-405D-8E93'  -- [샘플후기작성] 청첩장 4만원 할인쿠폰
										EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SS', @USER_ID, '0FD0-F786-434B-A6F5'  -- [샘플후기작성] 청첩장 5만원 할인쿠폰

										--EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SS', @USER_ID, '9C8C-D3D6-4CCF-9F67'  /*프페 통합쿠폰도 넣어준다*/

                                    END  

                                /* 바른손카드, 비핸즈카드, 프리미어페이퍼, 바른손몰은 쿠폰 발급 문자를 보낸다. */  
                                IF @COMPANY_SEQ <> 5007  
                                    BEGIN  

                                        SET @SMS_MSG = CASE   
                                            WHEN @COMPANY_SEQ = 5001 THEN '[바른손카드] 샘플이용후기- 할인쿠폰발급. 마이페이지>쿠폰보관함 확인'  
                                            WHEN @COMPANY_SEQ = 5003 THEN '[프리미어페이퍼] 샘플이용후기 감사합니다. 마이페이지>쿠폰보관함 확인'
                                            WHEN @COMPANY_SEQ = 5006 THEN '[비핸즈카드] 샘플이용후기- 할인쿠폰발급. 마이페이지>쿠폰관리 확인'  
                                         ELSE '[바른손몰] 샘플이용후기-최대 3만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인'  
                                                END  


                                        /* 2020-11-23 KT 문자 서비스 작업 변경 */
                                        EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @SMS_MSG, '', @CS_PHONE_NUMBER, 1, @HAND_HPHONE, 0, '', 0, @SITE_TYPE, '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

                                    END  
                            END

                        /* 취소일 경우 */
                        IF @P_STATUS = 2
                            BEGIN
                                /* 쿠폰발급상태를 취소한다. */  
                                UPDATE S4_EVENT_REVIEW_STATUS  
                                SET  ERA_COUPON_STATUS = 0  
                                WHERE ERA_ER_IDX = @P_IDX  

                                /* 더카드, 프리미어페이퍼는 취소일 경우의 로직이 없더라... */ 
                                /* 필요할 경우 취소 로직을 넣으세요... */
                                IF @COMPANY_SEQ NOT IN (5003)
                                    BEGIN
                                        IF @COMPANY_SEQ = 5001 OR @COMPANY_SEQ = 5006 OR @COMPANY_SEQ = 5007  -- 바/비/더 일경우
                                            BEGIN
                                                DECLARE @COUPON_DETAIL_SEQ_1 AS INT  
                                                DECLARE @COUPON_DETAIL_SEQ_2 AS INT  
                                                DECLARE @COUPON_DETAIL_SEQ_3 AS INT  

                                                --쿠폰정보 얻어오기
                                                IF @COMPANY_SEQ = 5007 AND @ER_TYPE = 12
                                                    BEGIN
                                                        --해당쿠폰에대한 DETAIL_SEQ GET (1만원) SNS  
                                                        SELECT @COUPON_DETAIL_SEQ_1 = COUPON_DETAIL_SEQ FROM COUPON_DETAIL  
                                                        WHERE COUPON_CODE = @COUPON_CODE_1  

                                                    END
                                                ELSE
                                                    BEGIN
                                                        --해당쿠폰에대한 DETAIL_SEQ GET  
                                                        SELECT @COUPON_DETAIL_SEQ_3 = COUPON_DETAIL_SEQ FROM COUPON_DETAIL  
                                                        WHERE COUPON_CODE = @COUPON_CODE_1  
                                                
                                                        SELECT @COUPON_DETAIL_SEQ_3 = COUPON_DETAIL_SEQ FROM COUPON_DETAIL  
                                                        WHERE COUPON_CODE = @COUPON_CODE_2
                                                            
                                                        SELECT @COUPON_DETAIL_SEQ_3 = COUPON_DETAIL_SEQ FROM COUPON_DETAIL  
                                                        WHERE COUPON_CODE = @COUPON_CODE_3  

                                                    END

                                                IF @COMPANY_SEQ = 5007 AND @ER_TYPE = 12
                                                    BEGIN
                                                        DELETE FROM COUPON_ISSUE
                                                            WHERE UID = @USER_ID
                                                            AND  COUPON_DETAIL_SEQ IN (@COUPON_DETAIL_SEQ_1)
                                                    END
                                                ELSE IF @COMPANY_SEQ = 5001
                                                    BEGIN
                                                        DELETE   
                                                        FROM    COUPON_ISSUE  
                                                   WHERE   UID = @USER_ID  
                                                        AND     COUPON_DETAIL_SEQ IN ( 

                                                            SELECT  COUPON_DETAIL_SEQ
                                                            FROM    COUPON_DETAIL 
                                                            WHERE   COUPON_CODE IN (
                                                                '7B10-5AF7-43D6-B43A'
                                                            ,   '9693-79AF-4F00-8967'
                                                            ,   '7F2C-DFEB-4A47-8F00'
                                                            ,   '3D8F-C9DD-4B3C-981F'
                                                            )
                                                        )      
                                                        
                                                    END 

                                                ELSE
                                                    BEGIN
                                                        --해당쿠폰에대한 DETAIL_SEQ GET  
                                                        DELETE   
                                                        FROM COUPON_ISSUE  
                                                        WHERE UID = @USER_ID  
                                                        AND  COUPON_DETAIL_SEQ IN (@COUPON_DETAIL_SEQ_1, @COUPON_DETAIL_SEQ_2, @COUPON_DETAIL_SEQ_3)  
                                                    END

                                            END
                                        ELSE -- 바른손몰
                                            BEGIN
                                                /* 발급된 쿠폰을 사용한 쿠폰으로 업데이트 한다. */  
                                                UPDATE S4_MYCOUPON  
                                                SET  ISMYYN = 'N'  
                                                WHERE UID = @USER_ID  
                                                AND  COUPON_CODE IN ( @COUPON_CODE_1, @COUPON_CODE_2, @COUPON_CODE_3, @COUPON_CODE_4 )  

                                            END
                                        
                                        /* SMS 발송 */  
                                        /* 바른손카드, 비핸즈카드, 바른손몰은 쿠폰 취소 문자를 보낸다. */  
                                        /*********************** KT *************/
                                            SET @SMS_MSG = '['+@SITE_NAME+']발급 조건에 맞지않아 쿠폰이 취소되었습니다.'
                                            -- SET @HAND_HPHONE = 'AA^' + @HAND_HPHONE
                                            EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @SMS_MSG, '', @CS_PHONE_NUMBER, 1, @HAND_HPHONE, 0, '', 0, @SITE_TYPE, '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

                                    END

                            END
                END

            set @pos = CHARINDEX('|', @list, @pos+@len) +1
        END

        
    END
    
GO
