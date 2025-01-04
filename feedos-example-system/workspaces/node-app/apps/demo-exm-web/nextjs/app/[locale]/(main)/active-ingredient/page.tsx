'use client';
import { ListActiveIngredient } from '@fos-psc-web/feature-ingredient';
import { useTranslations } from 'next-intl';
import { Suspense } from 'react';

export default function ListActiveIngredientPage() {
  const t = useTranslations('ingredient');
  return (
    <Suspense>
      <div>
        <ListActiveIngredient t={t} />
      </div>
    </Suspense>
  );
}
