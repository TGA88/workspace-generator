import React from 'react';
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  // TODO(scaffold): ตั้งชื่อแอปจริง — placeholder ของ template (เดิม hardcode ชื่อโปรเจกต์อื่นติดมา)
  title: 'App',
  description: '',
  icons: {
    icon: ['/favicon.ico?v=4'],
    apple: ['/apple-touch-icon.png?v=4'],
    shortcut: ['/apple-touch-icon.png'],
  },
};

// เจ้าของ <html>/<body> เพียงตัวเดียวของแอป — layout ชั้นในห้าม render ซ้ำ
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>): React.JSX.Element {
  return (
    <html lang={'th'}>
      <body>{children}</body>
    </html>
  );
}
