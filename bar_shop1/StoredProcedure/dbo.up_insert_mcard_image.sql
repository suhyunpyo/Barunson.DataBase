IF OBJECT_ID (N'dbo.up_insert_mcard_image', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_mcard_image
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-09
-- Description:	모바일 청첩장 갤러리 등록
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_mcard_image]
	-- Add the parameters for the stored procedure here
	@method			CHAR(1),
	@order_seq		INT,
	@fileIndex		INT,
	@fileName1		VARCHAR(100),
	@orgFileName1	VARCHAR(100),
	@imageSizeW1	FLOAT,
	@imageSizeH1	FLOAT,
	@fileName2		VARCHAR(100),
	@orgFileName2	VARCHAR(100),
	@imageSizeW2	FLOAT,
	@imageSizeH2	FLOAT,
	@fileName3		VARCHAR(100),
	@orgFileName3	VARCHAR(100),
	@imageSizeW3	FLOAT,
	@imageSizeH3	FLOAT,
	@fileName4		VARCHAR(100),
	@orgFileName4	VARCHAR(100),
	@imageSizeW4	FLOAT,
	@imageSizeH4	FLOAT,
	@result_code	int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ftype1 INT		-- big size image  fileType
	DECLARE @ftype2 INT		-- small size image fileType
	DECLARE @ftype3 INT		-- 320 size image fileType
	DECLARE @ftype4 INT		-- 640 size image fileType		
	
	-- 메인 이미지인 경우
	IF @method = 'M'
		BEGIN
			SET @ftype1 = '3'
			SET @ftype2 = '4'
			SET @ftype3 = '7'
			SET @ftype4 = '8'
		END
	
	-- 갤러리 이미지인 경우	
	ELSE
		BEGIN
			SET @ftype1 = '1'
			SET @ftype2 = '2'
			SET @ftype3 = '5'
			SET @ftype4 = '6'
		END		
		
	BEGIN TRAN

	-- 등록된 이미지 삭제 처리	
	DELETE FROM S5_nmCardImageInfo WHERE Order_Seq = @order_seq AND FileIndex=@fileIndex AND FileType in (@ftype1, @ftype2, @ftype3, @ftype4) 
	
	-- big size image 등록
	IF @fileName1 <> ''
		BEGIN
			INSERT INTO S5_nmCardImageInfo (Order_Seq, FileType, FileIndex, FileName, OrgFileName, imageSizeW, imageSizeH)
				VALUES (@order_seq, @ftype1, @fileIndex, @fileName1, @orgFileName1, @imageSizeW1, @imageSizeH1)
		END

	-- smaill size image 등록
	IF @fileName2 <> ''
		BEGIN
			INSERT INTO S5_nmCardImageInfo (Order_Seq, FileType, FileIndex, FileName, OrgFileName, imageSizeW, imageSizeH)
				VALUES (@order_seq, @ftype2, @fileIndex, @fileName2, @orgFileName2, @imageSizeW2, @imageSizeH2)
		END

	-- 320 size image 등록
	IF @fileName3 <> ''
		BEGIN
			INSERT INTO S5_nmCardImageInfo (Order_Seq, FileType, FileIndex, FileName, OrgFileName, imageSizeW, imageSizeH)
				VALUES (@order_seq, @ftype3, @fileIndex, @fileName3, @orgFileName3, @imageSizeW3, @imageSizeH3)
		END

	-- 640 size image 등록
	IF @fileName4 <> ''
		BEGIN
			INSERT INTO S5_nmCardImageInfo (Order_Seq, FileType, FileIndex, FileName, OrgFileName, imageSizeW, imageSizeH)
				VALUES (@order_seq, @ftype4, @fileIndex, @fileName4, @orgFileName4, @imageSizeW4, @imageSizeH4)
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
