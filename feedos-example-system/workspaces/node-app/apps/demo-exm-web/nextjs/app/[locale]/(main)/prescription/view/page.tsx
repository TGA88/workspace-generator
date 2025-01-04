'use client';
import { ViewPrescription } from '@fos-psc-web/feature-prescription';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function ViewPrescriptionPage() {
  const t = useTranslations('prescription');
  return (
    <Suspense>
      <div>
        <ViewPrescription t={t} />
      </div>
    </Suspense>
  );
}
