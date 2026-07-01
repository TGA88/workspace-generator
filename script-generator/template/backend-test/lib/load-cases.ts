// loadCases — อ่าน _cases.json (manifest) + envelope ต่อเคส (c*.json/e*.json) จาก contract folder
import { readFileSync } from 'node:fs';
import path from 'node:path';
import type { WithRequest } from './http.ts';
import type { WithResponse } from './assert-contract.ts';

export type CaseMeta = {
  key: string;
  desc: string;
  setup: string | null; // เช่น "setup.e1.sql" (case-level) · null = ใช้ action-level อย่างเดียว
  teardown: string | null;
};

export type LoadedCase = CaseMeta & {
  withRequest: WithRequest;
  withResponse: WithResponse;
};

type Manifest = { endpoint?: string; cases: CaseMeta[] };

export function loadCases(contractDir: string): LoadedCase[] {
  const manifest = JSON.parse(
    readFileSync(path.join(contractDir, '_cases.json'), 'utf8'),
  ) as Manifest;

  return manifest.cases.map((c) => {
    const envelope = JSON.parse(
      readFileSync(path.join(contractDir, `${c.key}.json`), 'utf8'),
    ) as { withRequest: WithRequest; withResponse: WithResponse };
    return { ...c, withRequest: envelope.withRequest, withResponse: envelope.withResponse };
  });
}
