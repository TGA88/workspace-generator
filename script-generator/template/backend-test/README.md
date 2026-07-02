# backend-test — black-box api-test (node:test, out-of-process)

ทดสอบ service ที่ **รันจริง** (ยิง HTTP + DB จริง) แบบ black-box · ไม่ผูกภาษา impl ·
data-driven จาก `infrastructure/contract/` (SSOT) · **1 action = 1 test file** · runner = **`node:test`**

```
backend-test/                        # standalone package (นอก node-app pnpm workspace)
├── package.json                     # deps: tsx (รัน .ts) + pg (setup/teardown sql)
├── lib/                             # harness: httpRequest · runSqlFile · assertContract · loadCases
├── _conformance/                    # contract-conformance skeleton (validate เทียบ core types)
└── <service>/<domain>-api/<action>.test.ts   # gen:api-contract สร้างคู่กับ contract folder
```

## รัน (ผ่าน root Makefile — bring-up สด → test → down)
```
make api-test                                          # ทุก domain
make api-test DOMAIN=product-api                       # เฉพาะ domain
make api-test DOMAIN=product-api ACTION=create-product # เฉพาะ action
```

## setup ครั้งแรก
เป็น package แยก → ติดตั้ง deps ในโฟลเดอร์นี้ก่อน (ครั้งเดียว):
```
cd workspaces/backend-test && pnpm install     # หรือ npm install
```
env override ได้: `API_BASE_URL` (default `http://localhost:3010`) · `DATABASE_URL` · `DB_SCHEMA_NAME`

> migrate/init/seed(shared/tenant/domain) โหลดที่ bring-up ผ่าน make+liquibase (นอกไฟล์เทสต์) ·
> ไฟล์เทสต์จัดการแค่ setup/teardown ราย **action** (`before`/`after`) และ **case** (ใน `it()`)
