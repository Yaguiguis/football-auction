"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";
import {
  benchSlotsForMode,
  boardForMode,
  effectiveGer,
  positionPenalty,
  rosterSizeForMode,
  squadGer,
  type GameMode,
  type RatedPlayer,
} from "../../../../lib/squad-board";
import PlayerFace from "../../../../components/PlayerFace";
import CardBadge, { cardClass } from "../../../../components/CardBadge";
import ConnectionBanner from "../../../../components/ConnectionBanner";
import RoomChat from "../../../../components/RoomChat";
import TradeCenter from "../../../../components/TradeCenter";

type Room = { id: string; code: string; mode: GameMode; reserve_count: number; room_kind: "auction" | "tournament"; status: string };
type Member = { id: string; user_id: string; display_name: string; squad_finalized: boolean };
type SquadRow = { member_id: string; player_id: string; slot_key: string; is_bench: boolean };
type Player = RatedPlayer & { league: string | null };

function errorMessage(error: unknown) {
  if (error instanceof Error) return error.message;
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as { message?: unknown }).message;
    if (typeof message === "string") return message;
  }
  return "Erro ao atualizar a prancheta.";
}

export default function SquadEditorPage() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();

  const [room, setRoom] = useState<Room | null>(null);
  const [me, setMe] = useState<Member | null>(null);
  const [squad, setSquad] = useState<SquadRow[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [selectedPlayerId, setSelectedPlayerId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [tradeOpen, setTradeOpen] = useState(false);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    const supabase = getSupabase();
    const session = await ensureAnonymousSession();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,mode,reserve_count,room_kind,status")
      .eq("code", code)
      .maybeSingle();
    if (roomError) throw roomError;
    if (!roomData) throw new Error("Sala não encontrada.");
    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const { data: memberData, error: memberError } = await supabase
      .from("fa_room_members")
      .select("id,user_id,display_name,squad_finalized")
      .eq("room_id", typedRoom.id)
      .eq("user_id", session.user.id)
      .maybeSingle();
    if (memberError) throw memberError;
    if (!memberData) throw new Error("Você não faz parte desta sala.");
    const typedMember = memberData as Member;
    setMe(typedMember);

    const { data: squadData, error: squadError } = await supabase
      .from("fa_squad_players")
      .select("member_id,player_id,slot_key,is_bench")
      .eq("member_id", typedMember.id);
    if (squadError) throw squadError;

    const typedSquad = (squadData || []) as SquadRow[];
    setSquad(typedSquad);

    const ids = typedSquad.map((row) => row.player_id);
    if (!ids.length) {
      setPlayers([]);
      return;
    }

    const { data: playerData, error: playerError } = await supabase
      .from("fa_players")
      .select("id,name,primary_position,secondary_positions,overall,league,image_url,player_type,metadata")
      .in("id", ids);
    if (playerError) throw playerError;
    setPlayers((playerData || []) as Player[]);
  }, [code]);

  const safeLoad = useCallback(async () => {
    try {
      await load();
      setError("");
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setLoading(false);
    }
  }, [load]);

  useEffect(() => {
    void safeLoad();
  }, [safeLoad]);

  useEffect(() => {
    if (!room?.id) return;
    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:squad-editor:${room.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_squad_players" }, () => void safeLoad())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => void safeLoad())
      .on("postgres_changes", { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` }, () => void safeLoad())
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [room?.id, safeLoad]);

  useEffect(() => {
    if (room?.status === "squads" || room?.status === "finished") {
      router.replace(
        room.room_kind === "tournament"
          ? `/sala/${code}/torneio`
          : `/sala/${code}/times`
      );
    }
  }, [room?.status, room?.room_kind, code, router]);


  useEffect(() => {
    if (!room?.id) return;

    const heartbeat = async () => {
      await getSupabase().rpc("fa_heartbeat_room", { p_room_id: room.id });
    };

    void heartbeat();
    const timer = window.setInterval(() => void heartbeat(), 8000);
    return () => window.clearInterval(timer);
  }, [room?.id]);

  const mode = room?.mode || "football";
  const board = boardForMode(mode);
  const benchSlots = benchSlotsForMode(mode, room?.reserve_count);
  const totalRosterSize = rosterSizeForMode(mode, room?.reserve_count);

  const playersById = useMemo(() => new Map(players.map((p) => [p.id, p])), [players]);
  const bySlot = useMemo(() => new Map(squad.map((row) => [row.slot_key, row])), [squad]);
  const ger = room ? squadGer(squad, playersById, room.mode) : 0;
  const selectedPlayer = selectedPlayerId ? playersById.get(selectedPlayerId) || null : null;

  const starterFilled = board.filter((slot) => bySlot.has(slot.key)).length;
  const benchFilled = benchSlots.filter((slot) => bySlot.has(slot.key)).length;
  const full =
    board.every((slot) => bySlot.has(slot.key)) &&
    benchSlots.every((slot) => bySlot.has(slot.key));

  async function moveSelected(targetSlot: string, explicitPlayerId?: string) {
    const playerId = explicitPlayerId || selectedPlayerId;
    if (!playerId || !me || me.squad_finalized) return;

    setSaving(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc("fa_move_squad_player", {
        p_player_id: playerId,
        p_target_slot: targetSlot,
      });
      if (rpcError) throw rpcError;

      setSelectedPlayerId(null);
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  async function finalize() {
    if (!room || !full || me?.squad_finalized) return;

    setSaving(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc("fa_finalize_squad", {
        p_room_id: room.id,
      });
      if (rpcError) throw rpcError;
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  const handleTradeChanged = useCallback(async () => {
    setTradeOpen(false);
    setSelectedPlayerId(null);
    await safeLoad();
  }, [safeLoad]);

  function selectOrMove(slotKey: string, playerId?: string) {
    if (selectedPlayerId) {
      if (playerId === selectedPlayerId) {
        setSelectedPlayerId(null);
      } else {
        void moveSelected(slotKey);
      }
    } else if (playerId) {
      setSelectedPlayerId(playerId);
    }
  }

  if (loading) {
    return <main className="container"><p>Carregando sua prancheta...</p></main>;
  }

  return (
    <main className="container">
      <ConnectionBanner />
      <div className="topbar">
        <div>
          <p className="red" style={{ margin: 0, fontWeight: 900, letterSpacing: 2 }}>SUA PRANCHETA</p>
          <h1 style={{ margin: "5px 0 0" }}>
            {room?.mode === "futsal" ? "Futsal" : "Futebol de campo"}
          </h1>
        </div>

        <div style={{ display: "flex", gap: 10, flexWrap: "wrap", justifyContent: "flex-end" }}>
          <button
            className="btn btn-secondary"
            onClick={() => router.push(`/sala/${code}/lobby`)}
          >
            Voltar ao lobby
          </button>
          <button
            className="btn btn-secondary"
            onClick={() => router.push(`/sala/${code}/leilao`)}
          >
            Voltar ao leilão
          </button>
        </div>
      </div>

      {error && (
        <div className="card" style={{ marginBottom: 16 }}>
          <p className="red" style={{ margin: 0 }}>{error}</p>
        </div>
      )}

      {room && <RoomChat roomId={room.id} />}

      {room && me && (
        <TradeCenter
          roomId={room.id}
          meId={me.id}
          meFinalized={me.squad_finalized}
          open={tradeOpen}
          offeredPlayer={selectedPlayer}
          onClose={() => setTradeOpen(false)}
          onChanged={handleTradeChanged}
        />
      )}

      <div className="grid grid-2">
        <section>
          <div className="card" style={{ marginBottom: 14 }}>
            <div style={{ display: "flex", justifyContent: "space-between", gap: 12, alignItems: "center", flexWrap: "wrap" }}>
              <div>
                <strong>{me?.display_name}</strong>
                <p className="muted" style={{ margin: "4px 0 0" }}>
                  {me?.squad_finalized
                    ? "Time finalizado"
                    : "Toque em um jogador e depois na vaga desejada. Você também pode arrastar."}
                </p>
              </div>

              <div style={{ textAlign: "center" }}>
                <div className="red" style={{ fontSize: 38, fontWeight: 900, lineHeight: 1 }}>{ger}</div>
                <small className="muted">GER DOS TITULARES</small>
              </div>
            </div>
          </div>

          <div
            style={{
              position: "relative",
              width: "100%",
              maxWidth: 580,
              margin: "0 auto",
              aspectRatio: room?.mode === "futsal" ? "3 / 4" : "68 / 105",
              border: "2px solid rgba(255,255,255,.7)",
              borderRadius: 18,
              overflow: "hidden",
              background: "linear-gradient(180deg, #173f2d 0%, #102d22 100%)",
            }}
          >
            <div style={{ position: "absolute", left: 0, right: 0, top: "50%", borderTop: "1px solid rgba(255,255,255,.45)" }} />
            <div style={{ position: "absolute", left: "35%", top: "43%", width: "30%", aspectRatio: "1", border: "1px solid rgba(255,255,255,.35)", borderRadius: "50%" }} />

            {board.map((slot) => {
              const row = bySlot.get(slot.key);
              const player = row ? playersById.get(row.player_id) : undefined;
              const isSelected = !!player && player.id === selectedPlayerId;
              const effective = player && room ? effectiveGer(player, slot.key, room.mode) : 0;
              const penalty = player ? player.overall - effective : 0;
              const selectedPenalty = selectedPlayer && room
                ? positionPenalty(selectedPlayer.primary_position, slot.key, room.mode)
                : null;
              const selectedGroup = selectedPlayer?.primary_position.toUpperCase();
              const incompatible =
                !!selectedPlayer &&
                ((slot.key === "GOL" && selectedGroup !== "GOL") ||
                  (slot.key !== "GOL" && selectedGroup === "GOL"));
              const guideBorder = selectedPlayer
                ? incompatible
                  ? "2px solid #ff4d4f"
                  : selectedPenalty === 0
                    ? "2px solid #2ecc71"
                    : selectedPenalty !== null && selectedPenalty <= 2
                      ? "2px solid #f1c40f"
                      : "2px solid #ff7a00"
                : null;

              return (
                <button
                  key={slot.key}
                  className={cardClass(player)}
                  aria-pressed={isSelected}
                  type="button"
                  disabled={saving || !!me?.squad_finalized}
                  onClick={() => selectOrMove(slot.key, player?.id)}
                  onDragOver={(e) => e.preventDefault()}
                  onDrop={(e) => {
                    e.preventDefault();
                    const playerId = e.dataTransfer.getData("text/player-id");
                    if (playerId) void moveSelected(slot.key, playerId);
                  }}
                  style={{
                    position: "absolute",
                    left: `${slot.x}%`,
                    top: `${slot.y}%`,
                    transform: "translate(-50%, -50%)",
                    width: room?.mode === "futsal" ? "clamp(84px, 22vw, 112px)" : "clamp(68px, 17vw, 92px)",
                    borderRadius: 12,
                    padding: "7px 5px",
                    background: player ? "#0b0b0b" : "rgba(0,0,0,.35)",
                    color: "white",
                    border: isSelected
                      ? "3px solid white"
                      : guideBorder
                        ? guideBorder
                        : player
                          ? "2px solid #e50914"
                          : "1px dashed rgba(255,255,255,.6)",
                    cursor: me?.squad_finalized ? "default" : "pointer",
                  }}
                >
                  <div style={{ fontSize: 10, fontWeight: 900, opacity: .8 }}>{slot.label}</div>
                  {player && (
                    <div style={{ display: "flex", justifyContent: "center", margin: "3px 0" }}>
                      <PlayerFace name={player.name} imageUrl={player.image_url} size={38} />
                    </div>
                  )}
                  {player && <CardBadge player={player}/>}
                  <div style={{ fontSize: 11, fontWeight: 900, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                    {player?.name || "Vazio"}
                  </div>
                  {player && (
                    <div className="red" style={{ fontSize: 13, fontWeight: 900 }}>
                      {effective} GER{penalty > 0 ? ` (-${penalty})` : ""}
                    </div>
                  )}
                </button>
              );
            })}
          </div>

          <div className="card" style={{ marginTop: 14 }}>
            <div className="topbar" style={{ marginBottom: 12 }}>
              <div>
                <h2 style={{ margin: 0 }}>Banco de reservas</h2>
                <p className="muted" style={{ margin: "4px 0 0" }}>
                  {benchFilled}/{benchSlots.length} reservas
                </p>
              </div>
              {selectedPlayer && <span className="badge">Selecionado: {selectedPlayer.name}</span>}
            </div>

            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(96px, 1fr))",
                gap: 10,
              }}
            >
              {benchSlots.map((slot) => {
                const row = bySlot.get(slot.key);
                const player = row ? playersById.get(row.player_id) : undefined;
                const selected = player?.id === selectedPlayerId;

                return (
                  <button
                    key={slot.key}
                    className={cardClass(player)}
                    aria-pressed={selected}
                    type="button"
                    disabled={saving || !!me?.squad_finalized}
                    onClick={() => selectOrMove(slot.key, player?.id)}
                    onDragOver={(e) => e.preventDefault()}
                    onDrop={(e) => {
                      e.preventDefault();
                      const playerId = e.dataTransfer.getData("text/player-id");
                      if (playerId) void moveSelected(slot.key, playerId);
                    }}
                    style={{
                      minWidth: 0,
                      padding: 10,
                      borderRadius: 12,
                      background: player ? "#0b0b0b" : "rgba(255,255,255,.03)",
                      border: selected
                        ? "3px solid #fff"
                        : player
                          ? "2px solid #e50914"
                          : "1px dashed #555",
                      color: "#fff",
                      cursor: me?.squad_finalized ? "default" : "pointer",
                    }}
                  >
                    <div className="muted" style={{ fontSize: 10, fontWeight: 900 }}>{slot.label}</div>
                    {player ? (
                      <>
                        <div style={{ display: "flex", justifyContent: "center", margin: "7px 0" }}>
                          <PlayerFace name={player.name} imageUrl={player.image_url} size={42} />
                        </div>
                        <CardBadge player={player}/><strong style={{ display: "block", fontSize: 12, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                          {player.name}
                        </strong>
                        <span className="red" style={{ fontSize: 12, fontWeight: 900 }}>{player.overall} GER</span>
                      </>
                    ) : (
                      <div className="muted" style={{ padding: "18px 0" }}>Vazio</div>
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        </section>

        <section className="card">
          <div className="topbar" style={{ marginBottom: 12 }}>
            <div>
              <h2 style={{ margin: 0 }}>Seu elenco</h2>
              <p className="muted" style={{ margin: "4px 0 0" }}>
                {squad.length}/{totalRosterSize} jogadores • Titulares {starterFilled}/{board.length} • Banco {benchFilled}/{benchSlots.length}
              </p>
            </div>

            {selectedPlayer && full && !me?.squad_finalized && (
              <button
                className="btn btn-primary"
                disabled={saving}
                onClick={() => setTradeOpen(true)}
              >
                Trocar {selectedPlayer.name}
              </button>
            )}
          </div>

          <div className="grid">
            {squad.length === 0 && <p className="muted">Você ainda não ganhou nenhum jogador.</p>}

            {squad.map((row) => {
              const player = playersById.get(row.player_id);
              if (!player) return null;

              const selected = selectedPlayerId === player.id;
              const boardSlot = board.find((item) => item.key === row.slot_key);
              const benchSlot = benchSlots.find((item) => item.key === row.slot_key);
              const slotLabel = boardSlot?.label || benchSlot?.label || row.slot_key;
              const isBench = row.slot_key.startsWith("BENCH");
              const effective = room && !isBench
                ? effectiveGer(player, row.slot_key, room.mode)
                : player.overall;

              return (
                <button
                  key={row.player_id}
                  type="button"
                  draggable={!me?.squad_finalized}
                  onDragStart={(e) => e.dataTransfer.setData("text/player-id", player.id)}
                  onClick={() => setSelectedPlayerId(selected ? null : player.id)}
                  disabled={!!me?.squad_finalized}
                  className={`card ${cardClass(player)}`}
                  aria-pressed={selected}
                  style={{
                    textAlign: "left",
                    cursor: me?.squad_finalized ? "default" : "pointer",
                    border: selected ? "2px solid #e50914" : undefined,
                  }}
                >
                  <CardBadge player={player}/><div style={{ marginBottom: 8 }}>
                    <PlayerFace name={player.name} imageUrl={player.image_url} size={50} />
                  </div>

                  <div style={{ display: "flex", justifyContent: "space-between", gap: 12 }}>
                    <div>
                      <strong>{player.name}</strong>
                      <div className="muted">
                        Original: {player.primary_position} • Em: {slotLabel}
                      </div>
                    </div>

                    <div style={{ textAlign: "right" }}>
                      <strong className="red">{effective} GER</strong>
                      {!isBench && effective !== player.overall && (
                        <div className="muted">Base {player.overall}</div>
                      )}
                    </div>
                  </div>
                </button>
              );
            })}
          </div>

          {!me?.squad_finalized && (
            <>
              <p className="muted" style={{ marginTop: 18 }}>
                Você pode trocar reservas e titulares livremente. Goleiro pode ficar no banco, mas somente goleiro pode ocupar a vaga GOL.
                Toque em um jogador para ver as melhores posições: verde = ideal, amarelo = boa, laranja = improvisada e vermelho = inválida.
                Organize o time antes de finalizar.
              </p>

              <button
                className="btn btn-primary"
                onClick={finalize}
                disabled={!full || saving}
              >
                {full
                  ? (saving ? "Finalizando..." : "Finalizar meu time")
                  : `Faltam ${totalRosterSize - squad.length} jogadores no elenco`}
              </button>
            </>
          )}

          {me?.squad_finalized && (
            <p className="red" style={{ fontWeight: 900, marginBottom: 0 }}>
              ✓ Time finalizado.
            </p>
          )}
        </section>
      </div>
    </main>
  );
}
