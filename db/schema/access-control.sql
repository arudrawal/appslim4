-- FOUR NEW TABLES
-- Activities translates into set of screens in application.
-- Complete list of activities:
-- Profile Types: Investigator, Reviewer, Review Admin, Sponsor, Monitor, Admin
-- Investigator: Add/edit Subject (1), Add Visit(2), View Forms(3), Edit Forms(), Record Audio(4),
--               Play Audio(), Record Video(6), Play Video (), AnswerQ(7)
-- AssignReview(8),ReviewVisitAskQSignOff(9)
CREATE TABLE `cta_activities` (
	`activity_num`			INTEGER,
	`description`		        TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(activity_num)
);
-- This table stored list of fixed role types.
-- Each role type translates into a application flow.
-- Admin, Inv, Review Admin, Reviewer, Sponsor
CREATE TABLE `cta_profiles` (
	`profile_num`		    INTEGER,
	`profile_name`			TEXT,
	`description`		        TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(profile_num)
);
-- Access profile definition
-- Profile contains access permission for multiple activities
-- access - 0=no access, 1=read-only, 2=read-write
CREATE TABLE `cta_profile_access` (
	`profile_num`			INTEGER,
	`activity_num`			INTEGER,
	`access_level`			INTEGER,
	`version_date_time`		TEXT,
	`version_number`		INTEGER DEFAULT 1,
	PRIMARY KEY(`profile_num`, `activity_num`)
);
--
-- Access level will be equal or less than model profile.
--
CREATE TABLE `cta_role_access` (
	`role_num`				INTEGER,
	`activity_num`			INTEGER,
	`access_level`			INTEGER,
	`profile_num`			INTEGER,
	`version_date_time`		TEXT,
	`version_number`		INTEGER DEFAULT 1,
	PRIMARY KEY(`role_num`, `activity_num`)
);
-- MODIFIED TABLE
-- Role numbers are describes in this table
-- Role class: Investigator, Reviewer, Sponsor, CRO, Admin.
-- Class decided set of activities user is allowed to do.
-- i.e.
-- Investigator: add/edit subject, add/del unplanned visit, conduct interview, answer question.
-- Reviewer: Assign Review, Review, Sign-off, Create Opinion Open, Create Opinion Blind.
-- Sponsor: read-only mode of Reviewer+Investigator.
-- CRO - read-only mode of Reviewer+Investigator. CRA-Monitor (Sign off - optional)
-- Admin - Prepare study.
-- RoleName - could be Project Manager, Project Leader etc.
-- Access Profile should point to a matrix of access list.
CREATE TABLE `cta_role` (
	`role_num`		    INTEGER,
	`role_name`		    TEXT,
	`profile_num`	    INTEGER DEFAULT 0,
	`description`	    TEXT,
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_gmt_offset`	INTEGER DEFAULT 0,
	`updated_by_user`			TEXT,
	`updated_by_client_uuid`	TEXT,
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(role_num)
	);
-- user-study-role-map - created by server and user by clients.
-- role_blinded - user not aware of
CREATE TABLE `cta_map_user_study_role` (
    `user_code`				VARCHAR(64),
	`study_num`				INTEGER,
	`role_num`				INTEGER,
	`profile_num`			INTEGER DEFAULT 0,
	`role_blinded`			INTEGER DEFAULT 0,
	`record_lock`			INTEGER DEFAULT 0,
	`updated_ts_gmt`		INTEGER,
	`updated_gmt_offset`	INTEGER,
	`updated_by_user`			TEXT,
	`updated_by_client_uuid`	TEXT,
	`updated_date_time`			TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY			(user_code, study_num, role_num)
);
