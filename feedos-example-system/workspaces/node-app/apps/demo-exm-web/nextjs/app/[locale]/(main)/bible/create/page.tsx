'use client';
import { CreateBible } from '@fos-psc-web/feature-bible';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function CreateBiblePage() {
  const t = useTranslations('bible');
  return (
    <Suspense>
      <div>
        <CreateBible t={t} />
      </div>
    </Suspense>
  );
}
