import { useState } from "react";

export default function useLocalStorage<T>(key: string, initialValue: T) {
    const [storedValue, setStoredValue] = useState<T>(() => {
      try {
        
        const item = window.localStorage.getItem(key);
        return item ? JSON.parse(item) : initialValue;
         
      } catch (_err) {
        console.warn(_err)
        return initialValue;
      }
    });

  
    const setValue = (value: T | ((val: T) => T)) => {
      try {
        const valueToStore = value instanceof Function ? value(storedValue) : value;
        setStoredValue(valueToStore);
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
      } catch (error) {
        console.error(error);
      }
    };
  
    return [storedValue, setValue] as const;
  }
  
//   // วิธีใช้
//   const [theme, setTheme] = useLocalStorage('theme', 'light');