IF OBJECT_ID (N'dbo.FN_GET_Days_of_making_cards', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_Days_of_making_cards', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_Days_of_making_cards', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_Days_of_making_cards', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_Days_of_making_cards', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_GET_Days_of_making_cards
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FN_GET_Days_of_making_cards] (
	@order_seq INT
)
RETURNS @TEMP TABLE (
	order_seq int,					-- 주문번호, 일수를 구할 수 없는 주문인 경우 이 값이 0으로 들어갑니다.
	WorkDay int,					-- 작업일수
	holiday int,					-- 기간 내 휴일 일수, 주말은 자동 계산 되고 법정 공휴일 및 단축근무는 holidays 테이블을 기준으로 구합니다.
	confirm_date datetime,			-- 인쇄확정일시 : 결제와 초안컨펌 중 더 나중 일시, 이 날짜를 기준으로 나머지 일수가 계산 됩니다.
	SendDate datetime,				-- 발송예상일
	SendDateWEEKDAY varchar(20),	-- 발송예상일(요일추가)
	Etc varchar(200)				-- 어떤 로직을 거쳤는지 검증하는 로그
)
AS
BEGIN
	-- 0. 변수선언
	DECLARE @ck_order_seq int				-- 존재하는 주문번호인지 확인
	DECLARE @CardKind_Seq VARCHAR(20)		-- 카드 카테고리
	DECLARE @src_confirm_date datetime		-- 컨펌완료시각
	DECLARE @settle_date datetime			-- 결제완료시각
	--DECLARE @order_type int				-- 주문타입 (1:청첩장 2:감사장 3:초대장 4,시즌카드 5:미니청첩장 6:포토/디지탈 7:이니셜 8:포토미니)

	DECLARE @isspecial char(1)				-- 초특급주문

	DECLARE @cardbrand VARCHAR(1)			-- 카드브랜드, 프리미어페이퍼를 구분하기 위해, S 프리미어페이퍼		

	-- 제본 관련 --
	DECLARE @isInpaper int					-- 내지제본
	DECLARE @isHandmade int					-- 부속품제본
	DECLARE @isEnvInsert int				-- 봉투삽입
	DECLARE @isEnvSpecial int				-- 스페셜봉투
	DECLARE @isPerfume int					-- 향기서비스

	DECLARE @SpecialAccYN char(1)			-- 부속제본
	-- 제본 관련 --

	-- 디지털인쇄 관련 --
	DECLARE @isLaser int					-- 서비스옵션 > 레이저컷
	DECLARE @isCustomDColor int				-- 정책옵션 > 커스텀디지털
	DECLARE @isMasterDigital VARCHAR(1)		-- 서비스옵션 > 마디카드(내부)
	-- 디지털인쇄 관련 --

	DECLARE @confirm_date datetime			-- 결제완료시각과 컨펌완료시각을 고려한 실제 인쇄확정일시
	DECLARE @confirm_hour int				-- 인쇄확정_시간
	DECLARE @confirm_min int				-- 인쇄확정_분
	DECLARE @printMethod VARCHAR(50)		-- 인쇄방법(XXX 세자리 캐릭터값이 다음과 같이 주어진다) [G:금박,S:은박,B:먹박,0:박없음][1:유광,0:무광][1:형압,0:압없음]
	DECLARE @WorkDay int					-- 작업 소요 일수

	DECLARE @DebugStr varchar(200)

	-- 1. 주문 정보
	SELECT
		@ck_order_seq = A.order_seq,
		@src_confirm_date = A.src_confirm_date,
		@settle_date = ISNULL(A.settle_date, 0),
		--@order_type = order_type,
		@isspecial = A.isspecial,
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
							card_seq = A.card_seq
						group by
							CardKind_Seq
					) a FOR XML PATH('')
			),
			1,
			1,
			''
		),
		@cardBrand = C1.cardBrand,
		@isMasterDigital = isnull(C3.isMasterDigital,0),

		@isInpaper = A.isInpaper, 
		@isHandmade = A.isHandmade, 
		@isEnvInsert = A.isEnvInsert, 
		@isEnvSpecial = CASE WHEN A.isEnvSpecial = '' THEN 0 ELSE A.isEnvSpecial END,
		@isPerfume = CASE WHEN A.isPerfume = '' THEN 0 ELSE A.isPerfume END,

		@isLaser = C3.isLaser,
		@printMethod = C3.PrintMethod,
		@isCustomDColor = C3.isCustomDColor,
		@SpecialAccYN = C3.SpecialAccYN
	FROM
		CUSTOM_ORDER A
		INNER JOIN S2_Card C1 ON A.card_seq = C1.Card_Seq
		INNER JOIN S2_CardDetail C2 ON C1.Card_Seq = C2.Card_Seq
		INNER JOIN S2_CardOption C3 ON C1.Card_Seq = C3.Card_Seq
		LEFT JOIN DELIVERY_INFO B ON A.order_seq = B.order_seq
	WHERE
		1 = 1
		AND A.order_seq = @order_seq
		AND status_Seq >= 9
		AND src_confirm_date is not null	-- 컨펌완료
		AND 
		(
			(
				settle_status > 0			-- 결제상태 (0:결제이전/ 1:가상계좌입금전/ 2:결제완료/ 3,5:결제취소)
				AND settle_date is not null
			)
			OR 
			(
				pay_Type = 4				-- 사고건
				AND settle_status > 0
			)
		)

	IF @ck_order_seq IS NOT NULL
	BEGIN
		-- 초안등록일 확인
		IF(@src_confirm_date > @settle_date)
		BEGIN
			-- 컨펌완료시각을 인쇄확정일시로 설정
			SET @confirm_date = @src_confirm_date

			SET @DebugStr = '인쇄확정일시 기준 : 컨펌완료시각'
		END
		ELSE
		BEGIN
			-- 결제완료시각을 인쇄확정일시로 설정
			SET @confirm_date = @settle_date

			SET @DebugStr = '인쇄확정일시 기준 : 결제완료시각'
		END

		-- 확정일이 휴일이라면 가장 가까운 평일 오전 9시를 확정일로 변경합니다.
		DECLARE @r_change INT
		SELECT @confirm_date = confirm_date, @r_change = is_change FROM dbo.FN_GET_ConfirmDate_holiday(@confirm_date)

		IF @r_change = 1
		BEGIN
			SET @DebugStr = @DebugStr + ' / 확정일이 휴일이라서 가장 가까운 평일 9시로 변경'
		END
		
		SET @confirm_hour = DATEPART(HOUR, @confirm_date)
		SET @confirm_min = DATEPART(MINUTE, @confirm_date)	

		IF @isspecial IN ('1','2')
		BEGIN
			-- 초특급주문
			IF @confirm_hour < 13 OR (@confirm_hour = 13 AND @confirm_min < 30) -- 13시 30분 이전 else 이후
			BEGIN
				SET @WorkDay = 0

				SET @DebugStr = @DebugStr + ' / 초특급주문 13시 30분 이전 +0'
			END
			ELSE
			BEGIN
				SET @WorkDay = 1

				SET @DebugStr = @DebugStr + ' / 초특급주문 13시 30분 이후 +1'
			END

			IF @isInpaper > 0 OR @isHandmade > 0 OR @isEnvInsert > 0 OR @isPerfume > 0
			BEGIN
				-- 제본이 추가된 경우
				SET @WorkDay = @WorkDay + 1

				SET @DebugStr = @DebugStr + ' / 제본추가 +1'
			END
		END
		ELSE IF (CHARINDEX('1', @CardKind_Seq) > 0 AND CHARINDEX('14', @CardKind_Seq) > 0) AND	-- 카드 카테고리가 청첩장이면서 커스텀 디지탈인 경우
			@isCustomDColor > 0																-- 정책옵션 > 커스텀디지털인쇄 체크		
		BEGIN
			-- 디지털인쇄
			SET @DebugStr = @DebugStr + ' / 디지털인쇄'

			IF @confirm_hour < 15
			BEGIN
				SET @WorkDay = 4

				SET @DebugStr = @DebugStr + ' / 15시 이전 +4'
			END
			ELSE
			BEGIN
				SET @WorkDay = 5

				SET @DebugStr = @DebugStr + ' / 15시 이후 +5'
			END

			IF @SpecialAccYN = 'Y'
			BEGIN
				-- 특수부속 (메탈, 큐빅, 진주)
				SET @WorkDay = @WorkDay + 1
				SET @DebugStr = @DebugStr + ' / 특수부속(메탈, 큐빅, 진주) 추가 +1'
			END
		END
		ELSE IF @isLaser > 0 OR LEFT(@printMethod, 1) <> '0' OR RIGHT(@printMethod, 1) <> '0' -- 레이저컷, 형압, 박 확인
		BEGIN
			-- 마스터+커스텀
			SET @DebugStr = @DebugStr + ' / 마스터+커스텀'

			-- 프리미어페이퍼는 기준 시각이 다름
			IF @cardbrand = 'S'
			BEGIN
				SET @DebugStr = @DebugStr + ' / 프리미어페이퍼'

				IF @confirm_hour < 13 OR (@confirm_hour = 13 AND @confirm_min < 30) -- 13시 30분 이전 else 이후
				BEGIN
					SET @WorkDay = 4

					SET @DebugStr = @DebugStr + ' / 13시 30분 이전 +4'
				END
				ELSE
				BEGIN
					SET @WorkDay = 5

					SET @DebugStr = @DebugStr + ' / 13시 30분 이후 +5'
				END

				/*
				-- 프리미어페이퍼 부속제본 +1
				IF @isHandmade > 0 OR @isPerfume > 0
				BEGIN
					SET @WorkDay = @WorkDay + 1

					SET @DebugStr = @DebugStr + ' / 프리미어페이퍼 부속제본 +1'
				END
				*/

				IF @SpecialAccYN = 'Y'
				BEGIN
					-- 특수부속 (메탈, 큐빅, 진주)
					SET @WorkDay = @WorkDay + 1
					SET @DebugStr = @DebugStr + ' / 특수부속(메탈, 큐빅, 진주) 추가 +1'
				END
			END				
			ELSE
			BEGIN
				IF @confirm_hour < 15
				BEGIN
					SET @WorkDay = 4

					SET @DebugStr = @DebugStr + ' / 15시 이전 +4'
				END
				ELSE
				BEGIN
					SET @WorkDay = 5

					SET @DebugStr = @DebugStr + ' / 15시 이후 +5'
				END
			END			
		END
		ELSE
		BEGIN
			-- 마스터기본
			SET @DebugStr = @DebugStr + ' / 마스터기본'

			IF @cardbrand = 'S'		-- 브랜드가 프리미어페이퍼 라면
			BEGIN
				SET @DebugStr = @DebugStr + ' / 프리미어페이퍼'

				IF @confirm_hour < 13 OR (@confirm_hour = 13 AND @confirm_min < 30) -- 13시 30분 이전 else 이후
				BEGIN
					SET @WorkDay = 3

					SET @DebugStr = @DebugStr + ' / 13시 30분 이전 +3'
				END
				ELSE
				BEGIN
					SET @WorkDay = 4

					SET @DebugStr = @DebugStr + ' / 13시 30분 이후 +4'
				END
			END
			ELSE IF (@cardbrand = 'D' OR @cardbrand = 'X') AND @SpecialAccYN = 'Y'  -- 브랜드가 디얼디어이면서 마스터 + 메탈, 큐빅, 진주 특수제본이 들어가는 카드라면
			BEGIN
				SET @DebugStr = @DebugStr + ' / 디얼디어 (마스터 + 메탈, 큐빅, 진주)'

				IF @confirm_hour < 15
				BEGIN
					SET @WorkDay = 4

					SET @DebugStr = @DebugStr + ' / 15시 이전 +4'
				END
				ELSE
				BEGIN
					SET @WorkDay = 5

					SET @DebugStr = @DebugStr + ' / 15시 이후 +5'
				END
			END
			ELSE
			BEGIN
				IF @confirm_hour < 15
				BEGIN
					SET @WorkDay = 2

					SET @DebugStr = @DebugStr + ' / 15시 이전 +2'
				END
				ELSE
				BEGIN
					SET @WorkDay = 3

					SET @DebugStr = @DebugStr + ' / 15시 이후 +3'
				END
			END

			IF (@cardbrand = 'D' OR @cardbrand = 'X') AND @SpecialAccYN = 'Y'  -- 브랜드가 디얼디어이면서 마스터 + 메탈, 큐빅, 진주 특수제본이 들어가는 카드라면
			BEGIN
				-- 무료포함 부속품제본을 제외하고 제본추가를 계산합니다.
				IF @isInpaper > 0 OR @isEnvInsert > 0 OR @isPerfume > 0
				BEGIN
					-- 제본이 추가된 경우
					SET @WorkDay = @WorkDay + 1

					SET @DebugStr = @DebugStr + ' / 제본 추가 +1'
					SET @DebugStr = @DebugStr + ' / ' + dbo.fn_get_jebon(@order_seq)	
				END
			END
			ELSE IF @isInpaper > 0 OR @isHandmade > 0 OR @isEnvInsert > 0 OR @isPerfume > 0
			BEGIN
				-- 제본이 추가된 경우
				SET @WorkDay = @WorkDay + 1

				SET @DebugStr = @DebugStr + ' / 제본 추가 +1'
				SET @DebugStr = @DebugStr + ' / ' + dbo.fn_get_jebon(@order_seq)
			END

			IF @cardbrand = 'S'		-- 브랜드가 프리미어페이퍼 라면
			BEGIN
				IF @SpecialAccYN = 'Y'
				BEGIN
					-- 특수부속 (메탈, 큐빅, 진주)
					SET @WorkDay = @WorkDay + 1
					SET @DebugStr = @DebugStr + ' / 특수부속(메탈, 큐빅, 진주) 추가 +1'
				END
			END
		END

		--기간내휴일
		DECLARE @holiday VARCHAR(10) = dbo.fn_IsWorkDay_(CONVERT(varchar(10), @confirm_date, 120), @WorkDay + 1)

		INSERT INTO @TEMP (order_Seq, confirm_date, WorkDay, holiday, SendDate, Etc) VALUES 
		(@order_seq, @confirm_date, @WorkDay, @holiday, dbo.fn_IsWorkDay(CONVERT(varchar(10), @confirm_date, 120), @WorkDay + 1), @DebugStr)

		-- 발송예정일에 요일 추가
		UPDATE
			@TEMP
		SET
			SendDateWEEKDAY = ISNULL(
				CONVERT(CHAR(10), SendDate, 23) + CASE
					WHEN(DATEPART(WEEKDAY, SendDate) = 1) THEN '(일)'
					WHEN(DATEPART(WEEKDAY, SendDate) = 2) THEN '(월)'
					WHEN(DATEPART(WEEKDAY, SendDate) = 3) THEN '(화)'
					WHEN(DATEPART(WEEKDAY, SendDate) = 4) THEN '(수)'
					WHEN(DATEPART(WEEKDAY, SendDate) = 5) THEN '(목)'
					WHEN(DATEPART(WEEKDAY, SendDate) = 6) THEN '(금)'
					WHEN(DATEPART(WEEKDAY, SendDate) = 7) THEN '(토)'
				END,
				''
			)
	END
	ELSE
	BEGIN
		INSERT INTO @TEMP (order_Seq) VALUES (0)
	END

	RETURN
END

GO