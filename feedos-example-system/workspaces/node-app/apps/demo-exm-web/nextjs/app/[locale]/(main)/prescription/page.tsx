'use client';
import { ListPrescription } from '@fos-psc-web/feature-prescription';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function ListPrescriptionPage() {
  const t = useTranslations('prescription');
  return (
    <Suspense>
      <div>
        <ListPrescription t={t} />
      </div>
    </Suspense>
  );
}
