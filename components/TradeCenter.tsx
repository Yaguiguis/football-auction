"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { getSupabase } from "../lib/supabase";
import type { RatedPlayer } from "../lib/squad-board";
import PlayerFace from "./PlayerFace";
import CardBadge, { cardClass } from "./CardBadge";

type TradeMember = {
  id: string;
  display_name: string;
  squad_finalized: boolean;
  is_spectator: boolean;
};

type TradeSquadRow = {
  member_id: string;
  player_id: string;
  slot_key: string;
  is_bench: boolean;
};

type TradePlayer = RatedPlayer & {
  league?: string | null;
};

type TradeRequest = {
  id: string;
  room_id: string;
  requester_member_id: string;
  recipient_member_id: string;
  offered_player_id: string;
  requested_player_id: string;
  status: "pending" | "accepted" | "declined" | "cancelled";
  created_at: string;
  responded_at: string | null;
};

function messageOf(error: unknown) {
  if (error instanceof Error) return error.message;
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as { message?: unknown }).message;
    if (typeof message === "string") return message;
  }
  return "Não foi possível atualizar a troca.";
}

function PlayerTradeCard({
  player,
  selected = false,
  onClick,
}: {
  player: TradePlayer;
  selected?: boolean;
  onClick?: () => void;
}) {
  const content = (
    <>
      <PlayerFace name={player.name} imageUrl={player.image_url} size={62} />
      <div className="trade-player-copy">
        <CardBadge player={player} />
        <strong>{player.name}</strong>
        <span>{player.primary_position} • {player.overall} GER</span>
      </div>
    </>
  );

  const className = `trade-player-card ${cardClass(player)} ${selected ? "selected" : ""}`;

  if (onClick) {
    return (
      <button type="button" onClick={onClick} className={className}>
        {content}
      </button>
    );
  }

  return <div className={className}>{content}</div>;
}

