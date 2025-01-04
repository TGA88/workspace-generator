'use client';

import { ErrorFailed } from '@fos-psc-web/feature-prescription';
import { Suspense } from 'react';
import CONFIG from '@fos-psc-web/config';

export default function ErrorFailedPage() {

    const goto = CONFIG.PORTAL_WEB +
        '?returnUrl=' +
        CONFIG.FOS_WEB +
        `/ssofoslogin?returnUrl=/`;

    return (
        <Suspense>
            <div>
                <ErrorFailed goto={goto} />
            </div>
        </Suspense>
    );
}
