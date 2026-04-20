class AppLanguages {
  static const Map<String, Map<String, String>> translations = {
    'tr': {
      // Auth
      'welcome': 'Hoş Geldin!',
      'create_account': 'Hesap Oluştur',
      'login_subtitle': 'Öğrenmeye devam etmek için giriş yap',
      'register_subtitle': 'Öğrenme yolculuğuna başla',
      'name': 'İsim',
      'email': 'Email',
      'password': 'Şifre',
      'grade': 'Sınıf',
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'no_account': 'Hesabın yok mu? Kayıt Ol',
      'have_account': 'Zaten hesabın var mı? Giriş Yap',
      'or': 'veya',
      'continue_with_google': 'Google ile devam et',
      'accept_terms': 'Kullanım Şartları ve Gizlilik Politikası\'nı okudum ve kabul ediyorum.',
      
      // Dashboard
      'dashboard': 'Ana Sayfa',
      'chat': 'Sohbet',
      'camera': 'Kamera',
      'profile': 'Profil',
      'quick_actions': 'Hızlı İşlemler',
      'recent_questions': 'Son Sorular',
      'solve_question': 'Soru Çöz',
      'math_problem': 'Matematik',
      'composition': 'Kompozisyon',
      'translate': 'Çeviri',
      
      // Camera
      'photo_scan': 'Fotoğraf Tarama',
      'take_photo_or_select': 'Sorunun fotoğrafını çek\nveya galeriden seç',
      'open_camera': 'Kamera Aç',
      'select_from_gallery': 'Galeriden Seç',
      'retake': 'Yeniden Çek',
      'continue': 'Devam Et',
      'processing': 'İşleniyor...',
      
      // Profile
      'statistics': 'İstatistikler',
      'total_questions': 'Toplam Soru',
      'education_level': 'Eğitim Seviyesi',
      'settings': 'Ayarlar',
      'edit_profile': 'Profil Düzenle',
      'dark_theme': 'Karanlık Tema',
      'change_password': 'Şifre Değiştir',
      'about': 'Hakkında',
      'logout': 'Çıkış Yap',
      
      // Errors
      'error': 'Hata',
      'success': 'Başarılı',
      'name_required': 'İsim gereklidir',
      'email_required': 'Email gereklidir',
      'valid_email': 'Geçerli bir email giriniz',
      'password_required': 'Şifre gereklidir',
      'password_min': 'Şifre en az 6 karakter olmalıdır',
      'grade_required': 'Sınıf seçimi gereklidir',
      'accept_terms_required': 'Kullanım şartlarını ve gizlilik politikasını kabul etmelisiniz',
      
      // Additional translations
      'history': 'Geçmiş',
      'hello': 'Merhaba',
      'send_message': 'Mesaj gönder',
      'type_message': 'Mesajınızı yazın...',
      'ask_question': 'Soru sor',
      'simplify': 'Basitleştir',
      'no_messages': 'Henüz mesaj yok',
      'start_conversation': 'Bir soru sorarak sohbete başlayın',
    },
    'en': {
      // Auth
      'welcome': 'Welcome!',
      'create_account': 'Create Account',
      'login_subtitle': 'Login to continue learning',
      'register_subtitle': 'Start your learning journey',
      'name': 'Name',
      'email': 'Email',
      'password': 'Password',
      'grade': 'Grade',
      'login': 'Login',
      'register': 'Register',
      'no_account': 'Don\'t have an account? Register',
      'have_account': 'Already have an account? Login',
      'or': 'or',
      'continue_with_google': 'Continue with Google',
      'accept_terms': 'I have read and accept the Terms of Service and Privacy Policy.',
      
      // Dashboard
      'dashboard': 'Dashboard',
      'chat': 'Chat',
      'camera': 'Camera',
      'profile': 'Profile',
      'quick_actions': 'Quick Actions',
      'recent_questions': 'Recent Questions',
      'solve_question': 'Solve Question',
      'math_problem': 'Math',
      'composition': 'Composition',
      'translate': 'Translate',
      
      // Camera
      'photo_scan': 'Photo Scan',
      'take_photo_or_select': 'Take a photo of the question\nor select from gallery',
      'open_camera': 'Open Camera',
      'select_from_gallery': 'Select from Gallery',
      'retake': 'Retake',
      'continue': 'Continue',
      'processing': 'Processing...',
      
      // Profile
      'statistics': 'Statistics',
      'total_questions': 'Total Questions',
      'education_level': 'Education Level',
      'settings': 'Settings',
      'edit_profile': 'Edit Profile',
      'dark_theme': 'Dark Theme',
      'change_password': 'Change Password',
      'about': 'About',
      'logout': 'Logout',
      
      // Errors
      'error': 'Error',
      'success': 'Success',
      'name_required': 'Name is required',
      'email_required': 'Email is required',
      'valid_email': 'Please enter a valid email',
      'password_required': 'Password is required',
      'password_min': 'Password must be at least 6 characters',
      'grade_required': 'Grade selection is required',
      'accept_terms_required': 'You must accept the terms and privacy policy',
      
      // Additional translations
      'history': 'History',
      'hello': 'Hello',
      'send_message': 'Send message',
      'type_message': 'Type your message...',
      'ask_question': 'Ask a question',
      'simplify': 'Simplify',
      'no_messages': 'No messages yet',
      'start_conversation': 'Start a conversation by asking a question',
    },
  };

  static String get(String key, [String lang = 'tr']) {
    return translations[lang]?[key] ?? translations['tr']?[key] ?? key;
  }
}
