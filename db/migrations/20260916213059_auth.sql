-- +goose Up
ALTER TABLE users
    ADD COLUMN password_hash text, -- nullable: passkey-only admins never get one
    ADD COLUMN username text UNIQUE NOT NULL, -- email or 4 word random phrase for passkey-only admins (fox-dog-apple-banana)
    ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN role text NOT NULL DEFAULT 'user' CHECK (role IN ('superuser','admin','user')),
    ADD COLUMN disabled_at TIMESTAMP,
    ALTER COLUMN id DROP DEFAULT,
    ALTER COLUMN id TYPE UUID USING gen_random_uuid(),
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
    DROP COLUMN email;

CREATE TABLE IF NOT EXISTS passkeys (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    credential_id text UNIQUE NOT NULL,
    signed_count BIGINT NOT NULL DEFAULT 0,
    transports text[],
    nickname text,
    public_key text NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS recovery_codes (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    code_hash text NOT NULL,
    used_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS oidc_auth_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id text NOT NULL,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text NOT NULL,
    code_challenge text NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    authorized_at TIMESTAMP,
    expires_at TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL '10 minutes')
);

CREATE TABLE IF NOT EXISTS oidc_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    client_id text NOT NULL,
    user_agent text NOT NULL,
    ip_address text NOT NULL,
    refresh_token_hash text NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    revoked_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- +goose Down
DROP TABLE IF EXISTS passkeys;
DROP TABLE IF EXISTS recovery_codes;
DROP TABLE IF EXISTS oidc_auth_requests;
DROP TABLE IF EXISTS oidc_tokens;

ALTER TABLE users
    DROP COLUMN password_hash,
    DROP COLUMN username,
    DROP COLUMN created_at,
    DROP COLUMN role,
    DROP COLUMN disabled_at,
    ADD COLUMN email text UNIQUE;
