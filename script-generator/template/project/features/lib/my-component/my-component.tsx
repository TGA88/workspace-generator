'use client'
// ตัวอย่างการใช้งาน MUI และ Tailwind ร่วมกัน
import  Button  from "@mui/material/Button";

function MyComponent() {
    return (
      <Button 
        variant="contained" 
        className="mt-4 hover:opacity-80"
      >
        Click me
      </Button>
    );
  }

  export default MyComponent