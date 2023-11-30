IF OBJECT_ID (N'dbo.up_select_expected_deliverydate_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_expected_deliverydate_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

exec up_select_expected_deliverydate_new 3108498  

*/

CREATE PROC [dbo].[up_select_expected_deliverydate_new]    
	@order_seq INT
AS        
BEGIN     

	DECLARE @card_seq int
	DECLARE @company_seq int
	DECLARE @sch_tm int
	DECLARE @sch_dt varchar(10)
	DECLARE @src_confirm_date datetime
	DECLARE @settle_date datetime
	DECLARE @returns varchar(100)
	DECLARE @order_type int
	DECLARE @order_type_name varchar(100)
	DECLARE @confirm_date datetime
	DECLARE @taesan_flag int
	DECLARE @delivery_date datetime
	DECLARE @src_print_date datetime
	DECLARE @isspecial char(1)
	DECLARE @add_day int
	DECLARE @jebon_day int = 0
	DECLARE @env_day int = 0
	DECLARE @ENVPREMIUM_PRICE int
	DECLARE @env_txt varchar(50) = ''
	DECLARE @jebon_txt varchar(50) = ''

	--1.주문기본정보
	SELECT @card_seq = card_seq, @src_confirm_date = src_confirm_date, @company_seq = company_seq, @settle_date = ISNULL(settle_date,0) 
	, @order_type = order_type, @order_type_name = (select code_value from manage_code where code_type ='worder_type' and code = order_type)
	, @delivery_date = B.DELIVERY_DATE
	, @src_print_date = src_print_date, @isspecial = isspecial,@ENVPREMIUM_PRICE = EnvPremium_price
	FROM CUSTOM_ORDER A
	LEFT JOIN DELIVERY_INFO B ON A.order_seq = B.order_seq
	WHERE 1=1
	AND A.order_seq = @order_seq
	AND status_Seq >= 9 AND src_confirm_date is not null --컨펌완료
	AND ((settle_status > 0 AND settle_date is not null)  OR (pay_Type =4 AND settle_status > 0))

	--제본정보
    DECLARE @jebon VARCHAR(100)= [dbo].[fn_get_jebon](@order_seq)



	--2.인쇄소(태산)여부 확인
	IF EXISTS 
	( 
		SELECT DISTINCT order_seq 
		FROM custom_order_plist CP 
		JOIN S2_Card CD ON CP.card_seq = CD.Card_Seq 
		JOIN CARD_COREL CC ON CD.Card_Code = CC.Card_Code AND ISNULL(CC.WEPOD_YORN, 'N') = 'Y'
		WHERE CP.print_type IN ( 'P' , 'I' )
		AND order_Seq = @order_seq  
	)
	BEGIN
		SET @taesan_flag = 1
	END
	ELSE
	BEGIN
		SET @taesan_flag = 0
	END

	--3.카드정보확인
	IF @card_seq IS NOT NULL 
	BEGIN
		DECLARE @CardKind_Seq VARCHAR(20) -- 카드 카테고리    
		DECLARE @CardKind VARCHAR(10) -- 카드 구분   
		DECLARE @CardCode VARCHAR(10)
    
		DECLARE @printMethod VARCHAR(3) 
		DECLARE @isLaser VARCHAR(1)     
		DECLARE @isLetterPress VARCHAR(1)    
		DECLARE @isMasterDigital VARCHAR(1)     
		DECLARE @isMaster2Color VARCHAR(1) 
		DECLARE @cardbrand VARCHAR(1) 
		
		DECLARE @isCustomDColor VARCHAR(1)      
		DECLARE @isInternalDigital VARCHAR(1)
		DECLARE @WEPOD_YORN VARCHAR(1)
		DECLARE @TAESAN_YN VARCHAR(2)
    
		DECLARE @std_txt VARCHAR(100)
		DECLARE @std_day int
		-- ====================================================================================   
		-- 카드 카테고리 / 청첩장 : 1 / 커스텀 디지탈 : 14
		-- ====================================================================================    
		SELECT @CardKind_Seq = STUFF((     
		SELECT ',' + CONVERT(VARCHAR(2), CardKind_Seq)     
		FROM (SELECT CardKind_Seq from s2_cardkind where card_seq = @card_seq group by CardKind_Seq ) a     
		FOR XML PATH('')     
		), 1, 1, '')   

		-- 카드 상세    
		SELECT @printMethod =   C.printMethod  
		, @isLaser =   ISNULL(C.isLaser, 0)       
		, @cardBrand = cardBrand    
		, @isLetterPress = isnull(C.isLetterPress,0)     
		, @isMasterDigital = isnull(C.isMasterDigital,0)   
		, @isMaster2Color = isnull(c.Master_2Color, 0)  
		, @isCustomDColor =   isnull(isCustomDColor,0)       
		, @isInternalDigital =   isnull(isInternalDigital,0)       
		, @WEPOD_YORN =   D.WEPOD_YORN
		, @CardCode = A.Card_Code
		FROM S2_Card A 
		INNER JOIN S2_CardDetail B ON A.card_Seq = B.card_seq 
		INNER JOIN S2_Cardoption C ON A.card_Seq = C.card_seq 
		INNER JOIN Card_Corel AS D ON A.Card_Code = D.Card_Code 
		WHERE A.CARD_SEQ= @card_seq   

		-- ====================================================================================   
		-- 인쇄확정시간설정 : 컨펌완료시간,결제완료시간 중에서 가장 마지막에 일어난 시간 선정
		-- ====================================================================================    
		IF(@src_confirm_date > @settle_date)
		BEGIN
			--컨펌완료시간을 인쇄확정시간으로 설정
			SET @confirm_date = @src_confirm_date
			SET @sch_dt = CONVERT(CHAR(10),[dbo].[fn_PrintDate](@src_confirm_date,@cardbrand),121)
			SET @sch_tm = (DATEPART("hh",@src_confirm_date) * 60 ) +  DATEPART("mi",@src_confirm_date)

		END
		ELSE
		BEGIN
			--결제완료시간을 인쇄확정시간으로 설정
			SET @confirm_date = @settle_date
			SET @sch_dt = CONVERT(CHAR(10),[dbo].[fn_PrintDate](@settle_date,@cardbrand),121)
			SET @sch_tm = (DATEPART("hh",@settle_date) * 60 ) +  DATEPART("mi",@settle_date)
		END
		-- ====================================================================================   

  
		-- ====================================================================================   
		-- 카드제작기간에 따른 발송일 계산
		-- ====================================================================================   
		IF CHARINDEX('1', @CardKind_Seq) > 0 AND CHARINDEX('14', @CardKind_Seq) > 0   --카드 카테고리가 청첩장이면서 커스텀 디지탈인 경우
		OR  @isMasterDigital = '1'  --마디카드(내부)
		BEGIN  
			-- 디지털
			IF(@order_type = '6' AND @isInternalDigital <> '1' AND @isCustomDColor = '1' AND @WEPOD_YORN = 'Y') OR @taesan_flag > 0
			BEGIN
				--태산
				SET @std_txt = '아웃소싱(태산)'
				IF @printMethod <> '000' Or @isLaser IN ('1','2')
				BEGIN
					IF @isLaser IN ('1','2')
						SET @std_txt = @std_txt + '/레이저컷'
					IF @printMethod <> '000' 
						SET @std_txt = @std_txt + '/' + dbo.fn_get_printmethod(@printMethod)

					SET @std_day = 3

					--제본추가시
					IF @jebon <> ''
						SET @jebon_txt = ' (제본 추가시 일정 추가 없음)'
				END
				ELSE    
				BEGIN
					SET @std_txt = @std_txt + '/기본(디지털만인쇄)'
					SET @std_day = 2

					--제본추가시
					IF @jebon <> ''
						SET @jebon_day = 1
				END
			END
			ELSE
			BEGIN
				--디지털인쇄
				SET @std_txt = '디지털인쇄(내부)'

				IF @isLaser IN ('1','2')
						SET @std_txt = @std_txt + '/레이저컷'
					IF @printMethod <> '000' 
						SET @std_txt = @std_txt + '/' + dbo.fn_get_printmethod(@printMethod)

				SET @std_day = 3

				--제본추가시
				IF @jebon <> ''
					SET @jebon_txt = ' (제본 추가시 일정 추가 없음)'
			END
		END   
		ELSE    
		BEGIN 
			IF @isMaster2Color = 1  
			BEGIN  
				SET @std_txt = '마스터 2도'
				SET @std_day = 2
				--제본추가시
				IF @jebon <> ''
					SET @jebon_day = 1
			END  
			ELSE
			BEGIN
				-- 마스터 인쇄
				IF @printMethod <> '000' Or @isLaser IN ('1','2')
				BEGIN
					SET @std_txt = '마스터+커스텀'
					SET @std_day = 3

					IF @isLaser IN ('1','2')
						SET @std_txt = @std_txt + '/레이저컷'
					IF @printMethod <> '000' 
						SET @std_txt = @std_txt + '/' + dbo.fn_get_printmethod(@printMethod)

					IF UPPER(@cardBrand) = 'S'  AND @card_seq IN (SELECT card_Seq FROM S2_CardOption WHERE SpecialAccYN = 'Y') -- 특수제본
					BEGIN
						IF @jebon <> ''
							SET @jebon_day = 1
					END
					ELSE
					BEGIN
						IF @jebon <> ''
							SET @jebon_txt = ' (제본 추가시 일정 추가 없음)'
					END
				END
				ELSE    
				BEGIN
					SET @std_txt = '마스터 기본'
					SET @std_day = 1
					IF UPPER(@cardBrand) = 'S' 
					BEGIN
						SET @std_txt = @std_txt + ' / 프리미어페이퍼'
						SET @std_day = 2
					END

					--제본추가시
					IF @jebon <> ''
						SET @jebon_day = 1
				END
			END
		END 

		--프리미엄 특수인쇄 봉투를 신청한 경우 3일.
		IF @ENVPREMIUM_PRICE > 0 
		BEGIN
			select @env_txt = ISNULL(C1.code_value,'')+' ' + ISNULL(C2.code_value,'')
			from custom_order_item A inner join s2_carddetail B on A.card_seq = B.card_seq
			left outer join (select code,code_value from manage_code where code_type ='print_mount' and code<>'0') C1 on B.envPrintMethod1 = C1.code
			left outer join (select code,code_value from manage_code where code_type ='print_mount' and code<>'0') C2 on B.envPrintMethod2 = C2.code
			where A.order_seq = @order_seq and A.item_type='E' and A.memo1='프리미엄봉투' and B.envPrintMethod1<>'0'

			SET @env_txt = '프리미엄봉투 ' + @env_txt 

			if @std_day < 3 
				SET @env_day = 3 - @std_day
			else
				SET @env_day = 0

		END

			

		SET @add_day = @std_day + @jebon_day + @env_day + 2
		
		-- ==================================================================================== 


		--최종예상발송일
		DECLARE @delivery_ex_date VARCHAR(10)
		IF @isspecial IN ('1','2')
			SET @delivery_ex_date = @sch_dt --초특급 인쇄당일출고
		ELSE
			SET @delivery_ex_date = dbo.fn_IsWorkDay(@sch_dt, @add_day)

		--기간내휴일
		DECLARE @holiday VARCHAR(10)= dbo.fn_IsWorkDay_(@sch_dt, @add_day)
		
		--RETURN
		SELECT 1 id, '초안확정일자' txt,ISNULL(CONVERT(CHAR(19), @confirm_date, 20),'') + ' > ' + [dbo].[fn_PrintDate_Reason](@src_confirm_date,@cardbrand) val,'' result
		UNION 
		SELECT 2, '인쇄일자' ,ISNULL( cast(@sch_dt as varchar) + '(' + LEFT(DATENAME (WEEKDAY, @sch_dt),1) + ')','') + CASE WHEN ISNULL(CONVERT(CHAR(19), @src_print_date, 20),'')  <> '' THEN ' / ' + ISNULL(CONVERT(CHAR(19), @src_print_date, 20),'')  ELSE '' END,''



		UNION 
		SELECT 3, ISNULL(@std_txt,''), ISNULL('+' + CAST(@std_day AS VARCHAR),''),''
		UNION 
		SELECT 4, CASE WHEN @env_txt <> '' THEN @env_txt ELSE '봉투특수인쇄없음' END, '+' + cast(@env_day as varchar) ,''
		UNION
		SELECT 5, CASE WHEN @jebon <> '' THEN @jebon ELSE '[제본없음]' END, '+' + cast(@jebon_day as varchar) + @jebon_txt ,''
		UNION
		SELECT 6, CASE WHEN @holiday = '0' THEN '[휴일없음]' ELSE '[휴일]' END, '+' + @holiday,''
		UNION
		SELECT 7, '52시간근무','+1',''
		UNION
		SELECT 8, CASE WHEN @isspecial IN ('1','2') THEN '발송일자(인쇄당일출고)' ELSE '발송일자' END,  ISNULL(@delivery_ex_date+ '(' + LEFT(DATENAME (WEEKDAY, @delivery_ex_date),1) + ')','') + CASE WHEN ISNULL(CONVERT(CHAR(19), @delivery_date, 20),'') <> '' THEN  ' / ' + ISNULL(CONVERT(CHAR(19), @delivery_date, 20),'') ELSE '' END, ISNULL(@delivery_ex_date + '(' + LEFT(DATENAME (WEEKDAY, @delivery_ex_date),1) + ')','')


	END
	ELSE
	BEGIN
		--RETURN
		SELECT 1 id, '' txt, '' val, '' result
		UNION 
		SELECT 2 id, '' txt, '' val, '' result
		UNION 
		SELECT 3 id, '' txt, '' val, '' result
		UNION 
		SELECT 4 id, '' txt, '' val, '' result
		UNION 
		SELECT 5 id, '' txt, '' val, '' result
		UNION 
		SELECT 6 id, '' txt, '' val, '' result
		UNION 
		SELECT 7 id, '' txt, '' val, '' result
	END
END

GO
