IF OBJECT_ID (N'dbo.sp_samsung_daily_list', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_samsung_daily_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*----------------------------------------------------------------------------------------------
1.Stored Procedure	: sp_samsung_daily_list
2.관련 Table		: SAMSUNG_DAILY_INFO
3.내용				: 삼성으로 일일 회원가입 정보 기본정보(1) / 부가정보 리스트(2)
					인자값1) 당일 
					인자값2) 1 -> 기본정보 / 2 -> 부가정보
4.작성자			: zen
5.작성일			: 2013.07.01
6.수정				: 웨딩날짜 없는것 제외, 참여날짜 07.01 이전것들 제외
-----------------------------------------------------------------------------------------------*/

/* 사용 방법-------------------------------------------------------------------------------------

-- 2013-07-01 데이터 
exec [dbo].[sp_samsung_daily_list]  '20130730','1'  -- 기본정보
exec [dbo].[sp_samsung_daily_list]  '20130730','2'  -- 부가정보

-- 중복데이터 확인
select distinct conninfo, (select COUNT(*) from dbo.SAMSUNG_DAILY_INFO aa where aa.conninfo = bb.conninfo) from dbo.SAMSUNG_DAILY_INFO bb
where (select COUNT(*) from dbo.SAMSUNG_DAILY_INFO aa where aa.conninfo = bb.conninfo) > 1


select * from SAMSUNG_DAILY_INFO

/ 2014.04.21
삼성멤버십가입일, 비핸즈가입일 교체
/ 2014.06.09
멤버십 수정가입으로 필터링 조건  가입일 20130701 -> 20100701 로 변경
/ 2014.06.13
멤버십 수정가입으로 필터링 조건  가입일 20100701 -> 20130701 로 변경 
=> 필수필드값이 없는 예전 가입자들 때문에 문재발생 
-----------------------------------------------------------------------------------------------*/

CREATE     Procedure [dbo].[sp_samsung_daily_list]

@today varchar(15),
@type  varchar(15)

as
SET NOCOUNT ON
DECLARE @sql NVARCHAR(2000)


