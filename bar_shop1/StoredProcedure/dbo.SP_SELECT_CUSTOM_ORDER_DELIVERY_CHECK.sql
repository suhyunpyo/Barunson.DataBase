IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_ORDER_DELIVERY_CHECK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_ORDER_DELIVERY_CHECK
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
CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_ORDER_DELIVERY_CHECK]
    @ORDER_SEQ AS INT
,   @ERROR_YORN AS CHAR(1) OUT
,   @ERROR_MSG AS NVARCHAR(500) OUT
AS
BEGIN

    SET NOCOUNT ON

    SET @ERROR_YORN = 'N'
    SET @ERROR_MSG = ''



    SELECT  @ERROR_YORN = MAX   (
                                    CASE 
                                            WHEN REPLACE(PHONE, '-', '') = '010010010' OR REPLACE(HPHONE, '-', '') = '010010010' 
                                            THEN 'Y'
                                             
                                            ELSE 'N' 
                                    END
                                )
    FROM    DELIVERY_INFO 
    WHERE   1 = 1
    AND     ORDER_SEQ = @order_seq
    GROUP BY ORDER_SEQ



    IF @ERROR_YORN = 'Y'
    BEGIN
        SET @ERROR_MSG = '전화번호가 잘못 입력 됨'
    END

END
GO
