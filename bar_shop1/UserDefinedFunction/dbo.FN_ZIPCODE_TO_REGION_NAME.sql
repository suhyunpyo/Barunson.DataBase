IF OBJECT_ID (N'dbo.FN_ZIPCODE_TO_REGION_NAME', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_ZIPCODE_TO_REGION_NAME', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_ZIPCODE_TO_REGION_NAME', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_ZIPCODE_TO_REGION_NAME', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_ZIPCODE_TO_REGION_NAME', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_ZIPCODE_TO_REGION_NAME
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[FN_ZIPCODE_TO_REGION_NAME] (@ZIP_CODE VARCHAR(10))
RETURNS VARCHAR(8000)
AS
BEGIN 

DECLARE  @RESULT_VALUE VARCHAR(5000) = ''
DECLARE @TEMP_ZIP_CODE AS VARCHAR(10) = ''
DECLARE @TEMP_ZIP_CODE_LEFT_2 AS VARCHAR(2) = ''
DECLARE @TEMP_ZIP_CODE_LENGTH AS INT



SET @TEMP_ZIP_CODE = [dbo].[FN_CR_LF_TAB_SPACE_REMOVE](@ZIP_CODE, 'Y', 'Y')
SET @TEMP_ZIP_CODE_LEFT_2 = LEFT(@TEMP_ZIP_CODE, 2)
SET @TEMP_ZIP_CODE_LENGTH = LEN(@TEMP_ZIP_CODE)



/* 구 우편번호 6자리 */
IF @TEMP_ZIP_CODE_LENGTH > 5
BEGIN
    
    SET     @RESULT_VALUE = 
    
            CASE 
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '10', '11', '12', '13', '14', '15' )
                    THEN '서울'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '20', '21', '22', '23', '24', '25', '26' )
                    THEN '강원'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '30' )
                    THEN '대전'
                    WHEN LEFT(@TEMP_ZIP_CODE, 3) IN ( '339' )
                    THEN '세종'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '31', '32', '33', '34', '35' )
                    THEN '충남'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '36', '37', '38', '39' )
                    THEN '충북'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '40' )
                    THEN '인천'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '41', '42', '43', '44', '45', '46', '47', '48' )
                    THEN '경기'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '50' )
                    THEN '광주'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '51', '52', '53', '54', '55' )
                    THEN '전남'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '56', '57', '58', '59' )
                    THEN '전북'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '60', '61' )
                    THEN '부산'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '62', '63', '64', '65', '66', '67' )
                    THEN '경남'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '68' )
                    THEN '울산'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '69' )
                    THEN '제주'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '70' )
                    THEN '대구'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '71', '72', '73', '74', '75', '76', '77', '78', '79' )
                    THEN '경북'
                    ELSE ''
            END

END

/* 신 우편번호 5자리 */
ELSE IF @TEMP_ZIP_CODE_LENGTH = 5
BEGIN
    
    SET     @RESULT_VALUE = 

            CASE 
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '01', '02', '03', '04', '05', '06', '07', '08', '09' )
                    THEN '서울'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20' )
                    THEN '경기'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '21', '22', '23' )
                    THEN '인천'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '24', '25', '26' )
                    THEN '강원'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '27', '28', '29' )
                    THEN '충북'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '30' )
                    THEN '세종'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '31', '32', '33' )
                    THEN '충남'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '34', '35' )
                    THEN '대전'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '36', '37', '38', '39', '40' )
                    THEN '경북'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '41', '42', '43' )
                    THEN '대구'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '44', '45' )
                    THEN '울산'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '46', '47', '48', '49' )
                    THEN '부산'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '50', '51', '52', '53' )
                    THEN '경남'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '54', '55', '56' )
                    THEN '전북'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '57', '58', '59', '60' )
                    THEN '전남'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '61', '62' )
                    THEN '광주'
                    WHEN @TEMP_ZIP_CODE_LEFT_2 IN ( '63' )
                    THEN '제주'
                    ELSE ''
            END

END



RETURN @RESULT_VALUE



END
GO
