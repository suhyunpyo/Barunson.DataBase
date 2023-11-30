IF OBJECT_ID (N'dbo.sp_card_expect_baesong_test', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_card_expect_baesong_test
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-- =============================================  
-- Author: 시스템지원팀, 정혜련  
-- Create date: 2016-08-10  
-- Description: 카드 제작 예상 일정   
-- 5006: 비핸즈 


 exec sp_card_expect_baesong '1', '2019-08-09', '9', '36724', '5007' 
 exec sp_card_expect_baesong '2', '2019-08-09', '9', '36724', '5007' 

  
-- =============================================  
*/


CREATE proc [dbo].[sp_card_expect_baesong_test]  
 @sch_gb   varchar(1), -- 1.초안, 2.배송  
 @sch_dt   varchar(10), -- 날짜  
 @sch_tm   int, -- 시간  
 @card_seq  int, -- 카드번호  
 @company_seq int  -- 사이트 구분  
  
AS  
  
BEGIN   
  
	 DECLARE @CardKind_Seq VARCHAR(20) -- 카드 카테고리  
	 DECLARE @CardKind VARCHAR(10) -- 카드 구분  
  
	 DECLARE @printMethod VARCHAR(3)    
	 DECLARE @isCustomDColor VARCHAR(1)    
	 DECLARE @isLaser VARCHAR(1)   
	 DECLARE @isLetterPress VARCHAR(1)  
	 DECLARE @isLiningjaebon VARCHAR(1) -- 2017.09.15 추가  
	 DECLARE @isMasterDigital VARCHAR(1)   
	 DECLARE @isMaster2Color VARCHAR(1) --// 2019-08-09 마스터2도 인쇄 카드의 경우 1일의 추가 일정이 계산되도록 세팅 변경을 요청   
	 DECLARE @cardbrand VARCHAR(1) -- 카드브랜드(바른손몰:프페추가)  
  
	 DECLARE @order_d_v1  int  -- 초안 일정  
	 DECLARE @order_d_v2  int  -- 배송 일정  
    
   
	   -- 카드 카테고리  
	 select @CardKind_Seq = STUFF((   
	  SELECT ',' + CONVERT(VARCHAR(2), CardKind_Seq)   
	  FROM (select CardKind_Seq from s2_cardkind where card_seq = @card_seq group by CardKind_Seq ) a   
	  FOR XML PATH('')   
	  ), 1, 1, '')   
   
  
	 -- 카드 상세  
	 Select @printMethod =   C.printMethod   
	  , @isCustomDColor =   isnull(isCustomDColor,0)     
	  , @isLaser =   ISNULL(C.isLaser, 0)     
	  , @cardBrand = cardBrand  
	  , @isLetterPress = isnull(C.isLetterPress,0)  
	  , @isLiningjaebon = isnull(C.isLiningjaebon,0)   
	  , @isMasterDigital = isnull(C.isMasterDigital,0) 
	  , @isMaster2Color = isnull(c.Master_2Color, 0)
	 From S2_Card A inner join S2_CardDetail B on A.card_Seq = B.card_seq ,S2_Cardoption C    
	 Where A.card_Seq = C.card_seq and A.CARD_SEQ= @card_seq  
   
	-- =============================================  
	-- 예정일 + a  
	-- =============================================   
	 -- 디지털인쇄   
	 IF charindex('1', @CardKind_Seq) > 0 AND charindex('14', @CardKind_Seq) > 0  OR  @isMasterDigital = '1'   
		  BEGIN  
		   set @CardKind = 'DIGITAL';   
		   set @order_d_v1 = 2;  -- 초안 +1일  
     
			   BEGIN  
				If left(@printMethod,1) <> '0' Or @isLaser = '1'   
				 set @order_d_v2 = 5; -- 배송출발일 +4일  
				else  
				 set @order_d_v2 = 4; -- 배송출발일 +3일  
			   END  
		  END   
    
	 -- 마스터 인쇄  
	 ELSE  
		  BEGIN 
			   set @CardKind = 'MASTER';  
			   set @order_d_v1 = 1; -- 초안 +0일   
  
			   BEGIN  
				If @printMethod <> '000' Or @isLaser = '1'  OR @isLiningjaebon = 2  
				 set @order_d_v2 = 4; -- 배송출발일 +3일   
				else  
				 set @order_d_v2 = 2; -- 배송출발일 +1일   
			   END  
       
		  END


  
	 -- 오후 3시 기준 --------------------------------------------------------  
	 begin  
	  if @sch_tm > 13 and @sch_gb = '1'  
	   if @CardKind = 'MASTER'  
		set @order_d_v1 = @order_d_v1 + 1;  
	 end    
  
   
	 begin  
	  if @sch_tm > 15 and @sch_gb = '2'   
	   set @order_d_v2 = @order_d_v2 + 1;    
	 end  
  
  
	 -- 프리미어페이퍼 추가1일더한다(배송일)====================================================================================================  
	 --2017.02.22 로직 수정 : 프페카드일경우 배송일은 초안확정일 기준 +4일. 초안완료는 오전 11시 기준으로 이전까지는 당일 이후는 익일 완료  
	 begin  
	  if @cardBrand = 'S' OR @cardBrand = 's'   
		  begin  
			   set @order_d_v1 = 1;  
  
			   -- 레터프레스,특정카드    
			   if  @card_seq = '33921' or @card_seq = '33950'   
				set @order_d_v2 = 8;  
			   else   
				set @order_d_v2 = 4;  
     
  
			   if  @sch_gb = '1'--초안완료일  
			   begin   
				if @sch_tm < 13  
				 set @order_d_v1 = 1;  
				else   
				 set @order_d_v1 = @order_d_v1 + 1;  
			   end   
  
  
			   if  @sch_gb = '2'--배송일자  
			   begin   
				if @sch_tm > 12  
				 set @order_d_v2 = @order_d_v2 + 1;  
			   end   
  
			   if  @isLetterPress = 1   
				set @order_d_v2 = @order_d_v2 + 9; -- 배송출발일 +10일   
		  END  
	 END   
	 --=========================================================================================================================================    
   
  
	 /* 라이닝제본이 들어가 있으면 +1일 추가 */  
	 /* 바른손카드만 */  
	 /* 김지선MD 요청 - 17.09.27 */  
	 if @card_seq > 0   
	 begin  
		 SET @order_d_v2 = @order_d_v2 + (  
				  SELECT CASE   
					  WHEN ISNULL(ISLININGJAEBON, 0) IN (1, 2) AND @company_seq = 5001  
					  THEN 1  
					  ELSE 0   
					END   
				  FROM S2_CARDOPTION   
				  WHERE CARD_SEQ = @card_seq  
				 )  
		 -- 특수인쇄 추가  
		 SET @order_d_v2 = @order_d_v2 + (  
				  SELECT CASE   
					  WHEN ISNULL(outsourcing_print, '') <> '' AND @company_seq = 5001  
					  THEN 1  
					  ELSE 0   
					END   
				  FROM S2_CARDOPTION   
				  WHERE CARD_SEQ = @card_seq  
				 )  
   
	 end  
	 
	
		/*
		2019-08-09  배송일만 +1일 추가
		마스터 2도 카드 추가 일정 세팅 요청 s
		*/
		if @isMaster2Color = 1
		begin
			set @order_d_v2 = @order_d_v2 +1 ; -- 배송출발일 +1일   
		end

		/*
		마스터 2도 카드 추가 일정 세팅 요청 e
		*/
  
  

-- =============================================  
-- 주말 & 휴일 날짜 체크함수 호출  
-- =============================================  
    
end  


	--주 52시간 근무에 따른 배송일 수정
	set @order_d_v1 = @order_d_v1 +1 ; -- 배송출발일 +1일 
	set @order_d_v2 = @order_d_v2 +1 ; -- 배송출발일 +1일   


if  @sch_gb = '1'  
 SELECT dbo.fn_IsWorkDay(@sch_dt,  @order_d_v1) as last_Dt  
else  
   SELECT dbo.fn_IsWorkDay(@sch_dt, @order_d_v2) as last_Dt 


GO
