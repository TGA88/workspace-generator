-- CreateTable
CREATE TABLE "PRESCRIPTION" (
    "ID" TEXT NOT NULL,
    "PRESCRIPTION_ID" SERIAL,
    "DOCUMENT_NO" TEXT,
    "DOC_DATE" TIMESTAMP(3) NOT NULL,
    "START_DATE" TIMESTAMP(3) NOT NULL,
    "END_DATE" TIMESTAMP(3) NOT NULL,
    "STATUS" TEXT NOT NULL DEFAULT 'ACTIVE',
    "COUNTRY_CODE" TEXT NOT NULL,
    "COUNTRY_NAME" TEXT NOT NULL,
    "VETERINARIAN_CODE" TEXT NOT NULL,
    "VETERINARIAN_NAME" TEXT NOT NULL,
    "FARM_CODE" TEXT NOT NULL,
    "FARM_NAME" TEXT NOT NULL,
    "FARM_TYPE_CODE" TEXT NOT NULL,
    "FARM_TYPE_NAME" TEXT NOT NULL,
    "FARM_TYPE" TEXT,
    "FARM_ADDRESS" TEXT NOT NULL,
    "ANIMAL_TYPE_CODE" TEXT NOT NULL,
    "ANIMAL_TYPE_NAME" TEXT NOT NULL,
    "MEDICINE_TYPE_CODE" TEXT NOT NULL,
    "MEDICINE_TYPE_NAME" TEXT NOT NULL,
    "SPECIES_CODE" TEXT NOT NULL,
    "SPECIES_NAME" TEXT NOT NULL,
    "AGE" TEXT,
    "AGE_UNIT" TEXT,
    "ORDER_PLANT" TEXT NOT NULL,
    "ORDER_PLANT_CODE" TEXT,
    "RECEIVE_PLANT" TEXT NOT NULL,
    "RECEIVE_PLANT_CODE" TEXT,
    "REMARKS" TEXT,
    "CANCEL_REMARKS" TEXT,
    "SUBMIT_DATE" TIMESTAMP(3),
    "HOUSE" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "CANCEL_DATE" TIMESTAMP(3),
    "UPDATE_TIME" INTEGER DEFAULT 0,
    "DOC_NUMBER_RESERVE" TEXT,
    "FARM_LICENSE" TEXT,
    "PROFESSIONAL_LICENSE" TEXT,

    CONSTRAINT "PRESCRIPTION_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "PRESCRIPTION_DETAIL" (
    "ID" TEXT NOT NULL,
    "BRANDE_CODE" TEXT NOT NULL,
    "MED_CODE" TEXT NOT NULL,
    "DOCUMENT_NO" TEXT,
    "ELT_PERIOD" INTEGER,
    "ELT_PERIOD_UNIT" TEXT,
    "STOP_PERIOD" INTEGER,
    "STOP_PERIOD_UNIT" TEXT,
    "WARNING" TEXT,
    "QUANTITY" DOUBLE PRECISION,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "PRESCRIPTION_ID" TEXT NOT NULL,

    CONSTRAINT "PRESCRIPTION_DETAIL_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "PRESCRIPTION_ACTIVE_INGREDIENT" (
    "ID" TEXT NOT NULL,
    "ACTIVE_INGREDIENT_SEQ" INTEGER NOT NULL,
    "ACTIVE_INGREDIENT_CODE" TEXT NOT NULL,
    "ACTIVE_INGREDIENT_NAME" TEXT NOT NULL,
    "INGREDIENT_QUANTITY" DOUBLE PRECISION,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "PRESCRIPTION_DETAIL_ID" TEXT NOT NULL,

    CONSTRAINT "PRESCRIPTION_ACTIVE_INGREDIENT_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "PRESCRIPTION_REASON" (
    "ID" TEXT NOT NULL,
    "REASON_CODE" TEXT NOT NULL,
    "REASON_NAME" TEXT NOT NULL,
    "SEQUENCE_NO" INTEGER,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "PRESCRIPTION_ID" TEXT NOT NULL,

    CONSTRAINT "PRESCRIPTION_REASON_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "PRESCRIPTION_ANIMAL_PERIOD" (
    "ID" TEXT NOT NULL,
    "ANIMAL_PERIOD_CODE" TEXT NOT NULL,
    "ANIMAL_PERIOD_NAME" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "PRESCRIPTION_ID" TEXT NOT NULL,

    CONSTRAINT "PRESCRIPTION_ANIMAL_PERIOD_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_COUNTRY" (
    "ID" TEXT NOT NULL,
    "COUNTRY_CODE" TEXT NOT NULL,
    "COUNTRY_NAME" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_COUNTRY_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_COUNTRY_FARM" (
    "ID" TEXT NOT NULL,
    "COUNTRY_CODE" TEXT,
    "COUNTRY_NAME" TEXT,
    "FARM_CODE" TEXT,
    "FARM_NAME" TEXT,
    "FARM_TYPE_CODE" TEXT,
    "FARM_TYPE_NAME" TEXT,
    "CV_CODE" TEXT,
    "SPECIES_CODE" TEXT,
    "SPECIES_NAME" TEXT,
    "ANIMAL_NUMBER" TEXT,
    "ADDRESS" TEXT,
    "CITY" TEXT,
    "PROVINCE" TEXT,
    "POSTAL_CODE" TEXT,
    "DESC" TEXT,
    "CPFYN" TEXT,
    "ZONE" TEXT,
    "CON1" TEXT,
    "CON2" TEXT,
    "CON3" TEXT,
    "FULL_ADDRESS" TEXT,
    "EMAIL" TEXT,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "SUBZONE" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_COUNTRY_FARM_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_ORG" (
    "ID" TEXT NOT NULL,
    "COUNTRY_CODE" TEXT,
    "ORG_CODE" TEXT,
    "ORG_NAME" TEXT,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "ORG_SHORT_NAME" TEXT,
    "BU_CODE" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "MAS_COUNTRY_ID" TEXT,
    "BU_ID" TEXT,

    CONSTRAINT "MAS_ORG_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_ELT_INFO" (
    "ID" TEXT NOT NULL,
    "COUNTRY_CODE" TEXT,
    "ORG_CODE" TEXT,
    "PRODUCT_CODE" TEXT,
    "BRAND_CODE" TEXT,
    "SAP_CODE" TEXT,
    "PRODUCT_NAME" TEXT,
    "FORMULA_CODE" TEXT,
    "MAIN_FORMULA" TEXT,
    "MAIN_FORMULA_NAME" TEXT,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_ELT_INFO_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_MEDICINE" (
    "ID" TEXT NOT NULL,
    "MEDICINE_CAT" TEXT,
    "MEDICINE_GROUP" TEXT,
    "MEDICINE_TYPE_CODE" TEXT,
    "COUNTRY_CODE" TEXT,
    "COUNTRY_NAME" TEXT,
    "MEDICINE_CODE" TEXT,
    "MEDICINE_NAME_LOCAL" TEXT,
    "MEDICINE_NAME_ENG" TEXT,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "REGISTER_NUMBER" TEXT,
    "PACK_SIZE" DOUBLE PRECISION,
    "UNIT" TEXT,
    "ANIMAL_TYPE_CODE" TEXT,
    "ANIMAL_TYPE_NAME" TEXT,
    "WHO_CLASSIFICATION" TEXT,
    "STOP_MEDICATION" INTEGER,
    "STOP_UNIT" TEXT,
    "REASON" TEXT,
    "HOW_TO_USER" TEXT,
    "OBJECTIVE" TEXT,
    "SPECIES_SHOW_DESC" TEXT,
    "QT_STRING" TEXT,
    "WARNING" TEXT,
    "DISPLAY_INGREDIENT" TEXT,
    "COMMERCIAL" BOOLEAN,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_MEDICINE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_MEDICINE_SPECIES" (
    "ID" TEXT NOT NULL,
    "MEDICINE_CODE" TEXT,
    "SPECIES_CODE" TEXT,
    "SPECIES_NAME" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "MAS_MEDICINE_ID" TEXT,

    CONSTRAINT "MAS_MEDICINE_SPECIES_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_INGREDIENT" (
    "ID" TEXT NOT NULL,
    "INGREDIENT_CODE" TEXT,
    "INGREDIENT_NAME" TEXT,
    "QUANTITY" DOUBLE PRECISION,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "REF_CODE" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_INGREDIENT_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_MAPPING_MEDICINE_INGREDIENT" (
    "INGREDIENT_ID" TEXT NOT NULL,
    "INGREDIENT_CODE" TEXT,
    "MEDICINE_ID" TEXT NOT NULL,
    "MEDICINE_CODE" TEXT,
    "QUANTITY" DOUBLE PRECISION NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_MAPPING_MEDICINE_INGREDIENT_pkey" PRIMARY KEY ("INGREDIENT_ID","MEDICINE_ID")
);

-- CreateTable
CREATE TABLE "MAS_MEDICINE_ANIMALTYPE" (
    "ID" TEXT NOT NULL,
    "ANIMAL_TYPE_CODE" TEXT NOT NULL,
    "ANIMAL_TYPE_DESC" TEXT,
    "MEDICINE_ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_MEDICINE_ANIMALTYPE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "VETERINARIAN" (
    "ID" TEXT NOT NULL,
    "VETERINARIAN_ID" SERIAL,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "EMAIL" TEXT,
    "FIRST_NAME_LOCAL" TEXT,
    "FIRST_NAME_ENG" TEXT,
    "LAST_NAME_LOCAL" TEXT,
    "LAST_NAME_ENG" TEXT,
    "NAME_LOCAL" TEXT,
    "NAME_ENG" TEXT,
    "TITLE_CODE" TEXT,
    "FARM_LICENSE" TEXT,
    "FARM_LICENSE_CK" TEXT,
    "PROFESSIONAL_LICENSE" TEXT,
    "VETERINARIAN_CODE" TEXT,
    "POSITION" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "VETERINARIAN_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "VETERINARIAN_SIGNATURE" (
    "ID" TEXT NOT NULL,
    "S3_URL" TEXT,
    "VETERINARIAN_ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "VETERINARIAN_SIGNATURE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_GENERAL_TYPE" (
    "ID" TEXT NOT NULL,
    "GDTYPE" TEXT NOT NULL,
    "TYPE_DESCRIPTION" TEXT,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_GENERAL_TYPE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MAS_GENERAL_DESC" (
    "ID" TEXT NOT NULL,
    "MAS_GENERAL_TYPE_ID" TEXT NOT NULL,
    "GDCODE" TEXT NOT NULL,
    "LOCAL_DESCRIPTION" TEXT,
    "ENGLISH_DESCRIPTION" TEXT,
    "SPTYPE" TEXT,
    "SEQUENCE_NO" INTEGER,
    "CONDITION" TEXT,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_GENERAL_DESC_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "BIBLE" (
    "ID" TEXT NOT NULL,
    "SPECIES_CODE" TEXT NOT NULL,
    "SPECIES_NAME" TEXT,
    "BIBLE_STATUS" TEXT NOT NULL,
    "YEAR" INTEGER NOT NULL,
    "COUNTRY_CODE" TEXT,
    "COUNTRY_NAME" TEXT,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "REVISED" INTEGER,
    "MEDICINE_TYPE_CODE" TEXT,
    "MEDICINE_TYPE_NAME" TEXT,
    "SUBMIT_DATE" TIMESTAMP(3),
    "REMARKS" TEXT,
    "CANCEL_DATE" TIMESTAMP(3),
    "CANCEL_REASON" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "BIBLE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "BIBLE_DETAIL" (
    "ID" TEXT NOT NULL,
    "SPECIES_CODE" TEXT,
    "MEDICINE_CODE" TEXT,
    "MEDICINE_GROUP" TEXT,
    "MEDICINE_TYPE" TEXT,
    "COUNTRY_CODE" TEXT,
    "STATUS" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "BIBLE_ID" TEXT NOT NULL,

    CONSTRAINT "BIBLE_DETAIL_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "BIBLE_ANIMAL_TYPE" (
    "ID" TEXT NOT NULL,
    "ANIMAL_TYPE_CODE" TEXT,
    "ANIMAL_TYPE_NAME" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "BIBLE_ID" TEXT NOT NULL,

    CONSTRAINT "BIBLE_ANIMAL_TYPE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "BIBLE_DETAIL_MAPPING_MAS_MEDICINE" (
    "ID" TEXT NOT NULL,
    "BIBLE_DETAIL_ID" TEXT NOT NULL,
    "MAS_MEDICINE_ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "BIBLE_DETAIL_MAPPING_MAS_MEDICINE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "ACCOUNT" (
    "ID" TEXT NOT NULL,
    "EMAIL" TEXT NOT NULL,
    "FULL_NAME" TEXT,
    "USERNAME" TEXT NOT NULL,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "LOCAL_LANGUAGE" TEXT DEFAULT 'Thai',
    "VETERINARIAN_ID" TEXT,
    "IDENTIFY_ID" TEXT NOT NULL,
    "USERNAME_PORTAL" TEXT,
    "PROVIDER" TEXT,
    "ONBOARDING_USER_1" BOOLEAN DEFAULT false,
    "ONBOARDING_USER_2" BOOLEAN DEFAULT false,
    "ONBOARDING_VETERINARIAN" BOOLEAN DEFAULT false,
    "ONBOARDING_MATCHING_EMAIL" BOOLEAN DEFAULT false,
    "ONBOARDING_TUTORIAL_ORDER" BOOLEAN DEFAULT false,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "ACCOUNT_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "ACCOUNT_MAS_COUNTRY" (
    "ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "ACCOUNT_ID" TEXT NOT NULL,
    "MAS_COUNTRY_ID" TEXT NOT NULL,
    "COUNTRY_CODE" TEXT,

    CONSTRAINT "ACCOUNT_MAS_COUNTRY_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "ACCOUNT_MAS_SPECIES" (
    "ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "ACCOUNT_ID" TEXT NOT NULL,
    "SPECIES_CODE" TEXT NOT NULL,

    CONSTRAINT "ACCOUNT_MAS_SPECIES_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "ACCOUNT_MAS_COUNTRY_FARM" (
    "ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "ACCOUNT_ID" TEXT NOT NULL,
    "COUNTRY_FARM_ID" TEXT NOT NULL,

    CONSTRAINT "ACCOUNT_MAS_COUNTRY_FARM_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "ACCOUNT_MAS_FARM_TYPE" (
    "ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "ACCOUNT_ID" TEXT NOT NULL,
    "FARM_TYPE_CODE" TEXT NOT NULL,

    CONSTRAINT "ACCOUNT_MAS_FARM_TYPE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "FARM_ANIMAL_TYPE" (
    "ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "FARM_ID" TEXT NOT NULL,
    "ANIMAL_TYPE_CODE" TEXT,

    CONSTRAINT "FARM_ANIMAL_TYPE_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MATCHING_EMAIL" (
    "ID" TEXT NOT NULL,
    "GROUP_NAME" TEXT,
    "GROUP_TYPE" TEXT,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "EMAIL" TEXT,
    "PLANT_CODE" TEXT,
    "FARM_ORG" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MATCHING_EMAIL_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MATCHING_EMAIL_MAPPING_MAS_ORG" (
    "ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "MAS_ORG_ID" TEXT NOT NULL,
    "MATCHING_EMAIL_ID" TEXT NOT NULL,

    CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_ORG_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM" (
    "ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),
    "MAS_COUNTRY_FARM_ID" TEXT NOT NULL,
    "MATCHING_EMAIL_ID" TEXT NOT NULL,

    CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "SYNC_FM_BRAND_INFO" (
    "PLANT_CODE" TEXT NOT NULL,
    "BRAND_CODE" TEXT NOT NULL,
    "MEDICINE_FLAG" TEXT NOT NULL,
    "PACKSIZE_CODE" INTEGER NOT NULL,
    "PRODUCT_CODE" TEXT,
    "GRADE_CODE" TEXT,
    "FORMULA_CODE" TEXT,
    "PACKAGING_CODE" TEXT,
    "WEM_FORMULA" TEXT,
    "PROCESS_LINE" TEXT,
    "CANCEL_FLAG" TEXT,
    "USER_CREATE" TEXT,
    "CREATE_DATE" TIMESTAMP(3),
    "EXPIRE_DAY" INTEGER,
    "BLOCK_SALE" TEXT,
    "EXCEPT_SPECIAL_DISC" TEXT,
    "DESC_LOC" TEXT,
    "DESC_ENG" TEXT,

    CONSTRAINT "SYNC_FM_BRAND_INFO_pkey" PRIMARY KEY ("PLANT_CODE","BRAND_CODE","MEDICINE_FLAG","PACKSIZE_CODE")
);

-- CreateTable
CREATE TABLE "SYNC_FM_MAS_MEDICINE" (
    "PLANT_CODE" TEXT NOT NULL,
    "MEDICINE_CODE" TEXT NOT NULL,
    "DESC_LOC" TEXT,
    "DESC_ENG" TEXT,
    "OWNER" TEXT,
    "CREATE_DATE" TIMESTAMP(3),
    "LAST_UPDATE_OWNER" TEXT,
    "LAST_UPDATE_DATE" TIMESTAMP(3),
    "LAST_FUNCTION" TEXT,

    CONSTRAINT "SYNC_FM_MAS_MEDICINE_pkey" PRIMARY KEY ("PLANT_CODE","MEDICINE_CODE")
);

-- CreateTable
CREATE TABLE "SYNC_FM_INGREDIENT_INFO" (
    "PLANT_CODE" TEXT NOT NULL,
    "INGREDIENT_CODE" TEXT NOT NULL,
    "INGREDIENT_NAME" TEXT,
    "CANCEL_FLAG" TEXT,
    "USER_CREATE" TEXT,
    "CREATE_DATE" TIMESTAMP(3),
    "LAST_USER_ID" TEXT,
    "LAST_UPDATE_DATE" TIMESTAMP(3),
    "INGREDIENT_TYPE" TEXT,
    "INGREDIENT_PROCESS" TEXT,
    "FORMULA_FLAG" TEXT,

    CONSTRAINT "SYNC_FM_INGREDIENT_INFO_pkey" PRIMARY KEY ("PLANT_CODE","INGREDIENT_CODE")
);

-- CreateTable
CREATE TABLE "SYNC_FM_MAS_MAPPING_INGREDIENT_MED" (
    "PLANT_CODE" TEXT NOT NULL,
    "INGREDIENT_CODE" TEXT NOT NULL,
    "MEDICINE_CODE" TEXT NOT NULL,
    "OWNER" TEXT,
    "CREATE_DATE" TIMESTAMP(3),
    "LAST_UPDATE_OWNER" TEXT,
    "LAST_UPDATE_DATE" TIMESTAMP(3),
    "LAST_FUNCTION" TEXT,

    CONSTRAINT "SYNC_FM_MAS_MAPPING_INGREDIENT_MED_pkey" PRIMARY KEY ("PLANT_CODE","INGREDIENT_CODE","MEDICINE_CODE")
);

-- CreateTable
CREATE TABLE "SYNC_GD2_FM_MEDICINE" (
    "MEDICINE_CODE" TEXT NOT NULL,
    "DESC_LOC" TEXT,
    "DESC_ENG" TEXT,
    "CANCEL_FLAG" TEXT,
    "USER_CREATE" TEXT,
    "CREATE_DATE" TIMESTAMP(3),
    "LAST_USER_ID" TEXT,
    "LAST_UPDATE_DATE" TIMESTAMP(3),

    CONSTRAINT "SYNC_GD2_FM_MEDICINE_pkey" PRIMARY KEY ("MEDICINE_CODE")
);

-- CreateTable
CREATE TABLE "SYNC_MAS_PRODUCT_GENERAL" (
    "REF_ACCOUNT_PRODUCT" TEXT,
    "SHORT_PRODUCT_CODE" TEXT,
    "PRODUCT_CODE" TEXT NOT NULL,
    "DESC_LOC" TEXT,
    "DESC_ENG" TEXT,
    "COMMERCIAL_NAME" TEXT,
    "SEARCH_CODE" TEXT,
    "ACCOUNT_PRODUCT_TYPE" TEXT,
    "MIS_PRODUCT_TYPE" TEXT,
    "CANCEL_FLAG" TEXT,
    "USER_CREATE" TEXT,
    "CREATE_DATE" TIMESTAMP(3),
    "LAST_USER_ID" TEXT,
    "LAST_UPDATE_DATE" TIMESTAMP(3),
    "LAST_FUNCTION" TEXT,
    "SAP_MATERIAL_GROUP" TEXT,
    "SAP_PRODUCT_GROUP" TEXT,
    "PACKING_CONVERT_FLAG" TEXT,

    CONSTRAINT "SYNC_MAS_PRODUCT_GENERAL_pkey" PRIMARY KEY ("PRODUCT_CODE")
);

-- CreateTable
CREATE TABLE "MAS_BU" (
    "ID" TEXT NOT NULL,
    "BU_CODE" TEXT NOT NULL,
    "BU_NAME" TEXT NOT NULL,
    "BU_DESCRIPTION" TEXT NOT NULL,
    "STATUS" TEXT DEFAULT 'ACTIVE',
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "MAS_BU_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "FARM_ORG" (
    "ID" TEXT NOT NULL,
    "FARM_ID" TEXT NOT NULL,
    "FARM_CODE" TEXT NOT NULL,
    "BU_ID" TEXT NOT NULL,
    "CV_CODE" TEXT,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "FARM_ORG_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "ACCOUNT_ORG" (
    "ID" TEXT NOT NULL,
    "ORG_CODE" TEXT NOT NULL,
    "ORG_NAME" TEXT NOT NULL,
    "ACCOUNT_ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "ACCOUNT_ORG_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "ACCOUNT_BU" (
    "ID" TEXT NOT NULL,
    "BU_CODE" TEXT NOT NULL,
    "BU_NAME" TEXT NOT NULL,
    "ACCOUNT_ID" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "ACCOUNT_BU_pkey" PRIMARY KEY ("ID")
);

-- CreateTable
CREATE TABLE "ACCOUNT_ROLE" (
    "ID" TEXT NOT NULL,
    "ACCOUNT_ID" TEXT NOT NULL,
    "ROLE_CODE" TEXT NOT NULL,
    "ROLE_NAME" TEXT NOT NULL,
    "CREATE_BY" TEXT,
    "UPDATE_BY" TEXT,
    "CREATE_AT" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "UPDATE_AT" TIMESTAMP(3),

    CONSTRAINT "ACCOUNT_ROLE_pkey" PRIMARY KEY ("ID")
);

-- CreateIndex
CREATE UNIQUE INDEX "MAS_COUNTRY_COUNTRY_CODE_key" ON "MAS_COUNTRY"("COUNTRY_CODE");

-- CreateIndex
CREATE UNIQUE INDEX "MAS_COUNTRY_FARM_FARM_CODE_key" ON "MAS_COUNTRY_FARM"("FARM_CODE");

-- CreateIndex
CREATE UNIQUE INDEX "MAS_ORG_ORG_CODE_key" ON "MAS_ORG"("ORG_CODE");

-- CreateIndex
CREATE UNIQUE INDEX "MAS_MEDICINE_MEDICINE_CODE_key" ON "MAS_MEDICINE"("MEDICINE_CODE");

-- CreateIndex
CREATE UNIQUE INDEX "VETERINARIAN_VETERINARIAN_ID_key" ON "VETERINARIAN"("VETERINARIAN_ID");

-- CreateIndex
CREATE UNIQUE INDEX "VETERINARIAN_VETERINARIAN_CODE_key" ON "VETERINARIAN"("VETERINARIAN_CODE");

-- CreateIndex
CREATE UNIQUE INDEX "VETERINARIAN_SIGNATURE_VETERINARIAN_ID_key" ON "VETERINARIAN_SIGNATURE"("VETERINARIAN_ID");

-- CreateIndex
CREATE UNIQUE INDEX "MAS_GENERAL_TYPE_GDTYPE_key" ON "MAS_GENERAL_TYPE"("GDTYPE");

-- CreateIndex
CREATE UNIQUE INDEX "MAS_GENERAL_DESC_GDCODE_key" ON "MAS_GENERAL_DESC"("GDCODE");

-- CreateIndex
CREATE UNIQUE INDEX "ACCOUNT_USERNAME_key" ON "ACCOUNT"("USERNAME");

-- CreateIndex
CREATE UNIQUE INDEX "ACCOUNT_IDENTIFY_ID_key" ON "ACCOUNT"("IDENTIFY_ID");

-- CreateIndex
CREATE UNIQUE INDEX "MAS_BU_BU_NAME_key" ON "MAS_BU"("BU_NAME");

-- AddForeignKey
ALTER TABLE "PRESCRIPTION_DETAIL" ADD CONSTRAINT "PRESCRIPTION_DETAIL_PRESCRIPTION_ID_fkey" FOREIGN KEY ("PRESCRIPTION_ID") REFERENCES "PRESCRIPTION"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PRESCRIPTION_ACTIVE_INGREDIENT" ADD CONSTRAINT "PRESCRIPTION_ACTIVE_INGREDIENT_PRESCRIPTION_DETAIL_ID_fkey" FOREIGN KEY ("PRESCRIPTION_DETAIL_ID") REFERENCES "PRESCRIPTION_DETAIL"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PRESCRIPTION_REASON" ADD CONSTRAINT "PRESCRIPTION_REASON_PRESCRIPTION_ID_fkey" FOREIGN KEY ("PRESCRIPTION_ID") REFERENCES "PRESCRIPTION"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PRESCRIPTION_ANIMAL_PERIOD" ADD CONSTRAINT "PRESCRIPTION_ANIMAL_PERIOD_PRESCRIPTION_ID_fkey" FOREIGN KEY ("PRESCRIPTION_ID") REFERENCES "PRESCRIPTION"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MAS_ORG" ADD CONSTRAINT "MAS_ORG_MAS_COUNTRY_ID_fkey" FOREIGN KEY ("MAS_COUNTRY_ID") REFERENCES "MAS_COUNTRY"("ID") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MAS_ORG" ADD CONSTRAINT "MAS_ORG_BU_ID_fkey" FOREIGN KEY ("BU_ID") REFERENCES "MAS_BU"("ID") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MAS_MEDICINE_SPECIES" ADD CONSTRAINT "MAS_MEDICINE_SPECIES_MAS_MEDICINE_ID_fkey" FOREIGN KEY ("MAS_MEDICINE_ID") REFERENCES "MAS_MEDICINE"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MAS_MAPPING_MEDICINE_INGREDIENT" ADD CONSTRAINT "MAS_MAPPING_MEDICINE_INGREDIENT_INGREDIENT_ID_fkey" FOREIGN KEY ("INGREDIENT_ID") REFERENCES "MAS_INGREDIENT"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MAS_MAPPING_MEDICINE_INGREDIENT" ADD CONSTRAINT "MAS_MAPPING_MEDICINE_INGREDIENT_MEDICINE_ID_fkey" FOREIGN KEY ("MEDICINE_ID") REFERENCES "MAS_MEDICINE"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MAS_MEDICINE_ANIMALTYPE" ADD CONSTRAINT "MAS_MEDICINE_ANIMALTYPE_MEDICINE_ID_fkey" FOREIGN KEY ("MEDICINE_ID") REFERENCES "MAS_MEDICINE"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VETERINARIAN_SIGNATURE" ADD CONSTRAINT "VETERINARIAN_SIGNATURE_VETERINARIAN_ID_fkey" FOREIGN KEY ("VETERINARIAN_ID") REFERENCES "VETERINARIAN"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MAS_GENERAL_DESC" ADD CONSTRAINT "MAS_GENERAL_DESC_MAS_GENERAL_TYPE_ID_fkey" FOREIGN KEY ("MAS_GENERAL_TYPE_ID") REFERENCES "MAS_GENERAL_TYPE"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BIBLE_DETAIL" ADD CONSTRAINT "BIBLE_DETAIL_BIBLE_ID_fkey" FOREIGN KEY ("BIBLE_ID") REFERENCES "BIBLE"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BIBLE_ANIMAL_TYPE" ADD CONSTRAINT "BIBLE_ANIMAL_TYPE_BIBLE_ID_fkey" FOREIGN KEY ("BIBLE_ID") REFERENCES "BIBLE"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BIBLE_DETAIL_MAPPING_MAS_MEDICINE" ADD CONSTRAINT "BIBLE_DETAIL_MAPPING_MAS_MEDICINE_BIBLE_DETAIL_ID_fkey" FOREIGN KEY ("BIBLE_DETAIL_ID") REFERENCES "BIBLE_DETAIL"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BIBLE_DETAIL_MAPPING_MAS_MEDICINE" ADD CONSTRAINT "BIBLE_DETAIL_MAPPING_MAS_MEDICINE_MAS_MEDICINE_ID_fkey" FOREIGN KEY ("MAS_MEDICINE_ID") REFERENCES "MAS_MEDICINE"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT" ADD CONSTRAINT "ACCOUNT_VETERINARIAN_ID_fkey" FOREIGN KEY ("VETERINARIAN_ID") REFERENCES "VETERINARIAN"("ID") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_MAS_COUNTRY" ADD CONSTRAINT "ACCOUNT_MAS_COUNTRY_ACCOUNT_ID_fkey" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNT"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_MAS_COUNTRY" ADD CONSTRAINT "ACCOUNT_MAS_COUNTRY_MAS_COUNTRY_ID_fkey" FOREIGN KEY ("MAS_COUNTRY_ID") REFERENCES "MAS_COUNTRY"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_MAS_SPECIES" ADD CONSTRAINT "ACCOUNT_MAS_SPECIES_ACCOUNT_ID_fkey" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNT"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_MAS_SPECIES" ADD CONSTRAINT "ACCOUNT_MAS_SPECIES_SPECIES_CODE_fkey" FOREIGN KEY ("SPECIES_CODE") REFERENCES "MAS_GENERAL_DESC"("GDCODE") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_MAS_COUNTRY_FARM" ADD CONSTRAINT "ACCOUNT_MAS_COUNTRY_FARM_ACCOUNT_ID_fkey" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNT"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_MAS_COUNTRY_FARM" ADD CONSTRAINT "ACCOUNT_MAS_COUNTRY_FARM_COUNTRY_FARM_ID_fkey" FOREIGN KEY ("COUNTRY_FARM_ID") REFERENCES "MAS_COUNTRY_FARM"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_MAS_FARM_TYPE" ADD CONSTRAINT "ACCOUNT_MAS_FARM_TYPE_ACCOUNT_ID_fkey" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNT"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_MAS_FARM_TYPE" ADD CONSTRAINT "ACCOUNT_MAS_FARM_TYPE_FARM_TYPE_CODE_fkey" FOREIGN KEY ("FARM_TYPE_CODE") REFERENCES "MAS_GENERAL_DESC"("GDCODE") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FARM_ANIMAL_TYPE" ADD CONSTRAINT "FARM_ANIMAL_TYPE_FARM_ID_fkey" FOREIGN KEY ("FARM_ID") REFERENCES "MAS_COUNTRY_FARM"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MATCHING_EMAIL_MAPPING_MAS_ORG" ADD CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_ORG_MAS_ORG_ID_fkey" FOREIGN KEY ("MAS_ORG_ID") REFERENCES "MAS_ORG"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MATCHING_EMAIL_MAPPING_MAS_ORG" ADD CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_ORG_MATCHING_EMAIL_ID_fkey" FOREIGN KEY ("MATCHING_EMAIL_ID") REFERENCES "MATCHING_EMAIL"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM" ADD CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM_MAS_COUNTRY_FARM_I_fkey" FOREIGN KEY ("MAS_COUNTRY_FARM_ID") REFERENCES "MAS_COUNTRY_FARM"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM" ADD CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM_MATCHING_EMAIL_ID_fkey" FOREIGN KEY ("MATCHING_EMAIL_ID") REFERENCES "MATCHING_EMAIL"("ID") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FARM_ORG" ADD CONSTRAINT "FARM_ORG_FARM_ID_fkey" FOREIGN KEY ("FARM_ID") REFERENCES "MAS_COUNTRY_FARM"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FARM_ORG" ADD CONSTRAINT "FARM_ORG_BU_ID_fkey" FOREIGN KEY ("BU_ID") REFERENCES "MAS_BU"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_ORG" ADD CONSTRAINT "ACCOUNT_ORG_ACCOUNT_ID_fkey" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNT"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_BU" ADD CONSTRAINT "ACCOUNT_BU_ACCOUNT_ID_fkey" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNT"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ACCOUNT_ROLE" ADD CONSTRAINT "ACCOUNT_ROLE_ACCOUNT_ID_fkey" FOREIGN KEY ("ACCOUNT_ID") REFERENCES "ACCOUNT"("ID") ON DELETE RESTRICT ON UPDATE CASCADE;
