'use client';
import { ListVeterinarian } from '@fos-psc-web/feature-veterinarian';
import CONFIG from '@fos-psc-web/config';

import { Suspense } from 'react';
import { useTranslations } from 'next-intl';

export default function ListVeterinarianPage() {
  const t = useTranslations('veterinarian');
  const t2 = useTranslations('onboarding');

  return (
    <Suspense>
      <div>
        <ListVeterinarian t={t} t2={t2} imagePath={CONFIG.FOS_REPORT_STATIC_WEB} />
      </div>
    </Suspense>
  );
}
