-- DropForeignKey
ALTER TABLE "PRESCRIPTION_DETAIL" DROP CONSTRAINT "PRESCRIPTION_DETAIL_PRESCRIPTION_ID_fkey";

-- DropForeignKey
ALTER TABLE "PRESCRIPTION_ACTIVE_INGREDIENT" DROP CONSTRAINT "PRESCRIPTION_ACTIVE_INGREDIENT_PRESCRIPTION_DETAIL_ID_fkey";

-- DropForeignKey
ALTER TABLE "PRESCRIPTION_REASON" DROP CONSTRAINT "PRESCRIPTION_REASON_PRESCRIPTION_ID_fkey";

-- DropForeignKey
ALTER TABLE "PRESCRIPTION_ANIMAL_PERIOD" DROP CONSTRAINT "PRESCRIPTION_ANIMAL_PERIOD_PRESCRIPTION_ID_fkey";

-- DropForeignKey
ALTER TABLE "MAS_ORG" DROP CONSTRAINT "MAS_ORG_MAS_COUNTRY_ID_fkey";

-- DropForeignKey
ALTER TABLE "MAS_ORG" DROP CONSTRAINT "MAS_ORG_BU_ID_fkey";

-- DropForeignKey
ALTER TABLE "MAS_MEDICINE_SPECIES" DROP CONSTRAINT "MAS_MEDICINE_SPECIES_MAS_MEDICINE_ID_fkey";

-- DropForeignKey
ALTER TABLE "MAS_MAPPING_MEDICINE_INGREDIENT" DROP CONSTRAINT "MAS_MAPPING_MEDICINE_INGREDIENT_INGREDIENT_ID_fkey";

-- DropForeignKey
ALTER TABLE "MAS_MAPPING_MEDICINE_INGREDIENT" DROP CONSTRAINT "MAS_MAPPING_MEDICINE_INGREDIENT_MEDICINE_ID_fkey";

-- DropForeignKey
ALTER TABLE "MAS_MEDICINE_ANIMALTYPE" DROP CONSTRAINT "MAS_MEDICINE_ANIMALTYPE_MEDICINE_ID_fkey";

-- DropForeignKey
ALTER TABLE "VETERINARIAN_SIGNATURE" DROP CONSTRAINT "VETERINARIAN_SIGNATURE_VETERINARIAN_ID_fkey";

-- DropForeignKey
ALTER TABLE "MAS_GENERAL_DESC" DROP CONSTRAINT "MAS_GENERAL_DESC_MAS_GENERAL_TYPE_ID_fkey";

-- DropForeignKey
ALTER TABLE "BIBLE_DETAIL" DROP CONSTRAINT "BIBLE_DETAIL_BIBLE_ID_fkey";

-- DropForeignKey
ALTER TABLE "BIBLE_ANIMAL_TYPE" DROP CONSTRAINT "BIBLE_ANIMAL_TYPE_BIBLE_ID_fkey";

-- DropForeignKey
ALTER TABLE "BIBLE_DETAIL_MAPPING_MAS_MEDICINE" DROP CONSTRAINT "BIBLE_DETAIL_MAPPING_MAS_MEDICINE_BIBLE_DETAIL_ID_fkey";

-- DropForeignKey
ALTER TABLE "BIBLE_DETAIL_MAPPING_MAS_MEDICINE" DROP CONSTRAINT "BIBLE_DETAIL_MAPPING_MAS_MEDICINE_MAS_MEDICINE_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT" DROP CONSTRAINT "ACCOUNT_VETERINARIAN_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_MAS_COUNTRY" DROP CONSTRAINT "ACCOUNT_MAS_COUNTRY_ACCOUNT_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_MAS_COUNTRY" DROP CONSTRAINT "ACCOUNT_MAS_COUNTRY_MAS_COUNTRY_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_MAS_SPECIES" DROP CONSTRAINT "ACCOUNT_MAS_SPECIES_ACCOUNT_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_MAS_SPECIES" DROP CONSTRAINT "ACCOUNT_MAS_SPECIES_SPECIES_CODE_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_MAS_COUNTRY_FARM" DROP CONSTRAINT "ACCOUNT_MAS_COUNTRY_FARM_ACCOUNT_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_MAS_COUNTRY_FARM" DROP CONSTRAINT "ACCOUNT_MAS_COUNTRY_FARM_COUNTRY_FARM_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_MAS_FARM_TYPE" DROP CONSTRAINT "ACCOUNT_MAS_FARM_TYPE_ACCOUNT_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_MAS_FARM_TYPE" DROP CONSTRAINT "ACCOUNT_MAS_FARM_TYPE_FARM_TYPE_CODE_fkey";

-- DropForeignKey
ALTER TABLE "FARM_ANIMAL_TYPE" DROP CONSTRAINT "FARM_ANIMAL_TYPE_FARM_ID_fkey";

