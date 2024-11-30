'use client'
// ตัวอย่างการใช้งาน MUI และ Tailwind ร่วมกัน
import  Button  from "@mui/material/Button";
import {useUsers} from './hooks/useUsers'

function MyComponent() {
  const {loading,error} = useUsers()
  if (loading){
    return <p>loading</p>
  }
  if (error){
    return <p>{error.message}</p>
  }

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