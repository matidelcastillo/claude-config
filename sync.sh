#!/usr/bin/env bash
set -euo pipefail
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v node >/dev/null || { echo "node required"; exit 1; }

mkdir -p "$DEST"
for d in skills output-styles commands terse-hooks; do
  mkdir -p "$DEST/$d"
  rsync -a --delete "$HERE/$d/" "$DEST/$d/"
done
cp "$HERE/terse.json" "$DEST/terse.json"

if [ -f "$DEST/CLAUDE.md" ] && ! grep -q "RESPONSE = one line" "$DEST/CLAUDE.md"; then
  printf '\n' >> "$DEST/CLAUDE.md"; cat "$HERE/CLAUDE.md" >> "$DEST/CLAUDE.md"
elif [ ! -f "$DEST/CLAUDE.md" ]; then
  cp "$HERE/CLAUDE.md" "$DEST/CLAUDE.md"
fi

S="$DEST/settings.json"; [ -f "$S" ] || echo '{}' > "$S"
node -e '
const fs=require("fs"),p=require("path");
const S=process.argv[1],H=process.argv[2];
const j=JSON.parse(fs.readFileSync(S,"utf8"));
j.outputStyle="Concise+";
j.env=Object.assign({},j.env,{CLAUDE_CODE_SIMPLE_SYSTEM_PROMPT:"0"});
j.hooks=j.hooks||{};
const hk=p.join(H,"terse-hooks");
const add=(ev,m,f)=>{
  j.hooks[ev]=j.hooks[ev]||[];
  if(j.hooks[ev].some(g=>(g.hooks||[]).some(h=>h.command&&h.command.includes(f)))) return;
  const e={hooks:[{type:"command",command:`node "${p.join(hk,f)}"`}]};
  if(m) e.matcher=m; j.hooks[ev].push(e);
};
add("SessionStart",null,"session-start.js");
add("UserPromptSubmit","*","prompt-submit.js");
add("PreToolUse","Write|Edit","pre-write.js");
add("PostToolUse","Write|Edit","post-write.js");
add("PreToolUse","Task|Agent","pre-agent.js");
fs.writeFileSync(S,JSON.stringify(j,null,2)+"\n");
' "$S" "$DEST"
echo "synced to $DEST — restart Claude session"
