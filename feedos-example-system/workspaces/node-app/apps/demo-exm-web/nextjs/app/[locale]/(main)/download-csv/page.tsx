'use client';
import CONFIG from '@fos-psc-web/config';
import { DownloadCsv } from '@fos-psc-web/feature-prescription-report';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function DownloadCsvPage() {
  const t = useTranslations('prescription_report');
  return (
    <Suspense>
      <div>
        <DownloadCsv url={CONFIG.FOS_REPORT_STATIC_WEB} t={t} />
      </div>
    </Suspense>
  );
}
