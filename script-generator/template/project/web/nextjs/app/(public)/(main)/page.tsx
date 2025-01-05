'use client';
import { useTranslations } from 'next-intl';

import  HelloComponent from '../../components/hello'
import { Suspense } from 'react';
export default function Home() {
  const t = useTranslations('hello');
  return (
    <Suspense>
      <div>
        <HelloComponent t={t} />
      </div>
    </Suspense>
  );
}
