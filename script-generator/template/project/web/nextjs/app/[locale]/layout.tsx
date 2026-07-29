import React from 'react';
import '../globals.css';
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';

// <html>/<body> live in the ROOT layout (app/layout.tsx) ONLY — a nested layout that renders them
// too emits a document inside a document. <html lang> is a root concern.
export default async function LocaleLayout({
  children,
  params: { locale },
}: Readonly<{
  children: React.ReactNode;
  params: { locale: string };
}>): Promise<React.JSX.Element> {
  const messages = await getMessages();
  return (
    <NextIntlClientProvider locale={locale} messages={messages}>
      {children}
    </NextIntlClientProvider>
  );
}
