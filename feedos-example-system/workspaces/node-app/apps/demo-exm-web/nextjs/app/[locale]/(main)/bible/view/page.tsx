'use client';
import { ViewBible } from '@fos-psc-web/feature-bible';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function ViewBiblePage() {
  const t = useTranslations('bible');
  return (
    <Suspense>
      <div>
        <ViewBible t={t} />
      </div>
    </Suspense>
  );
}
