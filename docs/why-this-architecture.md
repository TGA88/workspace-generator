# ทำไม Template ถึง "ดูเยอะ" — เหตุผลเบื้องหลังที่ทีมต้องเข้าใจ

เอกสารนี้เขียนสำหรับ developer ในทีมที่เปิด workspace นี้มาครั้งแรกแล้วรู้สึกว่า "ทำไมมันเยอะจัง / นี่มัน over-engineering รึเปล่า" — เป็นความรู้สึกที่ถูกต้องและควรตั้งคำถาม เอกสารนี้จะตอบทีละข้อว่าความซับซ้อนแต่ละชิ้น **กันความเจ็บปวดอะไร** และ **จะเกิดอะไรถ้าเราไม่มีมัน**

> เอกสาร "ทำงานยังไง" อยู่ที่ [export-strategy.md](./export-strategy.md) — ไฟล์นี้ตอบคนละคำถาม คือ "ทำไมต้องมี"

## อ่านอันนี้ก่อน: เรากำลังซื้ออะไร

ความซับซ้อนทั้งหมดในนี้ไม่ได้แลกมาด้วย "โค้ดที่ดูสวย" แต่แลกมาด้วย **optionality** — ความสามารถในการเปลี่ยนใจทีหลังโดยไม่ต้อง rewrite

ทีมส่วนใหญ่ที่เริ่มแบบ "เขียนรวมๆ ไปก่อน เดี๋ยวค่อย refactor" มาถึงจุดที่ refactor ไม่ได้แล้ว เพราะทุกอย่างผูกกันหมด การลงทุนโครงสร้างตอนนี้คือการจ่ายล่วงหน้าเพื่อไม่ต้องจ่ายก้อนใหญ่ (ที่มักจ่ายไม่ไหว) ตอนระบบโต

คำถามที่ถูกไม่ใช่ "อันนี้ over-engineering ไหม" แต่คือ **"ความซับซ้อนชิ้นนี้ กันความเสี่ยงที่เรามีจริงไหม"** — ถ้ากันความเสี่ยงที่เราไม่มี มันคือ over-engineering จริง แต่ถ้ากันความเสี่ยงที่เรามี มันคือ insurance

---

## ตอบทีละข้อที่ "ดูเยอะ"

> section 1-7 เป็นฝั่ง **backend libs** / section 8-10 เป็นฝั่ง **frontend libs**

### 1. ทำไมแบ่ง layer เยอะ (core / data / client / service / app) — backend

**ดูเหมือน:** แค่ดึงข้อมูลมาแสดง ทำไมต้องผ่านตั้ง 5 ชั้น

**กันอะไร:** กันไม่ให้ business logic ปนกับ infrastructure ผลคือ logic ส่วนใหญ่กลายเป็น pure function ที่ test ได้โดยไม่ต้อง mock database/HTTP/config — เขียน test 1 บรรทัด ไม่ใช่ setup 50 บรรทัด

**ถ้าไม่มี:** validation จะกระจายอยู่ใน controller บ้าง service บ้าง helper บ้าง — คนใหม่แก้ bug เดียวต้อง grep ทั้ง codebase, และพอ traffic พุ่งจนต้องแยก service จะ refactor ไม่ได้เพราะทุกอย่างผูกกัน

**เมื่อไหร่ไม่คุ้ม:** prototype ที่รู้ว่าจะทิ้ง, script ใช้ครั้งเดียว, ทีม 1 คนที่ scope เล็กและไม่มีแผนโต

### 2. ทำไม dependency ต้องไหลทางเดียว + ห้าม import ข้าม layer

**ดูเหมือน:** กฎจุกจิก ทำไมไม่ import ตรงๆ ให้จบ

**กันอะไร:** กัน circular dependency ที่แก้ไม่จบ และทำให้ Nx trace affected graph ได้แม่นยำ — แก้ที่หนึ่งรู้ทันทีว่ากระทบอะไรบ้าง CI build เฉพาะส่วนที่เปลี่ยน

**ถ้าไม่มี:** วันหนึ่งจะอยากแยก feature ออกมาแล้วพบว่า import กันวนจนตัดไม่ได้ แตะโค้ดที่เดียวกระทบทั้งระบบ — นี่คือสภาพที่ทำให้ระบบ "แก้อะไรก็พังที่อื่น"

