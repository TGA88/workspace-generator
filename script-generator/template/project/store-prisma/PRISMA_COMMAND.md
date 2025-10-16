# Prisma Commands

## Initialize Prisma

```sh
npx prisma init --datasource-provider postgresql
```

## Prisma Generate

```sh
npx prisma generate
```

## Migrate the Schema

```sh
npx prisma migrate dev --name [migrate name]
```

## Create Migrate Only

```sh
npx prisma  migrate dev --create-only
```

## Deploy to Production (use in CI/CD)

```sh
npx prisma migrate deploy
```

## Generate Migrate Down

For more information, refer to the [Prisma documentation](https://www.prisma.io/docs/guides/database/developing-with-prisma-migrate/generating-down-migrations#how-to-generate-and-run-down-migrations).

1. Edit schema (e.g., add field, rename column, add relation, etc.).
2. Generate down script with the command:
   ```sh
   npx prisma migrate diff --from-schema-datamodel prisma/schema.prisma --to-schema-datasource prisma/schema.prisma --script > down.sql
   ```
3. Generate migrate up script:
   ```sh
   npx prisma migrate dev --name [migrate name]
   ```
4. Copy `down.sql` to the folder `migrate` in step (3).

## Execute Migrate Down Script

```sh
npx prisma db execute --file prisma/migrations/20250313025434_add_table_audit_plan_datelist/down.sql --schema prisma/schema.prisma
```

```sh
npx prisma migrate resolve --rolled-back 20230113114307_test
```

## Note

If custom generate does not work, go to the `/prisma-client-js` that was generated. Then, in the `index.js` file, find the `findSync` function and update the paths:

```js
"prisma/generated/prisma-client-js",
"generated/prisma-client-js",
```

to the full paths, such as:

```js
"libs/student-store-prisma/src/generated/prisma-client-js",
"student-store-prisma/src/generated/prisma-client-js",
```
