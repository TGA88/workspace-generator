'use client';

import * as React from 'react';

type HelloProps = {
  t?: (key: string) => string;
} & React.HTMLAttributes<HTMLDivElement>;

const Hello: React.FC<HelloProps> = (props) => {
  return (
    <p className="text-32 font-bold text-[#101828]" id="pageTitle" data-testid="pageTitle">
     Dislplay: {props.t?.('say')}
    </p>
  );
};

export default Hello;
