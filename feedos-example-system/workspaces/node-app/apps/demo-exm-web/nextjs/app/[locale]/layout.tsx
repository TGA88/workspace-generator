import React from 'react';
import '../globals.css';
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';
import { cookies } from 'next/headers';
import { CustomLayout } from '../components/customLayout';

export default async function LocaleLayout({
  children,
  params: { locale },
}: Readonly<{
  children: React.ReactNode;
  params: { locale: string };
}>) {
  const messages = await getMessages();
  const cookieStore = cookies();
  const lang = cookieStore.get('NEXT_LOCALE')?.value;
  return (
    <html lang={locale ?? lang}>
      <body>
        <NextIntlClientProvider messages={messages}>
          <CustomLayout>{children}</CustomLayout>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
