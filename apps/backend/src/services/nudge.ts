// Nudge Generator: персонализированный, single-actionable текст пуша по стилю
// пользователя + Focus Hours (тихие часы). Никаких «у вас 5 новых сигналов».
export type NudgeStyle = 'direct' | 'gamified';
export interface NudgeCtx {
  trader?: string;
  winRate?: number;
}

/** Текст возвратного пуша: одно лёгкое действие, с заботой о фокусе. */
export function buildNudge(style: NudgeStyle, ctx: NudgeCtx): { title: string; body: string } {
  const trader = ctx.trader ?? 'Топ-трейдер';
  const wr = ctx.winRate ? ` (винрейт ${ctx.winRate}%)` : '';
  if (style === 'gamified') {
    return {
      title: `🎯 ${trader} снова в игре!`,
      body: `Золото (XAUUSD) в сильной зоне закупа. ${trader}${wr} выставил ордер. Один клик — и ты в деле 🔥 +бонусы за дисциплину.`,
    };
  }
  // direct — прямая инструкция, одно действие.
  return {
    title: `${trader} выставил ордер по золоту`,
    body: `Рынок золота (XAUUSD) сейчас в сильной зоне закупа. ${trader}${wr} уже вошёл. Глянуть его точку входа в один клик?`,
  };
}

/** Focus Hours: тихо 22:00–08:00 по локальному времени юзера (кроме крит. алертов).
 *  true = сейчас МОЖНО слать. */
export function canPushNow(prefs: { focus_hours: boolean; tz_offset_min: number }): boolean {
  if (!prefs.focus_hours) return true;
  const nowUtcMin = new Date().getUTCHours() * 60 + new Date().getUTCMinutes();
  const localMin = (((nowUtcMin + prefs.tz_offset_min) % 1440) + 1440) % 1440;
  const h = Math.floor(localMin / 60);
  return h >= 8 && h < 22; // тихо 22:00–07:59
}
