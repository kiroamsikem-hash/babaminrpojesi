// Vercel Serverless Function - Link oluştur
import { neon } from '@neondatabase/serverless';

export default async function handler(req, res) {
  // CORS headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { linkId, trackingId, title, redirectUrl } = req.body;

    if (!linkId || !trackingId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // NeonDB bağlantısı
    const sql = neon(process.env.DATABASE_URL);
    
    // Link'i kaydet
    await sql`
      INSERT INTO links (id, tracking_id, title, redirect_url, created_at)
      VALUES (${linkId}, ${trackingId}, ${title || 'İsimsiz Link'}, ${redirectUrl || ''}, NOW())
    `;
    
    return res.status(200).json({ 
      success: true,
      message: 'Link created successfully',
      linkId,
      trackingId
    });
  } catch (error) {
    console.error('Error creating link:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
}
