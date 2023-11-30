IF OBJECT_ID (N'dbo.sp_hyundai_daily_list', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_hyundai_daily_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*----------------------------------------------------------------------------------------------
1.STORED PROCEDURE	: [SP_HYUNDAI_DAILY_LIST]
2.관련 TABLE		: HYUNDAI_DAILY_INFO

EXEC [DBO].[SP_HYUNDAI_DAILY_LIST]  '20220331'
-----------------------------------------------------------------------------------------------*/

CREATE PROCEDURE [dbo].[sp_hyundai_daily_list]

@TODAY VARCHAR(15), 
@TYPE  VARCHAR(1) 
AS
SET NOCOUNT ON
DECLARE @SQL NVARCHAR(2000)

	IF @TYPE = '1' BEGIN --CI값, 성명, 생년월일, 성별, 핸드폰번호, 주소, 이메일주소, 예식일, 동의일시, 동의 사이트
	
		------ 기본정보리스트 ------
		SELECT	CONNINFO, 
				UNAME, 
				BIRTH_DATE, 
				(CASE WHEN GENDER = '0' THEN '여' ELSE '남' END ) GENDER, 
				HAND_PHONE, 	
				ZIPCODE, 
				ADDRESS, 
				ADDR_DETAIL,
				UMAIL,
				WEDDING_DAY, 
				CONVERT(VARCHAR(10),BARUN_REG_DATE,112) AS BARUN_REG_DATE, 
				CONVERT(VARCHAR(10),HYUNDAIMEMBERSHIP_REG_DATE,112) AS HYUNDAIMEMBERSHIP_REG_DATE,
				BARUN_REG_SITE = '바른손몰'
		FROM HYUNDAI_DAILY_INFO 
		WHERE CONVERT(VARCHAR(10),CREATE_DATE,112)=	@TODAY	
		
	END	 ELSE BEGIN 

		SELECT CANCEL_DT, HAND_PHONE, UNAME 
		FROM HYUNDAI_DAILY_INFO_CANCEL
		WHERE CONVERT(VARCHAR(10),CREATE_DATE,112)=	@TODAY	


	END 

GO
