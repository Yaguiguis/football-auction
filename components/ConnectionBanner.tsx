"use client";

import { useEffect, useRef, useState } from "react";

export default function ConnectionBanner() {
  const [online, setOnline] = useState(true);
  const [restored, setRestored] = useState(false);
  const wasOffline = useRef(false);

  useEffect(() => {
    setOnline(navigator.onLine);

    const onOffline = () => {
      wasOffline.current = true;
      setOnline(false);
      setRestored(false);
    };

    const onOnline = () => {
      setOnline(true);
      if (wasOffline.current) {
        setRestored(true);
        window.setTimeout(() => setRestored(false), 3500);
      }
    };

    window.addEventListener("offline", onOffline);
    window.addEventListener("online", onOnline);
    return () => {
      window.removeEventListener("offline", onOffline);
      window.removeEventListener("online", onOnline);
    };
  }, []);

  if (!online) {
    return (
      <div className="connection-banner offline">
        Sem conexão. O jogo continua para os outros participantes e tenta te reconectar automaticamente.
      </div>
    );
  }

  if (restored) {
    return <div className="connection-banner restored">Conexão restaurada. Você voltou para a sala.</div>;
  }

  return null;
}
