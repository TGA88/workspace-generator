import { RefObject, useEffect } from "react";

export default function useClickOutside(ref: RefObject<HTMLElement>, handler: () => void) {
    useEffect(() => {
      const listener = (event: MouseEvent | TouchEvent) => {
        if (!ref.current || ref.current.contains(event.target as Node)) {
          return;
        }
        handler();
      };
  
      document.addEventListener('mousedown', listener);
      document.addEventListener('touchstart', listener);
  
      return () => {
        document.removeEventListener('mousedown', listener);
        document.removeEventListener('touchstart', listener);
      };
    }, [ref, handler]);
  }
  
//  ตัวอย่างวิธีใช้
// components/Dropdown.tsx
// import { useRef, useState } from 'react';
// import { useClickOutside } from '../hooks/useClickOutside';

// interface DropdownProps {
//   items: string[];
//   onSelect: (item: string) => void;
// }

// function Dropdown({ items, onSelect }: DropdownProps) {
//   const [isOpen, setIsOpen] = useState(false);
//   const dropdownRef = useRef<HTMLDivElement>(null);
  
//   useClickOutside(dropdownRef, () => setIsOpen(false));

//   return (
//     <div ref={dropdownRef} className="relative">
//       <button
//         onClick={() => setIsOpen(!isOpen)}
//         className="px-4 py-2 border rounded"
//       >
//         Toggle Dropdown
//       </button>

//       {isOpen && (
//         <div className="absolute mt-2 w-48 bg-white border rounded shadow-lg">
//           {items.map((item, index) => (
//             <div
//               key={index}
//               className="px-4 py-2 hover:bg-gray-100 cursor-pointer"
//               onClick={() => {
//                 onSelect(item);
//                 setIsOpen(false);
//               }}
//             >
//               {item}
//             </div>
//           ))}
//         </div>
//       )}
//     </div>
//   );
// }

// // การใช้งาน Dropdown
// function App() {
//   const items = ['Option 1', 'Option 2', 'Option 3'];
  
//   const handleSelect = (item: string) => {
//     console.log('Selected:', item);
//   };

//   return (
//     <div className="p-4">
//       <Dropdown items={items} onSelect={handleSelect} />
//     </div>
//   );
// }
