-- IP Logger Database Schema

-- Links tablosu
CREATE TABLE IF NOT EXISTS links (
    id VARCHAR(10) PRIMARY KEY,
    tracking_id VARCHAR(10) UNIQUE NOT NULL,
    title VARCHAR(255),
    redirect_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Visits tablosu
CREATE TABLE IF NOT EXISTS visits (
    id SERIAL PRIMARY KEY,
    link_id VARCHAR(10) NOT NULL,
    tracking_id VARCHAR(10) NOT NULL,
    visitor_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (link_id) REFERENCES links(id) ON DELETE CASCADE
);

-- Index'ler
CREATE INDEX IF NOT EXISTS idx_visits_link_id ON visits(link_id);
CREATE INDEX IF NOT EXISTS idx_visits_tracking_id ON visits(tracking_id);
CREATE INDEX IF NOT EXISTS idx_visits_created_at ON visits(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_links_tracking_id ON links(tracking_id);
