import { getRequestConfig } from 'next-intl/server';
import { routing } from './routing';

// static export (output:'export'): ไม่มี request header ให้อ่าน → server config ใช้ default locale คงที่
// locale ต่อหน้าใช้ [locale] route param + NextIntlClientProvider ฝั่ง client (app/[locale]/layout.tsx)
// requestLocale() อ่าน headers() ⇒ ใช้กับ static export ไม่ได้
export default getRequestConfig(async () => {
  const locale = routing.defaultLocale;
  return {
    locale,
    messages: (await import(`../messages/${locale}.json`)).default,
  };
});
