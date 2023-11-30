IF OBJECT_ID (N'dbo.SP_EXEC_MEM_REGIST_GIFT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MEM_REGIST_GIFT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_EXEC_MEM_REGIST_GIFT]
	@COMPANY_SEQ AS INT
,   @UID AS VARCHAR(50)
,   @GIFT_CARD_SEQ AS INT
AS
BEGIN
    
   INSERT INTO [dbo].[evt_mem_regist_gift]
           ([company_seq]
           ,[uid]
           ,[gift_card_seq]
           ,[regist_Date]
		   ,[end_date])
     VALUES
           (@COMPANY_SEQ
           ,@UID
           ,@GIFT_CARD_SEQ
           ,GETDATE()
		   ,DATEADD(DAY, 90, GETDATE()))

END
GO