### 3. ทำไม contract/type อยู่ที่ share-core ที่เดียว

**ดูเหมือน:** ทำไมไม่ประกาศ type ตรงที่ใช้ ให้มันใกล้ๆ

**กันอะไร:** กัน type ซ้ำ 3 ที่ (data/service/controller) ที่ TypeScript ไม่เตือนเวลาแก้ไม่ครบ เพราะมันเป็น structural type แยกกัน — มี source of truth เดียว แก้ที่เดียว error เด้งทุกจุดที่เกี่ยว

**ถ้าไม่มี:** เปลี่ยน field จาก `string` เป็น enum แล้วลืมแก้ที่หนึ่ง — โค้ด compile ผ่าน แต่พัง runtime

### 4. ทำไม exports field ละเอียดถึงระดับ action (ไม่ export รวมก้อนเดียว)

**ดูเหมือน:** ทำไมไม่ `export *` จาก index เดียวให้จบ

**กันอะไร:** บังคับ encapsulation จริง (import ลึกเกินที่อนุญาตไม่ได้ทั้ง runtime และ TS), ทำให้ Nx affected ละเอียดระดับ action, และให้ bundler ฝั่ง consumer tree-shake ของที่ไม่ใช้ออกได้ → bundle เล็กลง

**ถ้าไม่มี:** consumer reach เข้า internal ของเราได้ทุกที่ พอเราจะ refactor internal ก็พังของคนอื่น — encapsulation ที่เป็นแค่ "convention" ไม่มีใครเคารพตอน deadline บีบ

### 5. ทำไมต้องมี dev-condition export strategy (development → src)

**ดูเหมือน:** package.json มี exports ซ้อนหลายชั้น งงไปหมด

**กันอะไร:** ทำให้ lint/test/build รันได้ทันทีโดย **ไม่ต้อง build dependency ก่อน** — ตอนเขียนโค้ดแก้ core แล้ว service เห็นทันที ไม่มีขั้น build คั่นกลางทุกครั้งที่แก้

**ถ้าไม่มี:** ทุกครั้งที่แก้ lib ที่คนอื่นใช้ ต้อง build มันก่อน เพื่อนถึงจะ lint/test ผ่าน — ที่ scale ~100 projects เสียเวลานี้ไปมหาศาล (เคยวัดจริง: เปิด strategy นี้แล้ว dev loop ต่อ project เหลือหลักวินาที และ build ของ lib ทุกตัวขนานกันได้ ไม่ต้องเรียงลำดับ)

### 6. ทำไมแยก UI เป็น lib + Storybook ทั้งที่เป็นแอปเดียว

**ดูเหมือน:** UI ใช้แค่ในแอปเดียว ทำไมไม่เขียนใน app ไปเลย

**กันอะไร:** ทำให้ component เป็น pure React ที่ไม่ผูกกับ Next → ย้าย framework ได้ และ **ทดสอบ React version ใหม่ได้โดยไม่กระทบ production app** (สร้าง canary app ที่ override react เป็นเวอร์ชันใหม่ ชี้มา lib เดิม ทดสอบ แล้ว production ยัง pin เวอร์ชัน stable)

**ถ้าไม่มี:** UI จะค่อยๆ ซึม `next/image`, `next/link`, server context เข้าไปจน decouple ไม่ได้ และวันที่ React major version ใหม่ออก จะอัปเกรดทั้งแอปรวดเดียวแบบเสี่ยงๆ แทนที่จะทดสอบ lib แยกก่อน

**เมื่อไหร่ไม่คุ้ม:** UI ที่ผูกกับ business ของแอปนี้โดยเฉพาะ ไม่มีวันย้ายไปไหน และไม่มีแผนทดสอบข้าม version — อันนั้นเก็บใน app พอ

### 7. ทำไม share-core มี dependencies เป็น {} เสมอ

**ดูเหมือน:** กฎเข้มไป ทำไมห้ามลง package ใน core

