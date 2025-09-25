import React, { useEffect, useState } from "react";
import { getHello } from "./api/helloApi";

function App() {
  const [message, setMessage] = useState("");

  useEffect(() => {
    getHello().then(setMessage);
  }, []);

  return <div>{message}</div>;
}

export default App;
