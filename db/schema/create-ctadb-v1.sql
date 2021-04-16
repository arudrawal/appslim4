--
-- Create CTA database version=1
-- Create a local hash table entry to keep track of database creation and sync time.
--
-- CURRENT_TIME Inserts only time
-- CURRENT_DATE Inserts only date
-- CURRENT_TIMESTAMP  Inserts both time and date
-- 1.2 Date and Time Datatype
--
-- SQLite does not have a storage class set aside for storing dates and/or times.
-- Instead, the built-in Date And Time Functions of SQLite are capable of storing dates
-- and times as TEXT, REAL, or INTEGER values:
-- TEXT as ISO8601 strings ("YYYY-MM-DD HH:MM:SS.SSS").
-- REAL as Julian day numbers, the number of days since noon in Greenwich on November 24, 4714 B.C. according to the proleptic Gregorian calendar.
-- INTEGER as Unix Time, the number of seconds since 1970-01-01 00:00:00 UTC.
-- 
-- updated_ts_gmt = store as miliseconds (MySql needs to BIGINT)
-- updated_gmt_offset = Store GMT offset in miliseconds (MySql needs to BIGINT).

START TRANSACTION;

-- Audit log stores changes to table->column.
-- Each log needs a unique id - this can be only stored in server side
-- We may not be concerned about the changes in a local sandbox.
-- We implement entry in this table on server side - when changes are received.
CREATE TABLE `audit_log` (
  `audit_log_uuid` 		VARCHAR(32),
  `table_name`          TEXT,
  `column_name` 		TEXT,
  `old_value`           TEXT,
  `new_value`           TEXT,
  `created_by_user`     VARCHAR(64),
  `updated_ts_gmt` 		INTEGER DEFAULT 0,
  `updated_gmt_offset` 	INTEGER DEFAULT 0,
  `updated_by_user`     VARCHAR(64),
  `updated_by_client_uuid`     VARCHAR(32),
  `updated_date_time` 	TEXT,
  `updated_comment`     TEXT,
  `version_date_time`		TEXT,
  `version_number`			INTEGER DEFAULT 1,
  PRIMARY KEY(audit_log_uuid)
);
-- Record device status, every 10 minutes
-- Device Info - extra device identifiers (WifiMAC/IP/Serial)
-- Status: Charge Level, Charging[Y/N], WiFi-Status,Server-Access
--         SD-Card (Mounted or not), INT/EXT - space available.
-- This table is only uploaded from device, not shared with other
-- devices in the group.
--CREATE TABLE `client_device_log` (
--  `client_device_uuid` 		VARCHAR(32),
--  `updated_ts_gmt` 		INTEGER,
--  `updated_date_time` 	TEXT,
--  `device_info` 		TEXT,
--  `log_level` 			TEXT,
--  `log_message` 		TEXT
--);

-- This is generic log file of each device.
-- Application can log important events on the device.
-- Specially events not captured in database,
-- Like: interview started, recording is turned on.
--       Power charger is connected.
-- Table has prefix of client not cta. This is uploaded
-- by client to server and not shared with other clients.
-- This log can grow too big, should be purged from device
-- on regular basis, however should not be purged from server.
-- Only insert should be upload to server, edit/delete should not.
-- This table should not have any key.
-- Date/Time format : yyyy-MM-dd'T'HH:mm:ss.SSSZ 1969-12-31T16:00:00.000-0800
CREATE TABLE `client_syslog` (
  `client_device_uuid` 	VARCHAR(32),
  `updated_ts_gmt`		INTEGER,
  `updated_date_time` 	TEXT,
  `priority` 			INTEGER,
  `source` 				TEXT,
  `json_id` 			TEXT,
  `message` 			TEXT,
  `version_date_time`		TEXT,
  `version_number`			INTEGER DEFAULT 1,
  PRIMARY KEY(client_device_uuid, updated_ts_gmt)
);
-- Activities translates into set of screens in application.
-- Complete list of activities:
-- Profile Types: Investigator, Reviewer, Review Admin, Sponsor, Monitor, Admin
-- Investigator: Add/edit Subject (1), Add Visit(2), View Forms(3), Edit Forms(), Record Audio(4),
--               Play Audio(), Record Video(6), Play Video (), AnswerQ(7)
-- AssignReview(8),ReviewVisitAskQSignOff(9)
--CREATE TABLE `cta_activities` (
--	`activity_num`			INTEGER,
--	`description`		        TEXT,
--	`version_date_time`			TEXT,
--	`version_number`			INTEGER DEFAULT 1,
--	PRIMARY KEY(activity_num)
--);