-- DropForeignKey
ALTER TABLE "MATCHING_EMAIL_MAPPING_MAS_ORG" DROP CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_ORG_MAS_ORG_ID_fkey";

-- DropForeignKey
ALTER TABLE "MATCHING_EMAIL_MAPPING_MAS_ORG" DROP CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_ORG_MATCHING_EMAIL_ID_fkey";

-- DropForeignKey
ALTER TABLE "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM" DROP CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM_MAS_COUNTRY_FARM_I_fkey";

-- DropForeignKey
ALTER TABLE "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM" DROP CONSTRAINT "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM_MATCHING_EMAIL_ID_fkey";

-- DropForeignKey
ALTER TABLE "FARM_ORG" DROP CONSTRAINT "FARM_ORG_FARM_ID_fkey";

-- DropForeignKey
ALTER TABLE "FARM_ORG" DROP CONSTRAINT "FARM_ORG_BU_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_ORG" DROP CONSTRAINT "ACCOUNT_ORG_ACCOUNT_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_BU" DROP CONSTRAINT "ACCOUNT_BU_ACCOUNT_ID_fkey";

-- DropForeignKey
ALTER TABLE "ACCOUNT_ROLE" DROP CONSTRAINT "ACCOUNT_ROLE_ACCOUNT_ID_fkey";

-- DropTable
DROP TABLE "PRESCRIPTION";

-- DropTable
DROP TABLE "PRESCRIPTION_DETAIL";

-- DropTable
DROP TABLE "PRESCRIPTION_ACTIVE_INGREDIENT";

-- DropTable
DROP TABLE "PRESCRIPTION_REASON";

-- DropTable
DROP TABLE "PRESCRIPTION_ANIMAL_PERIOD";

-- DropTable
DROP TABLE "MAS_COUNTRY";

-- DropTable
DROP TABLE "MAS_COUNTRY_FARM";

-- DropTable
DROP TABLE "MAS_ORG";

-- DropTable
DROP TABLE "MAS_ELT_INFO";

-- DropTable
DROP TABLE "MAS_MEDICINE";

-- DropTable
DROP TABLE "MAS_MEDICINE_SPECIES";

-- DropTable
DROP TABLE "MAS_INGREDIENT";

-- DropTable
DROP TABLE "MAS_MAPPING_MEDICINE_INGREDIENT";

-- DropTable
DROP TABLE "MAS_MEDICINE_ANIMALTYPE";

-- DropTable
DROP TABLE "VETERINARIAN";

-- DropTable
DROP TABLE "VETERINARIAN_SIGNATURE";

-- DropTable
DROP TABLE "MAS_GENERAL_TYPE";

-- DropTable
DROP TABLE "MAS_GENERAL_DESC";

-- DropTable
DROP TABLE "BIBLE";

-- DropTable
DROP TABLE "BIBLE_DETAIL";

-- DropTable
DROP TABLE "BIBLE_ANIMAL_TYPE";

-- DropTable
DROP TABLE "BIBLE_DETAIL_MAPPING_MAS_MEDICINE";

-- DropTable
DROP TABLE "ACCOUNT";

-- DropTable
DROP TABLE "ACCOUNT_MAS_COUNTRY";

-- DropTable
DROP TABLE "ACCOUNT_MAS_SPECIES";

-- DropTable
DROP TABLE "ACCOUNT_MAS_COUNTRY_FARM";

-- DropTable
DROP TABLE "ACCOUNT_MAS_FARM_TYPE";

-- DropTable
DROP TABLE "FARM_ANIMAL_TYPE";

-- DropTable
DROP TABLE "MATCHING_EMAIL";

-- DropTable
DROP TABLE "MATCHING_EMAIL_MAPPING_MAS_ORG";

-- DropTable
DROP TABLE "MATCHING_EMAIL_MAPPING_MAS_COUNTRY_FARM";

-- DropTable
DROP TABLE "SYNC_FM_BRAND_INFO";

-- DropTable
DROP TABLE "SYNC_FM_MAS_MEDICINE";

-- DropTable
DROP TABLE "SYNC_FM_INGREDIENT_INFO";

-- DropTable
DROP TABLE "SYNC_FM_MAS_MAPPING_INGREDIENT_MED";

-- DropTable
DROP TABLE "SYNC_GD2_FM_MEDICINE";

-- DropTable
DROP TABLE "SYNC_MAS_PRODUCT_GENERAL";

-- DropTable
DROP TABLE "MAS_BU";

-- DropTable
DROP TABLE "FARM_ORG";

-- DropTable
DROP TABLE "ACCOUNT_ORG";

-- DropTable
DROP TABLE "ACCOUNT_BU";

-- DropTable
DROP TABLE "ACCOUNT_ROLE";

