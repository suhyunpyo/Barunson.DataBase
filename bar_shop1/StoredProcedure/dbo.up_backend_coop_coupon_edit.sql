IF OBJECT_ID (N'dbo.up_backend_coop_coupon_edit', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_coupon_edit
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*  
 작성정보   :   [2003:08:20    13:28]  JJH:   
 관련페이지 :A_Info/coop_info.asp
 내용    :       업체 쿠폰정보
   
 수정정보   :   
*/  
CREATE pRocedure [dbo].[up_backend_coop_coupon_edit]
	@KIND			VARCHAR(20)
,	@COMPANY_SEQ		INT
,	@IID			INT
,	@S_NUM		INT
,	@E_NUM			INT
,	@CS_DAY		DATETIME
,	@CE_DAY		DATETIME
,	@ONOFF			VARCHAR(2)
,	@ADMIN_ID		VARCHAR(20)
as
IF @KIND = 'ADD'
	BEGIN
		INSERT INTO dbo.COOP_COUPON (COMPANY_SEQ
						,S_NUM
						,E_NUM
						,S_DAY
						,E_DAY
						,REG_ID)
				VALUES( @COMPANY_SEQ
						,@S_NUM
						,@E_NUM
						,@CS_DAY
						,@CE_DAY
						,@ADMIN_ID)
	END
ELSE IF @KIND = 'UPDATE'
	BEGIN
		UPDATE dbo.COOP_COUPON SET 
						 S_NUM	= @S_NUM
						,E_NUM	= @E_NUM
						,S_DAY	= @CS_DAY
						,E_DAY	= @CE_DAY
						,ONOFF	= @ONOFF
						,CHG_ID	= @ADMIN_ID
						,CHG_DT= GETDATE()
			WHERE  @IID = IID
	END

GO
