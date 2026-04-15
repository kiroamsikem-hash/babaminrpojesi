const axios = require('axios');
const Question = require('../models/Question.model');

// AI Service - Google Gemini (Ücretsiz)
const callGemini = async (prompt, systemPrompt) => {
  try {
    const fullPrompt = `${systemPrompt}\n\n${prompt}`;
    
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        contents: [{
          parts: [{
            text: fullPrompt
          }]
        }]
      },
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );
    
    return response.data.candidates[0].content.parts[0].text;
  } catch (error) {
    throw new Error('AI servisi yanıt vermedi: ' + error.message);
  }
};

// AI Service - OpenAI GPT-4 (Ücretli)
const callOpenAI = async (prompt, systemPrompt) => {
  try {
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      {
        model: 'gpt-4',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: prompt }
        ],
        temperature: 0.7,
        max_tokens: 2000
      },
      {
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    return response.data.choices[0].message.content;
  } catch (error) {
    throw new Error('AI servisi yanıt vermedi: ' + error.message);
  }
};

// AI Service Selector - Önce Gemini dene, yoksa OpenAI
const callAI = async (prompt, systemPrompt) => {
  // Önce Gemini dene (ücretsiz)
  if (process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY !== 'your-gemini-api-key') {
    try {
      return await callGemini(prompt, systemPrompt);
    } catch (error) {
      console.log('Gemini hatası, OpenAI deneniyor...', error.message);
    }
  }
  
  // Gemini yoksa veya hata verdiyse OpenAI dene
  if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'your-openai-api-key-here') {
    return await callOpenAI(prompt, systemPrompt);
  }
  
  throw new Error('Hiçbir AI API key tanımlanmamış. Lütfen GEMINI_API_KEY veya OPENAI_API_KEY ekleyin.');
};

// System prompts
const TEACHER_PROMPT = `Sen ilkokuldan üniversite seviyesine kadar öğrencilere rehberlik eden, empatik ve sabırlı bir öğretmensin. 
Soruları adım adım çöz, her adımı açıkla. Matematik sorularında LaTeX formatı kullan.
Doğrudan cevap verme, öğrencinin anlamasını sağla.`;

// @desc    Solve question with AI
exports.solveQuestion = async (req, res) => {
  try {
    const { question, type, educationLevel } = req.body;

    if (!question) {
      return res.status(400).json({
        success: false,
        message: 'Soru metni gereklidir'
      });
    }

    const prompt = `Eğitim Seviyesi: ${educationLevel || 'lise'}
Soru Tipi: ${type || 'genel'}
Soru: ${question}

Lütfen bu soruyu adım adım çöz ve açıkla.`;

    const answer = await callAI(prompt, TEACHER_PROMPT);

    // Save to database
    const savedQuestion = await Question.create({
      userId: req.user.id,
      type: type || 'genel',
      question,
      answer,
      subject: type
    });

    res.json({
      success: true,
      data: {
        id: savedQuestion.id,
        _id: savedQuestion.id,
        question,
        answer,
        type,
        createdAt: savedQuestion.created_at
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Soru çözülürken hata oluştu',
      error: error.message
    });
  }
};

// @desc    Perform OCR on image
exports.performOCR = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Resim dosyası gereklidir'
      });
    }

    // Convert image to base64
    const base64Image = req.file.buffer.toString('base64');

    // Use OpenAI Vision API for OCR
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      {
        model: 'gpt-4-vision-preview',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: 'Bu görseldeki metni ve matematiksel ifadeleri çıkar. Eğer matematik sorusu varsa LaTeX formatında yaz.'
              },
              {
                type: 'image_url',
                image_url: {
                  url: `data:image/jpeg;base64,${base64Image}`
                }
              }
            ]
          }
        ],
        max_tokens: 1000
      },
      {
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    const extractedText = response.data.choices[0].message.content;

    res.json({
      success: true,
      data: {
        text: extractedText
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'OCR işlemi sırasında hata oluştu',
      error: error.message
    });
  }
};

