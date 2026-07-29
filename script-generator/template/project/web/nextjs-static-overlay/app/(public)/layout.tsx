import React from 'react';
import '../globals.css';
import { NextIntlClientProvider } from 'next-intl';
import { messages } from '../../messages';
import { routing } from '../../i18n/routing';

type Props = {
  children: React.ReactNode;
};

// route group ที่ไม่มี [locale] → ใช้ messages ของ default locale เพื่อให้ useTranslations ทำงาน
export default function PublicLayout({ children }: Readonly<Props>): React.JSX.Element {
  const locale = routing.defaultLocale;
  return (
    <NextIntlClientProvider locale={locale} messages={messages[locale]}>
      {children}
    </NextIntlClientProvider>
  );
}
