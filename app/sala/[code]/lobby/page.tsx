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

export default function Lobby() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();
  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [userId, setUserId] = useState("");
  const [catalogCount, setCatalogCount] = useState(0);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);
  const [starting, setStarting] = useState(false);

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

    const [membersResult, catalogResult] = await Promise.all([
      supabase
        .from("fa_room_members")
        .select("id,user_id,display_name,balance,is_host")
        .eq("room_id", typedRoom.id)
        .order("joined_at"),
      supabase
        .from("fa_catalog_players")
        .select("id", { count: "exact", head: true })
        .eq("enabled", true),
    ]);

    if (membersResult.error) throw membersResult.error;
    if (catalogResult.error) throw catalogResult.error;

    setMembers((membersResult.data || []) as Member[]);
    setCatalogCount(catalogResult.count || 0);
  }, [code]);

  useEffect(() => {
    let mounted = true;
    refresh()
      .catch((e) => mounted && setError(e instanceof Error ? e.message : "Erro ao carregar a sala."))
      .finally(() => mounted && setLoading(false));
    return () => { mounted = false; };
  }, [refresh]);

  useEffect(() => {
    if (!room?.id) return;
    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:lobby:${room.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => refresh())
      .on("postgres_changes", { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` }, () => refresh())
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [room?.id, refresh]);

  useEffect(() => {
    if (room?.status === "auction") {
      router.replace(`/sala/${room.code}/leilao`);
    }
  }, [room?.status, room?.code, router]);

  const isHost = !!room && room.host_user_id === userId;

  async function startAuction() {
    if (!room || starting) return;
    setError("");
    setStarting(true);
    try {
      const { error: rpcError } = await getSupabase().rpc("fa_start_next_auction", { p_room_id: room.id });
      if (rpcError) throw rpcError;
      router.push(`/sala/${room.code}/leilao`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível iniciar o leilão.");
      setStarting(false);
    }
  }

  if (loading) return <main className="container"><p>Carregando sala...</p></main>;

  return (
    <main className="container">
      <div className="topbar">
        <div>
          <p className="muted" style={{ margin: 0 }}>CÓDIGO DA SALA</p>
          <h1 style={{ margin: 0 }}>{code}</h1>
        </div>
        <span className="badge">{members.length} pessoas</span>
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
          <p className="muted">Compartilhe o código <strong>{code}</strong> com quem vai participar.</p>
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
            <h2 style={{ marginBottom: 4 }}>Catálogo automático</h2>
            <p className="muted" style={{ margin: 0 }}>
              O jogo sorteia os jogadores automaticamente e não repete um nome na mesma sala.
            </p>
          </div>
          <span className="badge">{catalogCount} jogadores</span>
        </div>

        <div className="grid grid-2">
          <div className="card">
            <strong>5 grandes ligas</strong>
            <p className="muted">Premier League • La Liga • Serie A • Bundesliga • Ligue 1</p>
          </div>
          <div className="card">
            <strong>Lendas</strong>
            <p className="muted">Europa • América do Sul • América do Norte</p>
          </div>
        </div>
      </section>

      {isHost ? (
        <button
          className="btn btn-primary"
          style={{ marginTop: 16 }}
          onClick={startAuction}
          disabled={members.length < 2 || catalogCount === 0 || starting}
        >
          {starting ? "Iniciando..." : members.length < 2 ? "Aguardando mais 1 jogador" : "Iniciar leilão"}
        </button>
      ) : (
        <p className="muted" style={{ marginTop: 16 }}>Aguardando o administrador iniciar o leilão.</p>
      )}
    </main>
  );
}
