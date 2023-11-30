IF OBJECT_ID (N'dbo.SP_SELECT_OUTSOURCING_DELIVERY_LIST_PREMIER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_OUTSOURCING_DELIVERY_LIST_PREMIER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
/*

EXEC SP_SELECT_OUTSOURCING_DELIVERY_LIST_PREMIER '2297061'

*/

CREATE PROCEDURE [dbo].[SP_SELECT_OUTSOURCING_DELIVERY_LIST_PREMIER]
	@P_ORDER_SEQ AS VARCHAR(20)

AS
BEGIN
    
    SELECT  ROW_NUMBER() OVER(ORDER BY A.DELIVERY_DATE ASC) AS ROW_NUM
		, A.ORDER_SEQ
		, A.DELIVERY_SEQ
		, A.NAME
		, A.PHONE
		, A.HPHONE
		, A.ZIP
		, A.ADDR
		, A.ADDR_DETAIL	
		, ISNULL(A.DELIVERY_METHOD, 0) AS DELIVERY_METHOD
		, A.DELIVERY_INFO
		, ISNULL(A.DELIVERY_COM, '') AS DELIVERY_COM
		, ISNULL(A.DELIVERY_CODE_NUM, '') AS DELIVERY_CODE_NUM
		, A.DELIVERY_DATE
    FROM    DELIVERY_INFO AS A
    WHERE   1 = 1
    AND     A.ORDER_SEQ  = @P_ORDER_SEQ
    ORDER BY A.DELIVERY_SEQ ASC

    

END
GO
