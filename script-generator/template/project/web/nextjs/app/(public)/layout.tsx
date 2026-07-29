import React from 'react';
import '../globals.css';
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';
import { routing } from '../../i18n/routing';

// non-localed public group → provide the default-locale messages so useTranslations works.
// <html>/<body> live in the ROOT layout only (same reason as app/[locale]/layout.tsx).
export default async function PublicLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>): Promise<React.JSX.Element> {
  const messages = await getMessages();
  return (
    <NextIntlClientProvider locale={routing.defaultLocale} messages={messages}>
      {children}
    </NextIntlClientProvider>
  );
}
