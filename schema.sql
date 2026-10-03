-- Schema inferred from the INSERT in the "Execute a SQL query" node.
CREATE TABLE IF NOT EXISTS transactions (
    id               SERIAL PRIMARY KEY,
    transaction_hash TEXT           NOT NULL UNIQUE,  -- md5(date_currency_description_amount_occurrence)
    transaction_date DATE           NOT NULL,
    description      TEXT,                            -- already masked (IBAN, card numbers, dates)
    currency         TEXT           NOT NULL DEFAULT 'EUR',
    amount           NUMERIC(12, 2) NOT NULL,         -- negative = outgoing
    category         TEXT,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);
