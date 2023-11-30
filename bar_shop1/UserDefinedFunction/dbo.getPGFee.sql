IF OBJECT_ID (N'dbo.getPGFee', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getPGFee', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getPGFee', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getPGFee', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getPGFee', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.getPGFee
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





CREATE      Function [dbo].[getPGFee]
	(@pgid varchar(20), @Settle_Method int,  @Settle_Price int , @CdName nchar(10))  --pg아이디, 결제수단(1:계좌이체  2,6: 신용카드 5:핸드폰   3:가상계좌), 결제금액, 신용카드사
Returns varchar(20)
as
Begin

  Declare @FeePrice int



  BEGIN 	
	IF @Settle_Method = 1   --계좌이체
		 			
		IF @Settle_Price < 1000000  -- 결제금액이 100만원 보도 작으면 1.5
			Begin
				Select @FeePrice = @Settle_Price * 0.015
	
				IF @FeePrice < 150 
					Select @FeePrice = 150			
			End
		ELSE
			Begin
				Select @FeePrice = @Settle_Price * 0.015
	
			End

	Else If @Settle_Method = 2 or @Settle_Method = 6  --신용카드
		Begin 
			IF @pgid = 'barunson2' --pg아이디가 barunson2이면..
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = 'LG' --신한(구 LG)
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End
			Else If  @pgid = 'thecard1' 
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = 'LG'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.029
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028	
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End
			Else If  @pgid = 'storyoflove' 
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = 'LG'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.029
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028	
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End	
			Else If  @pgid = 'tiaracard' 
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = 'LG'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.029
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028	
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End
			Else If  @pgid = 'tiaracard1' 
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = 'LG'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.029
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028	
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End
			Else If  @pgid = 'zzico' 
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = 'LG' --신한(구 LG)
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End
	
			Else If  @pgid = 'barunsonb2b' 
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = 'LG'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.029
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028	
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End	
	
			Else If  @pgid = 'pigwedding' 
	
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = 'LG'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.029
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028	
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End
	
			Else If  @pgid = 'ob_master' 
	
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = 'LG'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028	
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End
			Else If  @pgid = 'samsungcard' 
	
				Begin
					If @CdName = '국민' or @CdName = '씨티'  or @CdName = '농협' 
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '외환' or @CdName = '산은'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = '비씨' or @CdName = '하나'
						Select @FeePrice = @Settle_Price * 0.0305
					Else If @CdName = 'LG'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '삼성'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '현대'
						Select @FeePrice = @Settle_Price * 0.028	
					Else If @CdName = '롯데'
						Select @FeePrice = @Settle_Price * 0.028
					Else If @CdName = '신한'
						Select @FeePrice = @Settle_Price * 0.028
					Else
						Select @FeePrice = @Settle_Price * 0.028 --수협, 제주, 광주, 전북
				End
	
		End 

	Else If @Settle_Method = 5   --핸드폰
		Begin
			
			Select @FeePrice = @Settle_Price * 0.065
			
		End
	Else If @Settle_Method = 3   --가상계좌
		Begin
			Select @FeePrice  = 250
			
		End
	
	Else 
		Begin
			Select @FeePrice  = 0
		End


	Return IsNull(@FeePrice,0) * 1.1
    
   End 
End 






GO
