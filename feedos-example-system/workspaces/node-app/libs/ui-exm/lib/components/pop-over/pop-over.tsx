// components/Popover.tsx
import { ReactNode, useRef, useState } from 'react';
import useClickOutside  from '@ui-exm/hooks/use-click-outside';

interface PopoverProps {
  trigger: ReactNode;
  content: ReactNode;
}

export default function Popover({ trigger, content }: PopoverProps) {
  const [isOpen, setIsOpen] = useState(false);
  const popoverRef = useRef<HTMLDivElement>(null);
  
  useClickOutside(popoverRef, () => setIsOpen(false));

  return (
    <div ref={popoverRef} className="relative inline-block">
      <div onClick={() => setIsOpen(!isOpen)}>
        {trigger}
      </div>

      {isOpen && (
        <div className="absolute z-10 mt-2 w-64 bg-white border rounded shadow-lg p-4">
          {content}
        </div>
      )}
    </div>
  );
}

