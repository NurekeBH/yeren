'use client';

// Лёгкие SVG-графики без внешних зависимостей (recharts не нужен — бандл остаётся
// маленьким, нет SSR/hydration-рисков). Все цвета через CSS-переменные темы админки.
import React from 'react';

type Series = { name: string; color: string; points: number[] };

// ── Линейный график (несколько серий) — регистрации / DAU и т.п. ──
export function LineChart({
  labels, series, height = 170,
}: { labels: string[]; series: Series[]; height?: number }) {
  const W = 640;
  const H = height;
  const pad = { l: 8, r: 8, t: 12, b: 18 };
  const max = Math.max(1, ...series.flatMap((s) => s.points));
  const n = Math.max(1, labels.length - 1);
  const x = (i: number) => pad.l + (i * (W - pad.l - pad.r)) / n;
  const y = (v: number) => pad.t + (1 - v / max) * (H - pad.t - pad.b);

  return (
    <div style={{ width: '100%' }}>
      <svg viewBox={`0 0 ${W} ${H}`} width="100%" height={H} preserveAspectRatio="none" style={{ display: 'block' }}>
        {/* базовая линия */}
        <line x1={pad.l} y1={H - pad.b} x2={W - pad.r} y2={H - pad.b} stroke="var(--border)" strokeWidth={1} />
        {series.map((s) => {
          const pts = s.points.map((v, i) => `${x(i)},${y(v)}`).join(' ');
          const area = `${pad.l},${H - pad.b} ${pts} ${x(s.points.length - 1)},${H - pad.b}`;
          return (
            <g key={s.name}>
              <polygon points={area} fill={s.color} opacity={0.08} />
              <polyline points={pts} fill="none" stroke={s.color} strokeWidth={2} strokeLinejoin="round" strokeLinecap="round" />
            </g>
          );
        })}
      </svg>
      <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap', marginTop: 6 }}>
        {series.map((s) => (
          <span key={s.name} style={{ fontSize: 12, color: 'var(--muted)', display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 10, height: 10, borderRadius: 2, background: s.color, display: 'inline-block' }} />
            {s.name}
          </span>
        ))}
      </div>
    </div>
  );
}

// ── Парные вертикальные бары (доход vs расход) ──
export function BarPair({
  groups, height = 170,
}: { groups: { label: string; a: number; b: number }[]; height?: number }) {
  const W = 640;
  const H = height;
  const pad = { l: 8, r: 8, t: 12, b: 22 };
  const max = Math.max(1, ...groups.flatMap((g) => [g.a, g.b]));
  const gw = (W - pad.l - pad.r) / Math.max(1, groups.length);
  const bw = Math.min(26, gw / 3);
  const y = (v: number) => pad.t + (1 - v / max) * (H - pad.t - pad.b);
  return (
    <svg viewBox={`0 0 ${W} ${H}`} width="100%" height={H} preserveAspectRatio="none" style={{ display: 'block' }}>
      <line x1={pad.l} y1={H - pad.b} x2={W - pad.r} y2={H - pad.b} stroke="var(--border)" strokeWidth={1} />
      {groups.map((g, i) => {
        const cx = pad.l + i * gw + gw / 2;
        return (
          <g key={g.label}>
            <rect x={cx - bw - 2} y={y(g.a)} width={bw} height={H - pad.b - y(g.a)} fill="#059669" rx={2} />
            <rect x={cx + 2} y={y(g.b)} width={bw} height={H - pad.b - y(g.b)} fill="#D97706" rx={2} />
            <text x={cx} y={H - 6} textAnchor="middle" fontSize={11} fill="var(--muted)">{g.label}</text>
          </g>
        );
      })}
    </svg>
  );
}

// ── Кольцевая диаграмма (структура выручки) ──
export function Donut({
  segments, size = 160,
}: { segments: { label: string; value: number; color: string }[]; size?: number }) {
  const total = Math.max(1, segments.reduce((s, x) => s + x.value, 0));
  const r = size / 2 - 14;
  const c = 2 * Math.PI * r;
  let acc = 0;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 18 }}>
      <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        <g transform={`rotate(-90 ${size / 2} ${size / 2})`}>
          {segments.map((s) => {
            const frac = s.value / total;
            const dash = frac * c;
            const el = (
              <circle
                key={s.label}
                cx={size / 2} cy={size / 2} r={r}
                fill="none" stroke={s.color} strokeWidth={16}
                strokeDasharray={`${dash} ${c - dash}`} strokeDashoffset={-acc}
              />
            );
            acc += dash;
            return el;
          })}
        </g>
      </svg>
      <div style={{ display: 'grid', gap: 6 }}>
        {segments.map((s) => (
          <span key={s.label} style={{ fontSize: 12, color: 'var(--muted)', display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 10, height: 10, borderRadius: 2, background: s.color, display: 'inline-block' }} />
            {s.label}: <b style={{ color: 'var(--text)' }}>{Math.round((s.value / total) * 100)}%</b>
          </span>
        ))}
      </div>
    </div>
  );
}

// ── Когортная тепловая карта (retention по неделям регистрации) ──
export function CohortHeatmap({
  rows, weeks = 8,
}: { rows: { cohort: string; size: number; weeks: Record<number, number> }[]; weeks?: number }) {
  const cols = Array.from({ length: weeks }, (_, i) => i);
  const cell = (v: number | undefined) => {
    if (v === undefined) return { background: 'transparent', color: 'var(--muted)' };
    const a = Math.max(0.06, Math.min(1, v / 100));
    return { background: `rgba(212,160,23,${a})`, color: a > 0.5 ? '#1a1205' : 'var(--text)' };
  };
  return (
    <div style={{ overflowX: 'auto' }}>
      <table style={{ borderCollapse: 'separate', borderSpacing: 3, fontSize: 12 }}>
        <thead>
          <tr style={{ color: 'var(--muted)' }}>
            <th style={{ textAlign: 'left', padding: '4px 8px' }}>Когорта</th>
            <th style={{ padding: '4px 8px' }}>Размер</th>
            {cols.map((w) => <th key={w} style={{ padding: '4px 8px' }}>W{w}</th>)}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 && (
            <tr><td colSpan={weeks + 2} style={{ padding: 12, color: 'var(--muted)' }}>
              Данные появятся после накопления активности (нужен мобильный трекинг).
            </td></tr>
          )}
          {rows.map((r) => (
            <tr key={r.cohort}>
              <td style={{ padding: '4px 8px', whiteSpace: 'nowrap' }}>{r.cohort}</td>
              <td style={{ padding: '4px 8px', textAlign: 'center', color: 'var(--muted)' }}>{r.size}</td>
              {cols.map((w) => {
                const v = r.weeks[w];
                const st = cell(v);
                return (
                  <td key={w} style={{ padding: '6px 8px', textAlign: 'center', borderRadius: 4, minWidth: 38, ...st }}>
                    {v === undefined ? '·' : `${v}%`}
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
