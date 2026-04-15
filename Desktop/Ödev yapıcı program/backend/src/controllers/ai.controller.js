const axios = require('axios');
const Question = require('../models/Question.model');

// AI Providers - Sırayla denenecek
const AI_PROVIDERS = [
  { name: 'Gemini', envKey: 'GEMINI_API_KEY', handler: callGemini },
  { name: 'OpenAI', envKey: 'OPENAI_API_KEY', handler: callOpenAI },
  { name: 'Claude', envKey: 'CLAUDE_API_KEY', handler: callClaude },
  { name: 'DeepSeek', envKey: 'DEEPSEEK_API_KEY', handler: callDeepSeek },
];

// AI Service - Google Gemini (Ücretsiz)
async function callGemini(prompt, systemPrompt) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey === 'your-gemini-api-key') {
    throw new Error('Gemini API key bulunamadı');
  }

  const fullPrompt = `${systemPrompt}\n\n${prompt}`;
  
  const response = await axios.post(
    `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
    {
      contents: [{
        parts: [{
          text: fullPrompt
        }]
      }],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 2048,
      }
    },
    {
      headers: { 'Content-Type': 'application/json' },
      timeout: 30000
    }
  );
  
  if (!response.data.candidates || !response.data.candidates[0]) {
    throw new Error('Gemini API yanıt vermedi');
  }
  
  return response.data.candidates[0].content.parts[0].text;
}

// AI Service - OpenAI GPT-4
async function callOpenAI(prompt, systemPrompt) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey || apiKey === 'your-openai-api-key-here') {
    throw new Error('OpenAI API key bulunamadı');
  }

  const response = await axios.post(
    'https://api.openai.com/v1/chat/completions',
    {
      model: 'gpt-4o-mini', // Ucuz ve hızlı
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 2000
    },
    {
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      timeout: 30000
    }
  );
  
  return response.data.choices[0].message.content;
}

// AI Service - Claude (Anthropic)
async function callClaude(prompt, systemPrompt) {
  const apiKey = process.env.CLAUDE_API_KEY;
  if (!apiKey || apiKey === 'your-claude-api-key') {
    throw new Error('Claude API key bulunamadı');
  }

  const response = await axios.post(
    'https://api.anthropic.com/v1/messages',
    {
      model: 'claude-3-haiku-20240307', // En ucuz Claude
      max_tokens: 2048,
      system: systemPrompt,
      messages: [
        { role: 'user', content: prompt }
      ]
    },
    {
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json'
      },
      timeout: 30000
    }
  );
  
  return response.data.content[0].text;
}

// AI Service - DeepSeek
async function callDeepSeek(prompt, systemPrompt) {
  const apiKey = process.env.DEEPSEEK_API_KEY;
  if (!apiKey || apiKey === 'your-deepseek-api-key') {
    throw new Error('DeepSeek API key bulunamadı');
  }

  const response = await axios.post(
    'https://api.deepseek.com/v1/chat/completions',
    {
      model: 'deepseek-chat',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 2000
    },
    {
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      timeout: 30000
    }
  );
  
  return response.data.choices[0].message.content;
}

// AI Service Selector - Tüm provider'ları sırayla dene
async function callAI(prompt, systemPrompt) {
  const errors = [];
  
  for (const provider of AI_PROVIDERS) {
    try {
      console.log(`🤖 ${provider.name} deneniyor...`);
      const result = await provider.handler(prompt, systemPrompt);
      console.log(`✅ ${provider.name} başarılı!`);
      return result;
    } catch (error) {
      const errorMsg = error.response?.data?.error?.message || error.message;
      console.log(`❌ ${provider.name} hatası: ${errorMsg}`);
      errors.push(`${provider.name}: ${errorMsg}`);
    }
  }
  
  throw new Error(`Tüm AI servisleri başarısız oldu:\n${errors.join('\n')}`);
}

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


