'use client';
import { EditPrescription } from '@fos-psc-web/feature-prescription';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function EditPrescriptionPage() {
  const t = useTranslations('prescription');
  return (
    <Suspense>
      <div>
        <EditPrescription t={t} />
      </div>
    </Suspense>
  );
}
