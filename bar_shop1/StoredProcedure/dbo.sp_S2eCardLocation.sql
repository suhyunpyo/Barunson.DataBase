IF OBJECT_ID (N'dbo.sp_S2eCardLocation', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2eCardLocation
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM S2_eCardOrder
--exec sp_S2eCardLocation 293
CREATE Proc [dbo].[sp_S2eCardLocation]
	@Order_Seq	int
	
AS
		DECLARE @idoc int
		DECLARE @doc nvarchar(max)
		DECLARE @location nvarchar(500)
		DECLARE @mapURL nvarchar(100)
		DECLARE @imgName nvarchar(20)
		
	--	Sample XML document
	--	SET @doc = N''
		
		SELECT @doc = xmlBackgroundData
		,@mapURL = case 
		when NOT(a.UploadImageURL = '' or a.UploadImageURL is null)  then a.UploadImageURL 
		else 'http://officefile.barunsoncard.com/theCard_wHallimg/'+b.imgFolder+'/'+b.ImgName
		end
		FROM S2_eCardOrder a left outer JOIN weddinghall_image b on a.wedding_seq = b.weddimg_idx WHERE order_seq = @Order_Seq
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

		-- Execute a SELECT statement using OPENXML rowset provider.
		SELECT @location = xmltext
		FROM OPENXML (@idoc, '/data/bgData/location', 9)
			  WITH (xmltext varchar(300) 'text()')
		            
		EXEC sp_xml_removedocument @idoc
		
		SELECT @location,@mapURL
		--SELECT @location,Replace(@location,@location,'http://officefile.barunsoncard.com/theCard_wHallimg/'+@imgfolder+'/'+@imgName)




GO
