IF OBJECT_ID (N'dbo.ufn_SerialNumber', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SerialNumber', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SerialNumber', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SerialNumber', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SerialNumber', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.ufn_SerialNumber
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT [dbo].[ufn_SerialNumber]() 
CREATE FUNCTION [dbo].[ufn_SerialNumber]() 
	returns VARCHAR(11) 
AS 
BEGIN 
	DECLARE @randInt INT; 
	DECLARE @1  CHAR(1) ;
	DECLARE @23 CHAR(2) ;
	DECLARE @tmp4  CHAR(4) = RIGHT(CONVERT(char(8),GETDATE(),112),4);
	DECLARE @4  CHAR(1) ;
	DECLARE @5  CHAR(1) = ''; 
	DECLARE @6  CHAR(1) ;
	DECLARE @7  CHAR(1) ;
	DECLARE @8  CHAR(1) ;
	DECLARE @910 CHAR(2) ;
	DECLARE @tmp11 CHAR(6);
	DECLARE @11 CHAR(1) ;

	--1번째 자리 A ~ Z까지 영문 랜덤. 예) A
	SET @1 = Char(dbo.ufn_RandBetween(65, 90)) 
    --2번째 자리, 3번째자리 :  발행월.예) 11월 발행 11( 1월발행 01)
	SET @23 =  RIGHT('00' + CAST(DATEPART(mm,GETDATE()) AS NVARCHAR), 2)
	--4번째 자리 : 발행일자 합계 + 7의 일자리. 예) 11월 22일 발행일 경우, 1+1+2+2+7 + 13의 일자리 3
	SET @4 =RIGHT(CAST(SUBSTRING(@tmp4,1,1) AS INT) + CAST(SUBSTRING(@tmp4,2,1) AS INT) + CAST(SUBSTRING(@tmp4,3,1) AS INT) + CAST(SUBSTRING(@tmp4,4,1) AS INT) + 7,1)
	--5번째 자리 : 0 ~ 9 까지숫자 랜덤 예) 2
	WHILE ( Len(@5) < 1 ) 
	BEGIN 
		SELECT @randInt = dbo.ufn_RandBetween(48, 122) 
		IF @randInt <= 57 
		BEGIN 
			SELECT @5 = Concat('', Char(@randInt) ) 
		END 
	END
	--6번째 자리 A ~ Z까지 영문 랜덤. 예) Z
	SET @6 = Char(dbo.ufn_RandBetween(65, 90)) 
	--7번째 자리 A ~ Z까지 영문 랜덤. 예) C
	SET @7 = Char(dbo.ufn_RandBetween(65, 90)) 
	--8번째 자리 A ~ Z까지 영문 랜덤. 예) G
	SET @8 = Char(dbo.ufn_RandBetween(65, 90)) 
	--9번째 자리, 10번째자리 :  발행일.예) 22일 발행시 22(1일 발행시 01)
	SET @910 =  RIGHT('00' + CAST(DATEPART(dd,GETDATE()) AS NVARCHAR), 2)

	SET @tmp11 = Concat(@23,@4,@5,@910)
	--11번째 자리 :  생성된 위 모든 숫자 +3의 일자리 예) 1+1+3+2+2+2+3 = 11
	SET @11 =RIGHT(CAST(SUBSTRING(@tmp11,1,1) AS INT) + CAST(SUBSTRING(@tmp11,2,1) AS INT) + CAST(SUBSTRING(@tmp11,3,1) AS INT) + 
	CAST(SUBSTRING(@tmp11,4,1) AS INT) + CAST(SUBSTRING(@tmp11,5,1) AS INT) + CAST(SUBSTRING(@tmp11,6,1) AS INT) + 3,1)

	RETURN CONCAT(@1,@23,@4,@5,@6,@7,@8,@910,@11)

END


GO
