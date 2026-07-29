import React from 'react';
import '../globals.css';
import { NextIntlClientProvider } from 'next-intl';
import { notFound } from 'next/navigation';
import { messages } from '../../messages';
import { routing } from '../../i18n/routing';

// static export: pre-render 1 หน้าต่อ locale (ไม่มี middleware/locale detection ตอน runtime)
export function generateStaticParams(): { locale: string }[] {
  return routing.locales.map((locale) => ({ locale }));
}

type Locale = (typeof routing.locales)[number];

type Props = {
  children: React.ReactNode;
  params: { locale: string };
};

// <html>/<body> อยู่ที่ root layout ตัวเดียว · messages โหลดแบบ static
// (getMessages()/cookies() ฝั่ง server ใช้กับ output:'export' ไม่ได้)
export default function LocaleLayout({ children, params: { locale } }: Readonly<Props>): React.JSX.Element {
  if (!routing.locales.includes(locale as Locale)) {
    notFound();
  }
  return (
    <NextIntlClientProvider locale={locale} messages={messages[locale as Locale]}>
      {children}
    </NextIntlClientProvider>
  );
}
