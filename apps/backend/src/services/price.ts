/// XAU/USD тірі бағасы — Binance PAXG/USDT (кілтсіз, mobile қолданатын дереккөз).
/// PAXG ≈ 1 тройя унция алтын, USDT ≈ USD. Қол жетпесе null.
export async function fetchXauPrice(): Promise<number | null> {
  try {
    const res = await fetch('https://api.binance.com/api/v3/ticker/price?symbol=PAXGUSDT', {
      signal: AbortSignal.timeout(8000),
    });
    if (!res.ok) return null;
    const data = (await res.json()) as { price?: string };
    const p = Number(data.price);
    return Number.isFinite(p) && p > 0 ? p : null;
  } catch {
    return null;
  }
}
