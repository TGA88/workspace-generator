'use client';
import { CreateVet } from '@fos-psc-web/feature-veterinarian';
import { Suspense } from 'react';
import CONFIG from '@fos-psc-web/config';
import { useTranslations } from 'next-intl';

export default function CreateVetPage() {
  const t = useTranslations('veterinarian');
  return (
    <Suspense>
      <div>
        <CreateVet t={t} imagePath={CONFIG.FOS_REPORT_STATIC_WEB} />
      </div>
    </Suspense>
  );
}
