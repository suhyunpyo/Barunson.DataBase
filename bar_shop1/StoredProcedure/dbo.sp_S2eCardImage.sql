IF OBJECT_ID (N'dbo.sp_S2eCardImage', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2eCardImage
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_S2eCardImage 247
CREATE Proc [dbo].[sp_S2eCardImage]
	@Order_Seq	int
	
AS
		DECLARE @idoc int
		DECLARE @doc nvarchar(4000)
		DECLARE @reDoc nvarchar(500)
		-- Sample XML document
		SET @doc = N''
		
		SELECT @doc = Cast(xmlMovieData as nvarchar(4000)) FROM S2_eCardOrder WHERE order_seq = @Order_Seq
		-- Create an internal representation of the XML document.
	
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

		-- Execute a SELECT statement using OPENXML rowset provider.
		SELECT @reDoc = xmltext
		FROM OPENXML (@idoc, '/data/movieImg/movie', 9)
			  WITH (xmltext varchar(300) 'text()')
		            
		EXEC sp_xml_removedocument @idoc
	
		SELECT @reDoc



GO
