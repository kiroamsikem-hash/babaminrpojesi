// Database setup script
import { neon } from '@neondatabase/serverless';

const DATABASE_URL = 'postgresql://neondb_owner:npg_FE6XqT1HzDZf@ep-quiet-smoke-aqc9m0wm-pooler.c-8.us-east-1.aws.neon.tech/neondb?sslmode=require';

async function setupDatabase() {
  try {
    const sql = neon(DATABASE_URL);
    
    console.log('🔄 Connecting to NeonDB...');
    
    // Links tablosu
    await sql`
      CREATE TABLE IF NOT EXISTS links (
        id VARCHAR(10) PRIMARY KEY,
        tracking_id VARCHAR(10) UNIQUE NOT NULL,
        title VARCHAR(255),
        redirect_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;
    console.log('✅ Created table: links');
    
    // Visits tablosu
    await sql`
      CREATE TABLE IF NOT EXISTS visits (
        id SERIAL PRIMARY KEY,
        link_id VARCHAR(10) NOT NULL,
        tracking_id VARCHAR(10) NOT NULL,
        visitor_data JSONB NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;
    console.log('✅ Created table: visits');
    
    // Index'ler
    await sql`CREATE INDEX IF NOT EXISTS idx_visits_link_id ON visits(link_id)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_visits_tracking_id ON visits(tracking_id)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_visits_created_at ON visits(created_at DESC)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_links_tracking_id ON links(tracking_id)`;
    console.log('✅ Created indexes');
    
    console.log('✅ Database setup completed!');
    
  } catch (error) {
    console.error('❌ Error setting up database:', error);
    process.exit(1);
  }
}

setupDatabase();
