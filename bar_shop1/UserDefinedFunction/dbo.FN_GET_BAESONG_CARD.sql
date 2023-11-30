IF OBJECT_ID (N'dbo.FN_GET_BAESONG_CARD', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_BAESONG_CARD', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_BAESONG_CARD', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_BAESONG_CARD', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_BAESONG_CARD', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_GET_BAESONG_CARD
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
-- Description: 카드제작 예상 작업일수 반환
-- =============================================
*/
CREATE FUNCTION [dbo].[FN_GET_BAESONG_CARD](
	@card_seq		int,			-- 카드번호
	@confirm_date 	datetime		-- 컨펌일시	
)
RETURNS @TEMP TABLE (
	WorkDay int,			-- 작업일수
	Etc varchar(200)		-- 어떤 로직을 거쳤는지 검증하는 로그
)
AS
BEGIN
	DECLARE @CardKind_Seq VARCHAR(20) 		-- 카드 카테고리

	DECLARE @cardbrand VARCHAR(1)			-- 카드브랜드, 프리미어페이퍼를 구분하기 위해, S 프리미어페이퍼

	-- 제본 관련 --
	DECLARE @isInpaper char(1)				-- 내지제본
	DECLARE @isHandmade char(1)				-- 부속품제본
	DECLARE @isEnvInsert char(1)			-- 봉투삽입
	DECLARE @isEnvSpecial char(1)			-- 스페셜봉투

	DECLARE @SpecialAccYN char(1)			-- 부속제본
	-- 제본 관련 --

	-- 디지털인쇄 관련 --
	DECLARE @isLaser int					-- 서비스옵션 > 레이저컷
	DECLARE @isCustomDColor int				-- 정책옵션 > 커스텀디지털
	-- 디지털인쇄 관련 --

	DECLARE @printMethod VARCHAR(50)		-- 인쇄방법(XXX 세자리 캐릭터값이 다음과 같이 주어진다) [G:금박,S:은박,B:먹박,0:박없음][1:유광,0:무광][1:형압,0:압없음]
	DECLARE @WorkDay int					-- 카드 작업 소요 일수
	DECLARE @WorkDay_Reason varchar(200)	-- 카드 작업 소요 일수 이유

	DECLARE @confirm_hour int				-- 인쇄확정_시간
	DECLARE @confirm_min int				-- 인쇄확정_분

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
		@isLaser = C3.isLaser,
		@printMethod = C3.PrintMethod,
		@isCustomDColor = C3.isCustomDColor,
		@cardBrand = C1.cardBrand,
		@isHandmade = C3.IsHandmade,
		@isInpaper = C3.IsInPaper,
		@isEnvInsert = C3.isEnvInsert,
		@isEnvSpecial = C3.isEnvSpecial,
		@SpecialAccYN = C3.SpecialAccYN
	FROM
		S2_Card C1
		INNER JOIN S2_CardDetail C2 ON C1.Card_Seq = C2.Card_Seq
		INNER JOIN S2_CardOption C3 ON C1.Card_Seq = C3.Card_Seq
	WHERE
		C1.Card_Seq = @card_seq

	SET @confirm_hour = DATEPART(HOUR, @confirm_date)
	SET @confirm_min = DATEPART(MINUTE, @confirm_date)

	-- 카드작업 소요일수 계산
	IF (CHARINDEX('1', @CardKind_Seq) > 0 AND CHARINDEX('14', @CardKind_Seq) > 0) AND	-- 카드 카테고리가 청첩장이면서 커스텀 디지탈인 경우
		@isCustomDColor > 0																-- 정책옵션 > 커스텀디지털인쇄 체크		
	BEGIN
		-- 디지털인쇄
		SET @WorkDay_Reason = '디지털인쇄'

		IF @confirm_hour < 15
		BEGIN
			SET @WorkDay = 4
		END
		ELSE
		BEGIN
			SET @WorkDay = 5
		END

		-- 특수부속 (메탈, 큐빅, 진주) +1
		IF @SpecialAccYN = 'Y'
		BEGIN
			SET @WorkDay_Reason = @WorkDay_Reason + ' / 특수부속 (메탈, 큐빅, 진주)'

			SET @WorkDay = @WorkDay + 1
		END
	END
	ELSE IF @isLaser > 0 OR LEFT(@printMethod, 1) <> '0' OR RIGHT(@printMethod, 1) <> '0' -- 레이저컷, 형압, 박 확인
	BEGIN
		-- 마스터+커스텀
		-- 프리미어페이퍼는 기준 시각이 다름
		SET @WorkDay_Reason = '마스터+커스텀'

		IF @cardbrand = 'S'
		BEGIN
			IF @confirm_hour < 13 OR (@confirm_hour = 13 AND @confirm_min < 30) -- 13시 30분 이전 else 이후
			BEGIN
				SET @WorkDay = 4
			END
			ELSE
			BEGIN
				SET @WorkDay = 5
			END

			-- 특수부속 (메탈, 큐빅, 진주) +1
			IF @SpecialAccYN = 'Y'
			BEGIN
				SET @WorkDay_Reason = @WorkDay_Reason + ' / 특수부속 (메탈, 큐빅, 진주)'

				SET @WorkDay = @WorkDay + 1
			END
		END				
		ELSE
		BEGIN
			IF @confirm_hour < 15
			BEGIN
				SET @WorkDay = 4
			END
			ELSE
			BEGIN
				SET @WorkDay = 5
			END
		END			
	END
	ELSE
	BEGIN
		-- 마스터기본
		SET @WorkDay_Reason = '마스터'

		IF @cardbrand = 'S'		-- 브랜드가 프리미어페이퍼 라면
		BEGIN			
			SET @WorkDay_Reason = @WorkDay_Reason + ' / 프리미어페이퍼'

			IF @confirm_hour < 13 OR (@confirm_hour = 13 AND @confirm_min < 30) -- 13시 30분 이전 else 이후
			BEGIN
				SET @WorkDay = 3
			END
			ELSE
			BEGIN
				SET @WorkDay = 4
			END
		END
		ELSE IF (@cardbrand = 'D' OR @cardbrand = 'X') AND @SpecialAccYN = 'Y'  -- 브랜드가 디얼디어이면서 마스터 + 메탈, 큐빅, 진주 특수제본이 들어가는 카드라면
		BEGIN
			SET @WorkDay_Reason = @WorkDay_Reason + ' / 디얼디어 (마스터 + 메탈, 큐빅, 진주)'

			IF @confirm_hour < 15
			BEGIN
				SET @WorkDay = 4
			END
			ELSE
			BEGIN
				SET @WorkDay = 5
			END
		END
		ELSE
		BEGIN
			IF @confirm_hour < 15
			BEGIN
				SET @WorkDay = 2
			END
			ELSE
			BEGIN
				SET @WorkDay = 3
			END
		END

		IF (@cardbrand = 'D' OR @cardbrand = 'X') AND @SpecialAccYN = 'Y'  -- 브랜드가 디얼디어이면서 마스터 + 메탈, 큐빅, 진주 특수제본이 들어가는 카드라면
		BEGIN
			-- 무료포함 부속품제본을 제외하고 제본추가를 계산합니다.
			IF @isInpaper = '2' OR @isEnvInsert = '2' OR @isEnvSpecial = '2'
			BEGIN
				-- 제본이 추가된 경우
				SET @WorkDay_Reason = @WorkDay_Reason + ' / 제본추가'

				SET @WorkDay = @WorkDay + 1
			END
		END
		ELSE IF @isInpaper = '2' OR @isHandmade = '2' OR @isEnvInsert = '2' OR @isEnvSpecial = '2'
		BEGIN
			-- 제본이 추가된 경우
			SET @WorkDay_Reason = @WorkDay_Reason + ' / 제본추가'

			SET @WorkDay = @WorkDay + 1
		END

		IF @cardbrand = 'S'		-- 브랜드가 프리미어페이퍼 라면
		BEGIN
			IF @SpecialAccYN = 'Y'
			BEGIN
				-- 특수부속 (메탈, 큐빅, 진주)
				SET @WorkDay = @WorkDay + 1
				SET @WorkDay_Reason = @WorkDay_Reason + ' / 특수부속(메탈, 큐빅, 진주)'
			END
		END
	END

	-- 결과 반환	
	INSERT INTO @TEMP (WorkDay, Etc) VALUES (@WorkDay, @WorkDay_Reason)

	RETURN
END
GO