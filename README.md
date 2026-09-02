# claude-config

Shared `~/.claude` setup: brutal-terse enforcement (Concise+ output style, terse-hooks, `/shut`), animation skills, graphify, humanizer, taste/ui skills.

## Install on a machine

```
git clone https://github.com/matidelcastillo/claude-config ~/REPOS/claude-config
~/REPOS/claude-config/sync.sh
```

Re-run `sync.sh` after `git pull` to update. It rsyncs `skills/ output-styles/ commands/ terse-hooks/`, copies `terse.json`, appends the terse block to `CLAUDE.md` once, and patches `settings.json` (outputStyle, env, 5 hooks).

## Tune brevity

`terse.json`: `{ "level": "brutal"|"normal", "wordBudget": N }`. Per-project override: drop `.claude/terse.json` in the repo.
