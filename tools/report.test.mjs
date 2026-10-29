import test from 'node:test';
import assert from 'node:assert/strict';
import { summarize } from './report.mjs';

test('summarizes detections while ignoring unrelated records and blank lines', async () => {
  assert.deepEqual(await summarize([
    '', '{"kind":"anticheat_detection","reason":"honeypot_remote"}',
    '{"kind":"anticheat_detection","reason":"honeypot_remote"}', '{"kind":"server_started"}',
  ]), { events: 2, ignored: 1, reasons: { honeypot_remote: 2 } });
});
test('rejects malformed logs with the offending line number', async () => {
  await assert.rejects(summarize(['{}', 'broken']), /Line 2/);
  await assert.rejects(summarize(['[]']), /expected a JSON object/);
  await assert.rejects(summarize(['{"kind":"anticheat_detection"}']), /invalid detection reason/);
});
test('handles empty logs and reason names that resemble object properties', async () => {
  assert.deepEqual(await summarize([]), { events: 0, ignored: 0, reasons: {} });
  const result = await summarize(['{"kind":"anticheat_detection","reason":"__proto__"}']);
  assert.equal(Object.getOwnPropertyDescriptor(result.reasons, '__proto__').value, 1);
});
