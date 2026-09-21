export function playAuctionWinFeedback() {
  if (typeof window === "undefined") return;

  try {
    navigator.vibrate?.([70, 45, 110]);
  } catch {
    // Vibração é opcional.
  }

  try {
    const AudioCtx =
      window.AudioContext ||
      (window as typeof window & { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
    if (!AudioCtx) return;

    const ctx = new AudioCtx();
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0.0001, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.14, ctx.currentTime + 0.01);
    gain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.24);
    gain.connect(ctx.destination);

    const osc = ctx.createOscillator();
    osc.type = "triangle";
    osc.frequency.setValueAtTime(150, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(78, ctx.currentTime + 0.22);
    osc.connect(gain);
    osc.start();
    osc.stop(ctx.currentTime + 0.25);
    window.setTimeout(() => void ctx.close(), 400);
  } catch {
    // Alguns navegadores bloqueiam áudio sem interação prévia.
  }
}
