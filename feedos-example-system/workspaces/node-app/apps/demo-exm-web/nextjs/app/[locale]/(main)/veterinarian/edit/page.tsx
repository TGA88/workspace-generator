'use client';
import { EditVet } from '@fos-psc-web/feature-veterinarian';
import { Suspense } from 'react';
import CONFIG from '@fos-psc-web/config';
import { useTranslations } from 'next-intl';

export default function EditVetPage() {
  const t = useTranslations('veterinarian');
  return (
    <Suspense>
      <div>
        <EditVet t={t} imagePath={CONFIG.FOS_REPORT_STATIC_WEB} />
      </div>
    </Suspense>
  );
}
