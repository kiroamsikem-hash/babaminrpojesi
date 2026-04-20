const axios = require('axios');
const Question = require('../models/Question.model');

// AI Provider (Groq)
async function callGroq(prompt, systemPrompt) {
  const groqKeys = [
    process.env.GROQ_API_KEY,
    process.env.GROQ_API_KEY_2,
    process.env.GROQ_API_KEY_3,
    process.env.GROQ_API_KEY_4,
    process.env.GROQ_API_KEY_5,
  ].filter(key => key && key !== 'your-groq-api-key');

  for (const apiKey of groqKeys) {
    try {
      const response = await axios.post(
        'https://api.groq.com/openai/v1/chat/completions',
        {
          model: 'llama-3.3-70b-versatile',
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: prompt }
          ],
          temperature: 0.7,
          max_tokens: 4000
        },
        {
          headers: {
            'Authorization': `Bearer ${apiKey}`,
            'Content-Type': 'application/json'
          },
          timeout: 45000
        }
      );
      
      return response.data.choices[0].message.content;
    } catch (error) {
      if (groqKeys.indexOf(apiKey) === groqKeys.length - 1) throw error;
    }
  }
}

// Gemini Vision API
async function analyzeImageWithGemini(imageBase64) {
  try {
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        contents: [{
          parts: [
            { text: "Bu sayfadaki TÜM soruları tespit et ve numaralandır. Her soru için:\n1. Soru numarası\n2. Soru metni\n3. Soru tipi (çoktan seçmeli, açık uçlu, matematik, vb.)\n\nJSON formatında döndür:\n[\n  {\n    \"questionNumber\": \"1\",\n    \"questionText\": \"Soru metni...\",\n    \"questionType\": \"çoktan seçmeli\",\n    \"options\": [\"A) ...\", \"B) ...\"] // varsa\n  }\n]\n\nSadece JSON döndür, başka açıklama ekleme." },
            {
              inline_data: {
                mime_type: "image/jpeg",
                data: imageBase64
              }
            }
          ]
        }]
      },
      { timeout: 30000 }
    );

    const text = response.data.candidates[0].content.parts[0].text;
    
    // JSON'u bul ve parse et
    const jsonMatch = text.match(/\[[\s\S]*\]/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
    
    throw new Error('JSON bulunamadı');
  } catch (error) {
    console.error('Gemini Vision error:', error.message);
    throw error;
  }
}

// @desc    Scan page and detect all questions
exports.scanPage = async (req, res) => {
  try {
    console.log('📄 Sayfa tarama başlatıldı');

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Resim dosyası gereklidir'
      });
    }

    // Base64'e çevir
    const imageBase64 = req.file.buffer.toString('base64');

    // Gemini Vision ile soruları tespit et
    const questions = await analyzeImageWithGemini(imageBase64);

    console.log(`✅ ${questions.length} soru tespit edildi`);

    res.json({
      success: true,
      data: {
        totalQuestions: questions.length,
        questions: questions.map((q, index) => ({
          id: index + 1,
          number: q.questionNumber || (index + 1).toString(),
          text: q.questionText,
          type: q.questionType || 'genel',
          options: q.options || []
        }))
      }
    });
  } catch (error) {
    console.error('Sayfa tarama hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Sayfa taranamadı',
      error: error.message
    });
  }
};

// @desc    Solve specific question from scanned page
exports.solveScannedQuestion = async (req, res) => {
  try {
    const { questionText, questionType, options } = req.body;

    if (!questionText) {
      return res.status(400).json({
        success: false,
        message: 'Soru metni gereklidir'
      });
    }

    const gradeLevel = req.user.grade || 9;
    
    const systemPrompt = `Sen ${gradeLevel}. sınıf seviyesinde bir öğretmensin. Öğrencilere adım adım, anlaşılır şekilde yardımcı oluyorsun.`;
    
    let prompt = `Soru: ${questionText}\n\n`;
    
    if (options && options.length > 0) {
      prompt += `Şıklar:\n${options.join('\n')}\n\n`;
    }
    
    prompt += `Bu soruyu ${gradeLevel}. sınıf seviyesinde, adım adım çöz ve açıkla.

CEVAP FORMATI:
📚 KONU: [Konuyu belirt]

🎯 ÇÖZÜM:
[Adım adım detaylı çözüm]

💡 İPUCU:
[Öğrenciye yardımcı ipucu]

✅ SONUÇ:
[Kısa özet ve cevap]`;

    const answer = await callGroq(prompt, systemPrompt);

    // Veritabanına kaydet
    const question = await Question.create({
      userId: req.user.id,
      type: questionType || 'genel',
      question: questionText,
      answer: answer,
      subject: questionType || 'Genel'
    });

    res.json({
      success: true,
      data: {
        questionId: question.id,
        question: questionText,
        answer: answer,
        type: questionType
      }
    });
  } catch (error) {
    console.error('Soru çözme hatası:', error);
    res.status(500).json({
      success: false,
      message: 'Soru çözülemedi',
      error: error.message
    });
  }
};

module.exports = exports;
