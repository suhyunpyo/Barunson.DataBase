IF OBJECT_ID (N'dbo.A', N'P') IS NOT NULL DROP PROCEDURE dbo.A
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE proc [dbo].[A]    
 @Str  varchar(300)    
as     
   set nocount on     
  
 select @Str = 'select * from ' + @Str      
  
 exec (@Str)    
  

GO
