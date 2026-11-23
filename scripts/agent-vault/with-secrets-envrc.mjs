import fs from 'node:fs';
import { dirname, join, resolve } from 'node:path';

// Warn by file presence alone; never open a potentially secret-bearing .envrc.
export function findRetiredEnvrc(startDir) {
  let dir = resolve(startDir);
  for (;;) {
    const candidate = join(dir, '.envrc');
    try {
      if (!fs.lstatSync(candidate).isDirectory()) return candidate;
    } catch {
      /* No entry here. */
    }
    const parent = dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}
