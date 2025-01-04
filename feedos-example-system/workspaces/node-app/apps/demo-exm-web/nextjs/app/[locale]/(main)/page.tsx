'use client';
import React from 'react';
import { ListBi } from '@fos-psc-web/feature-home';
import CONFIG from '@fos-psc-web/config';

export default function Home() {
  return <ListBi imagePath={CONFIG.FOS_REPORT_STATIC_WEB} idBi={CONFIG.ID_BI} />;
}
