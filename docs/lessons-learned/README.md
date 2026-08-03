# Lessons Learned

This is your **engineering journal**. Every time you learn something the hard way, write it here. Future you (and your interviewers) will thank you.

## Format

Use the template below for each entry:

```markdown
## [Date] — [Title]

### What happened
[Describe the situation]

### What I learned
[The lesson]

### How to avoid it
[The preventive measure]

### Interview answer
[How you'd explain this in an interview]
```

---

## Entries

### Phase 0.1 — 2026-08-03 — Project Foundation

**What I learned:**
- A clean folder structure communicates senior-level thinking before any code is written.
- `.gitignore` is the first line of defense against secret sprawl.
- Git tags are immutable references — essential for release management and rollbacks.
- Commit messages tell the story of a project. Write them like a book, not a tweet.

**Interview answer:**
"I start every project with a clear folder structure, .gitignore, and README. I use semantic versioning with Git tags. My commit messages follow a consistent format that documents the why, not just the what."

---

### Phase 0.2 — 2026-08-03 — Environment Setup

**What I learned:**
- Always use a Python virtual environment — never install packages globally.
- A Makefile makes common tasks reproducible and discoverable.
- Environment variables should be loaded through a single function, not scattered throughout code.
- Unit tests should use `monkeypatch` to avoid side effects between tests.

**Interview answer:**
"My Python projects always use venv. I centralize environment access through a config loader. I use pytest with monkeypatch for clean test isolation. Common dev tasks live in a Makefile so onboarding is one `make help` away."

---

## Common Pitfalls to Remember

1. **Never commit `.env` files** — they contain secrets.
2. **Never commit `*.tfstate`** — Terraform state contains plaintext secrets.
3. **Never commit `*.pem` or `*.key`** — these are SSH/TLS private keys.
4. **Never commit `node_modules/` or `venv/`** — they're huge and regenerable.
5. **Never hardcode API keys** — always use environment variables.
6. **Always test before committing** — `make test` should pass.
7. **Always write a clear commit message** — future you will read it.
