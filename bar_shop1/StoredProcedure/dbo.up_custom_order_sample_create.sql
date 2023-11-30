IF OBJECT_ID (N'dbo.up_custom_order_sample_create', N'P') IS NOT NULL DROP PROCEDURE dbo.up_custom_order_sample_create
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_custom_order_sample_create] -- always use schema prefix
    
AS


BEGIN -- use body wrappers around whole body
  SET NOCOUNT ON; -- put this at the beginning - no point in setting it at the end

  DECLARE @SQL NVARCHAR(MAX); -- dynamic SQL should always be Unicode
  declare @TABLENAME nvarchar(100)

  set @TABLENAME = 'CUSTOM_SAMPLE_ORDER_ITEM_'+left(replace(convert(varchar(10),getdate(),121),'-',''),6)

  SELECT @SQL = 'CREATE TABLE dbo.' + QUOTENAME(@TABLENAME) + '('
    + '[CARD_SEQ] [int] NOT NULL,
       [SAMPLE_ORDER_SEQ] [INT] NOT NULL,[CARD_PRICE] [int] NULL,
       [REG_DATE] [smalldatetime] NULL DEFAULT (GETDATE()),[FinStatusOpen] [bit] NOT NULL,
       [PeriodClosedTS] [smalldatetime] NULL,[PeriodClosedUID] [varchar](3) NULL,
       CONSTRAINT [PK_CARD_SEQ_' + @TABLENAME + '_1] PRIMARY KEY CLUSTERED(
         [CARD_SEQ])
		 
		 );'; -- all those options you specified were verbose defaults

  EXEC sp_executesql @sql; -- instead of EXEC(@sql)
END
GO
