// Vercel Serverless Function - Ziyaretçi verilerini kaydet
// Basit in-memory storage (demo için)
const visits = new Map();

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
    const { linkId, visitorData } = req.body;

    if (!linkId || !visitorData) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // In-memory storage'a kaydet
    if (!visits.has(linkId)) {
      visits.set(linkId, []);
    }
    visits.get(linkId).push(visitorData);
    
    return res.status(200).json({ 
      success: true,
      message: 'Visit saved successfully',
      totalVisits: visits.get(linkId).length
    });
  } catch (error) {
    console.error('Error saving visit:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
