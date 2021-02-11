-- Adding new fields, creating/updating indices and foreign keys.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

ALTER TABLE "COMPONENT"
    ADD COLUMN "AUTHOR"          VARCHAR(255),
    ADD COLUMN "BLAKE2B_256"     VARCHAR(64),
    ADD COLUMN "BLAKE2B_384"     VARCHAR(96),
    ADD COLUMN "BLAKE2B_512"     VARCHAR(128),
    ADD COLUMN "BLAKE3"          VARCHAR(255),
    ADD COLUMN "PROJECT_ID"      BIGINT NULL,
    ADD COLUMN "PUBLISHER"       VARCHAR(255),
    ADD COLUMN "PURLCOORDINATES" VARCHAR(255),
    ADD COLUMN "SHA_384"         VARCHAR(96),
    ADD COLUMN "SHA3_384"        VARCHAR(96),
    ADD COLUMN "SWIDTAGID"       VARCHAR(255);

ALTER TABLE "COMPONENT"
    DROP CONSTRAINT "COMPONENT_FK1",
    DROP CONSTRAINT "COMPONENT_FK2";

DROP INDEX "COMPONENT_N49";
DROP INDEX "COMPONENT_N50";

CREATE INDEX "COMPONENT_BLAKE2B_256_IDX" ON "COMPONENT" ("BLAKE2B_256");
CREATE INDEX "COMPONENT_BLAKE2B_384_IDX" ON "COMPONENT" ("BLAKE2B_384");
CREATE INDEX "COMPONENT_BLAKE2B_512_IDX" ON "COMPONENT" ("BLAKE2B_512");
CREATE INDEX "COMPONENT_BLAKE3_IDX" ON "COMPONENT" ("BLAKE3");
CREATE INDEX "COMPONENT_CPE_IDX" ON "COMPONENT" ("CPE");
CREATE INDEX "COMPONENT_N49" ON "COMPONENT" ("PROJECT_ID");
CREATE INDEX "COMPONENT_N50" ON "COMPONENT" ("PARENT_COMPONENT_ID");
CREATE INDEX "COMPONENT_N51" ON "COMPONENT" ("LICENSE_ID");
CREATE INDEX "COMPONENT_PURL_IDX" ON "COMPONENT" ("PURL");
CREATE INDEX "COMPONENT_PURL_COORDINATES_IDX" ON "COMPONENT" ("PURLCOORDINATES");
CREATE INDEX "COMPONENT_SHA384_IDX" ON "COMPONENT" ("SHA_384");
CREATE INDEX "COMPONENT_SHA3_384_IDX" ON "COMPONENT" ("SHA3_384");
CREATE INDEX "COMPONENT_SWID_TAGID_IDX" ON "COMPONENT" ("SWIDTAGID");


ALTER TABLE "COMPONENTANALYSISCACHE"
    ADD COLUMN "RESULT" TEXT;


ALTER TABLE "DEPENDENCYMETRICS"
    ADD COLUMN "POLICYVIOLATIONS_AUDITED"               INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_FAIL"                  INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_INFO"                  INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_AUDITED"       INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_TOTAL"         INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_UNAUDITED"     INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_AUDITED"   INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_TOTAL"     INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_UNAUDITED" INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_AUDITED"      INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_TOTAL"        INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_UNAUDITED"    INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_TOTAL"                 INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_UNAUDITED"             INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_WARN"                  INTEGER;

UPDATE "DEPENDENCYMETRICS"
SET "POLICYVIOLATIONS_AUDITED"               = 0,
    "POLICYVIOLATIONS_FAIL"                  = 0,
    "POLICYVIOLATIONS_INFO"                  = 0,
    "POLICYVIOLATIONS_LICENSE_AUDITED"       = 0,
    "POLICYVIOLATIONS_LICENSE_TOTAL"         = 0,
    "POLICYVIOLATIONS_LICENSE_UNAUDITED"     = 0,
    "POLICYVIOLATIONS_OPERATIONAL_AUDITED"   = 0,
    "POLICYVIOLATIONS_OPERATIONAL_TOTAL"     = 0,
    "POLICYVIOLATIONS_OPERATIONAL_UNAUDITED" = 0,
    "POLICYVIOLATIONS_SECURITY_AUDITED"      = 0,
    "POLICYVIOLATIONS_SECURITY_TOTAL"        = 0,
    "POLICYVIOLATIONS_SECURITY_UNAUDITED"    = 0,
    "POLICYVIOLATIONS_TOTAL"                 = 0,
    "POLICYVIOLATIONS_UNAUDITED"             = 0,
    "POLICYVIOLATIONS_WARN"                  = 0;


----------------------------

