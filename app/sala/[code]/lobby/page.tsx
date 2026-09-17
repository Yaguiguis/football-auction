"use client";

import { useCallback, useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";

type Room = {
  id: string;
  code: string;
  host_user_id: string;
  mode: "football" | "futsal";
  budget: number;
  max_players: number;
  status: string;
};

type Member = {
  id: string;
  user_id: string;
  display_name: string;
  balance: number;
  is_host: boolean;
};

type RoomPlayer = {
  id: string;
  name: string;
  primary_position: string;
  overall: number | null;
};

export default function Lobby() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();
  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [players, setPlayers] = useState<RoomPlayer[]>([]);
  const [userId, setUserId] = useState("");
  const [playerName, setPlayerName] = useState("");
  const [position, setPosition] = useState("ATA");
  const [overall, setOverall] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    const supabase = getSupabase();
    const session = await ensureAnonymousSession();
    setUserId(session.user.id);

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,mode,budget,max_players,status")
      .eq("code", code)
      .single();
    if (roomError) throw roomError;

    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const [{ data: memberData, error: memberError }, { data: playerData, error: playerError }] = await Promise.all([
      supabase.from("fa_room_members").select("id,user_id,display_name,balance,is_host").eq("room_id", typedRoom.id).order("joined_at"),
      supabase.from("fa_players").select("id,name,primary_position,overall").eq("room_id", typedRoom.id).order("created_at"),
    ]);

    if (memberError) throw memberError;
    if (playerError) throw playerError;
    setMembers((memberData || []) as Member[]);
    setPlayers((playerData || []) as RoomPlayer[]);
  }, [code]);

  useEffect(() => {
    let mounted = true;
    refresh().catch((e) => mounted && setError(e instanceof Error ? e.message : "Erro ao carregar a sala.")).finally(() => mounted && setLoading(false));
    return () => { mounted = false; };
  }, [refresh]);

  useEffect(() => {
    if (!room?.id) return;
    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:lobby:${room.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => refresh())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_players", filter: `room_id=eq.${room.id}` }, () => refresh())
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [room?.id, refresh]);

  const isHost = !!room && room.host_user_id === userId;

  async function addPlayer() {
    if (!room || !playerName.trim()) return;
    setError("");
    const supabase = getSupabase();
    const parsedOverall = overall.trim() ? Number(overall) : null;
    const { error: rpcError } = await supabase.rpc("fa_add_room_player", {
      p_room_id: room.id,
      p_name: playerName.trim(),
      p_position: position,
      p_overall: parsedOverall,
    });
    if (rpcError) return setError(rpcError.message);
    setPlayerName("");
    setOverall("");
    await refresh();
  }

  async function removePlayer(playerId: string) {
    if (!room) return;
    const supabase = getSupabase();
    const { error: rpcError } = await supabase.rpc("fa_remove_room_player", { p_room_id: room.id, p_player_id: playerId });
    if (rpcError) return setError(rpcError.message);
    await refresh();
  }

  async function startAuction() {
    if (!room) return;
    setError("");
    const supabase = getSupabase();
    const { error: rpcError } = await supabase.rpc("fa_start_next_auction", { p_room_id: room.id });
    if (rpcError) return setError(rpcError.message);
    router.push(`/sala/${room.code}/leilao`);
  }

  if (loading) return <main className="container"><p>Carregando sala...</p></main>;

  return (
    <main className="container">
      <div className="topbar">
        <div>
          <p className="muted" style={{ margin: 0 }}>CÓDIGO DA SALA</p>
          <h1 style={{ margin: 0 }}>{code}</h1>
        </div>
        <span className="badge">{members.length}/5 pessoas</span>
      </div>

      {error && <div className="card" style={{ marginBottom: 16 }}><p className="red">{error}</p></div>}

      <div className="grid grid-2">
        <section className="card">
          <h2>Participantes</h2>
          {members.map((member) => (
            <p key={member.id}>
              {member.is_host ? "👑" : "●"} {member.display_name} <span className="muted">— {member.balance} créditos</span>
            </p>
          ))}
          <p className="muted">Compartilhe o código <strong>{code}</strong> com até 4 amigos.</p>
        </section>

        <section className="card">
          <h2>Configuração</h2>
          <p>Modalidade: <strong>{room?.mode === "futsal" ? "Futsal" : "Futebol de campo"}</strong></p>
          <p>Orçamento: <strong>{room?.budget} créditos</strong></p>
          <p>Banco: <strong>2 reservas</strong></p>
        </section>
      </div>

      <section className="card" style={{ marginTop: 16 }}>
        <div className="topbar">
          <div>
            <h2 style={{ marginBottom: 4 }}>Jogadores do leilão</h2>
            <p className="muted" style={{ margin: 0 }}>{isHost ? "Somente você, como administrador, pode editar esta lista." : "O administrador está montando a lista."}</p>
          </div>
          <span className="badge">{players.length} cadastrados</span>
        </div>

        {isHost && room?.status === "lobby" && (
          <div className="grid" style={{ gridTemplateColumns: "2fr 1fr 1fr auto", alignItems: "end", marginBottom: 18 }}>
            <label>Nome<input className="input" value={playerName} onChange={(e) => setPlayerName(e.target.value)} placeholder="Ex.: Vinícius Jr." maxLength={60} /></label>
            <label>Posição<select className="input" value={position} onChange={(e) => setPosition(e.target.value)}>{["GOL","ZAG","LE","LD","VOL","MC","MEI","PE","PD","ATA"].map((p) => <option key={p}>{p}</option>)}</select></label>
            <label>Overall<input className="input" type="number" min="1" max="99" value={overall} onChange={(e) => setOverall(e.target.value)} placeholder="Opcional" /></label>
            <button className="btn btn-primary" onClick={addPlayer}>Adicionar</button>
          </div>
        )}

        <div className="grid">
          {players.length === 0 && <p className="muted">Nenhum jogador cadastrado ainda.</p>}
          {players.map((player) => (
            <div key={player.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12, borderBottom: "1px solid var(--border)", paddingBottom: 10 }}>
              <div>
                <strong>{player.name}</strong>
                <div className="muted">{player.primary_position}{player.overall ? ` • OVR ${player.overall}` : ""}</div>
              </div>
              {isHost && room?.status === "lobby" && <button className="btn btn-secondary" onClick={() => removePlayer(player.id)}>Remover</button>}
            </div>
          ))}
        </div>
      </section>

      {isHost && (
        <button className="btn btn-primary" style={{ marginTop: 16 }} onClick={startAuction} disabled={members.length < 2 || players.length === 0}>
          Iniciar leilão
        </button>
      )}
      {!isHost && <p className="muted" style={{ marginTop: 16 }}>Aguardando o administrador iniciar o leilão.</p>}
    </main>
  );
}
