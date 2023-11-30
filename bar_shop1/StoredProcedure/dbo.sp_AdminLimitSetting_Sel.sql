USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[sp_AdminLimitSetting_Sel]    Script Date: 2023-06-01 오후 5:42:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : sp_AdminLimitSetting_Sel
-- Author        : 임승인
-- Create date   : 2022-10-14
-- Description   : 관리자 발송일제한관리
-- Update History: 
-- Comment       : 관리자 발송일제한관리 리스트
****************************************************************************************************************/

	ALTER PROCEDURE [dbo].[sp_AdminLimitSetting_Sel]
		@type   VARCHAR(10)		
	AS

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SET LOCK_TIMEOUT 60000
	
	IF @TYPE = 'Order'
	BEGIN
		SELECT 
			TYPE,
			CASE TYPE WHEN 'O' THEN '초안등록 관리' WHEN 'B' THEN '배송 관리' END TypeNm,
			CONVERT(VARCHAR(10),START_DATE,120) 'StartDate',
			CONVERT(VARCHAR(2),DATEPART(HOUR,START_DATE)) 'StartHour',
			CONVERT(VARCHAR(2),DATEPART(MINUTE,START_DATE)) 'StartMinute',
			CONVERT(VARCHAR(10),END_DATE,120) 'EndDate',
			CONVERT(VARCHAR(2),DATEPART(HOUR,END_DATE)) 'EndHour',
			CONVERT(VARCHAR(2),DATEPART(MINUTE,END_DATE)) 'EndMinute',
			USE_YN 'UseYn'
		FROM ADMIN_LIMIT_SETTING 
		WHERE TYPE IN ('O','B')
	END
	ELSE IF @type = 'Special'
	BEGIN
		SELECT 
			TYPE,
			'초특급 버튼' as TypeNm,
			CONVERT(VARCHAR(10),START_DATE,120) 'StartDate',
			CONVERT(VARCHAR(2),DATEPART(HOUR,START_DATE)) 'StartHour',
			CONVERT(VARCHAR(2),DATEPART(MINUTE,START_DATE)) 'StartMinute',
			CONVERT(VARCHAR(10),END_DATE,120) 'EndDate',
			CONVERT(VARCHAR(2),DATEPART(HOUR,END_DATE)) 'EndHour',
			CONVERT(VARCHAR(2),DATEPART(MINUTE,END_DATE)) 'EndMinute',
			USE_YN 'UseYn'
		FROM ADMIN_LIMIT_SETTING 
		WHERE TYPE = 'S'
	END
	ELSE
	BEGIN
		SELECT 
			TYPE,
			CASE TYPE WHEN 'C' THEN '초안완료' WHEN 'D' THEN '발송완료' WHEN 'P' THEN '샘플발송완료' END TypeNm,
			CONVERT(VARCHAR(10),START_DATE,120) 'StartDate',
			CONVERT(VARCHAR(2),DATEPART(HOUR,START_DATE)) 'StartHour',
			CONVERT(VARCHAR(2),DATEPART(MINUTE,START_DATE)) 'StartMinute',
			CONVERT(VARCHAR(10),END_DATE,120) 'EndDate',
			CONVERT(VARCHAR(2),DATEPART(HOUR,END_DATE)) 'EndHour',
			CONVERT(VARCHAR(2),DATEPART(MINUTE,END_DATE)) 'EndMinute',
			USE_YN 'UseYn'
		FROM ADMIN_LIMIT_SETTING 
		WHERE TYPE IN ('C','D','P')

	END
