IF OBJECT_ID (N'dbo.VW_holidays', N'V') IS NOT NULL DROP View dbo.VW_holidays
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_holidays]
AS
	SELECT YDate FROM holidays
	UNION
	SELECT YDate FROM holidays_of_making_cards
Go