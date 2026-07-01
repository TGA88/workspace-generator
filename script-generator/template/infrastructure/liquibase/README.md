# liquibase — migrate / init / seed (context) + domain (label)

changelog เดียวคุม 3 เฟสด้วย **context** และ scope ราย domain ด้วย **label** — รันผ่าน root `Makefile`
(ไม่ต้องเรียก liquibase ตรงๆ):

```
make migrate                     # context=migrate — DDL (prisma migrations)
make init                        # context=init    — reference/lookup
make seed                        # context=seed    — test fixtures (ทุก domain)
make seed DOMAIN=product-api     # context=seed + label-filter "shared OR domain:product-api"
```

- **context** = เฟส (`migrate` | `init` | `seed`) → เลือกด้วย `--context-filter`
- **label** = `domain:<name>-api` (+ `shared`) → เลือกด้วย `--label-filter` (คุมผ่าน `DOMAIN=` ใน make)
- **searchPath** ครอบ `db/` (init/seed) + `prisma/` (DDL migrations, mount จาก node-app) — ดู `docker-compose.yml`
- ⚠️ **ทุก changeSet ต้องมี `rollback`** (ชี้ `*.down.sql` คู่กับ up) — `make down -v` ล้างทั้ง volume แต่
  ต้องมี rollback ต่อ changeSet ไว้ย้อนราย context/label ได้ (`liquibase rollback` โดยไม่ down ทั้งหมด)

domain seed changeSet ถูกแทรกอัตโนมัติโดย `gen:api-contract` ที่ anchor ใน `changelog.yaml`
(context `seed` + label `domain:<domain>-api` + rollback → `base.down.sql`).
