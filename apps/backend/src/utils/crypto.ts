import { createCipheriv, createDecipheriv, randomBytes } from 'node:crypto';
import { env } from '../config/env.js';

/**
 * TZ §16.3: Investor Password AES-256-GCM шифрі.
 * Шифрленген blob: iv(12) || tag(16) || ciphertext.
 * INVESTOR_PWD_KEY .env-те 32-byte hex (64 hex chars).
 */
const KEY = Buffer.from(env.INVESTOR_PWD_KEY, 'hex');

export function encryptInvestor(plain: string): Buffer {
  const iv = randomBytes(12);
  const cipher = createCipheriv('aes-256-gcm', KEY, iv);
  const ciphertext = Buffer.concat([cipher.update(plain, 'utf8'), cipher.final()]);
  const tag = cipher.getAuthTag();
  return Buffer.concat([iv, tag, ciphertext]);
}

export function decryptInvestor(blob: Buffer): string {
  const iv = blob.subarray(0, 12);
  const tag = blob.subarray(12, 28);
  const ciphertext = blob.subarray(28);
  const decipher = createDecipheriv('aes-256-gcm', KEY, iv);
  decipher.setAuthTag(tag);
  const plain = Buffer.concat([decipher.update(ciphertext), decipher.final()]);
  return plain.toString('utf8');
}

/** UI-ға beruge қауіпсіз mask. */
export function maskInvestor(plain: string): string {
  if (plain.length <= 2) return '••';
  return `••••••${plain.slice(-2)}`;
}
