---
name: mimo-sql
description: Generate or explain SQL against a provided schema fragment via Xiaomi MiMo V2.5 Pro. Use when the operator gives a schema snippet and a natural-language query and wants SQL out, or has a SQL query and wants a plain-English explanation.
---

# mimo-sql 🧠

SQL generator / explainer with schema-aware prompting.

## When to use

- Generate SQL from natural language given a schema snippet
- Explain an existing SQL query in plain English
- Refactor a slow query into a cleaner / indexed form

Skip when:
- Schema is too large to fit in prompt — use a vector schema lookup first
- Query needs to run against actual DB — main agent dispatches via DB tool

## Usage

```bash
# Generate SQL from natural language
echo "schema: users(id, email, created_at); orders(id, user_id, amount)" \
  | bash sql.sh "top 10 users by total spend in 2026"

# Explain an existing query
bash sql.sh --explain "SELECT u.email, SUM(o.amount) FROM users u JOIN orders o ON u.id = o.user_id WHERE o.created_at >= '2026-01-01' GROUP BY u.email ORDER BY 2 DESC LIMIT 10"
```

## Output

For generation: pure SQL, ready to run.
For explanation: bullet breakdown of what each clause does.