-- Field: form_num=2, form_section'panss.html' form_qnum=1, description=were you ever depressed ...?
-- type: boolean (yes/no), number, entry-text.
-- Needed to show logs with question reference.
CREATE TABLE `cta_available_form_question` (
	`form_num`			INTEGER,
	`form_section`	    VARCHAR(64),
	`form_qnum`			INTEGER,
	`qlabel`			TEXT,
	`qtext`		        TEXT,
	`ans_type`			TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(form_num, form_section, form_qnum)
);
-- Single section form form_name==section_name
-- Section: name:A, description=Major Depressive Episode
-- section_file='panss.html' - proper section display in log.
CREATE TABLE `cta_available_form_section` (
	`form_num`			INTEGER,
	`form_section`	    VARCHAR(64),
	`name`	            TEXT,
	`description`		TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(form_num, form_section)
);
--
-- List of implemented forms (Annotated list of forms)
--
CREATE TABLE `cta_available_forms` (
	`form_num`			INTEGER,
	`form_name`			TEXT,
	`description`		TEXT,
	`media_recording`	INTEGER,
	`prereq_form_list`	TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(form_num)
);

--
-- List of countries used by system.
--
CREATE TABLE `cta_country` (
	`country_num`		INTEGER,
	`country_code`		TEXT,
	`country_name`		TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(country_num)
);

--
-- device_reg -  not needed in Android
--

-- Data stored per question basis (one record per question)
-- Each question will be reviewed by multiple reviewers
-- Review Status in this table is not required, 
-- review status can be calculated based on reviewers table
-- Leaving this field here for time-being. In any case we must make
-- sure that no other than investigator can write to this table.
-- Recording markers: if audio/video is recorded,
-- we have to record the time offset in the recording
-- if no recording is going on still we should record
-- when user is clicking which answer compared to start
-- time. this will allow us to record some statistics,
--  like: how much time a scale usually takes.
-- review_status - is unused field.
CREATE TABLE `cta_form_data` (
	`subject_uuid`				VARCHAR(32),
	`subject_visit_uuid`		VARCHAR(32),
	`form_num`					INTEGER,
	`form_section`			    VARCHAR(64),
	`form_qnum`					INTEGER,
	`form_data_ans`				TEXT,
	`form_data_note`			TEXT,		
	`review_status`				TEXT,
	`media_file_name`			VARCHAR(128),
	`media_time_offset`			INTEGER DEFAULT 0,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(subject_uuid, subject_visit_uuid, form_num, form_section, form_qnum)
	);
-- Table-9
-- Create history of form data changes as per HIPAA requirements.
-- Update comment will record the reason for change in this table.
-- Old value JSON Object - record old value/note/device/update-date-time.
-- History could be used to deduct the visit date/time - earliest update
-- to any question.
--review_status-unused filed came as-is from data.
CREATE TABLE `cta_form_data_history` (
	`subject_uuid`				VARCHAR(32),
	`subject_visit_uuid`		VARCHAR(32),
	`form_num`					INTEGER,
	`form_section`				VARCHAR(64),
	`form_qnum`					INTEGER,
	`form_data_ans`				TEXT,
	`form_data_note`			TEXT,
	`review_status`				TEXT,		
	`media_file_name`			VARCHAR(128),
	`media_time_offset`			INTEGER DEFAULT 0,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,
	`protocol_visit_num`		INTEGER,
	`json_text_old_value`		TEXT,
	PRIMARY KEY(subject_uuid, subject_visit_uuid, form_num,
				form_section, form_qnum, updated_ts_gmt)	
	);

--
-- Table-10
-- Queries are raised by multiple reviewers
-- We may not want to show queries from 
-- one reviewer to other. Investigator will see 
-- and respond to all queries.
-- Purpose of Q/A back forth is to get agreement on
-- the answer to the form question by investigator.
-- This will result is approval by reviewer or
-- change of answer by investigator and eventually
-- Review completed by reviewer. 
CREATE TABLE `cta_form_data_query` (
	`subject_uuid`				VARCHAR(32),
	`subject_visit_uuid`		INTEGER,
	`form_num`					INTEGER,
	`form_section`				VARCHAR(64),
	`form_qnum`					INTEGER,			
	`form_query`				TEXT,
	`user_code_reviewer`		VARCHAR(64),
	`query_ts_gmt`				INTEGER,	
	`query_date_time`			TEXT,	
	`query_client_uuid`			VARCHAR(32),
	`form_reply`				TEXT,
	`reply_by_user`				VARCHAR(64),
	`reply_ts_gmt`				INTEGER DEFAULT 0,	
	`reply_date_time`			TEXT,	
	`reply_client_uuid`			VARCHAR(32),
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(subject_uuid, subject_visit_uuid, form_num,
				form_section, form_qnum, user_code_reviewer, query_ts_gmt)
	);