export default function TradeCenter({
  roomId,
  meId,
  meFinalized,
  open = false,
  offeredPlayer = null,
  onClose,
  onChanged,
}: {
  roomId: string;
  meId: string;
  meFinalized: boolean;
  open?: boolean;
  offeredPlayer?: TradePlayer | null;
  onClose?: () => void;
  onChanged?: () => void | Promise<void>;
}) {
  const [members, setMembers] = useState<TradeMember[]>([]);
  const [squadRows, setSquadRows] = useState<TradeSquadRow[]>([]);
  const [players, setPlayers] = useState<TradePlayer[]>([]);
  const [trades, setTrades] = useState<TradeRequest[]>([]);
  const [targetMemberId, setTargetMemberId] = useState<string | null>(null);
  const [requestedPlayerId, setRequestedPlayerId] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const initializedStatuses = useRef(false);
  const statusMap = useRef<Map<string, TradeRequest["status"]>>(new Map());

  const playersById = useMemo(
    () => new Map(players.map((player) => [player.id, player])),
    [players],
  );
  const membersById = useMemo(
    () => new Map(members.map((member) => [member.id, member])),
    [members],
  );

  const load = useCallback(async () => {
    const supabase = getSupabase();

    const { data: memberData, error: memberError } = await supabase
      .from("fa_room_members")
      .select("id,display_name,squad_finalized,is_spectator")
      .eq("room_id", roomId)
      .is("kicked_at", null)
      .order("joined_at");

    if (memberError) throw memberError;
    const typedMembers = (memberData || []) as TradeMember[];
    setMembers(typedMembers);

    const memberIds = typedMembers.map((member) => member.id);
    let typedSquads: TradeSquadRow[] = [];

    if (memberIds.length) {
      const { data: squadData, error: squadError } = await supabase
        .from("fa_squad_players")
        .select("member_id,player_id,slot_key,is_bench")
        .in("member_id", memberIds);

      if (squadError) throw squadError;
      typedSquads = (squadData || []) as TradeSquadRow[];
    }

    setSquadRows(typedSquads);

    const playerIds = Array.from(new Set(typedSquads.map((row) => row.player_id)));
    if (playerIds.length) {
      const { data: playerData, error: playerError } = await supabase
        .from("fa_players")
        .select("id,name,primary_position,secondary_positions,overall,league,image_url,player_type,metadata")
        .in("id", playerIds);

      if (playerError) throw playerError;
      setPlayers((playerData || []) as TradePlayer[]);
    } else {
      setPlayers([]);
    }

    const { data: tradeData, error: tradeError } = await supabase
      .from("fa_trade_requests")
      .select("*")
      .eq("room_id", roomId)
      .order("created_at", { ascending: false })
      .limit(40);

    if (tradeError) throw tradeError;

    const typedTrades = (tradeData || []) as TradeRequest[];
    setTrades(typedTrades);

    const nextStatuses = new Map(
      typedTrades.map((trade) => [trade.id, trade.status] as const),
    );

    if (initializedStatuses.current) {
      for (const trade of typedTrades) {
        const previous = statusMap.current.get(trade.id);
        if (previous !== "pending" || trade.requester_member_id !== meId) continue;

        if (trade.status === "accepted") {
          setNotice("Troca concluída!");
          void onChanged?.();
        } else if (trade.status === "declined") {
          const recipient = typedMembers.find(
            (member) => member.id === trade.recipient_member_id,
          );
          setNotice(`${recipient?.display_name || "O jogador"} não quer fazer a troca.`);
        } else if (trade.status === "cancelled") {
          setNotice("A proposta foi cancelada porque um dos jogadores mudou de situação.");
        }
      }
    } else {
      initializedStatuses.current = true;
    }

    statusMap.current = nextStatuses;
  }, [roomId, meId, onChanged]);

  const safeLoad = useCallback(async () => {
    try {
      await load();
      setError("");
    } catch (loadError) {
      setError(messageOf(loadError));
    }
  }, [load]);

  useEffect(() => {
    void safeLoad();
    const timer = window.setInterval(() => void safeLoad(), 3500);
    return () => window.clearInterval(timer);
  }, [safeLoad]);

  useEffect(() => {
    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:trades:${roomId}:${meId}`)
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "fa_trade_requests",
          filter: `room_id=eq.${roomId}`,
        },
        () => void safeLoad(),
      )
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [roomId, meId, safeLoad]);

  useEffect(() => {
    if (!open) {
      setTargetMemberId(null);
      setRequestedPlayerId(null);
      setError("");
    }
  }, [open]);

  const availableMembers = members.filter(
    (member) =>
      member.id !== meId &&
      !member.is_spectator &&
      !member.squad_finalized,
  );

  const targetRows = targetMemberId
    ? squadRows.filter((row) => row.member_id === targetMemberId)
    : [];

  const incoming = trades.filter(
    (trade) =>
      trade.recipient_member_id === meId &&
      trade.status === "pending",
  );

  async function sendTrade() {
    if (!offeredPlayer || !targetMemberId || !requestedPlayerId || busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_create_trade_request",
        {
          p_room_id: roomId,
          p_offered_player_id: offeredPlayer.id,
          p_recipient_member_id: targetMemberId,
          p_requested_player_id: requestedPlayerId,
        },
      );

      if (rpcError) throw rpcError;

      const target = membersById.get(targetMemberId);
      setNotice(`Proposta enviada para ${target?.display_name || "o jogador"}.`);
      onClose?.();
      await safeLoad();
    } catch (sendError) {
      setError(messageOf(sendError));
    } finally {
      setBusy(false);
    }
  }

  async function respond(trade: TradeRequest, accept: boolean) {
    if (busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_respond_trade_request",
        {
          p_trade_id: trade.id,
          p_accept: accept,
        },
      );

      if (rpcError) throw rpcError;

      setNotice(accept ? "Troca concluída!" : "Troca recusada.");
      await safeLoad();
      await onChanged?.();
    } catch (respondError) {
      setError(messageOf(respondError));
    } finally {
      setBusy(false);
    }
  }

  async function cancel(trade: TradeRequest) {
    if (busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_cancel_trade_request",
        { p_trade_id: trade.id },
      );

      if (rpcError) throw rpcError;
      setNotice("Proposta cancelada.");
      await safeLoad();
    } catch (cancelError) {
      setError(messageOf(cancelError));
    } finally {
      setBusy(false);
    }
  }

  const outgoingPending = trades.filter(
    (trade) =>
      trade.requester_member_id === meId &&
      trade.status === "pending",
  );

  return (
    <>
      {notice && (
        <div className="trade-result-overlay" role="status">
          <div className="card trade-result-card">
            <strong>{notice}</strong>
            <button className="btn btn-primary" onClick={() => setNotice("")}>
              OK
            </button>
          </div>
        </div>
      )}

      {incoming.length > 0 && (
        <div className="trade-request-stack">
          {incoming.map((trade) => {
            const offered = playersById.get(trade.offered_player_id);
            const requested = playersById.get(trade.requested_player_id);
            const requester = membersById.get(trade.requester_member_id);

            if (!offered || !requested) return null;

            return (
              <section className="card trade-request-card" key={trade.id}>
                <div className="topbar">
                  <div>
                    <span className="special-badge card-type-badge">PROPOSTA DE TROCA</span>
                    <h2>{requester?.display_name || "Um jogador"} quer fazer uma troca</h2>
                  </div>
                </div>

                <div className="trade-vs-grid">
                  <div>
                    <small className="muted">VOCÊ RECEBE</small>
                    <PlayerTradeCard player={offered} />
                  </div>
                  <div className="trade-vs-mark">⇄</div>
                  <div>
                    <small className="muted">VOCÊ ENTREGA</small>
                    <PlayerTradeCard player={requested} />
                  </div>
                </div>

                <div className="trade-actions">
                  <button
                    className="btn btn-primary"
                    disabled={busy || meFinalized}
                    onClick={() => void respond(trade, true)}
                  >
                    {busy ? "Processando..." : "ACEITAR TROCA"}
                  </button>
                  <button
                    className="btn btn-secondary"
                    disabled={busy}
                    onClick={() => void respond(trade, false)}
                  >
                    RECUSAR
                  </button>
                </div>
              </section>
            );
          })}
        </div>
      )}

      {outgoingPending.length > 0 && (
        <section className="card trade-outgoing-card">
          <strong>Propostas enviadas</strong>
          {outgoingPending.map((trade) => {
            const recipient = membersById.get(trade.recipient_member_id);
            const offered = playersById.get(trade.offered_player_id);
            const requested = playersById.get(trade.requested_player_id);

            return (
              <div className="trade-outgoing-row" key={trade.id}>
                <span>
                  {offered?.name || "Jogador"} ⇄ {requested?.name || "Jogador"} com{" "}
                  <b>{recipient?.display_name || "jogador"}</b>
                </span>
                <button
                  className="btn btn-secondary"
                  disabled={busy}
                  onClick={() => void cancel(trade)}
                >
                  Cancelar
                </button>
              </div>
            );
          })}
        </section>
      )}

      {open && offeredPlayer && !meFinalized && (
        <div className="trade-modal-backdrop" role="dialog" aria-modal="true">
          <section className="card trade-modal">
            <div className="topbar">
              <div>
                <span className="special-badge card-type-badge">NEGOCIAR</span>
                <h2>Trocar {offeredPlayer.name}</h2>
              </div>
              <button className="btn btn-secondary" onClick={onClose}>
                Fechar
              </button>
            </div>

            <div className="trade-offer-current">
              <small className="muted">VOCÊ OFERECE</small>
              <PlayerTradeCard player={offeredPlayer} />
            </div>

            {error && <p className="red">{error}</p>}

            <h3>1. Escolha com quem quer trocar</h3>
            <div className="trade-member-grid">
              {availableMembers.length === 0 && (
                <p className="muted">Não há outro elenco disponível para troca agora.</p>
              )}

              {availableMembers.map((member) => (
                <button
                  key={member.id}
                  className={`btn ${targetMemberId === member.id ? "btn-primary" : "btn-secondary"}`}
                  onClick={() => {
                    setTargetMemberId(member.id);
                    setRequestedPlayerId(null);
                  }}
                >
                  {member.display_name}
                </button>
              ))}
            </div>

            {targetMemberId && (
              <>
                <h3>2. Escolha quem você quer receber</h3>
                <div className="trade-player-grid">
                  {targetRows.map((row) => {
                    const targetPlayer = playersById.get(row.player_id);
                    if (!targetPlayer) return null;

                    return (
                      <PlayerTradeCard
                        key={row.player_id}
                        player={targetPlayer}
                        selected={requestedPlayerId === row.player_id}
                        onClick={() => setRequestedPlayerId(row.player_id)}
                      />
                    );
                  })}
                </div>
              </>
            )}

            <button
              className="btn btn-primary"
              style={{ width: "100%", marginTop: 16 }}
              disabled={busy || !targetMemberId || !requestedPlayerId}
              onClick={() => void sendTrade()}
            >
              {busy ? "Enviando..." : "ENVIAR PROPOSTA DE TROCA"}
            </button>
          </section>
        </div>
      )}
    </>
  );
}
