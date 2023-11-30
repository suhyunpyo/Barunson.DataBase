IF OBJECT_ID (N'dbo.sp_S2eCardThumb', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2eCardThumb
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_S2eCardThumb 247
CREATE Proc [dbo].[sp_S2eCardThumb]
	@Order_Seq	int
	
AS
		DECLARE @idoc int
		DECLARE @doc nvarchar(4000)
		DECLARE @reDoc nvarchar(500)
		DECLARE @Begindoc int
		DECLARE @Enddoc int
		-- Sample XML document
		SET @doc = N''
		
		SELECT @doc = xmlBackgroundData FROM S2_eCardOrder WHERE order_seq = @Order_Seq
		-- Create an internal representation of the XML document.
	
		Set @Begindoc = CHARINDEX('<bgImg>', @doc)
		Set @Enddoc = CHARINDEX('</bgImg>', @doc)
		Set @doc = Substring( @doc, @Begindoc, @Enddoc-@Begindoc+8)
		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

		-- Execute a SELECT statement using OPENXML rowset provider.
		SELECT @reDoc = xmltext
		--FROM OPENXML (@idoc, '/data/bgData/bgImg', 9)
		FROM OPENXML (@idoc, '/bgImg', 9)
			  WITH (xmltext varchar(300) 'text()')
		            
		EXEC sp_xml_removedocument @idoc
	
		SELECT @reDoc
GO
