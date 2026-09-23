"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../lib/supabase";
import { benchSlotsForMode, positionGroup, rosterSizeForMode } from "../lib/squad-board";
import { playAuctionWinFeedback } from "../lib/feedback";
import ConnectionBanner from "./ConnectionBanner";
import RoomChat from "./RoomChat";
import PlayerFace from "./PlayerFace";
import CardBadge, { cardClass } from "./CardBadge";
import GavelWinAnimation from "./GavelWinAnimation";

type Room = {
  id: string;
  code: string;
  host_user_id: string;
  budget: number;
  mode: "football" | "futsal";
  reserve_count: number;
  room_kind: "auction" | "tournament";
  status: string;
};

type Member = {
  id: string;
  user_id: string;
  display_name: string;
  balance: number;
  is_host: boolean;
  squad_finalized: boolean;
  is_spectator: boolean;
  last_seen_at: string;
};

type Player = {
  id: string;
  name: string;
  primary_position: string;
  overall: number;
  club: string | null;
  league: string | null;
  image_url: string | null;
  player_type: "ACTIVE" | "ICON" | "SPECIAL";
  metadata?: {version_label?: string; season_year?: number};
};

type SquadSlot = {
  member_id: string;
  player_id: string;
  slot_key: string;
  is_bench: boolean;
};

type Auction = {
  id: string;
  room_id: string;
  player_id: string;
  status: "interest" | "bidding" | "sold" | "skipped";
  current_bid: number;
  current_bidder_member_id: string | null;
  turn_member_id: string | null;
  winner_member_id: string | null;
  final_price: number | null;
  created_at: string;
};

type Interest = {
  wants: boolean;
  bidding_active: boolean;
  turn_order: number | null;
};

type HistoryItem = {
  id: string;
  status: Auction["status"];
  playerName: string;
  overall: number;
  playerType: Player["player_type"];
  metadata?: Player["metadata"];
  winnerName: string;
  finalPrice: number | null;
  createdAt: string;
};

const footballSlots = ["GOL", "LD", "ZAG1", "ZAG2", "LE", "VOL", "MC", "MEI", "PD", "PE", "ATA"];
const futsalSlots = ["GOL", "FIXO", "ALAE", "ALAD", "PIVO"];

function slotLabel(slot: string) {
  return slot
    .replace("ZAG1", "ZAG E")
    .replace("ZAG2", "ZAG D")
    .replace("ALAE", "ALA E")
    .replace("ALAD", "ALA D")
    .replace("PIVO", "PIVÔ");
}

function errorMessage(error: unknown) {
  if (error instanceof Error) return error.message;
  if (error && typeof error === "object" && "message" in error) {
    const value = (error as { message?: unknown }).message;
    if (typeof value === "string" && value.trim()) return value;
  }
  return "Falha temporária de sincronização.";
}

