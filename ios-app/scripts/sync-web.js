// Copies the canonical game file (../dominoes.html) into the Capacitor web dir
// as www/index.html, so the iOS app always wraps the latest version of the game.
const fs = require('fs');
const path = require('path');

const src = path.resolve(__dirname, '..', '..', 'dominoes.html');
const wwwDir = path.resolve(__dirname, '..', 'www');
const dest = path.join(wwwDir, 'index.html');

if (!fs.existsSync(src)) {
  console.error('ERROR: could not find game file at ' + src);
  process.exit(1);
}
fs.mkdirSync(wwwDir, { recursive: true });
fs.copyFileSync(src, dest);
console.log('Synced ' + src + ' -> ' + dest);