**กันอะไร:** เพราะทุก package depend core — ถ้า core ลาก dependency อะไรเข้ามา มันกลายเป็น transitive dependency ของทุกตัว และทำให้ Nx affected ทำงานผิด (แก้ core ดึง package ที่ไม่เกี่ยวมา rebuild หมด)

**สัญญาณว่าออกแบบผิด:** เมื่อไหร่ที่กำลังจะ `import` อะไรเข้า core — แปลว่า logic นั้นควรอยู่ที่ service ไม่ใช่ core

---

## Frontend libs

section 1-7 ข้างบนเป็นเหตุผลของฝั่ง **backend** (core/data/client/service/app) — ฝั่ง **frontend** มีปรัชญาเดียวกันแต่หน้าตาต่างกัน หัวข้อนี้ตอบ "ทำไม" ส่วน "อย่างไร" (กฎละเอียด, naming, promotion, import, Nx tags) อยู่ใน [frontend-structure.md](./frontend-structure.md)

### 8. ทำไมแบ่ง frontend เป็น feature / ui-components / ui-functions / ui-state-&lt;vendor&gt;

**ดูเหมือน:** ก็แค่หน้าเว็บ ทำไมต้องซอยเป็นหลายประเภท lib

**กันอะไร:** เป็น layer เดียวกับ backend แต่คนละมิติ — แยก **business** (`feature-*`) ออกจาก **reusable** (`ui-components`, `ui-functions`) และ **state** (`ui-state-<vendor>`) ผลคือ component/function ที่ reusable ทดสอบและ reuse ได้โดยไม่ลาก business มาด้วย, slice/reducer test ได้โดยไม่ต้อง mount UI, และแต่ละชิ้นยกไปเป็น project แยก/publish ได้เมื่อโตขึ้น

**ถ้าไม่มี:** ทุกอย่างกองใน feature เดียว — component ที่ควร reuse ถูก copy-paste ข้าม feature, pure function ปนกับ component จน test ต้อง render, และพอจะแยกของ shared ออกก็ทำไม่ได้เพราะมันผูกกับ business ของ feature นั้นไปแล้ว

**naming ที่ถูก:** shared component = `ui-components` (ไม่ใช่ `ui`), shared state = `ui-state-<vendor>` เสมอ เช่น `ui-state-redux` (ไม่มี `ui-state` เฉยๆ — vendor ต่อท้ายเสมอ เพราะ redux/zustand swap กันไม่ได้จริง รวมไว้ตัวเดียวจะพัง affected/release)

**เมื่อไหร่ไม่คุ้ม:** หน้าเดียวง่ายๆ ไม่มี component reuse ไม่มี state ซับซ้อน — เก็บใน feature ตัวเดียวพอ อย่าซอยล่วงหน้า

### 9. ทำไม feature ห้าม import feature อื่น

**ดูเหมือน:** ก็แค่ import มาใช้ ทำไมต้องห้าม

**กันอะไร:** กัน "distributed monolith ระดับ folder" — ถ้า `feature-cart` อ้าง `feature-checkout` ได้ ทั้งสองก็ผูกกันจนลบ/แยก/ย้ายไม่ได้ทีละตัว กฎนี้บังคับว่า **ถ้าของถูกใช้ 2 feature = มันไม่ใช่ของ feature ใดเลย ต้องยกขึ้น shared** ทำให้ shared code ไปอยู่ที่ถูกที่โดยอัตโนมัติ

**ถ้าไม่มี:** feature ค่อยๆ อ้างกันไปมาจนกลายเป็นก้อนเดียว — แก้ feature หนึ่งกระทบอีกหลายตัว, เขียน test ต้อง setup feature อื่นด้วย, และเป้าหมาย "feature แยกขาด deploy/promote ได้" หายไป

