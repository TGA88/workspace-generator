'use client';
import { ListBible } from '@fos-psc-web/feature-bible';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function ListBiblePage() {
  const t = useTranslations('bible');
  return (
    <Suspense>
      <div>
        <ListBible t={t} />
      </div>
    </Suspense>
  );
}
