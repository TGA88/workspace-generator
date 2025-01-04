'use client';

import { CreateMedicine } from '@fos-psc-web/feature-medicine';
import { useTranslations } from 'next-intl';

import { Suspense } from 'react';

export default function CreateMedicinePage() {
  const t = useTranslations('medicine');

  return (
    <Suspense>
      <div>
        <CreateMedicine t={t} />
      </div>
    </Suspense>
  );
}