// @desc    Perform OCR on image
exports.performOCR = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Resim dosyası gereklidir'
      });
    }

    // Convert image to base64
    const base64Image = req.file.buffer.toString('base64');

    // Gemini Vision kullan (ücretsiz)
    if (process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY !== 'your-gemini-api-key') {
      const response = await axios.post(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=${process.env.GEMINI_API_KEY}`,
        {
          contents: [{
            parts: [
              {
                text: 'Bu görseldeki metni ve matematiksel ifadeleri çıkar. Eğer matematik sorusu varsa LaTeX formatında yaz.'
              },
              {
                inline_data: {
                  mime_type: 'image/jpeg',
                  data: base64Image
                }
              }
            ]
          }]
        },
        {
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );

      const extractedText = response.data.candidates[0].content.parts[0].text;

      return res.json({
        success: true,
        data: {
          text: extractedText
        }
      });
    }

    // OpenAI Vision API (ücretli)
    if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY !== 'your-openai-api-key-here') {
      const response = await axios.post(
        'https://api.openai.com/v1/chat/completions',
        {
          model: 'gpt-4-vision-preview',
          messages: [
            {
              role: 'user',
              content: [
                {
                  type: 'text',
                  text: 'Bu görseldeki metni ve matematiksel ifadeleri çıkar. Eğer matematik sorusu varsa LaTeX formatında yaz.'
                },
                {
                  type: 'image_url',
                  image_url: {
                    url: `data:image/jpeg;base64,${base64Image}`
                  }
                }
              ]
            }
          ],
          max_tokens: 1000
        },
        {
          headers: {
            'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const extractedText = response.data.choices[0].message.content;

      return res.json({
        success: true,
        data: {
          text: extractedText
        }
      });
    }

    throw new Error('OCR için API key gerekli (GEMINI_API_KEY veya OPENAI_API_KEY)');

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'OCR işlemi sırasında hata oluştu',
      error: error.message
    });
  }
};

// @desc    Write composition/essay
exports.writeComposition = async (req, res) => {
  try {
    const { topic, wordCount, tone, educationLevel } = req.body;

    if (!topic) {
      return res.status(400).json({
        success: false,
        message: 'Konu başlığı gereklidir'
      });
    }

    const prompt = `Eğitim Seviyesi: ${educationLevel || 'lise'}
Konu: ${topic}
Kelime Sayısı: ${wordCount || 300}
Ton: ${tone || 'akademik'}

Bu konuda bir kompozisyon/essay yaz. Giriş, gelişme ve sonuç bölümlerini net bir şekilde ayır.`;

    const composition = await callAI(prompt, TEACHER_PROMPT);

    // Save to database
    const savedQuestion = await Question.create({
      userId: req.user.id,
      type: 'kompozisyon',
      question: topic,
      answer: composition
    });

    res.json({
      success: true,
      data: {
        id: savedQuestion.id,
        _id: savedQuestion.id,
        topic,
        composition,
        createdAt: savedQuestion.created_at
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Kompozisyon yazılırken hata oluştu',
      error: error.message
    });
  }
};

// @desc    Translate text
exports.translateText = async (req, res) => {
  try {
    const { text, sourceLang, targetLang } = req.body;

    if (!text || !targetLang) {
      return res.status(400).json({
        success: false,
        message: 'Metin ve hedef dil gereklidir'
      });
    }

    const prompt = `Aşağıdaki metni ${targetLang} diline çevir ve gramer açıklaması ekle:

${text}`;

    const translation = await callAI(prompt, 'Sen profesyonel bir çevirmen ve dil öğretmenisin.');

    res.json({
      success: true,
      data: {
        original: text,
        translation,
        sourceLang,
        targetLang
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Çeviri sırasında hata oluştu',
      error: error.message
    });
  }
};

// @desc    Simplify explanation
exports.simplifyExplanation = async (req, res) => {
  try {
    const { text, educationLevel } = req.body;

    if (!text) {
      return res.status(400).json({
        success: false,
        message: 'Açıklama metni gereklidir'
      });
    }

    const prompt = `Bu açıklamayı ${educationLevel || 'lise'} seviyesinde bir öğrencinin anlayabileceği şekilde daha basit hale getir:

${text}`;

    const simplified = await callAI(prompt, TEACHER_PROMPT);

    res.json({
      success: true,
      data: {
        original: text,
        simplified
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Basitleştirme sırasında hata oluştu',
      error: error.message
    });
  }
};