**enforce ยังไง:** กฎนี้เผลอละเมิดง่ายสุดตอนรีบ จึงต้องบังคับด้วย `@nx/enforce-module-boundaries` (tag `type:feature` ห้าม depend `type:feature`) ไม่ใช่พึ่งวินัยคน — รายละเอียดใน [frontend-structure.md §11](./frontend-structure.md#11-enforce-ด้วยเครื่อง)

### 10. ทำไมเริ่มเป็น folder ใน lib ก่อน แล้วค่อยแตกเป็น project

**ดูเหมือน:** ในเมื่อ template มี project type ui-components/ui-state ให้ ทำไมไม่สร้างแยกตั้งแต่แรก

**กันอะไร:** กัน over-engineering — แยก project มีต้นทุน (build/test/export/version แยก) ที่ไม่คุ้มถ้าของข้างในใช้ที่เดียว เริ่มเป็น folder ใน lib ของ web ที่ใช้ก่อน แล้วยกเป็น project เมื่อมี **consumer ตัวที่ 2** จริง เพราะตั้งชื่อ folder = ชื่อ project type ตั้งแต่แรก การ promote จึงเป็นแค่ "ย้าย" ไม่ใช่ "rewrite"

**ถ้าไม่มี:** ได้ project เปล่าๆ เต็มไปหมดที่มีของตัวเดียวข้างใน — จ่ายค่าความซับซ้อนโดยไม่ได้ประโยชน์ ตรงกับนิยาม over-engineering ที่เอกสารนี้พยายามกัน

---

## หลักการตัดสินใจ (ใช้เวลาเจอของที่ "ดูเยอะ")

เวลาเจอความซับซ้อนในนี้แล้วสงสัยว่าจำเป็นไหม ถามตัวเอง 3 ข้อ:

1. **มันกันความเสี่ยงที่เรามีจริงไหม** — ถ้าระบบเราจะโต/มีหลายทีม/ต้อง scale → ใช่ ถ้าเป็น throwaway → ไม่ใช่ ลัดได้
2. **ถ้าลัดตอนนี้ ราคาที่จ่ายทีหลังเท่าไหร่** — บางอย่างเพิ่มทีหลังถูก (เพิ่ม test) บางอย่างเพิ่มทีหลังแพงมหาศาล (แยก layer ตอนผูกกันหมดแล้ว) — โครงสร้างในนี้เน้นกันเฉพาะอย่างหลัง
3. **การลัดของฉันทำลาย optionality ของคนอื่นไหม** — เช่น import ข้าม layer ของฉันคนเดียวดูไม่เป็นไร แต่มันเปิดประตูให้ทุกคนทำตาม จนกฎหมดความหมาย

## เส้นที่ห้ามข้าม (ถ้าข้าม โครงสร้างพังเงียบ)

แม้จะรู้สึกว่าเยอะ แต่ข้อเหล่านี้คือสิ่งที่ทำให้ทุกอย่างข้างบนทำงาน ห้าม bypass:

1. dependency ไหลทางเดียวเสมอ — ห้าม import ย้อนหรือข้าม layer (รับผ่าน DI ที่ app)
2. ห้ามมี logic ใน share-core / ห้าม core มี dependencies
3. `development` ต้องเป็น key แรกของทุก exports entry
4. `react`/`react-dom` (และ vendor ของ state เช่น `react-redux`) เป็น `peerDependencies` ใน UI lib เสมอ (ไม่งั้น dual-React/redux)
5. dist จาก build มือ ห้ามเอาไป deploy/publish — ใช้ `nx release` / `build:all`
6. **feature ห้าม import feature อื่น** — ของที่ใช้ร่วมต้องยกขึ้น shared (enforce ด้วย Nx tags)
7. **`createStore`/`configureStore` ห้ามอยู่ใน lib** — lib เก็บแค่ slice/reducer/action, store สร้างที่ consumer

## สรุปให้ทีม

โครงสร้างนี้ไม่ใช่ "ทำให้ดูโปร" แต่คือการแลกเวลาเรียนรู้ช่วงแรก กับการไม่ต้อง rewrite ตอนโต ถ้าทีมเข้าใจ "ทำไม" ของแต่ละชิ้น จะใช้มันถูกและไม่ลัดผิดจุด — แต่ถ้าใช้โดยไม่เข้าใจ มันจะกลายเป็น over-engineering จริงๆ เพราะจ่ายค่าความซับซ้อนโดยไม่ได้ประโยชน์ที่มันออกแบบมาให้

ความซับซ้อนที่เข้าใจแล้ว = เครื่องมือ / ความซับซ้อนที่ไม่เข้าใจ = ภาระ — เอกสารนี้มีไว้ทำให้มันเป็นอย่างแรก
