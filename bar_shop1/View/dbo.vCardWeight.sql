IF OBJECT_ID (N'dbo.vCardWeight', N'V') IS NOT NULL DROP View dbo.vCardWeight
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vCardWeight]
AS
SELECT   A.CARD_SEQ, B.card_code, B.card_weight
FROM      dbo.CARD A INNER JOIN
                dbo.CARD_WEIGHT B ON A.CARD_CODE = B.card_code
GO
