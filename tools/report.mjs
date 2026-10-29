import { createReadStream } from 'node:fs';
import { createInterface } from 'node:readline';
import { pathToFileURL } from 'node:url';

// Reads JSON lines exported by the example server's detection callback.
// Counts are observations, not verdicts; this tool never bans players.
export async function summarize(lines) {
  const reasons = new Map();
  let events = 0;
  let ignored = 0;
  let lineNumber = 0;
  for await (const line of lines) {
    lineNumber++;
    if (!line.trim()) continue;
    let record;
    try { record = JSON.parse(line); }
    catch { throw new Error(`Line ${lineNumber}: expected a JSON object`); }
    if (!record || typeof record !== 'object' || Array.isArray(record)) {
      throw new Error(`Line ${lineNumber}: expected a JSON object`);
    }
    if (record.kind !== 'anticheat_detection') { ignored++; continue; }
    if (typeof record.reason !== 'string' || !record.reason.length || record.reason.length > 80) {
      throw new Error(`Line ${lineNumber}: missing or invalid detection reason`);
    }
    events++;
    reasons.set(record.reason, (reasons.get(record.reason) ?? 0) + 1);
  }
  return { events, ignored, reasons: Object.fromEntries([...reasons].sort(([a], [b]) => a.localeCompare(b))) };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const filename = process.argv[2];
  if (!filename || process.argv.length !== 3) {
    console.error('Usage: node tools/report.mjs <events.jsonl>');
    process.exitCode = 1;
  } else {
    try {
      const input = createReadStream(filename, { encoding: 'utf8' });
      const lines = createInterface({ input, crlfDelay: Infinity });
      // Forward stream errors to the iterator so missing files produce a clean error.
      input.on('error', error => lines.emit('error', error));
      try { console.log(JSON.stringify(await summarize(lines), null, 2)); }
      finally { lines.close(); input.destroy(); }
    } catch (error) {
      console.error(error.message);
      process.exitCode = 1;
    }
  }
}