CREATE TABLE "FINDINGATTRIBUTION"
(
    "ID"               serial                   NOT NULL
        CONSTRAINT "FINDINGATTRIBUTION_PK"
            PRIMARY KEY,
    "ALT_ID"           varchar(255),
    "ANALYZERIDENTITY" varchar(255)             NOT NULL,
    "ATTRIBUTED_ON"    timestamp WITH TIME ZONE NOT NULL,
    "COMPONENT_ID"     bigint                   NOT NULL,
    "PROJECT_ID"       bigint                   NOT NULL
        CONSTRAINT "FINDINGATTRIBUTION_FK2"
            REFERENCES "PROJECT"
            DEFERRABLE INITIALLY DEFERRED,
    "REFERENCE_URL"    varchar(255),
    "UUID"             varchar(36)              NOT NULL
        CONSTRAINT "FINDINGATTRIBUTION_UUID_IDX"
            UNIQUE,
    "VULNERABILITY_ID" bigint                   NOT NULL
        CONSTRAINT "FINDINGATTRIBUTION_FK3"
            REFERENCES "VULNERABILITY"
            DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX "FINDINGATTRIBUTION_N50"
    ON "FINDINGATTRIBUTION" ("PROJECT_ID");

CREATE INDEX "FINDINGATTRIBUTION_N51"
    ON "FINDINGATTRIBUTION" ("VULNERABILITY_ID");

CREATE INDEX "FINDINGATTRIBUTION_COMPOUND_IDX"
    ON "FINDINGATTRIBUTION" ("COMPONENT_ID", "VULNERABILITY_ID");

CREATE INDEX "FINDINGATTRIBUTION_N49"
    ON "FINDINGATTRIBUTION" ("COMPONENT_ID");


CREATE TABLE "LICENSEGROUP"
(
    "ID"         serial       NOT NULL
        CONSTRAINT "LICENSEGROUP_PK"
            PRIMARY KEY,
    "NAME"       varchar(255) NOT NULL,
    "RISKWEIGHT" integer      NOT NULL,
    "UUID"       varchar(36)  NOT NULL
        CONSTRAINT "LICENSEGROUP_UUID_IDX"
            UNIQUE
);

CREATE INDEX "LICENSEGROUP_NAME_IDX"
    ON "LICENSEGROUP" ("NAME");

CREATE TABLE "OIDCGROUP"
(
    "ID"   serial        NOT NULL
        CONSTRAINT "OIDCGROUP_PK"
            PRIMARY KEY,
    "NAME" varchar(1024) NOT NULL,
    "UUID" varchar(36)   NOT NULL
        CONSTRAINT "OIDCGROUP_UUID_IDX"
            UNIQUE
);

CREATE TABLE "MAPPEDOIDCGROUP"
(
    "ID"       serial      NOT NULL
        CONSTRAINT "MAPPEDOIDCGROUP_PK"
            PRIMARY KEY,
    "GROUP_ID" bigint      NOT NULL
        CONSTRAINT "MAPPEDOIDCGROUP_FK1"
            REFERENCES "OIDCGROUP"
            DEFERRABLE INITIALLY DEFERRED,
    "TEAM_ID"  bigint      NOT NULL
        CONSTRAINT "MAPPEDOIDCGROUP_FK2"
            REFERENCES "TEAM"
            DEFERRABLE INITIALLY DEFERRED,
    "UUID"     varchar(36) NOT NULL
        CONSTRAINT "MAPPEDOIDCGROUP_UUID_IDX"
            UNIQUE,
    CONSTRAINT "MAPPEDOIDCGROUP_U1"
        UNIQUE ("TEAM_ID", "GROUP_ID")
);

CREATE INDEX "MAPPEDOIDCGROUP_N50"
    ON "MAPPEDOIDCGROUP" ("TEAM_ID");

CREATE INDEX "MAPPEDOIDCGROUP_N49"
    ON "MAPPEDOIDCGROUP" ("GROUP_ID");

CREATE TABLE "OIDCUSER"
(
    "ID"                 serial       NOT NULL
        CONSTRAINT "OIDCUSER_PK"
            PRIMARY KEY,
    "SUBJECT_IDENTIFIER" varchar(255),
    "USERNAME"           varchar(255) NOT NULL
        CONSTRAINT "OIDCUSER_USERNAME_IDX"
            UNIQUE
);

CREATE TABLE "OIDCUSERS_PERMISSIONS"
(
    "PERMISSION_ID" bigint NOT NULL
        CONSTRAINT "OIDCUSERS_PERMISSIONS_FK1"
            REFERENCES "PERMISSION"
            DEFERRABLE INITIALLY DEFERRED,
    "OIDCUSER_ID"   bigint NOT NULL
        CONSTRAINT "OIDCUSERS_PERMISSIONS_FK2"
            REFERENCES "OIDCUSER"
            DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX "OIDCUSERS_PERMISSIONS_N49"
    ON "OIDCUSERS_PERMISSIONS" ("PERMISSION_ID");

CREATE INDEX "OIDCUSERS_PERMISSIONS_N50"
    ON "OIDCUSERS_PERMISSIONS" ("OIDCUSER_ID");

CREATE TABLE "OIDCUSERS_TEAMS"
(
    "OIDCUSERS_ID" bigint NOT NULL
        CONSTRAINT "OIDCUSERS_TEAMS_FK1"
            REFERENCES "OIDCUSER"
            DEFERRABLE INITIALLY DEFERRED,
    "TEAM_ID"      bigint NOT NULL
        CONSTRAINT "OIDCUSERS_TEAMS_FK2"
            REFERENCES "TEAM"
            DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX "OIDCUSERS_TEAMS_N49"
    ON "OIDCUSERS_TEAMS" ("OIDCUSERS_ID");

CREATE INDEX "OIDCUSERS_TEAMS_N50"
    ON "OIDCUSERS_TEAMS" ("TEAM_ID");

CREATE TABLE "POLICY"
(
    "ID"             serial       NOT NULL
        CONSTRAINT "POLICY_PK"
            PRIMARY KEY,
    "NAME"           varchar(255) NOT NULL,
    "OPERATOR"       varchar(255) NOT NULL,
    "UUID"           varchar(36)  NOT NULL
        CONSTRAINT "POLICY_UUID_IDX"
            UNIQUE,
    "VIOLATIONSTATE" varchar(255) NOT NULL
);

CREATE INDEX "POLICY_NAME_IDX"
    ON "POLICY" ("NAME");

CREATE TABLE "POLICYCONDITION"
(
    "ID"        serial       NOT NULL
        CONSTRAINT "POLICYCONDITION_PK"
            PRIMARY KEY,
    "OPERATOR"  varchar(255) NOT NULL,
    "POLICY_ID" bigint       NOT NULL
        CONSTRAINT "POLICYCONDITION_FK1"
            REFERENCES "POLICY"
            DEFERRABLE INITIALLY DEFERRED,
    "SUBJECT"   varchar(255) NOT NULL,
    "UUID"      varchar(36)  NOT NULL
        CONSTRAINT "POLICYCONDITION_UUID_IDX"
            UNIQUE,
    "VALUE"     varchar(255) NOT NULL
);

CREATE INDEX "POLICYCONDITION_N49"
    ON "POLICYCONDITION" ("POLICY_ID");

CREATE TABLE "POLICYVIOLATION"
(
    "ID"                 serial                   NOT NULL
        CONSTRAINT "POLICYVIOLATION_PK"
            PRIMARY KEY,
    "COMPONENT_ID"       bigint                   NOT NULL,
    "POLICYCONDITION_ID" bigint                   NOT NULL
        CONSTRAINT "POLICYVIOLATION_FK2"
            REFERENCES "POLICYCONDITION"
            DEFERRABLE INITIALLY DEFERRED,
    "PROJECT_ID"         bigint                   NOT NULL
        CONSTRAINT "POLICYVIOLATION_FK3"
            REFERENCES "PROJECT"
            DEFERRABLE INITIALLY DEFERRED,
    "TEXT"               varchar(255),
    "TIMESTAMP"          timestamp WITH TIME ZONE NOT NULL,
    "TYPE"               varchar(255)             NOT NULL,
    "UUID"               varchar(36)              NOT NULL
        CONSTRAINT "POLICYVIOLATION_UUID_IDX"
            UNIQUE
);

CREATE INDEX "POLICYVIOLATION_PROJECT_IDX"
    ON "POLICYVIOLATION" ("PROJECT_ID");

CREATE INDEX "POLICYVIOLATION_N49"
    ON "POLICYVIOLATION" ("POLICYCONDITION_ID");

CREATE INDEX "POLICYVIOLATION_COMPONENT_IDX"
    ON "POLICYVIOLATION" ("COMPONENT_ID");

CREATE TABLE "POLICY_PROJECTS"
(
    "POLICY_ID"  bigint NOT NULL
        CONSTRAINT "POLICY_PROJECTS_FK1"
            REFERENCES "POLICY"
            DEFERRABLE INITIALLY DEFERRED,
    "PROJECT_ID" bigint
        CONSTRAINT "POLICY_PROJECTS_FK2"
            REFERENCES "PROJECT"
            DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX "POLICY_PROJECTS_N49"
    ON "POLICY_PROJECTS" ("POLICY_ID");

CREATE INDEX "POLICY_PROJECTS_N50"
    ON "POLICY_PROJECTS" ("PROJECT_ID");



ALTER TABLE "PORTFOLIOMETRICS"
    ADD COLUMN "POLICYVIOLATIONS_AUDITED"               INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_FAIL"                  INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_INFO"                  INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_AUDITED"       INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_TOTAL"         INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_UNAUDITED"     INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_AUDITED"   INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_TOTAL"     INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_UNAUDITED" INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_AUDITED"      INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_TOTAL"        INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_UNAUDITED"    INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_TOTAL"                 INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_UNAUDITED"             INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_WARN"                  INTEGER,
    DROP COLUMN "DEPENDENCIES",
    DROP COLUMN "VULNERABLEDEPENDENCIES";

UPDATE "PORTFOLIOMETRICS"
SET "POLICYVIOLATIONS_AUDITED"               = 0,
    "POLICYVIOLATIONS_FAIL"                  = 0,
    "POLICYVIOLATIONS_INFO"                  = 0,
    "POLICYVIOLATIONS_LICENSE_AUDITED"       = 0,
    "POLICYVIOLATIONS_LICENSE_TOTAL"         = 0,
    "POLICYVIOLATIONS_LICENSE_UNAUDITED"     = 0,
    "POLICYVIOLATIONS_OPERATIONAL_AUDITED"   = 0,
    "POLICYVIOLATIONS_OPERATIONAL_TOTAL"     = 0,
    "POLICYVIOLATIONS_OPERATIONAL_UNAUDITED" = 0,
    "POLICYVIOLATIONS_SECURITY_AUDITED"      = 0,
    "POLICYVIOLATIONS_SECURITY_TOTAL"        = 0,
    "POLICYVIOLATIONS_SECURITY_UNAUDITED"    = 0,
    "POLICYVIOLATIONS_TOTAL"                 = 0,
    "POLICYVIOLATIONS_UNAUDITED"             = 0,
    "POLICYVIOLATIONS_WARN"                  = 0;


ALTER TABLE "PROJECT"
    ADD COLUMN "AUTHOR"     VARCHAR(255),
    ADD COLUMN "CLASSIFIER" VARCHAR(255),
    ADD COLUMN "CPE"        VARCHAR(255),
    ADD COLUMN "GROUP"      VARCHAR(255),
    ADD COLUMN "PUBLISHER"  VARCHAR(255),
    ADD COLUMN "SWIDTAGID"  VARCHAR(255);

CREATE INDEX "PROJECT_CLASSIFIER_IDX" ON "PROJECT" ("CLASSIFIER");
CREATE INDEX "PROJECT_CPE_IDX" ON "PROJECT" ("CPE");
CREATE INDEX "PROJECT_GROUP_IDX" ON "PROJECT" ("GROUP");
CREATE INDEX "PROJECT_PURL_IDX" ON "PROJECT" ("PURL");
CREATE INDEX "PROJECT_SWID_TAGID_IDX" ON "PROJECT" ("SWIDTAGID");


ALTER TABLE "PROJECTMETRICS"
    ADD COLUMN "POLICYVIOLATIONS_AUDITED"               INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_FAIL"                  INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_INFO"                  INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_AUDITED"       INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_TOTAL"         INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_LICENSE_UNAUDITED"     INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_AUDITED"   INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_TOTAL"     INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_OPERATIONAL_UNAUDITED" INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_AUDITED"      INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_TOTAL"        INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_SECURITY_UNAUDITED"    INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_TOTAL"                 INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_UNAUDITED"             INTEGER,
    ADD COLUMN "POLICYVIOLATIONS_WARN"                  INTEGER;

UPDATE "PROJECTMETRICS"
SET "POLICYVIOLATIONS_AUDITED"               = 0,
    "POLICYVIOLATIONS_FAIL"                  = 0,
    "POLICYVIOLATIONS_INFO"                  = 0,
    "POLICYVIOLATIONS_LICENSE_AUDITED"       = 0,
    "POLICYVIOLATIONS_LICENSE_TOTAL"         = 0,
    "POLICYVIOLATIONS_LICENSE_UNAUDITED"     = 0,
    "POLICYVIOLATIONS_OPERATIONAL_AUDITED"   = 0,
    "POLICYVIOLATIONS_OPERATIONAL_TOTAL"     = 0,
    "POLICYVIOLATIONS_OPERATIONAL_UNAUDITED" = 0,
    "POLICYVIOLATIONS_SECURITY_AUDITED"      = 0,
    "POLICYVIOLATIONS_SECURITY_TOTAL"        = 0,
    "POLICYVIOLATIONS_SECURITY_UNAUDITED"    = 0,
    "POLICYVIOLATIONS_TOTAL"                 = 0,
    "POLICYVIOLATIONS_UNAUDITED"             = 0,
    "POLICYVIOLATIONS_WARN"                  = 0;


ALTER TABLE IF EXISTS "SCANS_COMPONENTS"
    DROP CONSTRAINT "SCANS_COMPONENTS_FK2";

CREATE TABLE "VIOLATIONANALYSIS"
(
    "ID"                 serial       NOT NULL
        CONSTRAINT "VIOLATIONANALYSIS_PK"
            PRIMARY KEY,
    "STATE"              varchar(255) NOT NULL,
    "COMPONENT_ID"       bigint,
    "POLICYVIOLATION_ID" bigint       NOT NULL
        CONSTRAINT "VIOLATIONANALYSIS_FK2"
            REFERENCES "POLICYVIOLATION"
            DEFERRABLE INITIALLY DEFERRED,
    "PROJECT_ID"         bigint
        CONSTRAINT "VIOLATIONANALYSIS_FK3"
            REFERENCES "PROJECT"
            DEFERRABLE INITIALLY DEFERRED,
    "SUPPRESSED"         boolean      NOT NULL,
    CONSTRAINT "VIOLATIONANALYSIS_COMPOSITE_IDX"
        UNIQUE ("PROJECT_ID", "COMPONENT_ID", "POLICYVIOLATION_ID")
);

CREATE INDEX "VIOLATIONANALYSIS_N49"
    ON "VIOLATIONANALYSIS" ("PROJECT_ID");

CREATE INDEX "VIOLATIONANALYSIS_N51"
    ON "VIOLATIONANALYSIS" ("COMPONENT_ID");

CREATE INDEX "VIOLATIONANALYSIS_N50"
    ON "VIOLATIONANALYSIS" ("POLICYVIOLATION_ID");

CREATE TABLE "VIOLATIONANALYSISCOMMENT"
(
    "ID"                   serial                   NOT NULL
        CONSTRAINT "VIOLATIONANALYSISCOMMENT_PK"
            PRIMARY KEY,
    "COMMENT"              text                     NOT NULL,
    "COMMENTER"            varchar(255),
    "TIMESTAMP"            timestamp WITH TIME ZONE NOT NULL,
    "VIOLATIONANALYSIS_ID" bigint                   NOT NULL
        CONSTRAINT "VIOLATIONANALYSISCOMMENT_FK1"
            REFERENCES "VIOLATIONANALYSIS"
            DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX "VIOLATIONANALYSISCOMMENT_N49"
    ON "VIOLATIONANALYSISCOMMENT" ("VIOLATIONANALYSIS_ID");

ALTER TABLE "VULNERABILITY"
    ADD COLUMN "FRIENDLYVULNID" VARCHAR(255);

DROP TABLE "BOMS_COMPONENTS";
DROP TABLE "COMPONENTMETRICS";
DROP TABLE "CPEREFERENCE";

-- Find dangling components that no project depends on anymore and remove them

CREATE FUNCTION "cleanup_components"() RETURNS BOOLEAN
    LANGUAGE "plpgsql"
AS
$$
DECLARE
    "v_component_id"                 BIGINT;
    DECLARE "scan_components_exists" VARCHAR(255);
BEGIN
    SELECT TO_REGCLASS('SCANS_COMPONENTS') INTO "scan_components_exists";
    FOR "v_component_id" IN SELECT "c"."ID"
                            FROM "COMPONENT" "c"
                                     LEFT JOIN "DEPENDENCY" "d" ON "c"."ID" = "d"."COMPONENT_ID"
                            WHERE "d"."COMPONENT_ID" IS NULL
        LOOP
            IF "v_component_id" IS NOT NULL THEN
                DELETE
                FROM "ANALYSISCOMMENT" "ac"
                    USING "ANALYSIS" "a"
                WHERE "ac"."ANALYSIS_ID" = "a"."ID"
                  AND "a"."COMPONENT_ID" = "v_component_id";
                DELETE FROM "ANALYSIS" WHERE "COMPONENT_ID" = "v_component_id";
                DELETE FROM "COMPONENTS_VULNERABILITIES" WHERE "COMPONENT_ID" = "v_component_id";
                DELETE FROM "DEPENDENCYMETRICS" WHERE "COMPONENT_ID" = "v_component_id";
                IF "scan_components_exists" IS NOT NULL THEN
                    DELETE FROM "SCANS_COMPONENTS" WHERE "COMPONENT_ID" = "v_component_id";
                END IF;
                DELETE FROM "COMPONENT" WHERE "ID" = "v_component_id";
            END IF;
        END LOOP;
    RETURN TRUE;
END;
$$;
SELECT "cleanup_components"();

DROP FUNCTION "cleanup_components";


-- Updating the COMPONENT table's rows to match the new structure.
-- This includes the multiplication of the components for each applicable project.


ALTER TABLE "ANALYSIS"
    DROP CONSTRAINT "ANALYSIS_FK1";
ALTER TABLE "COMPONENTS_VULNERABILITIES"
    DROP CONSTRAINT "COMPONENTS_VULNERABILITIES_FK1";
ALTER TABLE "DEPENDENCY"
    DROP CONSTRAINT "DEPENDENCY_FK1";
ALTER TABLE "DEPENDENCYMETRICS"
    DROP CONSTRAINT "DEPENDENCYMETRICS_FK1";

CREATE TABLE "TMP_COMPONENT_MAPPING"
(
    "ORIGINAL_COMPONENT_ID" BIGINT,
    "NEW_COMPONENT_ID"      BIGINT,
    "PROJECT_ID"            BIGINT
);

CREATE TABLE IF NOT EXISTS "COMPONENT_40"
(
    "ID"                  serial       NOT NULL
        CONSTRAINT "COMPONENT_40_PK"
            PRIMARY KEY,
    "CLASSIFIER"          varchar(255)
        CONSTRAINT "COMPONENT_40_CLASSIFIER_check"
            CHECK ((("CLASSIFIER")::text = ANY
                    (ARRAY [('APPLICATION'::character varying)::text, ('FRAMEWORK'::character varying)::text, ('LIBRARY'::character varying)::text, ('OPERATING_SYSTEM'::character varying)::text, ('DEVICE'::character varying)::text, ('FILE'::character varying)::text])) OR
                   ("CLASSIFIER" IS NULL)),
    "COPYRIGHT"           varchar(1024),
    "CPE"                 varchar(255),
    "DESCRIPTION"         varchar(1024),
    "EXTENSION"           varchar(255),
    "FILENAME"            varchar(255),
    "GROUP"               varchar(255),
    "INTERNAL"            boolean,
    "LAST_RISKSCORE"      double precision,
    "LICENSE"             varchar(255),
    "MD5"                 varchar(32),
    "NAME"                varchar(255) NOT NULL,
    "PARENT_COMPONENT_ID" bigint,
    "PURL"                varchar(255),
    "LICENSE_ID"          bigint,
    "SHA1"                varchar(40),
    "SHA_256"             varchar(64),
    "SHA3_256"            varchar(64),
    "SHA3_512"            varchar(128),
    "SHA_512"             varchar(128),
    "UUID"                varchar(36)  NOT NULL
        CONSTRAINT "COMPONENT_40_UUID_IDX"
            UNIQUE,
    "VERSION"             varchar(255),
    "AUTHOR"              varchar(255),
    "BLAKE2B_256"         varchar(64),
    "BLAKE2B_384"         varchar(96),
    "BLAKE2B_512"         varchar(128),
    "BLAKE3"              varchar(255),
    "PROJECT_ID"          bigint,
    "PUBLISHER"           varchar(255),
    "PURLCOORDINATES"     varchar(255),
    "SHA_384"             varchar(96),
    "SHA3_384"            varchar(96),
    "SWIDTAGID"           varchar(255)
);

CREATE TABLE IF NOT EXISTS "COMPONENTS_VULNERABILITIES_40"
(
    "COMPONENT_ID"     bigint NOT NULL,
    "VULNERABILITY_ID" bigint NOT NULL
        CONSTRAINT "COMPONENTS_VULNERABILITIES_40_FK2"
            REFERENCES "VULNERABILITY"
            DEFERRABLE INITIALLY DEFERRED
);

CREATE OR REPLACE FUNCTION "convert_components"() RETURNS BOOLEAN
    LANGUAGE "plpgsql"
AS
$$
DECLARE
    "v_original_id"                 BIGINT;
    DECLARE "v_classifier"          VARCHAR(255);
    DECLARE "v_copyright"           VARCHAR(1024);
    DECLARE "v_cpe"                 VARCHAR(255);
    DECLARE "v_description"         VARCHAR(1024);
    DECLARE "v_extension"           VARCHAR(255);
    DECLARE "v_filename"            VARCHAR(255);
    DECLARE "v_group"               VARCHAR(255);
    DECLARE "v_internal"            BOOLEAN;
    DECLARE "v_last_riskscore"      DOUBLE precision;
    DECLARE "v_license"             VARCHAR(255);
    DECLARE "v_md5"                 VARCHAR(32);
    DECLARE "v_name"                VARCHAR(255);
    DECLARE "v_parent_component_id" BIGINT;
    DECLARE "v_purl"                VARCHAR(255);
    DECLARE "v_license_id"          BIGINT;
    DECLARE "v_sha1"                VARCHAR(40);
    DECLARE "v_sha_256"             VARCHAR(64);
    DECLARE "v_sha3_256"            VARCHAR(64);
    DECLARE "v_sha3_512"            VARCHAR(128);
    DECLARE "v_sha_512"             VARCHAR(128);
    DECLARE "v_uuid"                VARCHAR(36);
    DECLARE "v_version"             VARCHAR(255);
    DECLARE "v_project_id"          BIGINT;
    DECLARE "v_query_count"         BIGINT;
    DECLARE "v_new_id"              BIGINT;
    DECLARE "max_sequence"          BIGINT;
BEGIN
    SELECT MAX("ID") FROM "COMPONENT" INTO "max_sequence";
    PERFORM SETVAL('"COMPONENT_40_ID_seq"', "max_sequence", TRUE);
    FOR "v_original_id", "v_classifier", "v_copyright", "v_cpe", "v_description",
        "v_extension", "v_filename", "v_group", "v_internal", "v_last_riskscore", "v_license",
        "v_md5", "v_name", "v_parent_component_id", "v_purl", "v_license_id", "v_sha1", "v_sha_256",
        "v_sha3_256", "v_sha3_512", "v_sha_512", "v_uuid", "v_version", "v_project_id" IN SELECT "c"."ID",
                                                                                                 "c"."CLASSIFIER",
                                                                                                 "c"."COPYRIGHT",
                                                                                                 "c"."CPE",
                                                                                                 "c"."DESCRIPTION",
                                                                                                 "c"."EXTENSION",
                                                                                                 "c"."FILENAME",
                                                                                                 "c"."GROUP",
                                                                                                 "c"."INTERNAL",
                                                                                                 "c"."LAST_RISKSCORE",
                                                                                                 "c"."LICENSE",
                                                                                                 "c"."MD5",
                                                                                                 "c"."NAME",
                                                                                                 "c"."PARENT_COMPONENT_ID",
                                                                                                 "c"."PURL",
                                                                                                 "c"."LICENSE_ID",
                                                                                                 "c"."SHA1",
                                                                                                 "c"."SHA_256",
                                                                                                 "c"."SHA3_256",
                                                                                                 "c"."SHA3_512",
                                                                                                 "c"."SHA_512",
                                                                                                 "c"."UUID",
                                                                                                 "c"."VERSION",
                                                                                                 "d"."PROJECT_ID"
                                                                                          FROM "COMPONENT" "c"
                                                                                                   JOIN "DEPENDENCY" "d" ON "c"."ID" = "d"."COMPONENT_ID"
                                                                                          GROUP BY "c"."ID", "d"."PROJECT_ID"
        LOOP
            IF "v_parent_component_id" IS NOT NULL THEN
                SELECT "NEW_COMPONENT_ID"
                FROM "TMP_COMPONENT_MAPPING"
                WHERE "ORIGINAL_COMPONENT_ID" = "v_parent_component_id"
                  AND "PROJECT_ID" = "v_project_id"
                INTO "v_parent_component_id";
            END IF;

            SELECT COUNT(*) INTO "v_query_count" FROM "COMPONENT_40" WHERE "ID" = "v_original_id";

            IF "v_query_count" = 0 THEN
                INSERT INTO "COMPONENT_40" ("ID", "CLASSIFIER", "COPYRIGHT", "CPE", "DESCRIPTION", "EXTENSION",
                                            "FILENAME",
                                            "GROUP", "INTERNAL", "LAST_RISKSCORE", "LICENSE", "MD5", "NAME",
                                            "PARENT_COMPONENT_ID", "PURL", "LICENSE_ID", "SHA1", "SHA_256", "SHA3_256",
                                            "SHA3_512", "SHA_512", "UUID", "VERSION", "PROJECT_ID")
                VALUES ("v_original_id", "v_classifier", "v_copyright", "v_cpe", "v_description",
                        "v_extension", "v_filename", "v_group", "v_internal", "v_last_riskscore", "v_license",
                        "v_md5", "v_name", "v_parent_component_id", "v_purl", "v_license_id", "v_sha1", "v_sha_256",
                        "v_sha3_256", "v_sha3_512", "v_sha_512", "v_uuid", "v_version", "v_project_id");

                SELECT "v_original_id" INTO "v_new_id";
            ELSE
                -- TODO switch to cryptographically secure UUIDv4 generation if needed.
                INSERT INTO "COMPONENT_40" ("CLASSIFIER", "COPYRIGHT", "CPE", "DESCRIPTION", "EXTENSION", "FILENAME",
                                            "GROUP", "INTERNAL", "LAST_RISKSCORE", "LICENSE", "MD5", "NAME",
                                            "PARENT_COMPONENT_ID", "PURL", "LICENSE_ID", "SHA1", "SHA_256", "SHA3_256",
                                            "SHA3_512", "SHA_512", "UUID", "VERSION", "PROJECT_ID")
                VALUES ("v_classifier", "v_copyright", "v_cpe", "v_description",
                        "v_extension", "v_filename", "v_group", "v_internal", "v_last_riskscore", "v_license",
                        "v_md5", "v_name", "v_parent_component_id", "v_purl", "v_license_id", "v_sha1", "v_sha_256",
                        "v_sha3_256", "v_sha3_512", "v_sha_512", "uuid_generate_v1"(), "v_version", "v_project_id");

                SELECT LASTVAL() INTO "v_new_id";
            END IF;

            INSERT INTO "TMP_COMPONENT_MAPPING" VALUES ("v_original_id", "v_new_id", "v_project_id");

        END LOOP;


    FOR "v_original_id", "v_new_id", "v_project_id" IN SELECT "ORIGINAL_COMPONENT_ID", "NEW_COMPONENT_ID", "PROJECT_ID"
                                                       FROM "TMP_COMPONENT_MAPPING"
                                                       ORDER BY "ORIGINAL_COMPONENT_ID" DESC
        LOOP


            UPDATE "ANALYSIS"
            SET "COMPONENT_ID" = "v_new_id"
            WHERE "COMPONENT_ID" = "v_original_id"
              AND "PROJECT_ID" = "v_project_id";

            UPDATE "DEPENDENCYMETRICS"
            SET "COMPONENT_ID" = "v_new_id"
            WHERE "COMPONENT_ID" = "v_original_id"
              AND "PROJECT_ID" = "v_project_id";
        END LOOP;


    INSERT INTO "COMPONENTS_VULNERABILITIES_40"
    SELECT "tcm"."NEW_COMPONENT_ID", "cv"."VULNERABILITY_ID"
    FROM "TMP_COMPONENT_MAPPING" "tcm"
             JOIN "COMPONENTS_VULNERABILITIES" "cv" ON "tcm"."ORIGINAL_COMPONENT_ID" = "cv"."COMPONENT_ID";
    RETURN TRUE;
END
$$;

SELECT "convert_components"();

DROP FUNCTION "convert_components";

DROP TABLE "TMP_COMPONENT_MAPPING";

DROP TABLE "COMPONENT";

ALTER
    TABLE "COMPONENT_40"
    RENAME
        TO "COMPONENT";

ALTER INDEX "COMPONENT_40_PK" RENAME TO "COMPONENT_PK";

ALTER SEQUENCE "COMPONENT_40_ID_seq" RENAME TO "COMPONENT_ID_seq";

ALTER TABLE "COMPONENT"
    RENAME CONSTRAINT "COMPONENT_40_UUID_IDX" TO "COMPONENT_UUID_IDX";

ALTER TABLE "COMPONENT"
    RENAME CONSTRAINT "COMPONENT_40_CLASSIFIER_check" TO "COMPONENT_CLASSIFIER_check";

ALTER TABLE "COMPONENT"
    ADD CONSTRAINT "COMPONENT_FK1" FOREIGN KEY ("PARENT_COMPONENT_ID") REFERENCES "COMPONENT" ("ID"),
    ADD CONSTRAINT "COMPONENT_FK2" FOREIGN KEY ("PROJECT_ID") REFERENCES "PROJECT" ("ID"),
    ADD CONSTRAINT "COMPONENT_FK3" FOREIGN KEY ("LICENSE_ID") REFERENCES "LICENSE" ("ID");

CREATE INDEX IF NOT EXISTS "COMPONENT_CLASSIFIER_IDX"
    ON "COMPONENT" ("CLASSIFIER");

CREATE INDEX IF NOT EXISTS "COMPONENT_GROUP_IDX"
    ON "COMPONENT" ("GROUP");

CREATE INDEX IF NOT EXISTS "COMPONENT_LAST_RISKSCORE_IDX"
    ON "COMPONENT" ("LAST_RISKSCORE");

CREATE INDEX IF NOT EXISTS "COMPONENT_MD5_IDX"
    ON "COMPONENT" ("MD5");

CREATE INDEX IF NOT EXISTS "COMPONENT_NAME_IDX"
    ON "COMPONENT" ("NAME");

CREATE INDEX IF NOT EXISTS "COMPONENT_SHA1_IDX"
    ON "COMPONENT" ("SHA1");

CREATE INDEX IF NOT EXISTS "COMPONENT_SHA256_IDX"
    ON "COMPONENT" ("SHA_256");

CREATE INDEX IF NOT EXISTS "COMPONENT_SHA3_256_IDX"
    ON "COMPONENT" ("SHA3_256");

CREATE INDEX IF NOT EXISTS "COMPONENT_SHA3_512_IDX"
    ON "COMPONENT" ("SHA3_512");

CREATE INDEX IF NOT EXISTS "COMPONENT_SHA512_IDX"
    ON "COMPONENT" ("SHA_512");

CREATE INDEX IF NOT EXISTS "COMPONENT_BLAKE2B_256_IDX"
    ON "COMPONENT" ("BLAKE2B_256");

CREATE INDEX IF NOT EXISTS "COMPONENT_BLAKE2B_384_IDX"
    ON "COMPONENT" ("BLAKE2B_384");

CREATE INDEX IF NOT EXISTS "COMPONENT_BLAKE2B_512_IDX"
    ON "COMPONENT" ("BLAKE2B_512");

CREATE INDEX IF NOT EXISTS "COMPONENT_BLAKE3_IDX"
    ON "COMPONENT" ("BLAKE3");

CREATE INDEX IF NOT EXISTS "COMPONENT_CPE_IDX"
    ON "COMPONENT" ("CPE");

CREATE INDEX IF NOT EXISTS "COMPONENT_N49"
    ON "COMPONENT" ("PROJECT_ID");

CREATE INDEX IF NOT EXISTS "COMPONENT_N50"
    ON "COMPONENT" ("PARENT_COMPONENT_ID");

CREATE INDEX IF NOT EXISTS "COMPONENT_N51"
    ON "COMPONENT" ("LICENSE_ID");

CREATE INDEX IF NOT EXISTS "COMPONENT_PURL_IDX"
    ON "COMPONENT" ("PURL");

CREATE INDEX IF NOT EXISTS "COMPONENT_PURL_COORDINATES_IDX"
    ON "COMPONENT" ("PURLCOORDINATES");

CREATE INDEX IF NOT EXISTS "COMPONENT_SHA384_IDX"
    ON "COMPONENT" ("SHA_384");

CREATE INDEX IF NOT EXISTS "COMPONENT_SHA3_384_IDX"
    ON "COMPONENT" ("SHA3_384");

CREATE INDEX IF NOT EXISTS "COMPONENT_SWID_TAGID_IDX"
    ON "COMPONENT" ("SWIDTAGID");

ALTER TABLE "ANALYSIS"
    ADD CONSTRAINT "ANALYSIS_FK1" FOREIGN KEY ("COMPONENT_ID") REFERENCES "COMPONENT" ("ID");

DROP TABLE "COMPONENTS_VULNERABILITIES";

ALTER
    TABLE "COMPONENTS_VULNERABILITIES_40"
    RENAME
        TO "COMPONENTS_VULNERABILITIES";

ALTER TABLE "COMPONENTS_VULNERABILITIES"
    DROP CONSTRAINT "COMPONENTS_VULNERABILITIES_40_FK2",
    ADD CONSTRAINT "COMPONENTS_VULNERABILITIES_FK1" FOREIGN KEY ("COMPONENT_ID") REFERENCES "COMPONENT" ("ID"),
    ADD CONSTRAINT "COMPONENTS_VULNERABILITIES_FK2" FOREIGN KEY ("VULNERABILITY_ID") REFERENCES "VULNERABILITY" ("ID");

ALTER TABLE "DEPENDENCYMETRICS"
    ADD CONSTRAINT "DEPENDENCYMETRICS_FK1" FOREIGN KEY ("COMPONENT_ID") REFERENCES "COMPONENT" ("ID");

ALTER TABLE "FINDINGATTRIBUTION"
    ADD CONSTRAINT "FINDINGATTRIBUTION_FK1" FOREIGN KEY ("COMPONENT_ID") REFERENCES "COMPONENT" ("ID");

ALTER TABLE "POLICYVIOLATION"
    ADD CONSTRAINT "POLICYVIOLATION_FK1" FOREIGN KEY ("COMPONENT_ID") REFERENCES "COMPONENT" ("ID");

ALTER TABLE IF EXISTS "SCANS_COMPONENTS"
    ADD CONSTRAINT "SCANS_COMPONENTS_FK2" FOREIGN KEY ("COMPONENT_ID") REFERENCES "COMPONENT" ("ID");

ALTER TABLE "VIOLATIONANALYSIS"
    ADD CONSTRAINT "VIOLATIONANALYSIS_FK1" FOREIGN KEY ("COMPONENT_ID") REFERENCES "COMPONENT" ("ID");

DROP TABLE "DEPENDENCY";

UPDATE "SCHEMAVERSION"
SET "VERSION" = '4.0.0'
WHERE "ID" = 1;


-- Fill FINDINGATTRIBUTION table

CREATE OR REPLACE FUNCTION "process_findings"() RETURNS BOOLEAN
    LANGUAGE "plpgsql"
AS
$$
DECLARE
    "v_analyzer_identity"        VARCHAR(255);
    DECLARE "v_component_id"     BIGINT;
    DECLARE "v_project_id"       BIGINT;
    DECLARE "v_source"           VARCHAR(255);
    DECLARE "v_vulnerability_id" BIGINT;
BEGIN
    FOR "v_component_id", "v_project_id", "v_source", "v_vulnerability_id" IN
        SELECT "c"."ID", "c"."PROJECT_ID", "v"."SOURCE", "v"."ID"
        FROM "COMPONENT" "c"
                 INNER JOIN "COMPONENTS_VULNERABILITIES" "cv" ON "c"."ID" = "cv"."COMPONENT_ID"
                 INNER JOIN "VULNERABILITY" "v" ON "v"."ID" = "cv"."VULNERABILITY_ID"
        LOOP
            -- Infer analyzer identity based on the vuln's source
            IF "v_source" = 'INTERNAL' THEN
                SELECT 'INTERNAL_ANALYZER' INTO "v_analyzer_identity";
            ELSEIF "v_source" = 'NPM' THEN
                SELECT 'NPM_AUDIT_ANALYZER' INTO "v_analyzer_identity";
            ELSEIF "v_source" = 'OSSINDEX' THEN
                SELECT 'OSSINDEX_ANALYZER' INTO "v_analyzer_identity";
            ELSEIF "v_source" = 'VULNDB' THEN
                SELECT 'VULNDB_ANALYZER' INTO "v_analyzer_identity";
            ELSE
                SELECT 'NONE' INTO "v_analyzer_identity";
            END IF;

            INSERT INTO "FINDINGATTRIBUTION" ("ANALYZERIDENTITY", "COMPONENT_ID", "PROJECT_ID", "UUID",
                                              "VULNERABILITY_ID", "ATTRIBUTED_ON")
            VALUES ("v_analyzer_identity", "v_component_id", "v_project_id", "uuid_generate_v1"(),
                    "v_vulnerability_id", CURRENT_TIMESTAMP);
        END LOOP;
    RETURN TRUE;
END
$$;
SELECT "process_findings"();

DROP FUNCTION "process_findings";