-- -- Table-11
-- Form data is reviewed question-by-question. All differences
-- of opinion has to be hashed out. Reviewer creates his own
-- copy for side-by-side comparison and to calculate difference
-- in score. Could also be a blind review opinion based on
-- audio and notes only.
-- review_status - per question question basis - may be not required.
-- question status will be agree/disagree - can be derived by comparision.
CREATE TABLE `cta_form_data_review` (
	`subject_uuid`				VARCHAR(32),
	`subject_visit_uuid`		VARCHAR(32),
	`form_num`					INTEGER,
	`form_section`				VARCHAR(64),
	`form_qnum`					INTEGER,
	`user_code_reviewer`		VARCHAR(64),
	`form_data_ans`				TEXT,
	`form_data_note`			TEXT,
	`review_status`			    TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(subject_uuid, subject_visit_uuid, form_num,
		    form_section, form_qnum, user_code_reviewer)
	);

--
-- Table-12
-- Audio/Video recording for a form. This is optional for some forms
-- Audio start/end time and date/time of recording are main data to collect
-- Audio recording is a sure way to tell on what date visit is conducted.
-- file_uploaded - uploaded to server - used for automatic upload.
--                 and allow us to control delete/upload actions.
CREATE TABLE `cta_form_media` (
	`subject_uuid`				VARCHAR(32),
	`subject_visit_uuid`		VARCHAR(32),
	`form_num`					INTEGER,
	`media_file_name`			VARCHAR(128),
	`start_ts_gmt`				INTEGER DEFAULT 0,
	`end_ts_gmt`				INTEGER DEFAULT 0,
	`file_uploaded`				INTEGER DEFAULT 0,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`			TEXT,
    `version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(subject_uuid, subject_visit_uuid, form_num, media_file_name)
	);
--
-- T13 Monitor review form for completeness
--
CREATE TABLE `cta_form_monitor` (
	`subject_uuid`				VARCHAR(32),
	`subject_visit_uuid`		VARCHAR(32),
	`form_num`					INTEGER,
	`monitor_status`			TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(subject_uuid, subject_visit_uuid, form_num, updated_by_user)
	);
-- T14 Reviews are performed form by form basis by reviewer.
-- These records are populated when reviewer sign-off a form review.
-- Default form status=review-pending(4) from reviewers' perspective.
-- Possible values for form status are:
-- Review-Pending, Accepted, Bypassed, Rejected, Inconclusive. Review status are
-- subset of form-status in general. Must be stored as integer.
-- Multiple reviews are possible for a form, reviewer is also part of the key.
--
CREATE TABLE `cta_form_review` (
	`subject_uuid`				    VARCHAR(32),
	`subject_visit_uuid`			VARCHAR(32),
	`form_num`					    INTEGER,
	`user_code_reviewer`	        VARCHAR(64),
	`form_status_num`			    INTEGER DEFAULT 4,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(subject_uuid, subject_visit_uuid, form_num, user_code_reviewer)
	);

-- Table 15 - Form Status
CREATE TABLE `cta_form_status` (
	`form_status_num`		INTEGER,
	`form_status_name`      TEXT,
	`description`			TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(form_status_num)
	);

