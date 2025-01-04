'use client';
import { FeedInfoList } from '@fos-psc-web/feature-feed-info';

import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function FeedInfoListPage() {
  const t = useTranslations('feed_info');
  return (
    <Suspense>
      <div>
        <FeedInfoList t={t} />
      </div>
    </Suspense>
  );
}
