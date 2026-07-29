// static export: bundle ข้อความทุก locale ตั้งแต่ build (getMessages() ฝั่ง server ใช้ไม่ได้)
import en from './en.json';
import th from './th.json';

export const messages = { en, th };
