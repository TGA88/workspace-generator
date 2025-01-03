// components/Modal.tsx
import { ReactNode, useRef } from 'react';
import  useClickOutside  from '@ui-exm/hooks/use-click-outside'


interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  children: ReactNode;
}

export default  function Modal({ isOpen, onClose, children }: ModalProps) {
    const modalRef = useRef<HTMLDivElement>(null);
    useClickOutside(modalRef, onClose);
  
    if (!isOpen) return null;
  
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
        <div ref={modalRef} className="bg-white p-6 rounded-lg">
          {children}
        </div>
      </div>
    );
  }