CREATE TABLE `cta_language` (
	`lang_num`		INTEGER,
	`lang_code`		        TEXT,
	`lang_name`		        TEXT,
	`description`	        TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		TEXT,
    `version_number`		INTEGER DEFAULT 1,
	PRIMARY KEY(lang_num)
);
--
-- study-site-map - created by server and user by clients.
--
CREATE TABLE `cta_map_study_site` (
	`study_num`				INTEGER,
	`site_num`				INTEGER,
	`updated_ts_gmt`		INTEGER,
	`updated_gmt_offset`	INTEGER,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY			(study_num,site_num)
);
--
-- user-study-role-map - created by server and user by clients.
-- role_blinded - user not aware of
/* CREATE TABLE `cta_map_user_study_role` (
    `user_code`				VARCHAR(64),
	`study_num`				INTEGER,
	`role_num`				INTEGER,
	`profile_num`			INTEGER DEFAULT 0,
	`role_blinded`			INTEGER DEFAULT 0,
	`record_lock`			INTEGER DEFAULT 0,
	`updated_ts_gmt`		INTEGER,
	`updated_gmt_offset`	INTEGER,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY			(user_code, study_num, role_num)
); */
-- user-study-site-map - created by server and user by clients.
-- record_lock: 0=read-write, 1=read-only, 2=no-access
CREATE TABLE `cta_map_user_study_site` (
    `user_code`			VARCHAR(64),
	`study_num`			INTEGER,
	`site_num`			INTEGER,
	`record_lock`		INTEGER DEFAULT 0,
	`updated_ts_gmt`	INTEGER,
	`updated_gmt_offset`	INTEGER,
	`updated_by_user`		VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`		    TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY			(user_code, study_num, site_num)
);

-- user_code is key in this table.
-- client device updated password, server will be synchronized
-- Last change should win in case of conflict.
CREATE TABLE `cta_password` (
	`user_code`			VARCHAR(64),
	`password_digest`	TEXT,
	`auto_password`		TEXT DEFAULT NULL,
	`autogen_flag`		INTEGER DEFAULT 0,
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_gmt_offset`	INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64) DEFAULT NULL,
	`updated_by_client_uuid`	VARCHAR(32) DEFAULT NULL,
	`updated_date_time`			TEXT DEFAULT NULL,
    `version_date_time`		    TEXT DEFAULT NULL,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(user_code)
);