IF @type = '1'
	BEGIN
		------ 기본정보리스트 ------
		SET @sql = '	select bb.ConnInfo, bb.uid, bb.uname, substring(bb.Birthdate, 3, 6) as Birthdate,	'
		SET @sql = @sql + '	case '
		SET @sql = @sql + '	when bb.Gender = ''1'' then ''M''	'
		SET @sql = @sql + '	when bb.Gender = ''0'' then ''F''	'
		SET @sql = @sql + '	else ''--''	'
		SET @sql = @sql + '	end as Gender,	'
		SET @sql = @sql + '	''H'' as p_gubun,	'
		SET @sql = @sql + '	bb.phone1,bb.phone2,bb.phone3,	'
		SET @sql = @sql + '	bb.hand_phone1,bb.hand_phone2,bb.hand_phone3,	'
		SET @sql = @sql + '	bb.chk_TM,	'
		SET @sql = @sql + '	bb.zip1+bb.zip2 as zip,	'
		SET @sql = @sql + '	bb.address, bb.addr_detail,	'
		SET @sql = @sql + '	bb.zip1+bb.zip2 as c_zip,	'
		SET @sql = @sql + '	bb.address as c_address, bb.addr_detail as c_addr_detail,	'
		SET @sql = @sql + '	bb.chk_DM,	'
		SET @sql = @sql + '	bb.chk_sms,	'
		--SET @sql = @sql + '	convert(varchar(10),bb.reg_date,112) as reg_date,	'
		SET @sql = @sql + '	convert(varchar(10),bb.smembership_reg_date,112) as smembership_reg_date,	'
		SET @sql = @sql + '	bb.umail,	'
		SET @sql = @sql + '	bb.chk_mailservice,	'
		SET @sql = @sql + '	bb.chk_aoi as chk_aoi,	'
		SET @sql = @sql + '	bb.chk_tpa as chk_tpa,	'
		SET @sql = @sql + '	''N'' as secession,	'
		SET @sql = @sql + '	convert(varchar(10),GETDATE(),112) as trans_date,	'
		SET @sql = @sql + '	(select COUNT(*) from SAMSUNG_DAILY_INFO where convert(varchar(10),reg_date_s,112)=	''' + @today + ''' and not wedd_year ='''' and convert(varchar(10),reg_date,112) >= ''20130701'') as total,	'
		--SET @sql = @sql + '	convert(varchar(10),bb.smembership_reg_date,112) as smembership_reg_date,	'
		SET @sql = @sql + '	convert(varchar(10),bb.reg_date,112) as reg_date,	'
		SET @sql = @sql + '	convert(varchar(10),bb.smembership_leave_date,112) as smembership_leave_date,	'
		SET @sql = @sql + '	convert(varchar(10),bb.mod_date,112) as mod_date,	'
		SET @sql = @sql + '	bb.chk_smembership,	'
		SET @sql = @sql + '	replace(convert(varchar(8),bb.smembership_reg_date,14),'':'','''') as smembership_reg_tm, '
		SET @sql = @sql + '	''Y'' as marketing1, '
		SET @sql = @sql + '	''Y'' as marketing2, '
		SET @sql = @sql + '	''Y'' as marketing3, '
		SET @sql = @sql + ' ISNULL(bb.smembership_period,''R'') '
		SET @sql = @sql + '	from SAMSUNG_DAILY_INFO bb	'
		SET @sql = @sql + '	where convert(varchar(10),bb.reg_date_s,112)=	''' + @today + ''' and not wedd_year ='''' and convert(varchar(10),reg_date,112) >= ''20130701'''
		SET @sql = @sql + '	and bb.smembership_leave_date is null'		
	END	
ELSE IF @type = '2'
	BEGIN 
		------ 부가정보리스트 ------	
		SET @sql = '	select bb.ConnInfo,	' 
		SET @sql = @sql + '	case	'
		SET @sql = @sql + '	when bb.site_div = ''SB'' then ''2'' 	'
		SET @sql = @sql + '	when bb.site_div = ''SS'' then ''4'' 	'
		SET @sql = @sql + '	when bb.site_div = ''N'' then ''1'' 	'
		SET @sql = @sql + '	when bb.site_div = ''Y'' then ''5'' 	'
		SET @sql = @sql + '	else ''3''	'
		SET @sql = @sql + '	end as site_div,	'
		SET @sql = @sql + '	bb.ugubun,	'
		SET @sql = @sql + '	bb.wedd_year + 	'
		SET @sql = @sql + '	case	'
		SET @sql = @sql + '	when len(bb.wedd_month) =''1'' then ''0''+bb.wedd_month	'
		SET @sql = @sql + '	when len(bb.wedd_month) =''2'' then bb.wedd_month	'
		SET @sql = @sql + '	else ''--''	'
		SET @sql = @sql + '	end	'
		SET @sql = @sql + '	+	'
		SET @sql = @sql + '	case	'
		SET @sql = @sql + '	when len(bb.wedd_day) =''1'' then ''0''+bb.wedd_day	'
		SET @sql = @sql + '	when len(bb.wedd_day) =''2'' then bb.wedd_day	'
		SET @sql = @sql + '	else ''--''	'
		SET @sql = @sql + '	end	'
		SET @sql = @sql + '	as weddday,	'
		SET @sql = @sql + '	case	'
		SET @sql = @sql + '	when bb.wedd_pgubun = ''W'' then ''A'' 	'
		SET @sql = @sql + '	when bb.wedd_pgubun = ''H'' then ''B'' 	'
		SET @sql = @sql + '	when bb.wedd_pgubun = ''M'' then ''C'' 	'
		SET @sql = @sql + '	when bb.wedd_pgubun = ''E'' then ''D'' 	'
		SET @sql = @sql + '	when bb.wedd_pgubun = ''C'' then ''E'' 	'
		SET @sql = @sql + '	else ''--''	'
		SET @sql = @sql + '	end as wedd_pgubun,	'
		SET @sql = @sql + '	convert(varchar(10),GETDATE(),112) as trans_date,	'
		SET @sql = @sql + '	(select COUNT(*) from SAMSUNG_DAILY_INFO where convert(varchar(10),reg_date_s,112)=	''' + @today + ''' and not wedd_year ='''' and convert(varchar(10),reg_date,112) >= ''20130701'') as total,	'
		--SET @sql = @sql + '	convert(varchar(10),bb.smembership_reg_date,112) as smembership_reg_date	'
		SET @sql = @sql + '	convert(varchar(10),bb.reg_date,112) as reg_date	'
		SET @sql = @sql + '	from SAMSUNG_DAILY_INFO bb	'
		SET @sql = @sql + '	where convert(varchar(10),bb.reg_date_s,112)=	''' + @today + ''' and not wedd_year ='''' and convert(varchar(10),reg_date,112) >= ''20130701'''	
		SET @sql = @sql + '	and bb.smembership_leave_date is null'	
		
	END
