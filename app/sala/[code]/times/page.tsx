"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";

type Room = { id: string; code: string; mode: "football" | "futsal"; status: string };
type Member = {
  id: string;
  display_name: string;
  balance: number;
  is_host: boolean;
  squad_finalized: boolean;
};
type SquadRow = { member_id: string; player_id: string; slot_key: string };
type Player = { id: string; name: string; primary_position: string; overall: number | null };

type BoardSlot = { key: string; label: string; x: number; y: number };

const footballBoard: BoardSlot[] = [
  { key: "GOL", label: "GOL", x: 50, y: 91 },
  { key: "LE", label: "LE", x: 14, y: 72 },
  { key: "ZAG1", label: "ZAG E", x: 37, y: 76 },
  { key: "ZAG2", label: "ZAG D", x: 63, y: 76 },
  { key: "LD", label: "LD", x: 86, y: 72 },
  { key: "VOL", label: "VOL", x: 50, y: 58 },
  { key: "MC", label: "MC", x: 30, y: 44 },
  { key: "MEI", label: "MEI", x: 70, y: 44 },
  { key: "PE", label: "PE", x: 18, y: 22 },
  { key: "ATA", label: "ATA", x: 50, y: 15 },
  { key: "PD", label: "PD", x: 82, y: 22 },
];

const futsalBoard: BoardSlot[] = [
  { key: "GOL", label: "GOL", x: 50, y: 88 },
  { key: "LINHA1", label: "LINHA", x: 28, y: 60 },
  { key: "LINHA2", label: "LINHA", x: 72, y: 60 },
  { key: "LINHA3", label: "LINHA", x: 28, y: 30 },
  { key: "LINHA4", label: "LINHA", x: 72, y: 30 },
];

