'use client';
import { EditMedicine } from '@fos-psc-web/feature-medicine';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function EditMedicinePage() {
  const t = useTranslations('medicine');

  return (
    <Suspense>
      <div>
        <EditMedicine t={t} />
      </div>
    </Suspense>
  );
}
