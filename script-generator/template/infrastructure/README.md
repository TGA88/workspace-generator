# infrastructure — contract (SSOT) + db (init/seed) + tooling

**plain folder** (ไม่ใช่ node project — ไม่มี `package.json`) · เก็บ "สภาพแวดล้อมรัน" ของ api-test

```
infrastructure/
├── docker-compose.yml       # postgres + liquibase(one-shot) + api · service names ตรงกับ root Makefile
├── liquibase/
│   ├── changelog.yaml       # context migrate|init|seed · label domain:<name>
│   ├── liquibase.properties # ต่อ DB ตอนรัน CLI ตรงๆ
│   └── README.md
├── db/<db-schema>/
│   ├── init/{shared,tenant}/ # reference/lookup — production-like (context=init)
│   └── seed/{shared,tenant,<domain>-api}/  # test fixtures (context=seed) · domain โดย gen:api-contract
├── initdb/init.postgresql.sql   # CREATE SCHEMA ตอน postgres init
└── contract/                    # ★ SSOT (.json) — <service>/<domain>-api/<action>/ · gen:api-contract
```

- **contract** = SSOT: `contract/<service>/<domain>-api/<action>/` → `c*.json`/`e*.json` (envelope) +
  `setup.sql`/`teardown.sql` (action-level) + `setup.<case>.sql` (case-level) + `_cases.json` (manifest)
- **db** = init/seed แยกตาม scope (shared/tenant/domain) โหลดที่ bring-up ผ่าน liquibase
- ทุกอย่างรันผ่าน root `make api-test [DOMAIN=] [ACTION=]` (local == CI)

รายละเอียด strategy + naming → ดู handbook: Backend Test & Infrastructure + DB Architecture Standard (ARCH-STD-001)
