'use client';

import { ListMedicine } from '@fos-psc-web/feature-medicine';
import { Suspense } from 'react';
import { useTranslations } from 'next-intl';

export default function ListMedicinePage() {
    const t = useTranslations('medicine');

    return (
        <Suspense>
            <div>
                <ListMedicine t={t} />
            </div>
        </Suspense>
    );
}
