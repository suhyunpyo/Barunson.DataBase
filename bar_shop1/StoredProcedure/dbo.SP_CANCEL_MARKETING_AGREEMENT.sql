IF OBJECT_ID (N'dbo.SP_CANCEL_MARKETING_AGREEMENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CANCEL_MARKETING_AGREEMENT
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
CREATE PROCEDURE [dbo].[SP_CANCEL_MARKETING_AGREEMENT] 
	@P_USER_ID VARCHAR(40),
	@P_ADMIN_ID VARCHAR(40)
AS
BEGIN

	DECLARE @uname NVARCHAR(20);
	DECLARE @conninfo VARCHAR(100);

	--BEGIN TRANSACTION;
	--SAVE TRANSACTION marketingAgreement;

	BEGIN TRY

		BEGIN TRANSACTION;
	
		/* 삼성 마케팅 동의 해지 관련 테이블 갱신 */
		INSERT INTO SAMSUNG_DELETE_MEMBER (
			CONNINFO,
			UID,
			UNAME,
			DELETE_SAMSUNG,
			DELETE_MARKETING,
			DELETE_LG,
			DELETE_DATE,
			DELETE_UID,
			DELETE_CUCKOO,
			DELETE_CASAMIA,
            DELETE_KT,
			DELETE_HYUNDAI --추가 
		)
		SELECT top 1 UI.ConnInfo, 
			@P_USER_ID AS UID, 
			UI.uname,
			CASE WHEN UI.smembership_reg_date IS NOT NULL THEN 'Y' ELSE 'N' END AS DELETE_SAMSUNG,
			CASE WHEN UI.mkt_chk_flag = 'Y' THEN 'Y' ELSE 'N' END AS DELETE_MARKETING,
			CASE WHEN UI.lgmembership_reg_date is not null then 'Y' else 'N' end as DELETE_LG,
			GETDATE() AS DELETE_DATE,
			@P_ADMIN_ID AS DELETE_UID,
			CASE WHEN UI.cuckoosship_reg_Date is not null then 'Y' else 'N' end as DELETE_CUCKOO,
			CASE WHEN UI.casamiaship_reg_Date is not null then 'Y' else 'N' end as DELETE_CASAMIA,
            CASE WHEN UI.KTMEMBERSHIP_REG_DATE is not null then 'Y' else 'N' end as DELETE_KT,
			CASE WHEN UI.HYUNDAIMEMBERSHIP_REG_DATE is not null then 'Y' else 'N' end as DELETE_HYUNDAI --추가 
		FROM S2_USERINFO_THECARD AS UI
			LEFT OUTER JOIN SAMSUNG_DAILY_INFO SDI
				ON UI.UID = SDI.uid
		WHERE UI.UID = @P_USER_ID 
		UNION 
		SELECT top 1 
			case when sdi.ConnInfo is not null then sdi.ConnInfo when sdi.ConnInfo is null and hl.P_SSN_CI is not null then hl.P_SSN_CI else @P_USER_ID end as ConnInfo
			, @P_USER_ID as uid
			, case when sdi.uname is not null then sdi.uname when sdi.uname is null and hl.P_CUST_NM is not null then hl.P_CUST_NM else null end as uname
			, case when sdi.smembership_reg_date is not null then 'Y' else 'N' end as DELETE_SAMSUNG
			, case when er.reg_date is not null then 'Y' else 'N' end as DELETE_MARKETING
			, case when hl.reg_date is not null then 'Y' else 'N' end as DELETE_LG
			, GETDATE() AS DELETE_DATE
			, @P_ADMIN_ID as DELETE_UID
			, case when er.reg_date is not null then 'Y' else 'N' end as DELETE_CUCKOO
			, case when cdi.create_date is not null then 'Y' else 'N' end as DELETE_CASAMIA
            , case when kdi.create_date is not null then 'Y' else 'N' end as DELETE_KT
			, case when hd.create_date is not null then 'Y' else 'N' end as DELETE_Hyundai --추가 
		FROM S2_UserBye ub
			LEFT OUTER JOIN SAMSUNG_DAILY_INFO SDI
				ON ub.UID = SDI.uid
			left outer join S4_Event_Raina er
				on ub.uid = er.uid
			left outer join S2_Userinfo_HiPlaza_Log hl
				on ub.uid = hl.uid
			left outer join CASAMIA_DAILY_INFO cdi
				on ub.uid = cdi.uid
            left outer join KT_DAILY_INFO kdi
                on ub.uid = kdi.uid
			/* 추가 */
			LEFT OUTER JOIN Hyundai_DAILY_INFO hd
                ON UB.UID = hd.UID

		WHERE
			ub.uid = @P_USER_ID;
		--ORDER BY seq DESC ;

		/* 회원 정보에서 마케팅 동의 갱신 */
		UPDATE S2_USERINFO SET
			smembership_leave_date = case when smembership_reg_date is not null then getdate() else null end ,
			chk_smembership_leave = case when smembership_reg_date is not null then 'Y' else null end,
			chk_smembership = 'N',
			mkt_chk_flag = 'N',
			chk_myomee = 'N',
			myomee_reg_date = null,
			chk_iloommembership = 'N'
			--,iloommembership_reg_date = null
			, chk_lgmembership = 'N'
			, lgmembership_leave_date = case when lgmembership_reg_date is not null then getdate() else null end
			, chk_cuckoosmembership = 'N'
			, cuckoosship_leave_date = case when cuckoosship_reg_Date is not null then getdate() else null end
			, chk_casamiamembership ='N'
			, casamiaship_leave_date = case when casamiaship_reg_Date is not null then getdate() else null end
            , CHK_KTMEMBERSHIP = 'N'
            , KTMEMBERSHIP_leave_date = case when KTMEMBERSHIP_REG_DATE is not null then getdate() else null end
			/* 추가 */
			, CHK_HYUNDAIMEMBERSHIP = 'N'
			, HYUNDAIMEMBERSHIP_LEAVE_DATE = CASE WHEN HYUNDAIMEMBERSHIP_LEAVE_DATE IS NOT NULL THEN GETDATE() ELSE NULL END
		WHERE UID = @P_USER_ID ;

		UPDATE S2_UserInfo_BHands SET
			smembership_leave_date = case when smembership_reg_date is not null then getdate() else null end ,
			chk_smembership_leave = case when smembership_reg_date is not null then 'Y' else null end,
			chk_smembership = 'N',
			mkt_chk_flag = 'N',
			chk_myomee = 'N',
			myomee_reg_date = null,
			chk_iloommembership = 'N'
			-- ,iloommembership_reg_date = null
			, chk_lgmembership = 'N'
			, lgmembership_leave_date = case when lgmembership_reg_date is not null then getdate() else null end
			, chk_cuckoosmembership = 'N'
			, cuckoosship_leave_date = case when cuckoosship_reg_Date is not null then getdate() else null end
			, chk_casamiamembership ='N'
			, casamiaship_leave_date = case when casamiaship_reg_Date is not null then getdate() else null end
            , CHK_KTMEMBERSHIP = 'N'
            , KTMEMBERSHIP_leave_date = case when KTMEMBERSHIP_REG_DATE is not null then getdate() else null end

			/* 추가 */
			, CHK_HYUNDAIMEMBERSHIP = 'N'
			, HYUNDAIMEMBERSHIP_LEAVE_DATE = CASE WHEN HYUNDAIMEMBERSHIP_LEAVE_DATE IS NOT NULL THEN GETDATE() ELSE NULL END

		WHERE UID = @P_USER_ID ;

		UPDATE S2_UserInfo_TheCard SET
			smembership_leave_date = case when smembership_reg_date is not null then getdate() else null end ,
			chk_smembership_leave = case when smembership_reg_date is not null then 'Y' else null end,
			chk_smembership = 'N',
			mkt_chk_flag = 'N',
			chk_myomee = 'N',
			myomee_reg_date = null,
			chk_iloommembership = 'N'
			--,iloommembership_reg_date = null
			, chk_lgmembership = 'N'
			, lgmembership_leave_date = case when lgmembership_reg_date is not null then getdate() else null end
			, chk_cuckoosmembership = 'N'
			, cuckoosship_leave_date = case when cuckoosship_reg_Date is not null then getdate() else null end
			, chk_casamiamembership ='N'
			, casamiaship_leave_date = case when casamiaship_reg_Date is not null then getdate() else null end
            , CHK_KTMEMBERSHIP = 'N'
            , KTMEMBERSHIP_leave_date = case when KTMEMBERSHIP_REG_DATE is not null then getdate() else null end

			/* 추가 */
			, CHK_HYUNDAIMEMBERSHIP = 'N'
			, HYUNDAIMEMBERSHIP_LEAVE_DATE = CASE WHEN HYUNDAIMEMBERSHIP_LEAVE_DATE IS NOT NULL THEN GETDATE() ELSE NULL END

		WHERE UID = @P_USER_ID ;

		/* 마케팅 동의 약관 동의 내역에서 삭제 */
		DELETE FROM S4_Event_Raina WHERE UID = @P_USER_ID;

		DELETE FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT WHERE UID = @P_USER_ID ;

		/* 이벤트 마케팅 동의 삭제 */
		DELETE FROM EVENT_MARKETING_AGREEMENT WHERE UID = @P_USER_ID ;

		/* 마케팅 동의 로그에서 갱신 */
		UPDATE S4_MARKETING_AGREEMENT_LOG SET
			DEL_DATE = GETDATE()
		WHERE UID = @P_USER_ID ;
	
		/*	LG제휴 동의 로그에서 갱신 */
		UPDATE S2_Userinfo_HiPlaza_Log SET
			cancel_date = GETDATE()
		WHERE UID = @P_USER_ID;
		/*
		UPDATE SAMSUNG_DELETE_MEMBER SET
			DELETE_LG = (SELECT CASE WHEN lgmembership_reg_date is not null then 'Y' else 'N' end FROM S2_UserInfo_TheCard WHERE UID = @P_USER_ID)
		WHERE UID = @P_USER_ID;
		*/	

		COMMIT TRANSACTION ;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            --ROLLBACK TRANSACTION marketingAgreement; -- rollback to MySavePoint
            ROLLBACK
        END
    END CATCH


END
GO