-- user_code+updated_by_client_uuid+updated_ts_gmt+)is key in this table.
-- If modified from web (SRC=ServerMac)
-- Table key should ensure no conflict while synchronizing with server from multiple devices.
-- Address change conflict from multiple devices, make application UUID part of key.
-- Also need to use GMT time stamp (good if in Milliseconds - to avoid back-forth in time)
-- Also if clock settings are not reliable, good to generate a sequence number for device.
CREATE TABLE `cta_password_history` (
	`user_code`			VARCHAR(64),
    `password_digest`	TEXT,
    `auto_password`		TEXT,
    `autogen_flag`		INTEGER,
    `updated_ts_gmt`		INTEGER DEFAULT 0,
    `updated_gmt_offset`	INTEGER DEFAULT 0,
    `updated_by_user`			VARCHAR(64),
    `updated_by_client_uuid`	VARCHAR(32),
    `updated_date_time`			TEXT,
    `version_date_time`		    TEXT,
    `version_number`			INTEGER DEFAULT 1,
    PRIMARY KEY(user_code,updated_by_client_uuid, updated_ts_gmt)
);
-- Store configurable parameters
-- Policy id has a fixed interpretation in the application code
-- This is like global configuration variable.
-- For example: password expires in 90 days.
-- ID=1, value=90
-- Android device Blue-tooth should be always off.
-- ID=2, values=0(off).
-- Android device should be encrypted(1), okay if not encrypted(0).
-- ID=3, values=1
CREATE TABLE `cta_policy`
(
	`policy_id` INTEGER NOT NULL,
	`policy_name`       TEXT,
	`policy_type`       TEXT,
	`policy_value`      TEXT ,
	`description`       TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY (policy_id)
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

--
-- PRIMARY KEY(user_code, updated_ts_gmt, updated_by_client_uuid)
--
CREATE TABLE `cta_protocol` (
	`protocol_num`		INTEGER,
	`protocol_code`		TEXT,
	`protocol_revision`	TEXT,
	`draft_date`		TEXT,
	`phase`				TEXT,
	`medical_product`	TEXT,
	`sponsor_num`	    INTEGER,
	`description`		TEXT,
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_gmt_offset`	INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
    `version_date_time`		TEXT,
    `version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(protocol_num)
);
CREATE TABLE `cta_protocol_form` (
	`protocol_num`				INTEGER,
	`protocol_visit_num`		INTEGER,
	`form_num`					INTEGER,
	`protocol_form_order_num`	INTEGER,
	`updated_ts_gmt`			INTEGER,
	`updated_gmt_offset`		INTEGER,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(protocol_num, protocol_visit_num, form_num)
);

-- some rules like min-age, max-age
-- Rule number must be fixed. Rules will be enforced by code.
-- Meaning of the rule has to be known in advance.
-- Can't create rules in advance and expect it to work.
-- We need name, value pair kind of rules. Like MinAge=18, MaxAge=70
-- Gender=0 (no rule), 1=MaleOnly, 2=FemaleOnly, 3=BothAllowed
CREATE TABLE `cta_protocol_rule` (
	`protocol_rule_num`		INTEGER,
	`protocol_num`		INTEGER,
	`protocol_rule`		TEXT,
	`protocol_rule_value`	TEXT,
	`protocol_rule_desc`		TEXT,
	`created_by_user`		VARCHAR(64),
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(protocol_rule_num, protocol_num)
);
-- We have to either implement Q/A engine based on these rules.
-- OR implement scales and allow protocol designer to add thit to first visit.
--
CREATE TABLE `cta_protocol_screening_question`
(
	`protocol_screening_qnum` INTEGER,
	`protocol_num`		    INTEGER,
	`question_category`     TEXT,
	`question`              TEXT,
	`question_data_type`    TEXT
	`created_by_user`		VARCHAR(64),
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY (protocol_screening_qnum, protocol_num)
);


-- Store configurable parameters
--CREATE TABLE `cta_hash_table` (
--  `var_name` 	TEXT,
--  `var_value` 	TEXT,
--  `var_type` 	TEXT,
--  `description` 		TEXT,
--  PRIMARY KEY (var_name)
--);



-- Table-26
-- time-unit - days, hours
-- visit_type= Protocol Defined Visit=0,
-- Unplanned Visit=1,Closure Visit=2
-- time_ref_visit_num =0 means this visit is a reference visit itself.
--                    1..n (points to reference visit within the visit list)
--                       n should be always refer to visit prior to this visit.
--                       n must be less than its own visit number.
-- time_after_ref: these many days/hours after reference visit
-- time_unit: HH:DD:MM
CREATE TABLE `cta_protocol_visit` (
	`protocol_num`				INTEGER,
	`protocol_visit_num`		INTEGER,
	`visit_type`				INTEGER,
	`visit_name`				TEXT,
	`description`				TEXT,
	`time_ref_visit_num`		INTEGER,
	`time_after_ref`			INTEGER,
	`time_plus_variance`		INTEGER,
	`time_minus_variance`		INTEGER,
	`time_unit`					TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(protocol_num, protocol_visit_num)
);

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
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(role_num)
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

-- site - created by server and user by clients.
CREATE TABLE `cta_site` (
	`site_num`		INTEGER NOT NULL,
	`site_code`		TEXT,
	`site_name`		TEXT,
	`address`		TEXT,
	`department`	TEXT,
	`city`			TEXT,
	`state`			TEXT,
	`country_num`		INTEGER DEFAULT 0,
	`site_gmt_offset`	INTEGER DEFAULT 0,
	`phone`			TEXT,
	`email`			TEXT,
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_gmt_offset`	INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY			(site_num)
);


-- Capture Sponsor name and contact details
-- Database will have one sponsor almost always.
-- Sponsors are competitors and study data is never shared in real world.
--
CREATE TABLE `cta_sponsor` (
  `sponsor_num` 		INTEGER,
  `sponsor_code` 		TEXT,
  `sponsor_name` 		TEXT,
  `version_date_time`	TEXT,
  `version_number`		INTEGER DEFAULT 1,
  PRIMARY KEY(sponsor_num)
);
--
-- Multiple contacts - Sponsor
--
CREATE TABLE `cta_sponsor_contact` (
  `sponsor_num` 		INTEGER,
  `contact_num` 		INTEGER,
  `contact_name` 	    TEXT,
  `address` 	        TEXT,
  `tel1` 	            TEXT,
  `tel2` 	            TEXT,
  `mob1` 	            TEXT,
  `mob2` 	            TEXT,
  `fax1` 	            TEXT,
  `fax2` 	            TEXT,
  `email1` 	        TEXT,
  `email2` 	        TEXT,
  `updated_ts_gmt`			INTEGER DEFAULT 0,
  `updated_gmt_offset`		INTEGER DEFAULT 0,
  `updated_by_user`			VARCHAR(64),
  `updated_by_client_uuid`	VARCHAR(32),
  `updated_date_time`		TEXT,
  `version_date_time`		TEXT,
  `version_number`			INTEGER DEFAULT 1,
  PRIMARY KEY(sponsor_num, contact_num)
);


-- User Classes are fixed for a version of application
-- New class involves implementation of new code.
-- Investigator, Reviewer, Sponsor, CRO, Admin
--CREATE TABLE `cta_user_class` (
--	`class_num`				INTEGER,
--	`class_name`		    INTEGER,
--	`description`		    TEXT
--	`version_date_time`			TEXT,
--	`version_number`			INTEGER DEFAULT 1,
--);


-- For each class of user there is list of activities.
-- Define classes of users.

-- Table-31
-- study - created by server and user by clients.
CREATE TABLE `cta_study` (
	`study_num`		INTEGER,
	`protocol_num`		INTEGER,
	`study_code`		TEXT,
	`study_status_num`	INTEGER,
	`description`		TEXT,	
	`start_date`		TEXT,
	`end_date`			TEXT,	
	`updated_ts_gmt`	INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY			(study_num)
);
-- Table-32
CREATE TABLE `cta_study_status` (
	`study_status_num`		INTEGER,
	`study_status_name`		TEXT,
	`description`			TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(study_status_num)
	);

-- IF UUID is not used than key will be:
--  Study->Country->Site->subject_num.
-- server should calculate subject code
CREATE TABLE `cta_subject` (
	`subject_uuid`			VARCHAR(32) NOT NULL,
	`study_num`				INTEGER DEFAULT 0,
	`country_num`			INTEGER DEFAULT 0,
	`site_num`				INTEGER DEFAULT 0,
	`subject_num`			INTEGER DEFAULT 0,
	`subject_code`			TEXT DEFAULT NULL,

	`subject_code1`			TEXT DEFAULT NULL,
	`subject_code1_name`	TEXT DEFAULT NULL,
	`subject_code2`			TEXT DEFAULT NULL,
	`subject_code2_name`	TEXT DEFAULT NULL,

	`initials`				TEXT DEFAULT NULL,
	`gender`				TEXT DEFAULT NULL,
	`dob`					TEXT DEFAULT NULL,
	`dob_approximate`		INTEGER DEFAULT 0,
	`dob_unavailable`		INTEGER DEFAULT 0,
	`date_enrolled`			TEXT DEFAULT NULL,

	`subject_status_num`	INTEGER DEFAULT 0,
	`record_lock`			INTEGER DEFAULT 0,

	`created_by_user`		VARCHAR(64) DEFAULT NULL,
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_gmt_offset`	INTEGER DEFAULT 0,
	`updated_by_user`		VARCHAR(64) DEFAULT NULL,
	`updated_by_client_uuid`	VARCHAR(32) DEFAULT NULL,
	`updated_date_time`			TEXT DEFAULT NULL,
	`updated_comment`			TEXT DEFAULT NULL,

	`version_date_time`			TEXT DEFAULT NULL,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(subject_uuid)
	);

--
-- Table-35 owner is investigator who updated the form first time.
-- Must record time-stamp when owner was designated - this also
-- gives a clue that when a visit was started. If audio is recorded
-- Earliest audio record is the visit start date/time.
-- We need to derive visit start time to predict date for future visits.
--
CREATE TABLE `cta_subject_form` (
	`subject_uuid`				VARCHAR(32),
	`subject_visit_uuid`		VARCHAR(32),
	`form_num`					INTEGER DEFAULT 0,
	`subject_form_order_num`	INTEGER DEFAULT 0,
	`study_num`                 INTEGER DEFAULT 0,
	`form_status_num`			INTEGER DEFAULT 0,
	`form_owner`			    TEXT DEFAULT NULL,
	`form_owner_updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64) DEFAULT NULL,
	`updated_by_client_uuid`	VARCHAR(32) DEFAULT NULL,
	`updated_date_time`			TEXT DEFAULT NULL,
	`updated_comment`			TEXT DEFAULT NULL,
	`version_date_time`			TEXT DEFAULT NULL,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(subject_uuid, subject_visit_uuid, form_num)
	);
-- Table-36
CREATE TABLE `cta_subject_history` (
	`subject_uuid`			VARCHAR(32) NOT NULL,
	`study_num`				INTEGER DEFAULT 0,
	`country_num`			INTEGER DEFAULT 0,
	`site_num`				INTEGER DEFAULT 0,
	`subject_num`			INTEGER DEFAULT 0,
	`subject_code`			TEXT DEFAULT NULL,

	`subject_code1`			TEXT DEFAULT NULL,
	`subject_code1_name`	TEXT DEFAULT NULL,
	`subject_code2`			TEXT DEFAULT NULL,
	`subject_code2_name`	TEXT DEFAULT NULL,

	`initials`				TEXT DEFAULT NULL,
	`gender`				TEXT DEFAULT NULL,
	`dob`					TEXT DEFAULT NULL,
	`dob_approximate`		INTEGER DEFAULT 0,
	`dob_unavailable`		INTEGER DEFAULT 0,
	`date_enrolled`			TEXT DEFAULT NULL,

	`subject_status_num`	INTEGER DEFAULT 0,
	`record_lock`			INTEGER DEFAULT 0,

	`created_by_user`		VARCHAR(64) DEFAULT NULL,
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_gmt_offset`	INTEGER DEFAULT 0,
	`updated_by_user`		VARCHAR(64) DEFAULT NULL,
	`updated_by_client_uuid`	VARCHAR(32) DEFAULT NULL,
	`updated_date_time`			TEXT DEFAULT NULL,
	`updated_comment`			TEXT DEFAULT NULL,

	`version_date_time`			TEXT DEFAULT NULL,
	`version_number`			INTEGER DEFAULT 1,
	`json_text_old_value`		TEXT DEFAULT NULL,
	PRIMARY KEY(subject_uuid,updated_by_client_uuid,updated_ts_gmt)
	);


-- Must be revisit
-- T34
CREATE TABLE `cta_subject_screening_answer`
(
	subject_screening_anum INTEGER,
	protocol_screening_qnum INTEGER,
	protocol_num INTEGER,
	answer TEXT,
	`created_by_user`		VARCHAR(64),
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_gmt_offset`	INTEGER DEFAULT 0,
	`updated_by_user`		VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY (subject_screening_anum, protocol_screening_qnum, protocol_num)
);

-- Table-37
CREATE TABLE `cta_subject_status` (
	`subject_status_num`	INTEGER,
	`subject_status_code`	TEXT,
	`description`			TEXT,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(subject_status_num)
);
-- Table-38
-- Visit can be locked once review is completed by review admin.
-- visit_lock_ts_gmt=0 - not locked, !=0 GMT when visit is locked.
-- Once locked - no more changes possible.
-- visit_status_num - must be calculated summary of Form status
-- form_status_num - summary of all forms - calculated values
-- No need to store status values. However good if filled
-- and returned to UI in JSON format along with the record.
-- subject_visit_uuid: must be assigned by the device record is added.
-- subject_visit_num: a serial number calculated by server.
CREATE TABLE `cta_subject_visit` (
	`subject_uuid`				VARCHAR(32) NOT NULL,
	`subject_visit_uuid`		VARCHAR(32) NOT NULL,
	`subject_visit_num`			INTEGER DEFAULT 0,
	`visit_serial_num`			INTEGER DEFAULT 0,

	`study_num`                 INTEGER DEFAULT 0,
	`protocol_num`		        INTEGER DEFAULT 0,
	`protocol_visit_num`		INTEGER DEFAULT 0,

	`visit_status_num`			INTEGER DEFAULT 0,
	`record_lock`			    INTEGER DEFAULT 0,
	`visit_start_ts_gmt`		INTEGER DEFAULT 0,
	`visit_end_ts_gmt`			INTEGER DEFAULT 0,

	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(subject_uuid, subject_visit_uuid)
	);
-- Table-39
-- Visits will be assigned to reviewer by review administrator.
-- We have to keep track of review dead-line, record time info.
-- Reviewer may agree with investigator assessment and approve
-- whole visit with one command from here.
-- Other way out is when all questions are reviewed and approved
-- approval of a visit can be derived from answers.
-- Approval can be top->down, down->top.
-- All forms are automatically assigned for review with visit.
--
--CREATE TABLE `cta_subject_form_review` (
--	`subject_uuid`				TEXT,
--	`subject_visit_uuid`		VARCHAR(32),
--	`form_num`					INTEGER,
--	`subject_form_order_num`	INTEGER,
--	`assigned_to`		        TEXT, // reviewer user-code
--	`assign_ts_gmt`		        TEXT, // time of assignment
--	`assignment_accepted`		TEXT, // time of assignment
--	`review_status`				TEXT, // default pending
--	`reviewed_ts_gmt`			INT,
--	`reviewed_date_time`		TEXT,
--	`assigned_by`		        TEXT,
--	`assignment_ts_gmt`			INT DEFAULT "0",
--	`assignment_date_time`		TEXT,
--	PRIMARY KEY(subject_uuid, subject_visit_uuid, user_code_reviewer)
--	);

-- Table-31	
-- user_code is key in this table.
-- this table should be administered from server.
-- only one way sync from server to client is required here.
-- Keep created_on and created_by_client to identify further
-- In case updated from multiple clients and leads to a conflict
-- last update should be taken.   
-- role_type: 1=study-site-wise(Investigator), 2-study-wise (Reviewer) 3=global
-- For global users role_num is specific in this record.
CREATE TABLE `cta_user` (
	`user_code`		VARCHAR(64),
	`role_type`		INTEGER DEFAULT 1,
	`profile_num`	INTEGER DEFAULT 0,
	`first_name`	TEXT,
	`last_name`		TEXT,
	`employer`		TEXT,
	`enabled`		INTEGER DEFAULT 1,
	`email`			TEXT,
	`phone`			TEXT,
	`alt_phone`		TEXT,
	`cell`			TEXT,
	`pmc`			TEXT,
	`language`		TEXT,
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	`updated_gmt_offset`	INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`	TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(user_code)
);

CREATE TABLE `cta_user_language` (
	`user_code`		VARCHAR(64),
	`lang_num`		INTEGER,
	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,
	PRIMARY KEY(user_code, lang_num)
);


-- Visit review assignment.
-- Reviewer can accept/reject a visit.
--
-- Table-40
-- 90% of the visits are not reviewed.
-- Review Admin can assign reviewer, review himself or bypass review.
-- When not bypassed - multiple reviews are possible for a single visit.
-- Repeat study_num to avoid join with subject table.
--
-- Review status of a visit is calculated by the lowest form review status or
-- individual form review status is summarized to calculate visit status.
-- Review_mode: 0: normal-QA, 1=Open-opinion, 2-Blinded opinion.
CREATE TABLE `cta_visit_review` (
	`subject_uuid`				VARCHAR(32),
	`subject_visit_uuid`		VARCHAR(32),
	`user_code_reviewer`	    VARCHAR(64),
	`review_mode`	        	INTEGER DEFAULT 0,

	`study_num`		            INTEGER,
	`protocol_num`		        INTEGER,
	`protocol_visit_num`		INTEGER,

	`assigned_by_user`	        VARCHAR(64),
	`assigned_ts_gmt`	        INTEGER DEFAULT 0,
	`assignment_accepted`	    TEXT,
	`accepted_ts_gmt`	        INTEGER DEFAULT 0,

	`updated_ts_gmt`			INTEGER DEFAULT 0,
	`updated_gmt_offset`		INTEGER DEFAULT 0,
	`updated_by_user`			VARCHAR(64),
	`updated_by_client_uuid`	VARCHAR(32),
	`updated_date_time`			TEXT,
	`updated_comment`			TEXT,

	`version_date_time`			TEXT,
	`version_number`			INTEGER DEFAULT 1,

	PRIMARY KEY(subject_uuid, subject_visit_uuid, user_code_reviewer)
	);

-- Store local add/changes in all tables.
-- pkey: table_name.key1.key2.key3.key4.key5.key6.key7
-- table_name:
-- key_1..7 as needed basis (study->site->subject->visit->form->section->question)
-- Normal scenario: change->sync-up->sync-down->change
-- Abnormal scenario: change->sync-up->change->change->change->sync-down
--  If same user racing against himself than allow user to upload outdated data.
--  We can check the device-id of the last changer - if it is myself then allow.
--  sync-ts-gmt is less than update_ts_gmt than user updated again after sync.
-- if up-sync is completed receive all changes for table and update original table and remove
-- cached copy.
CREATE TABLE `cta_local_cache` (
	`pkey`		        TEXT NOT NULL,
	`table_name`		TEXT,
	`key_1`		        TEXT,
	`key_2`		        TEXT,
	`key_3`		        TEXT,
	`key_4`		        TEXT,
	`key_5`		        TEXT,
	`key_6`		        TEXT,
	`key_7`		        TEXT,

	`sync_status`	    INTEGER DEFAULT 0,
	`client_json_value`		TEXT DEFAULT NULL,
	`server_json_value`		TEXT DEFAULT NULL,
	PRIMARY KEY(pkey)
);
--
-- Keep track of what is requested to server for down sync.
-- We don't want to rely on what contains in the table records.
-- Local table in each device. Empty table means full sync
-- will be requested.
--
CREATE TABLE `cta_down_sync_request` (
	`table_name`			TEXT NOT NULL,
	`req_min_version`		INTEGER DEFAULT 0,
	`req_max_version`		INTEGER DEFAULT 0,
	`resp_min_version`		INTEGER DEFAULT 0,
	`resp_max_version`		INTEGER DEFAULT 0,
	`resp_row_count`		INTEGER DEFAULT 0,
	`updated_ts_gmt`		INTEGER DEFAULT 0,
	PRIMARY KEY(table_name)
);

COMMIT;

	