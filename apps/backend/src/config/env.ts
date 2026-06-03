import 'dotenv/config';
import { z } from 'zod';

const Env = z.object({
  PORT: z.coerce.number().default(3000),
  HOST: z.string().default('0.0.0.0'),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  LOG_LEVEL: z.string().default('info'),
  CORS_ORIGIN: z.string().default('*'),

  DATABASE_URL: z.string().min(1),

  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 chars'),
  JWT_EXPIRES_IN: z.string().default('30d'),
  BCRYPT_ROUNDS: z.coerce.number().default(12),

  INVESTOR_PWD_KEY: z.string().length(64, 'INVESTOR_PWD_KEY must be 32 bytes (64 hex chars)'),

  ANTHROPIC_API_KEY: z.string().optional(),
  FINNHUB_API_KEY: z.string().optional(),
  TELEGRAM_BOT_TOKEN: z.string().optional(),
  TELEGRAM_SIGNAL_CHANNEL_ID: z.string().optional(),
  KASPI_ADMIN_CHAT_ID: z.string().optional(),
  SUPABASE_URL: z.string().optional(),
  SUPABASE_SERVICE_KEY: z.string().optional(),
});

export const env = Env.parse(process.env);
export type AppEnv = typeof env;
