'use client';
import { ListUserManagement } from '@fos-psc-web/feature-user-management';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';
import CONFIG from '@fos-psc-web/config';

export default function ListUserPage() {
  const t = useTranslations('user');
  const t2 = useTranslations('onboarding');

  return (
    <Suspense>
      <div>
        <ListUserManagement t={t} t2={t2} imagePath={CONFIG.FOS_REPORT_STATIC_WEB} />
      </div>
    </Suspense>
  );
}
