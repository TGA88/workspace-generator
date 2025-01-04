'use client';
import { Suspense } from 'react';
import { SsoFoslogin } from '@fos-psc-web/feature-prescription';
import CONFIG from '@fos-psc-web/config';

export default function SsoFosloginPage() {
  return (
    <Suspense>
      <div>
        <SsoFoslogin portalApi={CONFIG.PORTAL_API} />
      </div>
    </Suspense>
  );
}
