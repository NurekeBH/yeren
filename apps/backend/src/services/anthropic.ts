// Минимальный клиент Anthropic Messages API (fetch, без SDK-зависимости).
// Используется AI Insights для копирайтинга советов администратору.
import { env } from '../config/env.js';

const API_URL = 'https://api.anthropic.com/v1/messages';
// Дешёвая модель для коротких формулировок (инсайты — 1 абзац + действие).
const MODEL = 'claude-haiku-4-5-20251001';

export function hasAnthropic(): boolean {
  return !!env.ANTHROPIC_API_KEY;
}

/** Один запрос к Claude. Возвращает текст или null при ошибке/отсутствии ключа. */
export async function claudeText(prompt: string, opts?: { maxTokens?: number; system?: string }): Promise<string | null> {
  if (!env.ANTHROPIC_API_KEY) return null;
  try {
    const res = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: opts?.maxTokens ?? 400,
        ...(opts?.system ? { system: opts.system } : {}),
        messages: [{ role: 'user', content: prompt }],
      }),
    });
    if (!res.ok) return null;
    const data = (await res.json()) as { content?: Array<{ type: string; text?: string }> };
    const text = (data.content ?? []).filter((b) => b.type === 'text').map((b) => b.text ?? '').join('').trim();
    return text || null;
  } catch {
    return null;
  }
}
