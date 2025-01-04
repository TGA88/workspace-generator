'use client';
import { ViewUser } from '@fos-psc-web/feature-user-management';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function ViewUserPage() {
  const t = useTranslations('user');
  return (
    <Suspense>
      <div>
        <ViewUser t={t} />
      </div>
    </Suspense>
  );
}
