"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { ensureAnonymousSession, getSupabase } from "../lib/supabase";

type ChatMessage = {
  id: string;
  room_id: string;
  member_id: string | null;
  display_name: string;
  body: string;
  created_at: string;
  deleted_at: string | null;
};

type Member = {
  id: string;
  user_id: string;
};

export default function RoomChat({ roomId }: { roomId: string }) {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [me, setMe] = useState<Member | null>(null);
  const [isHost, setIsHost] = useState(false);
  const [unread, setUnread] = useState(0);
  const [body, setBody] = useState("");
  const [sending, setSending] = useState(false);
  const [error, setError] = useState("");
  const listRef = useRef<HTMLDivElement | null>(null);

  const loadMessages = useCallback(async () => {
    const supabase = getSupabase();
    const { data, error: loadError } = await supabase
      .from("fa_room_messages")
      .select("id,room_id,member_id,display_name,body,created_at,deleted_at")
      .eq("room_id", roomId)
      .order("created_at", { ascending: false })
      .limit(80);

    if (loadError) throw loadError;
    setMessages(((data || []) as ChatMessage[]).reverse());
  }, [roomId]);

  useEffect(() => {
    let mounted = true;

    void (async () => {
      try {
        const supabase = getSupabase();
        const session = await ensureAnonymousSession();

        const [{ data: memberData, error: memberError }, { data: roomData, error: roomError }] =
          await Promise.all([
            supabase
              .from("fa_room_members")
              .select("id,user_id")
              .eq("room_id", roomId)
              .eq("user_id", session.user.id)
              .maybeSingle(),
            supabase
              .from("fa_rooms")
              .select("host_user_id")
              .eq("id", roomId)
              .maybeSingle(),
          ]);

        if (memberError) throw memberError;
        if (roomError) throw roomError;
        if (!mounted) return;

        setMe((memberData || null) as Member | null);
        setIsHost(roomData?.host_user_id === session.user.id);
        await loadMessages();
      } catch (e) {
        if (mounted) setError(e instanceof Error ? e.message : "Não foi possível abrir o chat.");
      }
    })();

    return () => {
      mounted = false;
    };
  }, [roomId, loadMessages]);

  useEffect(() => {
    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:chat:${roomId}`)
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "fa_room_messages", filter: `room_id=eq.${roomId}` },
        (payload) => {
          const newMessage = payload.new as ChatMessage | undefined;

          if (
            payload.eventType === "INSERT" &&
            !open &&
            newMessage?.member_id &&
            newMessage.member_id !== me?.id
          ) {
            setUnread((value) => value + 1);
          }

          void loadMessages();
        },
      )
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [roomId, loadMessages, open, me?.id]);

  useEffect(() => {
    if (!open) return;
    setUnread(0);
    window.setTimeout(() => {
      listRef.current?.scrollTo({ top: listRef.current.scrollHeight, behavior: "smooth" });
    }, 40);
  }, [open, messages.length]);

  async function sendMessage() {
    const value = body.trim();
    if (!value || sending) return;

    setSending(true);
    setError("");

    try {
      const { error: sendError } = await getSupabase().rpc("fa_send_room_message", {
        p_room_id: roomId,
        p_body: value,
      });

      if (sendError) throw sendError;
      setBody("");
      await loadMessages();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível enviar a mensagem.");
    } finally {
      setSending(false);
    }
  }

  async function deleteMessage(messageId: string) {
    setError("");

    try {
      const { error: deleteError } = await getSupabase().rpc("fa_delete_room_message", {
        p_message_id: messageId,
      });

      if (deleteError) throw deleteError;
      await loadMessages();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível apagar a mensagem.");
    }
  }

  return (
    <>
      <button
        type="button"
        className={`room-chat-toggle ${open ? "open" : ""}`}
        onClick={() => setOpen((value) => !value)}
        aria-label={open ? "Fechar chat" : "Abrir chat"}
      >
        <span aria-hidden="true">💬</span>
        <strong>{open ? "Fechar" : "Chat"}</strong>
        {unread > 0 && <b className="room-chat-unread">{unread > 99 ? "99+" : unread}</b>}
      </button>

      {open && (
        <aside className="room-chat-panel" aria-label="Chat da sala">
          <div className="room-chat-header">
            <div>
              <strong>Chat da sala</strong>
              <small>Conversa ao vivo</small>
            </div>
            <button type="button" onClick={() => setOpen(false)} aria-label="Fechar chat">×</button>
          </div>

          <div className="room-chat-messages" ref={listRef}>
            {messages.length === 0 && (
              <div className="room-chat-empty">
                <span>💬</span>
                <strong>Comece a conversa</strong>
                <small>As mensagens desta sala aparecem aqui em tempo real.</small>
              </div>
            )}

            {messages.map((message) => {
              const mine = message.member_id === me?.id;
              const canDelete = !message.deleted_at && (mine || isHost);

              return (
                <div
                  key={message.id}
                  className={`room-chat-message ${mine ? "mine" : ""} ${message.deleted_at ? "deleted" : ""}`}
                >
                  <div className="room-chat-message-top">
                    <strong>{mine ? "Você" : message.display_name}</strong>
                    <span>
                      {new Date(message.created_at).toLocaleTimeString([], {
                        hour: "2-digit",
                        minute: "2-digit",
                      })}
                    </span>
                  </div>

                  <p>{message.body}</p>

                  {canDelete && (
                    <button type="button" onClick={() => void deleteMessage(message.id)}>
                      Apagar
                    </button>
                  )}
                </div>
              );
            })}
          </div>

          <div className="room-chat-compose">
            {error && <p className="room-chat-error">{error}</p>}

            <div className="room-chat-quick">
              {["😂", "🔥", "😭", "💸", "👑"].map((emoji) => (
                <button
                  type="button"
                  key={emoji}
                  onClick={() => setBody((value) => (value + emoji).slice(0, 400))}
                >
                  {emoji}
                </button>
              ))}
            </div>

            <textarea
              value={body}
              onChange={(event) => setBody(event.target.value.slice(0, 400))}
              onKeyDown={(event) => {
                if (event.key === "Enter" && !event.shiftKey) {
                  event.preventDefault();
                  void sendMessage();
                }
              }}
              placeholder="Escreva uma mensagem..."
              maxLength={400}
              rows={2}
            />

            <div className="room-chat-send-row">
              <small>{body.length}/400</small>
              <button
                type="button"
                className="btn btn-primary"
                onClick={() => void sendMessage()}
                disabled={!body.trim() || sending}
              >
                {sending ? "Enviando..." : "Enviar"}
              </button>
            </div>
          </div>
        </aside>
      )}
    </>
  );
}
