import { ReactNode } from 'react';
import { PublicLayout } from '../components/publicLayout';

interface Props {
  children: ReactNode;
}

export default async function SsoLayout({ children }: Props) {
  return <PublicLayout>{children}</PublicLayout>;
}
