IF OBJECT_ID (N'dbo.getPGFee_New', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getPGFee_New', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getPGFee_New', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getPGFee_New', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getPGFee_New', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.getPGFee_New
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





CREATE      Function [dbo].[getPGFee_New]
	(@pgid varchar(20), @Settle_Method int,  @Settle_Price int)  --pg아이디, 결제수단(1:계좌이체  2,6: 신용카드 5:핸드폰   3:가상계좌), 결제금액, 신용카드사
Returns varchar(20)
as
Begin

  Declare @FeePrice int


	IF @Settle_Method = 1   --계좌이체
	BEGIN
		IF ( LEFT(@pgid, 8 ) = 'bhandsca' )	--이니시스 PG수수료
		BEGIN 
			Select @FeePrice = @Settle_Price * 0.01210	--Vat포함
		
		END
		ELSE
		BEGIN 		 			
				IF @Settle_Price <= 1000000  -- 결제금액이 100만원 보다 작으면 1.2%
				Begin
					Select @FeePrice = @Settle_Price * 0.01320	--변경 20110726  기존: 0.0165 Vat포함
			
					IF @FeePrice < 165		
						Select @FeePrice = 165		--최저수수료 건당 150원	Vat포함: 165원
				End
				ELSE
				Begin
					Select @FeePrice = @Settle_Price * 0.01320	--변경 20110726  기존: 0.0143 Vat포함

				End
		END 
	END
	Else If @Settle_Method = 2 or @Settle_Method = 6  --신용카드
	BEGIN
		 
		--Select @FeePrice = @Settle_Price * 0.02915	-- 변경 20110726  기존: 0.03036	Vat포함
		--Select @FeePrice = @Settle_Price * 0.02750	-- 변경 20130814  기존: 0.02915	Vat포함
		Select @FeePrice = @Settle_Price * 0.02530		-- 변경 20130828  기존: 0.02750	Vat포함
		
	END
	Else If @Settle_Method = 5   --핸드폰
	BEGIN
		
		--Select @FeePrice = @Settle_Price * 0.033
		--Select @FeePrice = @Settle_Price * 0.02420	--변경 20130814  기존: 0.033	Vat포함
		
		Select @FeePrice = @Settle_Price * 0.02310	--변경 20130828  기존: 0.02420	Vat포함
			
	END
	Else If @Settle_Method = 3   --가상계좌
	Begin
		--Select @FeePrice  = 220		--변경 20110726  기존: 275		Vat포함
		Select @FeePrice  = 198		--변경 20130828  기존: 220		Vat포함
		
	End
	Else 
	Begin
		Select @FeePrice  = 0
	End


	Return IsNull(@FeePrice,0) 
    

End 






GO
