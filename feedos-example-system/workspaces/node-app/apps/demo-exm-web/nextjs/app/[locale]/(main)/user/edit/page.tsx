'use client';
import { EditUser } from '@fos-psc-web/feature-user-management';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function EditUserPage() {
  const t = useTranslations('user');
  return (
    <Suspense>
      <div>
        <EditUser t={t} />
      </div>
    </Suspense>
  );
}
