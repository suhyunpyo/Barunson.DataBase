IF OBJECT_ID (N'dbo.fn_GetIdxDataLikeSplit', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_GetIdxDataLikeSplit', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_GetIdxDataLikeSplit', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_GetIdxDataLikeSplit', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_GetIdxDataLikeSplit', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_GetIdxDataLikeSplit
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	

/*
	-- 우편번호,전화번호 쿼리 예제
	DECLARE	@wZipData	VARCHAR(100)
	DECLARE	@wTelData	VARCHAR(100)
		
	DECLARE	@wPos	INT

	SELECT	@wZipData = '010-202'

	SELECT	SUBSTRING(@wZipData,1,CHARINDEX('-',@wZipData)-1) 우편번호앞자리,
			SUBSTRING(@wZipData,CHARINDEX('-',@wZipData)+1,3) 우편번호뒷자리


	SELECT	@wTelData = '012-3456-7890'
	
	SELECT	SUBSTRING(@wTelData,1,CHARINDEX('-',@wTelData)-1) 전화번호앞자리,
			SUBSTRING(@wTelData,CHARINDEX('-', @wTelData) + 1,LEN(@wTelData) - CHARINDEX('-', @wTelData) - CHARINDEX('-', REVERSE(@wTelData))) 전화번호중간자,
			RIGHT(@wTelData, CHARINDEX('-', REVERSE(@wTelData)) - 1) 전화번호뒷자리
*/
-----------------------------------------------------------------------------------------------------------
--  Split 유형의 함수
--  문자열에서 구분자(@iSeparator)로 몇번째 단어 가져오기
--  예: SELECT 데이터베이스명.소유자명.fn_GetIdxDataLikeSplit('가-나-다',2,'-') --> '나'
-----------------------------------------------------------------------------------------------------------
CREATE	FUNCTION  [dbo].[fn_GetIdxDataLikeSplit] 
	(
		@iText			VARCHAR(4000),
		@idx				INT,
		@iSeparator		VARCHAR(10)	= '-'
	)
RETURNS  VARCHAR(4000) 
AS
BEGIN
	DECLARE	@wData 			VARCHAR(4000)
	DECLARE	@wText 			VARCHAR(4000)
	DECLARE	@wSeparator	VARCHAR(10)
	DECLARE	@wNum 			INT

	SET	@wData			= ''
	SET	@wNum			= 1;
	SET	@wSeparator		= LTRIM(RTRIM(@iSeparator));
	SET	@wText			= LTRIM(RTRIM(@iText)) + @wSeparator; 

	IF CHARINDEX(@wSeparator, @iText) > 0
	BEGIN
		WHILE	 @idx >= @wNum
		BEGIN
			IF CHARINDEX(@wSeparator, @wText) > 0
			BEGIN
				   -- 문자열의 인덱스 위치의 요소를 반환
				   SET @wData	= SUBSTRING(@wText, 1, CHARINDEX(@wSeparator, @wText) - 1);
				   SET @wData	= LTRIM(RTRIM(@wData));

				-- 반환된 문자는 버린후 좌우공백 제거   
					SET @wText	= LTRIM(RTRIM(RIGHT(@wText, LEN(@wText) - (LEN(@wData) + LEN(@iSeparator)))))
			END 
			ELSE
			BEGIN
					SET @wData	= ''
			END
			SET @wNum = @wNum + 1
		END
	END
 	ELSE
 	BEGIN
 		SET @wData	= @iText
 	END 	
 	
 	RETURN(@wData)
 	
END










GO
