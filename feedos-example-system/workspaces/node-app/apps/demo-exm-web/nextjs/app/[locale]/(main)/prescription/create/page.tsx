'use client';
import { CreatePrescription } from '@fos-psc-web/feature-prescription';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function CreatePrescriptionPage() {
  const t = useTranslations('prescription');
  return (
    <Suspense>
      <div>
        <CreatePrescription t={t} />
      </div>
    </Suspense>
  );
}
