IF OBJECT_ID (N'dbo.FN_GET_BAESONG_CHOAN', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_BAESONG_CHOAN', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_BAESONG_CHOAN', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_BAESONG_CHOAN', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_BAESONG_CHOAN', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_GET_BAESONG_CHOAN
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-- =============================================  
-- Author: 개발팀 김은석
-- Create date: 2023-05-24
-- Description: 카드별 초안 예상 작업일수 반환
-- =============================================
*/
CREATE FUNCTION [dbo].[FN_GET_BAESONG_CHOAN](
	@card_seq		int,			-- 카드번호
	@confirm_date 	datetime		-- 컨펌일시
)
RETURNS INT
AS
BEGIN
	DECLARE @CardKind_Seq VARCHAR(20) -- 카드 카테고리

	-- 디지털인쇄 관련 --
	DECLARE @isCustomDColor int				-- 정책옵션 > 커스텀디지털
	-- 디지털인쇄 관련 --

	DECLARE @confirm_hour int				-- 인쇄확정_시간
	DECLARE @WorkDay_choan int				-- 초안 작업 소요 일수

	-- 카드정보
	SELECT
		@CardKind_Seq = STUFF(
			(
				SELECT
					',' + CONVERT(VARCHAR(2), CardKind_Seq)
				FROM
					(
						SELECT
							CardKind_Seq
						from
							s2_cardkind
						where
							card_seq = C1.card_seq
						group by
							CardKind_Seq
					) a FOR XML PATH('')
			),
			1,
			1,
			''
		),
		@isCustomDColor = C3.isCustomDColor
	FROM
		S2_Card C1
		INNER JOIN S2_CardDetail C2 ON C1.Card_Seq = C2.Card_Seq
		INNER JOIN S2_CardOption C3 ON C1.Card_Seq = C3.Card_Seq
	WHERE
		C1.Card_Seq = @card_seq
	
	SET @confirm_hour = DATEPART(HOUR, @confirm_date)

	-- 초안 작업 소요일수 계산
	IF @confirm_hour < 13
	BEGIN
		SET @WorkDay_choan = 0
	END
	ELSE
	BEGIN
		SET @WorkDay_choan = 1
	END

	IF (CHARINDEX('1', @CardKind_Seq) > 0 AND CHARINDEX('14', @CardKind_Seq) > 0) AND	-- 카드 카테고리가 청첩장이면서 커스텀 디지탈인 경우
		@isCustomDColor > 0																-- 정책옵션 > 커스텀디지털인쇄 체크
	BEGIN
		-- 디지털인쇄인 경우 초안 +1일
		SET @WorkDay_choan = @WorkDay_choan + 1
	END

	-- 결과 반환	
	RETURN @WorkDay_choan
END
GO