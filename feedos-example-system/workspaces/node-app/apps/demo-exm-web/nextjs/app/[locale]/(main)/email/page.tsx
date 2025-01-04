'use client';
import { ListMatchingEmail } from '@fos-psc-web/feature-matching-email';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';
import CONFIG from '@fos-psc-web/config';

export default function ListMatchingEmailPage() {
  const t = useTranslations('email');
  const t2 = useTranslations('onboarding');

  return (
    <Suspense>
      <div>
        <ListMatchingEmail t={t} t2={t2} imagePath={CONFIG.FOS_REPORT_STATIC_WEB} />
      </div>
    </Suspense>
  );
}
