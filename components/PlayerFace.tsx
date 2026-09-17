"use client";

import { useEffect, useMemo, useState } from "react";

type PlayerFaceProps = {
  name: string;
  imageUrl?: string | null;
  size?: number;
};

export default function PlayerFace({ name, imageUrl, size = 56 }: PlayerFaceProps) {
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    setFailed(false);
  }, [imageUrl]);

  const initials = useMemo(() => {
    const parts = name.trim().split(/\s+/).filter(Boolean);
    if (!parts.length) return "?";
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }, [name]);

  const baseStyle = {
    width: size,
    height: size,
    borderRadius: "50%",
    border: "2px solid rgba(255,255,255,.22)",
    boxShadow: "0 8px 24px rgba(0,0,0,.28)",
    flex: "0 0 auto",
  } as const;

  if (imageUrl && !failed) {
    return (
      <img
        src={imageUrl}
        alt={`Foto de ${name}`}
        loading="lazy"
        referrerPolicy="no-referrer"
        onError={() => setFailed(true)}
        style={{
          ...baseStyle,
          display: "block",
          objectFit: "cover",
          objectPosition: "center top",
          background: "#171717",
        }}
      />
    );
  }

  return (
    <div
      aria-label={`Sem foto cadastrada para ${name}`}
      title="Foto ainda não cadastrada"
      style={{
        ...baseStyle,
        display: "grid",
        placeItems: "center",
        background: "linear-gradient(145deg, #262626, #111)",
        color: "#fff",
        fontWeight: 900,
        fontSize: Math.max(12, Math.round(size * 0.28)),
        letterSpacing: 1,
      }}
    >
      {initials}
    </div>
  );
}
