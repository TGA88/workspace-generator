'use client';
import { FarmInfoList } from '@fos-psc-web/feature-farm-info';

import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function FarmInfoListPage() {
  const t = useTranslations('farm_info');
  return (
    <Suspense>
      <div>
        <FarmInfoList t={t} />
      </div>
    </Suspense>
  );
}
