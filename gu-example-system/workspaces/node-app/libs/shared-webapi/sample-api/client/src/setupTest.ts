

// jest.setup.ts

// // เก็บ function ดั้งเดิมไว้
// const originalLog = console.log
// const originalInfo = console.info 
// const originalDebug = console.debug

// override console methods
global.console.log = (): void => {}
global.console.warn = (): void => {}
global.console.info = (): void => {}
global.console.debug = (): void => {}
global.console.trace = (): void => {}

// console.error ยังคงทำงานตามปกติ