ELSE IF @type = '3'
	BEGIN 
	
		------ 선할인 정보 ------
		
		SET @sql = 'select conninfo as CUST_CI'
		SET @sql = @sql + ', site_gubun'
		SET @sql = @sql + ',left(convert(varchar(10),order_date,112) + replace(convert(varchar(10),order_date,24),'':'',''''),12) as ORDER_DATE'
		SET @sql = @sql + ',left(convert(varchar(10),settle_date,112) + replace(convert(varchar(10),settle_date,24),'':'',''''),12) as PAYMENT_DATE'
		SET @sql = @sql + ', '
		SET @sql = @sql + 'case	'
		SET @sql = @sql + 'when settle_status =''2'' then ''Y'''
		SET @sql = @sql + 'when settle_status =''3'' then ''N'''
		SET @sql = @sql + 'when settle_status =''5'' then ''N'''
		SET @sql = @sql + 'else ''N''	'
		SET @sql = @sql + 'end	as PAYMENT_YN'
		SET @sql = @sql + ', settle_price as PAYMENT_AMT'
		SET @sql = @sql + ', dacom_tid as PG_TID'
		SET @sql = @sql + ', order_seq as BHANDS_ORDERNO'
		SET @sql = @sql + ', discount_in_advance as DISCOUNT_YN'
		SET @sql = @sql + ', dbo.get_yorn_discount_date(seq) DISCOUNT_DATE '
		SET @sql = @sql + 'from [bar_shop1].[dbo].[SAMSUNG_DAILY_DISCOUNT]'
		SET @sql = @sql + 'where convert(varchar(10),reg_date_s,112)=	''' + @today + ''''
		SET @sql = @sql + '		and seq in '
		SET @sql = @sql + '('
		SET @sql = @sql + '	select ta.seqq from '
		SET @sql = @sql + '	('
		SET @sql = @sql + '	select distinct conninfo'
		SET @sql = @sql + '	, (select top 1 a.seq from [bar_shop1].[dbo].[SAMSUNG_DAILY_DISCOUNT] a where a.conninfo = b.conninfo and convert(varchar(10),a.reg_date_s,112)='''+ @today +''' order by a.seq desc) seqq'
		SET @sql = @sql + '	from [bar_shop1].[dbo].[SAMSUNG_DAILY_DISCOUNT] b '
		SET @sql = @sql + '	where'
		SET @sql = @sql + '	convert(varchar(10),reg_date_s,112)='''+ @today +''''
		SET @sql = @sql + '	) ta'
		SET @sql = @sql + ')'		
	
	END
ELSE

	select 2
	
	

EXEC sp_executesql @sql
--print @sql

GO
