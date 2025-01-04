'use client';
import { CreateUser } from '@fos-psc-web/feature-user-management';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function CreateUserPage() {
  const t = useTranslations('user');
  return (
    <Suspense>
      <div>
        <CreateUser t={t} />
      </div>
    </Suspense>
  );
}
