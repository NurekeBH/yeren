'use client';

export const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? 'http://localhost:3000/api/v1';

const TOKEN_KEY = 'altyn_admin_token';

export function getToken(): string | null {
  if (typeof window === 'undefined') return null;
  return window.localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string) {
  window.localStorage.setItem(TOKEN_KEY, token);
}

export function clearToken() {
  window.localStorage.removeItem(TOKEN_KEY);
}

export class ApiError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

/** HTTP статус → понятное оператору сообщение (вместо «HTTP 500» / сырых кодов). */
function friendlyHttp(status: number, raw?: string): string {
  if (status === 401) return 'Сессия истекла. Войдите снова';
  if (status === 403) return 'Недостаточно прав для этого действия';
  if (status === 404) return 'Не найдено';
  if (status === 409) return 'Конфликт данных. Обновите страницу';
  if (status === 413 || status === 415) return 'Неверный формат или слишком большой файл';
  if (status === 429) return 'Слишком много запросов. Подождите немного';
  if (status >= 500) return 'Ошибка сервера. Попробуйте позже';
  return raw || 'Не удалось выполнить действие';
}

/** Безопасный разбор JSON: при не-JSON ответе (например, HTML 502 от nginx) не падаем. */
function safeJson(text: string): any {
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

/** Суретті backend арқылы Supabase Storage-қа жүктеп, public URL қайтарады. */
export async function uploadImage(file: File): Promise<string> {
  const token = getToken();
  const form = new FormData();
  form.append('file', file);
  const res = await fetch(`${API_BASE}/uploads`, {
    method: 'POST',
    headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: form,
    cache: 'no-store',
  });
  const data = safeJson(await res.text());
  if (!res.ok) {
    throw new ApiError(res.status, friendlyHttp(res.status));
  }
  return data?.url as string;
}

export async function api<T = any>(
  path: string,
  options: { method?: string; body?: unknown } = {},
): Promise<T> {
  const token = getToken();
  const hasBody = options.body !== undefined;
  const res = await fetch(`${API_BASE}${path}`, {
    method: options.method ?? 'GET',
    headers: {
      ...(hasBody ? { 'Content-Type': 'application/json' } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: hasBody ? JSON.stringify(options.body) : undefined,
    cache: 'no-store',
  });

  const data = safeJson(await res.text());

  if (!res.ok) {
    if (res.status === 401 && typeof window !== 'undefined') {
      clearToken(); // сессия истекла — страница-гард сама вернёт на /login
    }
    throw new ApiError(res.status, friendlyHttp(res.status));
  }
  return data as T;
}