export default function AuctionGame() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();

  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [me, setMe] = useState<Member | null>(null);
  const [mySquad, setMySquad] = useState<SquadSlot[]>([]);
  const [auction, setAuction] = useState<Auction | null>(null);
  const [player, setPlayer] = useState<Player | null>(null);
  const [myInterest, setMyInterest] = useState<Interest | null>(null);
  const [history, setHistory] = useState<HistoryItem[]>([]);
  const [view, setView] = useState<"auction" | "history">("auction");
  const [revealed, setRevealed] = useState(false);
  const [answered, setAnswered] = useState(false);
  const [bid, setBid] = useState(1);
  const [actionError, setActionError] = useState("");
  const [syncError, setSyncError] = useState("");
  const [loading, setLoading] = useState(true);
  const [actionBusy, setActionBusy] = useState(false);

  const lastAuctionId = useRef<string | null>(null);
  const feedbackAuctionId = useRef<string | null>(null);

  const refresh = useCallback(async () => {
    const supabase = getSupabase();
    const session = await ensureAnonymousSession();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,budget,mode,reserve_count,room_kind,status")
      .eq("code", code)
      .maybeSingle();

    if (roomError) throw roomError;
    if (!roomData) throw new Error("Sala não encontrada.");

    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const { data: memberData, error: memberError } = await supabase
      .from("fa_room_members")
      .select("id,user_id,display_name,balance,is_host,squad_finalized,is_spectator,last_seen_at")
      .eq("room_id", typedRoom.id)
      .order("joined_at");

    if (memberError) throw memberError;

    const typedMembers = (memberData || []) as Member[];
    setMembers(typedMembers);

    const myMember = typedMembers.find((member) => member.user_id === session.user.id) || null;
    setMe(myMember);

    if (!myMember) {
      throw new Error("Sua sessão não está vinculada a esta sala. Entre novamente pelo código.");
    }

    const { data: squadData, error: squadError } = await supabase
      .from("fa_squad_players")
      .select("member_id,player_id,slot_key,is_bench")
      .eq("member_id", myMember.id);

    if (squadError) throw squadError;
    setMySquad((squadData || []) as SquadSlot[]);

    const { data: historyData, error: historyError } = await supabase
      .from("fa_auctions")
      .select("id,player_id,status,winner_member_id,final_price,created_at")
      .eq("room_id", typedRoom.id)
      .order("created_at", { ascending: false })
      .limit(30);

    if (historyError) throw historyError;

    const rawHistory = (historyData || []) as Array<{
      id: string;
      player_id: string;
      status: Auction["status"];
      winner_member_id: string | null;
      final_price: number | null;
      created_at: string;
    }>;

    const historyPlayerIds = Array.from(new Set(rawHistory.map((item) => item.player_id)));
    let historyPlayers: Player[] = [];

    if (historyPlayerIds.length) {
      const { data: historyPlayerData, error: historyPlayerError } = await supabase
        .from("fa_players")
        .select("id,name,club,primary_position,overall,league,image_url,player_type,metadata")
        .in("id", historyPlayerIds);

      if (historyPlayerError) throw historyPlayerError;
      historyPlayers = (historyPlayerData || []) as Player[];
    }

    const historyPlayerMap = new Map(historyPlayers.map((item) => [item.id, item]));
    const memberMap = new Map(typedMembers.map((item) => [item.id, item]));

    setHistory(
      rawHistory.map((item) => {
        const historyPlayer = historyPlayerMap.get(item.player_id);
        return {
          id: item.id,
          status: item.status,
          playerName: historyPlayer?.name || "Jogador",
          overall: historyPlayer?.overall || 0,
          playerType: historyPlayer?.player_type || "ACTIVE",
          metadata: historyPlayer?.metadata,
          winnerName: item.winner_member_id
            ? memberMap.get(item.winner_member_id)?.display_name || "Jogador"
            : "",
          finalPrice: item.final_price,
          createdAt: item.created_at,
        };
      }),
    );

    const { data: auctionData, error: auctionError } = await supabase
      .from("fa_auctions")
      .select("id,room_id,player_id,status,current_bid,current_bidder_member_id,turn_member_id,winner_member_id,final_price,created_at")
      .eq("room_id", typedRoom.id)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (auctionError) throw auctionError;

    if (!auctionData) {
      setAuction(null);
      setPlayer(null);
      setMyInterest(null);
      setAnswered(false);
      lastAuctionId.current = null;
      setSyncError("");
      return;
    }

    const typedAuction = auctionData as Auction;
    const isNewAuction = lastAuctionId.current !== typedAuction.id;

    if (isNewAuction) {
      setAnswered(false);
      lastAuctionId.current = typedAuction.id;
      setBid(Math.max(1, typedAuction.current_bid + 1));
    } else {
      setBid((value) => Math.max(value, typedAuction.current_bid + 1));
    }

    setAuction(typedAuction);

    const { data: playerData, error: playerError } = await supabase
      .from("fa_players")
      .select("id,name,club,primary_position,overall,league,image_url,player_type,metadata")
      .eq("id", typedAuction.player_id)
      .maybeSingle();

    if (playerError) throw playerError;
    if (!playerData) throw new Error("O jogador atual ainda não foi sincronizado.");

    setPlayer(playerData as Player);

    if (!myMember.is_spectator && (typedAuction.status === "interest" || typedAuction.status === "bidding")) {
      const { data: interest, error: interestError } = await supabase
        .from("fa_player_interest")
        .select("wants,bidding_active,turn_order")
        .eq("auction_id", typedAuction.id)
        .eq("member_id", myMember.id)
        .maybeSingle();

      if (interestError) throw interestError;

      const typedInterest = (interest || null) as Interest | null;
      setMyInterest(typedInterest);

      if (typedAuction.status === "interest") setAnswered(!!typedInterest);
    } else {
      setMyInterest(null);
    }

    setSyncError("");
  }, [code]);

  const safeRefresh = useCallback(async () => {
    try {
      await refresh();
    } catch (error) {
      setSyncError(errorMessage(error));
    } finally {
      setLoading(false);
    }
  }, [refresh]);

  useEffect(() => {
    void safeRefresh();
    const retry = window.setInterval(() => void safeRefresh(), 12000);
    return () => window.clearInterval(retry);
  }, [safeRefresh]);

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

    const supabase = getSupabase();
    let refreshTimer: number | null = null;
    const queueRefresh = () => {
      if (refreshTimer !== null) window.clearTimeout(refreshTimer);
      refreshTimer = window.setTimeout(() => {
        refreshTimer = null;
        void safeRefresh();
      }, 120);
    };

    const channel = supabase
      .channel(`football-auction:auction:${room.id}`)
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "fa_auctions", filter: `room_id=eq.${room.id}` },
        queueRefresh,
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` },
        queueRefresh,
      )
      .on(
        "postgres_changes",
        { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` },
        queueRefresh,
      )
      .subscribe();

    return () => {
      if (refreshTimer !== null) window.clearTimeout(refreshTimer);
      void supabase.removeChannel(channel);
    };
  }, [room?.id, safeRefresh]);

  useEffect(() => {
    if (!auction?.id) return;
    setRevealed(false);
    const timer = window.setTimeout(() => setRevealed(true), 1250);
    return () => window.clearTimeout(timer);
  }, [auction?.id]);

  useEffect(() => {
    if (auction?.status !== "sold" || feedbackAuctionId.current === auction.id) return;
    feedbackAuctionId.current = auction.id;
    playAuctionWinFeedback();
  }, [auction?.id, auction?.status]);

  const winnerName = useMemo(
    () => members.find((member) => member.id === auction?.winner_member_id)?.display_name || "",
    [members, auction?.winner_member_id],
  );

  const bidderName = useMemo(
    () => members.find((member) => member.id === auction?.current_bidder_member_id)?.display_name || "",
    [members, auction?.current_bidder_member_id],
  );

  const turnName = useMemo(
    () => members.find((member) => member.id === auction?.turn_member_id)?.display_name || "",
    [members, auction?.turn_member_id],
  );

  const online = useCallback(
    (member: Member) => Date.now() - new Date(member.last_seen_at).getTime() < 30_000,
    [],
  );

  const isHost = !!room && !!me && room.host_user_id === me.user_id;
  const isSpectator = !!me?.is_spectator;
  const isMyTurn = !!auction && !!me && !isSpectator && auction.turn_member_id === me.id;
  const isHighestBidder = !!auction && !!me && !isSpectator && auction.current_bidder_member_id === me.id;
  const isActiveBidder = !!myInterest?.bidding_active;

  const requiredSlots = room?.mode === "futsal" ? futsalSlots : footballSlots;
  const benchSlots = benchSlotsForMode(room?.mode || "football", room?.reserve_count).map((slot) => slot.key);
  const rosterSize = rosterSizeForMode(room?.mode || "football", room?.reserve_count);
  const filledSlots = new Set(mySquad.map((slot) => slot.slot_key));
  const starterComplete = requiredSlots.every((slot) => filledSlots.has(slot));
  const rosterComplete = starterComplete && benchSlots.every((slot) => filledSlots.has(slot));
  const minimumBid = (auction?.current_bid || 0) + 1;

  const currentPositionFull = useMemo(() => {
    if (isSpectator) return true;
    if (!player || !room) return false;
    if (mySquad.length >= rosterSize) return true;

    // Enquanto houver lugar no banco, um segundo jogador da mesma posição
    // continua elegível. Depois ele pode substituir o titular na prancheta.
    const benchHasRoom = benchSlots.some((slot) => !filledSlots.has(slot));
    if (benchHasRoom) return false;

    const target = positionGroup(player.primary_position);

    // Banco cheio: só deixa disputar se essa posição ainda puder preencher
    // uma vaga titular que esteja faltando.
    if (room.mode === "futsal") {
      if (target === "GOL") return filledSlots.has("GOL");
      return ["FIXO", "ALAE", "ALAD", "PIVO"].every((slot) => filledSlots.has(slot));
    }

    if (target === "ZAG") return filledSlots.has("ZAG1") && filledSlots.has("ZAG2");

    if (["GOL", "LD", "LE", "VOL", "MC", "MEI", "PD", "PE", "ATA"].includes(target)) {
      return filledSlots.has(target);
    }

    return true;
  }, [isSpectator, player, room, mySquad.length, rosterSize, benchSlots, filledSlots]);

  function applyAuctionResponse(data: unknown) {
    if (!data || typeof data !== "object" || !("id" in data) || !("status" in data)) return;
    const nextAuction = data as Auction;
    setAuction(nextAuction);
    setBid(Math.max(1, nextAuction.current_bid + 1));
  }

  async function chooseInterest(wants: boolean) {
    if (!auction || isSpectator || actionBusy || answered) return;

    setActionError("");
    setAnswered(true);
    setActionBusy(true);

    try {
      const { data, error } = await getSupabase().rpc("fa_set_interest", {
        p_auction_id: auction.id,
        p_wants: wants,
      });

      if (error) throw error;

      applyAuctionResponse(data);
      window.setTimeout(() => void safeRefresh(), 80);
    } catch (error) {
      setAnswered(false);
      setActionError(errorMessage(error));
    } finally {
      setActionBusy(false);
    }
  }

  async function placeBid() {
    if (!auction || !isMyTurn || isSpectator || actionBusy) return;

    const amount = Math.max(minimumBid, Math.trunc(Number(bid) || minimumBid));
    if (!me || amount > me.balance) {
      setActionError("Seu lance não pode ser maior que o seu saldo.");
      return;
    }

    setActionError("");
    setActionBusy(true);

    try {
      const { data, error } = await getSupabase().rpc("fa_place_bid", {
        p_auction_id: auction.id,
        p_amount: amount,
      });

      if (error) throw error;

      applyAuctionResponse(data);
      window.setTimeout(() => void safeRefresh(), 80);
    } catch (error) {
      setActionError(errorMessage(error));
    } finally {
      setActionBusy(false);
    }
  }

  async function withdrawBid() {
    if (!auction || !isMyTurn || isSpectator || actionBusy) return;

    setActionError("");
    setActionBusy(true);

    try {
      const { data, error } = await getSupabase().rpc("fa_withdraw_bid", {
        p_auction_id: auction.id,
      });

      if (error) throw error;

      applyAuctionResponse(data);
      window.setTimeout(() => void safeRefresh(), 80);
    } catch (error) {
      setActionError(errorMessage(error));
    } finally {
      setActionBusy(false);
    }
  }

  async function nextPlayer() {
    if (!room || !isHost || actionBusy) return;

    setActionError("");
    setActionBusy(true);

    const { data, error } = await getSupabase().rpc("fa_start_next_auction", {
      p_room_id: room.id,
    });

    if (error) {
      setActionBusy(false);
      return setActionError(error.message);
    }

    applyAuctionResponse(data);

    const result = data as {
      auto_completed_last?: boolean;
      waiting_for_lineups?: boolean;
      players_added?: number;
    } | null;

    if (result?.auto_completed_last) {
      setActionError(
        result.players_added
          ? `O último elenco recebeu ${result.players_added} jogador(es) automaticamente. Agora falta organizar e finalizar.`
          : "O último elenco já está completo. Falta organizar e finalizar.",
      );
    } else if (result?.waiting_for_lineups) {
      setActionError("Os elencos restantes já estão completos. Falta organizar a prancheta e finalizar.");
    }

    setAnswered(false);
    setActionBusy(false);
    window.setTimeout(() => void safeRefresh(), 80);
  }

  if (loading) {
    return <main className="container"><p>Carregando leilão...</p></main>;
  }

  return (
    <main className="container">
      <ConnectionBanner />

      <div className="topbar auction-topbar">
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          <span className="badge">Sala {code}</span>
          {isSpectator && <span className="badge spectator-badge">Modo espectador</span>}
        </div>

        <div style={{ display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap", justifyContent: "flex-end" }}>
          <button
            className="btn btn-secondary"
            onClick={() => router.push(`/sala/${code}/lobby`)}
          >
            Voltar ao lobby
          </button>

          {!isSpectator && (
            <button
              className="btn btn-secondary"
              onClick={() => router.push(`/sala/${code}/elenco`)}
              disabled={!mySquad.length}
            >
              Organizar prancheta
            </button>
          )}

          {!isSpectator && <span className="badge">Elenco: {mySquad.length}/{rosterSize}</span>}
          {!isSpectator && <strong>Saldo: {me?.balance ?? 0}</strong>}
        </div>
      </div>

      <div className="auction-tabs">
        <button
          className={`btn ${view === "auction" ? "btn-primary" : "btn-secondary"}`}
          onClick={() => setView("auction")}
        >
          Leilão
        </button>
        <button
          className={`btn ${view === "history" ? "btn-primary" : "btn-secondary"}`}
          onClick={() => setView("history")}
        >
          Histórico
        </button>
      </div>

      <div className="online-strip">
        {members.map((member) => (
          <span className="badge" key={member.id}>
            <span className={`presence-dot ${online(member) ? "online" : "offline"}`} />
            {member.display_name}{member.is_spectator ? " 👀" : ""}
          </span>
        ))}
      </div>

      {!isSpectator && (
        <section className="card squad-progress-card">
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            {requiredSlots.map((slot) => (
              <span key={slot} className="badge" style={{ opacity: filledSlots.has(slot) ? 1 : 0.45 }}>
                {filledSlots.has(slot) ? "✓ " : "○ "}{slotLabel(slot)}
              </span>
            ))}
          </div>

          {mySquad.length > 0 && !me?.squad_finalized && (
            <p className="muted" style={{ marginBottom: 0 }}>
              O sorteio prioriza as posições titulares que faltam. Depois completa o banco.
            </p>
          )}

          {rosterComplete && !me?.squad_finalized && (
            <div style={{ marginTop: 14 }}>
              <p className="red" style={{ fontWeight: 900 }}>
                Seu elenco está completo. Organize titulares e reservas antes de finalizar.
              </p>
              <button className="btn btn-primary" onClick={() => router.push(`/sala/${code}/elenco`)}>
                Organizar prancheta e finalizar
              </button>
            </div>
          )}

          {me?.squad_finalized && (
            <p className="muted" style={{ marginBottom: 0 }}>
              ✓ Seu time está finalizado. Você continua acompanhando o leilão.
            </p>
          )}
        </section>
      )}

      {syncError && (
        <div className="card" style={{ marginBottom: 16 }}>
          <p className="red" style={{ marginBottom: 6 }}>Sincronização instável</p>
          <p className="muted" style={{ margin: 0 }}>{syncError} O jogo tentará novamente automaticamente.</p>
        </div>
      )}

      {actionError && (
        <div className="card" style={{ marginBottom: 16 }}>
          <p className="red" style={{ margin: 0 }}>{actionError}</p>
        </div>
      )}

      {room && <RoomChat roomId={room.id} />}

      {view === "history" ? (
        <section className="card history-panel">
          <div className="topbar" style={{ marginBottom: 12 }}>
            <div>
              <h2 style={{ margin: 0 }}>Histórico da partida</h2>
              <p className="muted" style={{ margin: "4px 0 0" }}>Últimos {history.length} sorteios.</p>
            </div>
          </div>

          <div className="history-list">
            {history.length === 0 && <p className="muted">Nenhum jogador sorteado ainda.</p>}

            {history.map((item) => (
              <div className={`history-row ${cardClass({player_type:item.playerType})}`} key={item.id}>
                <div>
                  <CardBadge player={{player_type:item.playerType,metadata:item.metadata}} /> <strong>{item.playerName}</strong>
                  {item.overall > 0 && <span className="muted"> • GER {item.overall}</span>}
                </div>

                <div style={{ textAlign: "right" }}>
                  {item.status === "sold" ? (
                    <>
                      <strong className="red">{item.winnerName}</strong>
                      <div className="muted">
                        {item.finalPrice === 0 ? "de graça" : `${item.finalPrice} créditos`}
                      </div>
                    </>
                  ) : item.status === "skipped" ? (
                    <span className="muted">Passou sem dono</span>
                  ) : (
                    <span className="muted">Em andamento</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </section>
      ) : !auction || !player ? (
        <section className="card auction-card-shell">
          <h2>Aguardando jogador</h2>
          <p className="muted">O administrador precisa iniciar o próximo sorteio.</p>
        </section>
      ) : !revealed ? (
        <section className="card auction-card-shell reveal-stage">
          <div className="reveal-kicker">NOVO JOGADOR</div>
          <div className="reveal-position">{player.primary_position}</div>
          <div className="reveal-pulse">•••</div>
          <p className="muted">Revelando...</p>
        </section>
      ) : (
        <section className={`card auction-card-shell auction-player-card ${player.player_type === "SPECIAL" ? "special-card special-reveal" : player.player_type === "ICON" ? "icon-card" : "active-card"}`}>
          <div className="red" style={{ fontSize: 18, fontWeight: 900, letterSpacing: 2 }}>GER</div>
          <div className="red auction-ger">{player.overall}</div>
          {player.player_type === "SPECIAL" && <><div className="special-orbit" aria-hidden="true">✦</div><CardBadge player={player}/></>}

          {player.player_type === "ICON" && (
            <div style={{ marginTop: 8 }}>
              <span className="badge icon-badge">★ ICON</span>
            </div>
          )}

          <div className="auction-face">
            <PlayerFace name={player.name} imageUrl={player.image_url} size={124} />
          </div>

          <h1 className="auction-player-name">{player.name}</h1>
          <p style={{ margin: "0 0 12px", fontWeight: 900 }}>
            {player.club || (player.league === "LEGENDS" ? "Lendas" : "Clube em revisão")} — {player.primary_position}
          </p>

          <div style={{ display: "flex", gap: 8, justifyContent: "center", flexWrap: "wrap" }}>
            <span className="badge"><strong>Clube:</strong> {player.club || "Em revisão"}</span>
            <span className="badge"><strong>Posição:</strong> {player.primary_position}</span>
            <span className="badge"><strong>Liga:</strong> {player.league === "LEGENDS" ? "Lendas" : (player.league || "—")}</span>
          </div>

          {isSpectator ? (
            <div className="spectator-message">
              <strong>👀 Você está assistindo.</strong>
              <p className="muted">Os jogadores conectados decidem o leilão.</p>
            </div>
          ) : auction.status === "interest" ? (
            <div style={{ marginTop: 26 }}>
              <h2>Você quer disputar este jogador?</h2>

              {me?.squad_finalized ? (
                <p className="muted">Seu time já está finalizado.</p>
              ) : currentPositionFull ? (
                <p className="muted">Este jogador não pode entrar no seu elenco agora. PASSAR automático.</p>
              ) : answered ? (
                <p className="muted">Resposta enviada. Aguardando os outros jogadores...</p>
              ) : (
                <div style={{ display: "flex", gap: 12, justifyContent: "center" }}>
                  <button
                    className="btn btn-primary"
                    disabled={actionBusy}
                    onClick={() => void chooseInterest(true)}
                  >
                    {actionBusy ? "ENVIANDO..." : "QUERO"}
                  </button>
                  <button
                    className="btn btn-secondary"
                    disabled={actionBusy}
                    onClick={() => void chooseInterest(false)}
                  >
                    {actionBusy ? "ENVIANDO..." : "PASSAR"}
                  </button>
                </div>
              )}
            </div>
          ) : auction.status === "bidding" ? (
            <div style={{ marginTop: 28 }}>
              <div className="card bid-status-card">
                {auction.current_bidder_member_id ? (
                  <p style={{ margin: 0, fontSize: 18 }}>
                    Maior lance: <strong className="red">{auction.current_bid} créditos</strong> — {bidderName}
                  </p>
                ) : (
                  <p style={{ margin: 0, fontSize: 18 }}>Ainda não houve lance.</p>
                )}
              </div>

              {!isActiveBidder ? (
                <p className="muted">Você não está mais na disputa. Aguardando os demais.</p>
              ) : isHighestBidder ? (
                <div>
                  <h2 className="red">VOCÊ ESTÁ NA FRENTE</h2>
                  <p className="muted">Seu lance é o maior.</p>
                </div>
              ) : isMyTurn ? (
                <div>
                  <h2 className="red" style={{ fontSize: 30 }}>SUA VEZ</h2>
                  <p className="muted">Aumente o maior lance ou desista.</p>

                  <div className="bid-controls">
                    <label className="bid-input-wrap">
                      <span>Digite seu lance</span>
                      <input
                        className="input bid-amount-input"
                        type="number"
                        inputMode="numeric"
                        min={minimumBid}
                        max={me?.balance ?? undefined}
                        step={1}
                        value={bid || ""}
                        disabled={actionBusy}
                        onFocus={(event) => event.currentTarget.select()}
                        onChange={(event) => {
                          const value = Number(event.target.value);
                          setBid(Number.isFinite(value) ? Math.max(0, Math.trunc(value)) : minimumBid);
                        }}
                        onBlur={() => {
                          setBid((value) =>
                            Math.min(
                              me?.balance ?? Math.max(minimumBid, value),
                              Math.max(minimumBid, value),
                            ),
                          );
                        }}
                        onKeyDown={(event) => {
                          if (event.key === "Enter") {
                            event.preventDefault();
                            void placeBid();
                          }
                        }}
                        aria-label="Valor do lance"
                      />
                      <small className="muted">
                        Mínimo {minimumBid} • Saldo {me?.balance ?? 0}
                      </small>
                    </label>

                    <button
                      className="btn btn-primary"
                      onClick={() => void placeBid()}
                      disabled={
                        actionBusy ||
                        !me ||
                        Math.max(minimumBid, Math.trunc(Number(bid) || minimumBid)) > me.balance
                      }
                    >
                      {actionBusy ? "ENVIANDO..." : "DAR LANCE"}
                    </button>

                    <button
                      className="btn btn-secondary"
                      disabled={actionBusy}
                      onClick={() => void withdrawBid()}
                    >
                      DESISTIR
                    </button>
                  </div>
                </div>
              ) : (
                <div>
                  <h2>Vez de {turnName || "outro jogador"}</h2>
                  <p className="muted">Se ele perder conexão, o jogo segue automaticamente.</p>
                </div>
              )}
            </div>
          ) : auction.status === "sold" ? (
            <div style={{ marginTop: 28 }}>
              <GavelWinAnimation auctionId={auction.id} />
              <h2 className="red">LEILOADO PARA {winnerName.toUpperCase()}</h2>
              <p>{auction.final_price === 0 ? "Levou de graça." : `${auction.final_price} créditos`}</p>

              {isHost && <button className="btn btn-primary" disabled={actionBusy} onClick={() => void nextPlayer()}>{actionBusy ? "CARREGANDO..." : "Próximo jogador"}</button>}
              {!isHost && <p className="muted">Aguardando o administrador chamar o próximo jogador.</p>}
            </div>
          ) : (
            <div style={{ marginTop: 28 }}>
              <h2>Ninguém ficou com este jogador</h2>
              <p className="muted">Jogador pulado.</p>
              {isHost && <button className="btn btn-primary" onClick={() => void nextPlayer()}>Próximo jogador</button>}
              {!isHost && <p className="muted">Aguardando o administrador.</p>}
            </div>
          )}
        </section>
      )}
    </main>
  );
}
