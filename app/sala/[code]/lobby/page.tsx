"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";
import ConnectionBanner from "../../../../components/ConnectionBanner";
import RoomChat from "../../../../components/RoomChat";

type Room = {
  id: string;
  code: string;
  host_user_id: string;
  mode: "football" | "futsal";
  budget: number;
  reserve_count: number;
  allow_icons: boolean;
  min_overall: number;
  max_overall: number;
  active_only: boolean;
  allowed_leagues: string[] | null;
  disconnect_mode: "skip" | "bot";
  spectators_allowed: boolean;
  status: string;
};

type Member = {
  id: string;
  user_id: string;
  display_name: string;
  balance: number;
  is_host: boolean;
  ready: boolean;
  is_spectator: boolean;
  last_seen_at: string;
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
  const [busyMember, setBusyMember] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    const supabase = getSupabase();
    const session = await ensureAnonymousSession();
    setUserId(session.user.id);

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,mode,budget,reserve_count,allow_icons,min_overall,max_overall,active_only,allowed_leagues,disconnect_mode,spectators_allowed,status")
      .eq("code", code)
      .single();

    if (roomError) throw roomError;

    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const [membersResult, catalogResult] = await Promise.all([
      supabase
        .from("fa_room_members")
        .select("id,user_id,display_name,balance,is_host,ready,is_spectator,last_seen_at")
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

    void refresh()
      .catch((e) => mounted && setError(e instanceof Error ? e.message : "Erro ao carregar a sala."))
      .finally(() => mounted && setLoading(false));

    return () => {
      mounted = false;
    };
  }, [refresh]);

  useEffect(() => {
    if (!room?.id) return;

    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:lobby:${room.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => void refresh())
      .on("postgres_changes", { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` }, () => void refresh())
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [room?.id, refresh]);

  useEffect(() => {
    if (!room?.id) return;

    const heartbeat = async () => {
      await getSupabase().rpc("fa_heartbeat_room", { p_room_id: room.id });
    };

    void heartbeat();
    const timer = window.setInterval(() => void heartbeat(), 8000);
    return () => window.clearInterval(timer);
  }, [room?.id]);

  useEffect(() => {
    if (!room) return;

    if (room.status === "auction") {
      router.replace(`/sala/${room.code}/leilao`);
    } else if (room.status === "squads" || room.status === "finished") {
      router.replace(`/sala/${room.code}/times`);
    }
  }, [room, router]);

  const isHost = !!room && room.host_user_id === userId;
  const me = members.find((member) => member.user_id === userId) || null;

  const online = useCallback(
    (member: Member) => Date.now() - new Date(member.last_seen_at).getTime() < 30_000,
    [],
  );

  const activePlayers = useMemo(
    () => members.filter((member) => !member.is_spectator && online(member)),
    [members, online],
  );

  const allReady = activePlayers.length >= 2 && activePlayers.every((member) => member.ready);

  async function toggleReady() {
    if (!room || !me || me.is_spectator) return;
    setError("");

    const { error: rpcError } = await getSupabase().rpc("fa_set_ready", {
      p_room_id: room.id,
      p_ready: !me.ready,
    });

    if (rpcError) return setError(rpcError.message);
    await refresh();
  }

  async function kick(memberId: string) {
    if (!isHost || busyMember) return;
    setBusyMember(memberId);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc("fa_kick_member", {
        p_member_id: memberId,
      });
      if (rpcError) throw rpcError;
      await refresh();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível remover o participante.");
    } finally {
      setBusyMember(null);
    }
  }

  async function startAuction() {
    if (!room || starting) return;

    setError("");
    setStarting(true);

    try {
      const { error: rpcError } = await getSupabase().rpc("fa_begin_auction", {
        p_room_id: room.id,
      });

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
      <ConnectionBanner />

      <div className="topbar">
        <div>
          <p className="muted" style={{ margin: 0 }}>CÓDIGO DA SALA</p>
          <h1 style={{ margin: 0 }}>{code}</h1>
        </div>

        <div style={{ display: "flex", gap: 8, flexWrap: "wrap", justifyContent: "flex-end" }}>
          <span className="badge">{activePlayers.length} jogando online</span>
          <span className="badge">{members.filter((m) => m.is_spectator).length} espectadores</span>
        </div>
      </div>

      {error && (
        <div className="card" style={{ marginBottom: 16 }}>
          <p className="red" style={{ margin: 0 }}>{error}</p>
        </div>
      )}

      <div className="grid grid-2">
        <section className="card">
          <div className="topbar" style={{ marginBottom: 12 }}>
            <h2 style={{ margin: 0 }}>Participantes</h2>
            {!me?.is_spectator && (
              <button
                className={`btn ${me?.ready ? "btn-secondary" : "btn-primary"}`}
                onClick={() => void toggleReady()}
              >
                {me?.ready ? "Cancelar pronto" : "Estou pronto"}
              </button>
            )}
          </div>

          <div className="member-list">
            {members.map((member) => {
              const isOnline = online(member);

              return (
                <div className="member-row" key={member.id}>
                  <div>
                    <div style={{ display: "flex", gap: 8, alignItems: "center", flexWrap: "wrap" }}>
                      <span className={`presence-dot ${isOnline ? "online" : "offline"}`} />
                      <strong>{member.is_host ? "👑 " : ""}{member.display_name}</strong>
                      {member.is_spectator && <span className="badge">Espectador</span>}
                      {!member.is_spectator && member.ready && <span className="badge ready-badge">Pronto</span>}
                    </div>

                    <small className="muted">
                      {isOnline ? "online" : "offline"}
                      {!member.is_spectator ? ` • ${member.balance} créditos` : ""}
                    </small>
                  </div>

                  {isHost && member.user_id !== userId && (
                    <button
                      className="btn danger-btn"
                      onClick={() => void kick(member.id)}
                      disabled={busyMember === member.id}
                    >
                      {busyMember === member.id ? "Removendo..." : "Expulsar"}
                    </button>
                  )}
                </div>
              );
            })}
          </div>

          <p className="muted">
            Compartilhe o código <strong>{code}</strong>. Jogadores offline não travam a partida.
          </p>
        </section>

        <section className="card">
          <h2>Configuração</h2>

          <div className="settings-summary">
            <span className="badge">{room?.mode === "futsal" ? "Futsal" : "Futebol de campo"}</span>
            <span className="badge">{room?.budget} créditos</span>
            <span className="badge">{room?.reserve_count} reservas</span>
            <span className="badge">GER {room?.min_overall}–{room?.max_overall}</span>
            <span className="badge">{room?.allow_icons ? "ICONS ligados" : "Sem ICONS"}</span>
            {room?.active_only && <span className="badge">Somente ativos</span>}
            <span className="badge">
              Desconexão: {room?.disconnect_mode === "bot" ? "BOT conservador" : "continuar sem ele"}
            </span>
            <span className="badge">{room?.spectators_allowed ? "Espectadores permitidos" : "Sem espectadores"}</span>
          </div>

          <p className="muted" style={{ marginBottom: 0 }}>
            Ligas: {room?.allowed_leagues?.length ? room.allowed_leagues.join(" • ") : "todas"}
          </p>
        </section>
      </div>

      <section className="card" style={{ marginTop: 16 }}>
        <div className="topbar" style={{ marginBottom: 12 }}>
          <div>
            <h2 style={{ margin: 0 }}>Catálogo automático</h2>
            <p className="muted" style={{ margin: "4px 0 0" }}>
              O sorteio respeita as posições faltantes e os filtros desta sala.
            </p>
          </div>
          <span className="badge">{catalogCount} cadastrados</span>
        </div>
      </section>

      {room && <RoomChat roomId={room.id} />}

      {isHost ? (
        <button
          className="btn btn-primary"
          style={{ marginTop: 16, width: "100%" }}
          onClick={() => void startAuction()}
          disabled={!allReady || catalogCount === 0 || starting}
        >
          {starting
            ? "Iniciando..."
            : activePlayers.length < 2
              ? "Aguardando mais 1 jogador online"
              : !allReady
                ? "Aguardando todos ficarem prontos"
                : "Iniciar leilão"}
        </button>
      ) : me?.is_spectator ? (
        <p className="muted" style={{ marginTop: 16, textAlign: "center" }}>
          Você está assistindo. Quando a partida começar, irá automaticamente para o leilão.
        </p>
      ) : (
        <p className="muted" style={{ marginTop: 16, textAlign: "center" }}>
          Marque “Estou pronto” e aguarde o administrador iniciar.
        </p>
      )}
    </main>
  );
}
