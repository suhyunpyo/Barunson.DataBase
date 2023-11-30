IF OBJECT_ID (N'dbo.up_update_mcard_show', N'P') IS NOT NULL DROP PROCEDURE dbo.up_update_mcard_show
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-13
-- Description:	모바일 청접장 영상 처리 
-- =============================================
CREATE PROCEDURE [dbo].[up_update_mcard_show]
	-- Add the parameters for the stored procedure here
	@mode			AS VARCHAR(20),
	@order_seq		AS INT,
	@showHash		AS VARCHAR(50),
	@ShakrInstanceId AS VARCHAR(50),
	@EditSIstatus	AS SMALLINT = 0,
	@EditSSstatus	AS SMALLINT = 0,
	@EditSCstatus	AS SMALLINT = 0,
	@EditECstatus	AS SMALLINT = 0,
	@StyleSlug		AS VARCHAR(100),
	@ShowViewUrl	AS VARCHAR(100),
	@ShowHdDownUrl	AS VARCHAR(100),
	@ShowSdDownUrl	AS VARCHAR(100),
	@ShowStatus		AS INT = 0,
	@RenderProgress	AS INT = 0,
	@PurchasedStatus AS CHAR(1),					
	@result_code		INT = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ShowViewAliasUrl VARCHAR(100)
	DECLARE @ShowViewAliasHdUrl VARCHAR(100)
	DECLARE @ShowViewAliasSdUrl VARCHAR(100)
	
		
	BEGIN TRAN	
	
	IF @mode = 'ShowStart'
		BEGIN
			IF EXISTS(SELECT showindex FROM S5_nmCardShowInfo  WHERE order_seq = @order_seq AND ShowHash = @showHash)
			BEGIN
				UPDATE S5_nmCardShowInfo SET ShakrInstanceId = @ShakrInstanceId, EditSIstatus=@EditSIstatus, EditSSstatus=@EditSSstatus, ModDate=GETDATE()
					WHERE order_seq = @order_seq AND ShowHash = @showHash
			END
			ELSE
			BEGIN
				INSERT INTO S5_nmCardShowInfo(order_seq,ShowHash,ShakrInstanceId,EditSIstatus,EditSSstatus)
					VALUES(@order_seq, @showHash, @ShakrInstanceId, @EditSIstatus, @EditSSstatus)
			END
		END

	ELSE IF @mode = 'ShowCompleted'
		BEGIN
			IF EXISTS(SELECT showindex FROM S5_nmCardShowInfo  WHERE order_seq = @order_seq AND ShowHash = @showHash)
			BEGIN
				UPDATE S5_nmCardShowInfo SET shakrInstanceId = @ShakrInstanceId, EditSCstatus=@EditSCstatus, ModDate=GETDATE()
					WHERE order_seq = @order_seq AND ShowHash = @showHash
			END
			ELSE
			BEGIN
				INSERT INTO S5_nmCardShowInfo(order_seq,ShowHash,ShakrInstanceId,EditSCstatus)
					VALUES(@order_seq, @showHash, @ShakrInstanceId, @EditSCstatus)
			END		
		END

	ELSE IF @mode = 'EditorClosed'
		BEGIN
			IF EXISTS(SELECT showindex FROM S5_nmCardShowInfo  WHERE order_seq = @order_seq AND ShowHash = @showHash)
			BEGIN
				UPDATE S5_nmCardShowInfo SET shakrInstanceId = @ShakrInstanceId, EditECstatus=@EditECstatus, ModDate=GETDATE()
					WHERE order_seq = @order_seq AND ShowHash = @showHash
			END
			ELSE
			BEGIN
				INSERT INTO S5_nmCardShowInfo(order_seq,ShowHash,ShakrInstanceId,EditECstatus)
					VALUES(@order_seq, @showHash, @ShakrInstanceId, @EditECstatus)
			END			
		END
		
	ELSE IF @mode = 'ShowUpdate'
		BEGIN
		
			SET @ShowViewAliasUrl = 'https://www.shakr.com/embed/' + @showHash 
			SET @ShowViewAliasHdUrl = 'https://www.shakr.com/video/' + @showHash + '/watch.mp4?q=hd'
			SET @ShowViewAliasSdUrl = 'https://www.shakr.com/video/' + @showHash + '/watch.mp4?q=sd'

			UPDATE S5_nmCardShowInfo 
				SET 
					StyleSlug = @StyleSlug, 
					ShowViewUrl=@ShowViewUrl, 
					ShowViewAliasUrl=@ShowViewAliasUrl, 
					ShowViewAliasHdUrl=@ShowViewAliasHdUrl, 
					ShowViewAliasSdUrl=@ShowViewAliasSdUrl, 
					ShowHdDownUrl=@ShowHdDownUrl, 
					ShowSdDownUrl=@ShowSdDownUrl, 
					ShowStatus=@ShowStatus, 
					RenderProgress=@RenderProgress, 
					PurchasedStatus=@PurchasedStatus, 
					ModDate=GETDATE()
				WHERE ShowHash = @showHash
	
		END		
		
	ELSE IF @mode = 'ShowDelete'
		BEGIN
			UPDATE S5_nmCardShowInfo SET DelFlag = 'Y', ModDate=GETDATE() WHERE order_seq = @order_seq AND ShowHash = @showHash
			
			IF EXISTS(SELECT order_seq FROM S5_nmCardorder  WHERE order_seq = @order_seq AND show_hash = @showHash)
			BEGIN
				UPDATE S5_nmCardorder SET show_hash = '', ModDate=GETDATE() WHERE order_seq = @order_seq	
			END
		END
		
	ELSE IF @mode = 'ShowSelectSave'
		BEGIN
			UPDATE S5_nmCardorder SET show_hash = @showHash, ModDate=GETDATE() WHERE order_seq = @order_seq	
		END
								
	
    	
	SET @result_code = @@Error		--에러발생 cnt
	IF (@result_code <> 0) 
		BEGIN
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			COMMIT TRAN
		END 

	RETURN @result_code
END
GO
