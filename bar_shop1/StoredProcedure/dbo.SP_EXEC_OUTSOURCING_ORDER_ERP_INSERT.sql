IF OBJECT_ID (N'dbo.SP_EXEC_OUTSOURCING_ORDER_ERP_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_OUTSOURCING_ORDER_ERP_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
    EXEC SP_EXEC_OUTSOURCING_ORDER_ERP_INSERT 2499205  
*/  
CREATE PROCEDURE [dbo].[SP_EXEC_OUTSOURCING_ORDER_ERP_INSERT]  
@p_order_seq AS INT  
  
AS  
BEGIN
  
    DECLARE @JumunNo    AS NVARCHAR(10)  
    DECLARE @CsCode     AS NVARCHAR(20)  
    DECLARE @ItemCode   AS NCHAR(20)  
    DECLARE @ItemQty    AS INT  
    DECLARE @OrderDate  AS NCHAR(8)  
    DECLARE @InvStatus  AS NCHAR(1)  
	DECLARE @CardCode AS VARCHAR(50)  
	DECLARE @isInternalDigital AS VARCHAR(1)
  
	-- 카드코드 조회
	SELECT @CardCode = Card_Code FROM S2_Card WHERE Card_Seq = (SELECT Card_Seq FROM Custom_Order WHERE Order_Seq = @p_order_seq)  

	-- 카드옵션 조회 (디지털내부)
	SELECT @isInternalDigital = isInternalDigital FROM S2_CardOption WHERE Card_seq = (SELECT Card_Seq FROM Custom_Order WHERE Order_Seq = @p_order_seq)
   
	-- ERP 거래처코드 : 위피오디 = 2014336 , 태산 = 2016191, 세영 = 2300137, 디지털(내부) = 2017163  
	-- 이윤지 청첩장만 세영금박에 전달
	IF (@CardCode IN ('BH4145', 'BH4145M', 'BH4145P') AND @isInternalDigital <> '1')
	BEGIN
		-- 세영금박  
		SET @CsCode = '2300137'  
	END  
	ELSE IF (@CardCode NOT IN ('BH4145', 'BH4145M', 'BH4145P') AND @isInternalDigital = '1')
	BEGIN
		-- 디지털(내부) 
		SET @CsCode = '2017163'
	END  
	ELSE  
	BEGIN
		-- 태산  
		SET @CsCode = '2016191'
	END  
  
  
	SELECT  @JumunNo = CAST(A.Order_Seq AS NVARCHAR(10))  
		--,   @CsCode = '2016191'    -- 위피오디 = 2014336 , 태산 = 2016191, 세영 = 2300137, 디지털(내부) = 2017163
		,   @ItemCode = ( CASE WHEN B.Card_ERPCode IN ('BH7604', 'BH7606') THEN 'BH7604_I' ELSE B.Card_ERPCode END )  
		,   @ItemQty = ( CASE WHEN A.Order_Count = 0 THEN (SELECT MAX(Item_Count) FROM Custom_Order_Item WHERE Order_Seq = @p_order_seq AND Item_Type IN ('C', 'I', 'P')) ELSE A.Order_Count END )  
		,   @OrderDate = CONVERT(NCHAR(8), GETDATE(), 112)  
	--,   @OrderDate = CONVERT(NCHAR(8), CASE WHEN ISNULL(A.settle_date, '') <> ''  THEN A.settle_date ELSE A.order_date END, 112)  
		,   @InvStatus = 'A'  
	FROM    Custom_Order AS A  
	    INNER JOIN    S2_CARD AS B ON A.Card_Seq = B.Card_Seq  
	WHERE   A.Order_Seq = @p_order_seq  
  
  
    IF NOT EXISTS(SELECT * FROM [erpdb.bhandscard.com].[XERP].dbo.[C_OsOrderData] WHERE JumunNo = @JumunNo AND InvStatus IN ( 'B' , 'C' ))  
    BEGIN  
      
        IF EXISTS(SELECT * FROM [erpdb.bhandscard.com].[XERP].dbo.[C_OsOrderData] WHERE JumunNo = @JumunNo AND InvStatus IN ( 'A' ))  
        BEGIN  
            DELETE FROM [erpdb.bhandscard.com].[XERP].dbo.[C_OsOrderData] WHERE JumunNo = @JumunNo AND InvStatus IN ( 'A' )  
        END  

        -- BH7725와 BH4145 시리즈는 물류에서 수동으로 입고처리함
        IF NOT @ItemCode IN ('BH4145', 'BH4145M', 'BH4145P', 'BH7725')
        BEGIN
            INSERT INTO [erpdb.bhandscard.com].[XERP].dbo.[C_OsOrderData]   
                    (JumunNo, CsCode, ItemCode, ItemQty, OrderDate, InvStatus)  
            VALUES  (@JumunNo, @CsCode, @ItemCode, @ItemQty, @OrderDate, @InvStatus)  
        END
    END  
  
      
  
END  
GO