export default function TeamsPage() {
  const params = useParams<{ code: string }>();
  const code = String(params.code).toUpperCase();
  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [squads, setSquads] = useState<SquadRow[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    await ensureAnonymousSession();
    const supabase = getSupabase();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,mode,status")
      .eq("code", code)
      .single();
    if (roomError) throw roomError;
    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const { data: memberData, error: memberError } = await supabase
      .from("fa_room_members")
      .select("id,display_name,balance,is_host,squad_finalized")
      .eq("room_id", typedRoom.id)
      .order("joined_at");
    if (memberError) throw memberError;
    const typedMembers = (memberData || []) as Member[];
    setMembers(typedMembers);

    const memberIds = typedMembers.map((m) => m.id);
    if (memberIds.length === 0) {
      setSquads([]);
      setPlayers([]);
      return;
    }

    const { data: squadData, error: squadError } = await supabase
      .from("fa_squad_players")
      .select("member_id,player_id,slot_key")
      .in("member_id", memberIds);
    if (squadError) throw squadError;
    const typedSquads = (squadData || []) as SquadRow[];
    setSquads(typedSquads);

    const playerIds = Array.from(new Set(typedSquads.map((s) => s.player_id)));
    if (playerIds.length === 0) {
      setPlayers([]);
      return;
    }

    const { data: playerData, error: playerError } = await supabase
      .from("fa_players")
      .select("id,name,primary_position,overall")
      .in("id", playerIds);
    if (playerError) throw playerError;
    setPlayers((playerData || []) as Player[]);
  }, [code]);

  useEffect(() => {
    load()
      .catch((e) => setError(e instanceof Error ? e.message : "Erro ao carregar as escalações."))
      .finally(() => setLoading(false));
  }, [load]);

  useEffect(() => {
    if (!room?.id) return;
    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:teams:${room.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_squad_players" }, () => load())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => load())
      .subscribe();
    return () => { supabase.removeChannel(channel); };
  }, [room?.id, load]);

  const playerById = useMemo(() => new Map(players.map((p) => [p.id, p])), [players]);
  const boardSlots = room?.mode === "futsal" ? futsalBoard : footballBoard;

  if (loading) return <main className="container"><p>Montando as pranchetas...</p></main>;

  return (
    <main className="container">
      <div className="topbar">
        <div>
          <p className="red" style={{ margin: 0, fontWeight: 900, letterSpacing: 2 }}>RESULTADO DOS ELENCOS</p>
          <h1 style={{ marginTop: 6 }}>Pranchetas finais</h1>
        </div>
        <span className="badge">Sala {code}</span>
      </div>

      {error && <div className="card"><p className="red">{error}</p></div>}

      <div className="grid" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(340px, 1fr))" }}>
        {members.map((member) => {
          const memberSquad = squads.filter((s) => s.member_id === member.id);
          const memberPlayers = memberSquad
            .map((s) => playerById.get(s.player_id))
            .filter((p): p is Player => !!p);
          const ger = memberPlayers.length
            ? Math.round(memberPlayers.reduce((sum, p) => sum + (p.overall ?? 70), 0) / memberPlayers.length)
            : 0;
          const bySlot = new Map(memberSquad.map((s) => [s.slot_key, playerById.get(s.player_id)]));

          return (
            <section className="card" key={member.id}>
              <div className="topbar" style={{ marginBottom: 14 }}>
                <div>
                  <h2 style={{ margin: 0 }}>{member.is_host ? "👑 " : ""}{member.display_name}</h2>
                  <p className="muted" style={{ margin: "5px 0 0" }}>{member.squad_finalized ? "Time finalizado" : "Montando time"}</p>
                </div>
                <div style={{ textAlign: "center", minWidth: 74 }}>
                  <div className="red" style={{ fontSize: 34, fontWeight: 900, lineHeight: 1 }}>{ger}</div>
                  <small className="muted">GER</small>
                </div>
              </div>

              <div style={{
                position: "relative",
                width: "100%",
                maxWidth: 520,
                margin: "0 auto",
                aspectRatio: room?.mode === "futsal" ? "3 / 4" : "68 / 105",
                border: "2px solid rgba(255,255,255,.7)",
                borderRadius: 18,
                overflow: "hidden",
                background: "linear-gradient(180deg, #173f2d 0%, #102d22 100%)",
              }}>
                <div style={{ position: "absolute", left: 0, right: 0, top: "50%", borderTop: "1px solid rgba(255,255,255,.45)" }} />
                <div style={{ position: "absolute", left: "35%", top: "43%", width: "30%", aspectRatio: "1", border: "1px solid rgba(255,255,255,.35)", borderRadius: "50%" }} />
                <div style={{ position: "absolute", left: "23%", right: "23%", bottom: 0, height: "14%", border: "1px solid rgba(255,255,255,.4)", borderBottom: 0 }} />
                <div style={{ position: "absolute", left: "23%", right: "23%", top: 0, height: "14%", border: "1px solid rgba(255,255,255,.4)", borderTop: 0 }} />

                {boardSlots.map((slot) => {
                  const p = bySlot.get(slot.key);
                  return (
                    <div key={slot.key} style={{
                      position: "absolute",
                      left: `${slot.x}%`,
                      top: `${slot.y}%`,
                      transform: "translate(-50%, -50%)",
                      width: 88,
                      textAlign: "center",
                    }}>
                      <div style={{
                        background: p ? "#0b0b0b" : "rgba(0,0,0,.35)",
                        border: p ? "2px solid #e50914" : "1px dashed rgba(255,255,255,.5)",
                        borderRadius: 12,
                        padding: "7px 5px",
                        boxShadow: p ? "0 6px 18px rgba(0,0,0,.35)" : "none",
                      }}>
                        <div style={{ color: p ? "#fff" : "#aaa", fontSize: 10, fontWeight: 900 }}>{slot.label}</div>
                        <div style={{ fontSize: 11, fontWeight: 800, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{p?.name || "Vazio"}</div>
                        {p?.overall && <div className="red" style={{ fontSize: 13, fontWeight: 900 }}>{p.overall}</div>}
                      </div>
                    </div>
                  );
                })}
              </div>

              <div style={{ display: "flex", justifyContent: "space-between", gap: 12, marginTop: 14 }}>
                <span className="muted">{memberPlayers.length}/{boardSlots.length} jogadores</span>
                <strong>{member.balance} créditos restantes</strong>
              </div>
            </section>
          );
        })}
      </div>
    </main>
  );
}
