"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";
import { boardForMode, effectiveGer, squadGer, type GameMode, type RatedPlayer } from "../../../../lib/squad-board";
import PlayerFace from "../../../../components/PlayerFace";

type Room = { id: string; code: string; mode: GameMode; status: string };
type Member = { id: string; user_id: string; display_name: string; squad_finalized: boolean };
type SquadRow = { member_id: string; player_id: string; slot_key: string };
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
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    const supabase = getSupabase();
    const session = await ensureAnonymousSession();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,mode,status")
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
      .select("member_id,player_id,slot_key")
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
      .select("id,name,primary_position,overall,league,image_url")
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
    return () => { void supabase.removeChannel(channel); };
  }, [room?.id, safeLoad]);

  useEffect(() => {
    if (room?.status === "squads") router.replace(`/sala/${code}/times`);
  }, [room?.status, code, router]);

  const playersById = useMemo(() => new Map(players.map((p) => [p.id, p])), [players]);
  const board = boardForMode(room?.mode || "football");
  const bySlot = useMemo(() => new Map(squad.map((row) => [row.slot_key, row])), [squad]);
  const ger = room ? squadGer(squad, playersById, room.mode) : 0;
  const selectedPlayer = selectedPlayerId ? playersById.get(selectedPlayerId) || null : null;
  const full = squad.length === board.length && board.every((slot) => bySlot.has(slot.key));

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
      const { error: rpcError } = await getSupabase().rpc("fa_finalize_squad", { p_room_id: room.id });
      if (rpcError) throw rpcError;
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setSaving(false);
    }
  }

  if (loading) return <main className="container"><p>Carregando sua prancheta...</p></main>;

  return (
    <main className="container">
      <div className="topbar">
        <div>
          <p className="red" style={{ margin: 0, fontWeight: 900, letterSpacing: 2 }}>SUA PRANCHETA</p>
          <h1 style={{ margin: "5px 0 0" }}>{room?.mode === "futsal" ? "Futsal" : "Futebol de campo"}</h1>
        </div>
        <button className="btn btn-secondary" onClick={() => router.push(`/sala/${code}/leilao`)}>Voltar ao leilão</button>
      </div>

      {error && <div className="card" style={{ marginBottom: 16 }}><p className="red">{error}</p></div>}

      <div className="grid grid-2">
        <section>
          <div className="card" style={{ marginBottom: 14 }}>
            <div style={{ display: "flex", justifyContent: "space-between", gap: 12, alignItems: "center", flexWrap: "wrap" }}>
              <div>
                <strong>{me?.display_name}</strong>
                <p className="muted" style={{ margin: "4px 0 0" }}>
                  {me?.squad_finalized ? "Time finalizado" : "Toque em um jogador e depois na vaga desejada."}
                </p>
              </div>
              <div style={{ textAlign: "center" }}>
                <div className="red" style={{ fontSize: 38, fontWeight: 900, lineHeight: 1 }}>{ger}</div>
                <small className="muted">GER DA ESCALAÇÃO</small>
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

              return (
                <button
                  key={slot.key}
                  type="button"
                  disabled={saving || !!me?.squad_finalized}
                  onClick={() => {
                    if (selectedPlayerId) {
                      if (player?.id === selectedPlayerId) setSelectedPlayerId(null);
                      else void moveSelected(slot.key);
                    } else if (player) {
                      setSelectedPlayerId(player.id);
                    }
                  }}
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
                    width: room?.mode === "futsal" ? 112 : 92,
                    borderRadius: 12,
                    padding: "7px 5px",
                    background: player ? "#0b0b0b" : "rgba(0,0,0,.35)",
                    color: "white",
                    border: isSelected ? "3px solid white" : player ? "2px solid #e50914" : "1px dashed rgba(255,255,255,.6)",
                    cursor: me?.squad_finalized ? "default" : "pointer",
                  }}
                >
                  <div style={{ fontSize: 10, fontWeight: 900, opacity: .8 }}>{slot.label}</div>
                  {player && <div style={{ display: "flex", justifyContent: "center", margin: "3px 0" }}><PlayerFace name={player.name} imageUrl={player.image_url} size={38} /></div>}
                  <div style={{ fontSize: 11, fontWeight: 900, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{player?.name || "Vazio"}</div>
                  {player && (
                    <div className="red" style={{ fontSize: 13, fontWeight: 900 }}>
                      {effective} GER{penalty > 0 ? ` (-${penalty})` : ""}
                    </div>
                  )}
                </button>
              );
            })}
          </div>
        </section>

        <section className="card">
          <div className="topbar" style={{ marginBottom: 12 }}>
            <div>
              <h2 style={{ margin: 0 }}>Seus jogadores</h2>
              <p className="muted" style={{ margin: "4px 0 0" }}>{squad.length}/{board.length} vagas preenchidas</p>
            </div>
            {selectedPlayer && <span className="badge">Selecionado: {selectedPlayer.name}</span>}
          </div>

          <div className="grid">
            {squad.length === 0 && <p className="muted">Você ainda não ganhou nenhum jogador.</p>}
            {squad.map((row) => {
              const player = playersById.get(row.player_id);
              if (!player) return null;
              const selected = selectedPlayerId === player.id;
              const slot = board.find((item) => item.key === row.slot_key);
              const effective = room ? effectiveGer(player, row.slot_key, room.mode) : player.overall;
              return (
                <button
                  key={row.player_id}
                  type="button"
                  draggable={!me?.squad_finalized}
                  onDragStart={(e) => e.dataTransfer.setData("text/player-id", player.id)}
                  onClick={() => setSelectedPlayerId(selected ? null : player.id)}
                  disabled={!!me?.squad_finalized}
                  className="card"
                  style={{ textAlign: "left", cursor: me?.squad_finalized ? "default" : "pointer", border: selected ? "2px solid #e50914" : undefined }}
                >
                  <div style={{ marginBottom: 8 }}><PlayerFace name={player.name} imageUrl={player.image_url} size={50} /></div>
                  <div style={{ display: "flex", justifyContent: "space-between", gap: 12 }}>
                    <div>
                      <strong>{player.name}</strong>
                      <div className="muted">Original: {player.primary_position} • Em: {slot?.label || row.slot_key}</div>
                    </div>
                    <div style={{ textAlign: "right" }}>
                      <strong className="red">{effective} GER</strong>
                      {effective !== player.overall && <div className="muted">Base {player.overall}</div>}
                    </div>
                  </div>
                </button>
              );
            })}
          </div>

          {!me?.squad_finalized && (
            <>
              <p className="muted" style={{ marginTop: 18 }}>
                Goleiro fica no gol. Jogadores de linha podem trocar entre as outras vagas. Fora da função mais adequada, o GER da escalação recebe uma pequena penalidade.
              </p>
              <button className="btn btn-primary" onClick={finalize} disabled={!full || saving}>
                {full ? "Finalizar meu time" : `Faltam ${board.length - squad.length} jogadores`}
              </button>
            </>
          )}
        </section>
      </div>
    </main>
  );
}
