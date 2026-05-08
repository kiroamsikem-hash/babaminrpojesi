# 🚀 Hızlı Deploy Komutları

## Vercel ile Deploy (ÖNERİLEN - 2 Dakika)

### İlk Kurulum
```bash
# 1. Vercel CLI kur (sadece bir kez)
npm install -g vercel

# 2. Deploy et
vercel

# İlk deploy için soruları cevapla:
# ? Set up and deploy? [Y/n] → Y (Enter)
# ? Which scope? → Enter (varsayılan)
# ? Link to existing project? [y/N] → N (Enter)
# ? What's your project's name? → ip-logger (veya istediğin isim)
# ? In which directory is your code located? → ./ (Enter)
# ? Want to override the settings? [y/N] → N (Enter)

# ✅ HAZIR! Link gösterilecek
```

### Sonraki Güncellemeler
```bash
# Sadece bu komutu çalıştır
vercel --prod
```

---

## Netlify ile Deploy (Alternatif - 2 Dakika)

### İlk Kurulum
```bash
# 1. Netlify CLI kur (sadece bir kez)
npm install -g netlify-cli

# 2. Login ol
netlify login

# 3. Deploy et
netlify deploy --prod

# İlk deploy için:
# ? Create & configure a new site → Yes
# ? Team → (Enter - varsayılan)
# ? Site name → ip-logger (veya istediğin isim)
# ? Publish directory → . (nokta koy, Enter)

# ✅ HAZIR! Link gösterilecek
```

### Sonraki Güncellemeler
```bash
# Sadece bu komutu çalıştır
netlify deploy --prod
```

---

## GitHub Pages ile Deploy (3 Dakika)

```bash
# 1. Git başlat
git init
git add .
git commit -m "Initial commit"

# 2. GitHub'da yeni repo oluştur (tarayıcıdan)
# https://github.com/new

# 3. GitHub'a yükle (KULLANICI_ADIN yerine kendi kullanıcı adını yaz)
git branch -M main
git remote add origin https://github.com/KULLANICI_ADIN/ip-logger.git
git push -u origin main

# 4. GitHub repo ayarlarına git
# Settings > Pages > Source: main branch > Save

# ✅ HAZIR! Link: https://KULLANICI_ADIN.github.io/ip-logger/
```

---

## Netlify Drop (EN KOLAY - 1 Dakika)

### Tarayıcıdan:
1. https://app.netlify.com/drop adresine git
2. Proje klasörünü sürükle bırak
3. ✅ HAZIR! Link gösterilecek

**Not**: Bu yöntemde güncellemeler için her seferinde yeniden sürükle bırak yapman gerekir.

---

## 🎯 Hangi Yöntemi Seçmeliyim?

### Vercel (En İyi)
- ✅ En hızlı
- ✅ Otomatik güncellemeler
- ✅ Özel domain kolay
- ✅ Analytics ücretsiz

### Netlify (İyi)
- ✅ Drag & drop kolay
- ✅ Form handling var
- ✅ Güvenilir

### GitHub Pages (Basit)
- ✅ GitHub entegrasyonu
- ✅ Tamamen ücretsiz
- ❌ Biraz yavaş

---

## 📝 Deploy Sonrası

### Link Örneği:
- Vercel: `https://ip-logger-abc123.vercel.app`
- Netlify: `https://ip-logger-abc123.netlify.app`
- GitHub: `https://kullaniciadin.github.io/ip-logger/`

### Özel Domain Eklemek İçin:
1. Domain satın al (Namecheap, GoDaddy, vb.)
2. Vercel/Netlify panelinden "Add domain" tıkla
3. DNS ayarlarını yap
4. ✅ Hazır! (örn: `iplogger.com`)

---

## 🔄 Güncelleme Yapmak

### Vercel/Netlify CLI ile:
```bash
# Değişiklikleri yap
# Sonra:
vercel --prod
# veya
netlify deploy --prod
```

### GitHub Pages ile:
```bash
# Değişiklikleri yap
git add .
git commit -m "Update"
git push
# Otomatik deploy olur
```

---

## ⚡ HEMEN BAŞLA!

**Terminalde çalıştır:**

```bash
# Vercel için (Önerilen)
npm i -g vercel && vercel

# VEYA Netlify için
npm i -g netlify-cli && netlify login && netlify deploy --prod
```

**2 dakika sonra siteniz yayında! 🎉**
