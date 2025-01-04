'use client';
import { ReactNode } from 'react';
import { Provider } from 'react-redux';
import { store } from '@fos-psc-web/utils';

interface Props {
  children: ReactNode;
}

export const PublicLayout = ({ children }: Props) => {
  return <Provider store={store}>{children}</Provider>;
};
