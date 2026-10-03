# Bank Statement Categorizer (n8n + local LLM)

> Upload a bank statement CSV, mask sensitive data, categorise every transaction (rules first, local LLM as fallback) and store the result in PostgreSQL. Nothing leaves your machine.

## Why it exists

Bank exports are messy and full of personal data: IBANs, card numbers, tax codes, timestamps. Sending them to a cloud LLM is a privacy problem. This workflow masks that data first and uses a **local** model (Ollama) only for the transactions the fixed rules cannot classify.

## How it works

```
Form upload (CSV, ";" separated)
  -> Column detection (exact name, then keyword fallback) and amount parsing (DARE/AVERE or IMPORTO)
  -> Filter out balance rows
  -> Masking of IBAN / card / tax code / date / time + removal of bank boilerplate
  -> Keyword rules (generic examples included, edit them for your own merchants)
       |-- matched  ------------------------------------.
       '-- "Altro" -> batches of 10 -> Ollama (qwen2.5:3b) -> category
  -> PostgreSQL insert (parameterised, idempotent hash)
```

**Design choices**

- Masking happens before anything else, so descriptions stored in the database never contain raw IBANs or card numbers.
- Rules cover the predictable cases for free; the small local model handles the rest with a few-shot prompt at `temperature: 0`.
- The transaction hash includes an *occurrence counter*, so two identical payments on the same day are both kept, while re-uploading the same file does not create duplicates.
- The insert uses query parameters, never string concatenation.

## Run it

Requirements: n8n, PostgreSQL, [Ollama](https://ollama.com) with the model pulled (`ollama pull qwen2.5:3b`).

1. Create the table with `schema.sql`.
2. Import `workflow/bank_statement_categorizer.json` in n8n and attach your own PostgreSQL credential to the "Execute a SQL query" node.
3. If n8n runs in Docker, check that the Ollama URL in the "HTTP Request" node (`host.docker.internal:11434`) is reachable from the container.
4. Activate the workflow, open the form URL and upload `examples/sample_statement.csv` (synthetic data).

## Repository content

| Path | Purpose |
|------|---------|
| `workflow/bank_statement_categorizer.json` | n8n workflow export (credentials removed, example rules only) |
| `schema.sql` | `transactions` table |
| `examples/sample_statement.csv` | synthetic statement for testing |
| `src/security.py` | first Python prototype of the masking step, before it was moved into the workflow |

## Known limitations and roadmap

- The CSV format assumed is Italian: `;` separator, comma decimals, `DD/MM/YYYY` dates.
- The "balance row" filter combines its conditions with OR and is worth revisiting.
- The hash depends on row order inside a file; overlapping statements uploaded separately may create duplicates.
- A 3B model is fast but approximate: category accuracy has not been measured yet. A small labelled test set is planned.
- No dashboard yet; the next step is a monthly overview by category.
- `docker-compose.yml` for a one-command setup is planned.
- Workflow strings and comments are in Italian.
