// ════════════════════════ JOURNAL · SECURE CREDENTIAL STORAGE ════════════════════════
// Investor (READ-ONLY) пароль ешқашан plaintext сақталмайды. AES-256-GCM-мен шифрленіп,
// trading_accounts.investor_password_cipher (text) бағанында base64 түрінде жатады.
//
// ┌─ Қауіпсіздік шекарасы (client-side encryption placeholder) ──────────────────────────┐
// │ ИДЕАЛДА: мобайл клиент паролді ҚҰРЫЛҒЫДА AES-256-мен шифрлеп жібереді (E2E), сервер   │
// │ тек opaque blob көреді. Бұл — сол шекараның СЕРВЕР-ЖАҚТЫ іске асырылуы: enterprise    │
// │ KMS/HSM-ге көшкенде `wrapInvestorPassword`/`unwrapInvestorPassword` ғана өзгереді.    │
// │ Кілт: env.INVESTOR_PWD_KEY (32-byte hex). Прод-та KMS-тен (AWS KMS / GCP KMS) алынуы  │
// │ тиіс — TODO: replace static key with envelope encryption (data key per account).      │
// └──────────────────────────────────────────────────────────────────────────────────────┘
import { encryptInvestor, decryptInvestor, maskInvestor } from '../../utils/crypto.js';

/** Plaintext инвестор паролі → base64 шифр (text бағанға сақтауға). */
export function wrapInvestorPassword(plain: string): string {
  return encryptInvestor(plain).toString('base64');
}

/** base64 шифр → plaintext (синхрон қозғалтқышы ғана ішкі қолданады, жауапқа ЕШҚАШАН шықпайды). */
export function unwrapInvestorPassword(cipherB64: string): string {
  return decryptInvestor(Buffer.from(cipherB64, 'base64'));
}

/** UI-ға қайтаруға қауіпсіз маска (соңғы 2 таңба). */
export { maskInvestor };
