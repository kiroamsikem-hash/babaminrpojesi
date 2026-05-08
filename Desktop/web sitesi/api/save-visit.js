// Vercel Serverless Function - Ziyaretçi verilerini kaydet
const { neon } = require('@neondatabase/serverless');

module.exports = async function handler(req, res) {
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
    const { linkId, trackingId, visitorData } = req.body;

    if (!linkId || !trackingId || !visitorData) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // NeonDB bağlantısı
    const sql = neon(process.env.DATABASE_URL);
    
    // Veriyi kaydet
    await sql`
      INSERT INTO visits (link_id, tracking_id, visitor_data, created_at)
      VALUES (${linkId}, ${trackingId}, ${JSON.stringify(visitorData)}, NOW())
    `;
    
    return res.status(200).json({ 
      success: true,
      message: 'Visit saved successfully'
    });
  } catch (error) {
    console.error('Error saving visit:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
}
