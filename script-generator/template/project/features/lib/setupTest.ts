import '@testing-library/jest-dom';
// MSW server lifecycle (listen/reset/close) อยู่ที่ integration test ของ feature เอง
// (mocks/ ย้ายเป็นของ per-feature — global setup ไม่รู้จัก feature ไหนใช้ MSW บ้าง)
