const User = require('../models/User.model');

exports.checkDailyLimit = async (req, res, next) => {
  try {
    // Test için limit kontrolünü devre dışı bırak
    // TODO: Production'da aktif et
    next();
    return;
    
    // Reset daily count if needed
    await User.resetDailyCount(req.user.id);
    
    // Get updated user
    const user = await User.findById(req.user.id);
    
    const limit = user.is_premium 
      ? parseInt(process.env.DAILY_QUESTION_LIMIT_PREMIUM) 
      : parseInt(process.env.DAILY_QUESTION_LIMIT_FREE);
    
    if (user.daily_question_count >= limit) {
      return res.status(429).json({
        success: false,
        message: 'Günlük soru limitiniz doldu',
        limit,
        used: user.daily_question_count
      });
    }
    
    // Increment count
    await User.incrementQuestionCount(req.user.id);
    
    next();
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Limit kontrolü sırasında hata oluştu'
    });
  }
};
