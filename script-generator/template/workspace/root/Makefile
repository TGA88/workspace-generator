# __WS__ — root entrypoint (local == CI)
# ห่อ docker-compose (topology) + liquibase (migrate/init/seed) + backend-test (node:test)
# ทุก target เรียกจาก git root · CI checkout ลง root แล้วเรียก target เดียวกับ local
#
# ใช้:
#   make api-test                                  # ทุก domain (bring-up สด → test → down -v)
#   make api-test DOMAIN=product-api               # เฉพาะ domain
#   make api-test DOMAIN=product-api ACTION=create-product   # เฉพาะ action
#
# recipe ใช้รูปแบบ `target: ; cmd` (inline) เพื่อเลี่ยงปัญหา TAB ในไฟล์ generate
# (.editorconfig + .gitattributes บังคับ Makefile = TAB/LF อยู่แล้ว ถ้าจะเพิ่ม recipe แบบหลายบรรทัด)

# ⚠️ อย่าใส่คอมเมนต์ `#` ท้ายบรรทัด assignment — make เก็บ space ก่อน `#` เข้าไปในค่า (พัง TEST_PATH)
# SERVICE = webapi app (service) = โฟลเดอร์ใน backend-test/ + contract/
# DOMAIN  = ว่าง = ทุก domain (เช่น product-api) · ACTION = ว่าง = ทุก action (เช่น create-product)
SERVICE ?= __SERVICE__
DOMAIN  ?=
ACTION  ?=

COMPOSE = docker compose -f workspaces/infrastructure/docker-compose.yml --project-directory workspaces/infrastructure
LB      = $(COMPOSE) run --rm liquibase

.PHONY: up migrate init seed api-up down test api-test help

up:      ; $(COMPOSE) up -d postgres
migrate: ; $(LB) update --context-filter=migrate
init:    ; $(LB) update --context-filter=init
seed:    ; $(LB) update --context-filter=seed $(if $(DOMAIN),--label-filter="shared OR domain:$(DOMAIN)")
api-up:  ; $(COMPOSE) up -d --build --wait api
down:    ; $(COMPOSE) down -v

# backend-test = standalone package (นอก node-app pnpm workspace) → cd เข้าไปให้ tsx/pg resolve
# path ใน test file อ้าง contract แบบ file-relative (../../../infrastructure) → cwd ไม่กระทบ
# ⚠️ node --test ต้องได้ "ไฟล์" ระบุตรงๆ — dir/argless discovery ครอบเฉพาะ .js, glob รองรับเฉพาะ node22+
#    → ใช้ find enumerate .test.ts (ปลอดภัยทุกเวอร์ชัน) · action ระบุ = ไฟล์เดียว
BT        = workspaces/backend-test
TEST_FILES = $(if $(ACTION),$(SERVICE)/$(DOMAIN)/$(ACTION).test.ts,$$(find $(SERVICE)$(if $(DOMAIN),/$(DOMAIN)) -name '*.test.ts'))
test:    ; cd $(BT) && node --test --import tsx $(TEST_FILES)

# full pipeline (local == CI) — DB สดทุกครั้ง (down -v ท้าย)
api-test: up migrate init seed api-up test down

help: ; @echo "targets: up migrate init seed api-up test down api-test  | vars: SERVICE=$(SERVICE) DOMAIN=<d>-api ACTION=<verb>-<d>"
