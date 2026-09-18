"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";
import { boardForMode, effectiveGer, squadGer, type GameMode, type RatedPlayer } from "../../../../lib/squad-board";
import PlayerFace from "../../../../components/PlayerFace";

type Room = { id: string; code: string; host_user_id: string; mode: GameMode; status: string };
type Member = {
  id: string;
  user_id: string;
  display_name: string;
  balance: number;
  is_host: boolean;
  squad_finalized: boolean;
  replay_requested: boolean;
};
type SquadRow = { member_id: string; player_id: string; slot_key: string };
type Player = RatedPlayer;

export default function TeamsPage() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();
  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [squads, setSquads] = useState<SquadRow[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [userId, setUserId] = useState("");
  const [loading, setLoading] = useState(true);
  const [replaying, setReplaying] = useState(false);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    const session = await ensureAnonymousSession();
    setUserId(session.user.id);
    const supabase = getSupabase();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,mode,status")
      .eq("code", code)
      .single();
    if (roomError) throw roomError;
    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const { data: memberData, error: memberError } = await supabase
      .from("fa_room_members")
      .select("id,user_id,display_name,balance,is_host,squad_finalized,replay_requested")
      .eq("room_id", typedRoom.id)
      .order("joined_at");
    if (memberError) throw memberError;
    const typedMembers = (memberData || []) as Member[];
    setMembers(typedMembers);

    const memberIds = typedMembers.map((m) => m.id);
    if (!memberIds.length) {
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
    if (!playerIds.length) {
      setPlayers([]);
      return;
    }

    const { data: playerData, error: playerError } = await supabase
      .from("fa_players")
      .select("id,name,primary_position,overall,image_url")
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
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_squad_players" }, () => void load())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => void load())
      .on("postgres_changes", { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` }, () => void load())
      .subscribe();
    return () => { void supabase.removeChannel(channel); };
  }, [room?.id, load]);

  useEffect(() => {
    if (room?.status === "lobby") {
      router.replace(`/sala/${code}/lobby`);
    }
  }, [room?.status, code, router]);

  const playerById = useMemo(() => new Map(players.map((p) => [p.id, p])), [players]);
  const boardSlots = boardForMode(room?.mode || "football");
  const me = members.find((member) => member.user_id === userId) || null;
  const isHost = !!room && room.host_user_id === userId;
  const replayRequests = members.filter((member) => member.replay_requested).length;

  async function requestReplay() {
    if (!room || replaying) return;
    setReplaying(true);
    setError("");
    try {
      const { data, error: rpcError } = await getSupabase().rpc("fa_request_replay", { p_room_id: room.id });
      if (rpcError) throw rpcError;

      const result = data as { restarted?: boolean } | null;
      if (result?.restarted) {
        router.replace(`/sala/${code}/lobby`);
        return;
      }

      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível pedir uma nova partida.");
    } finally {
      setReplaying(false);
    }
  }

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
          const ger = room ? squadGer(memberSquad, playerById, room.mode) : 0;
          const bySlot = new Map(memberSquad.map((s) => [s.slot_key, playerById.get(s.player_id)]));

          return (
            <section className="card" key={member.id}>
              <div className="topbar" style={{ marginBottom: 14 }}>
                <div>
                  <h2 style={{ margin: 0 }}>{member.is_host ? "👑 " : ""}{member.display_name}</h2>
                  <p className="muted" style={{ margin: "5px 0 0" }}>{member.squad_finalized ? "Time finalizado" : "Montando time"}</p>
                </div>
                <div style={{ textAlign: "center", minWidth: 82 }}>
                  <div className="red" style={{ fontSize: 34, fontWeight: 900, lineHeight: 1 }}>{ger}</div>
                  <small className="muted">GER ESCALAÇÃO</small>
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

                {boardSlots.map((slot) => {
                  const p = bySlot.get(slot.key);
                  const effective = p && room ? effectiveGer(p, slot.key, room.mode) : 0;
                  const penalty = p ? p.overall - effective : 0;
                  return (
                    <div key={slot.key} style={{
                      position: "absolute",
                      left: `${slot.x}%`,
                      top: `${slot.y}%`,
                      transform: "translate(-50%, -50%)",
                      width: room?.mode === "futsal" ? 112 : 92,
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
                        {p && <div style={{ display: "flex", justifyContent: "center", margin: "3px 0" }}><PlayerFace name={p.name} imageUrl={p.image_url} size={34} /></div>}
                        <div style={{ fontSize: 11, fontWeight: 800, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{p?.name || "Vazio"}</div>
                        {p && <div className="red" style={{ fontSize: 13, fontWeight: 900 }}>{effective} GER{penalty > 0 ? ` (-${penalty})` : ""}</div>}
                        {p && <div style={{ fontSize: 9, opacity: .7 }}>orig. {p.primary_position}</div>}
                      </div>
                    </div>
                  );
                })}
              </div>

              <div style={{ display: "flex", justifyContent: "space-between", gap: 12, marginTop: 14 }}>
                <span className="muted">{memberSquad.length}/{boardSlots.length} jogadores</span>
                <strong>{member.balance} créditos restantes</strong>
              </div>
            </section>
          );
        })}
      </div>

      <section className="card" style={{ marginTop: 20, textAlign: "center" }}>
        <h2>Outra partida?</h2>
        <p className="muted">
          {replayRequests}/{members.length} participantes pediram para jogar novamente.
        </p>

        {!isHost && me?.replay_requested && (
          <p className="red" style={{ fontWeight: 900 }}>
            Pedido enviado. Aguardando o administrador clicar em Jogar novamente.
          </p>
        )}

        {isHost && replayRequests > 0 && (
          <p className="muted">
            Há participantes aguardando você. Quando você confirmar, a sala inteira volta ao lobby com o orçamento renovado.
          </p>
        )}

        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", marginTop: 14 }}>
          <button
            className="btn btn-primary"
            onClick={requestReplay}
            disabled={replaying || (!isHost && !!me?.replay_requested)}
          >
            {replaying
              ? "Preparando..."
              : !isHost && me?.replay_requested
                ? "Aguardando administrador"
                : "Jogar novamente"}
          </button>

          <button className="btn btn-secondary" onClick={() => router.push("/")}>
            Tela inicial
          </button>
        </div>
      </section>
    </main>
  );
}
