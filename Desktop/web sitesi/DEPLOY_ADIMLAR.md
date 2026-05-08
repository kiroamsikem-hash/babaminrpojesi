# 🚀 Deploy Adımları - hksg.qzz.io

## ✅ Vercel CLI Kuruldu!

Şimdi deploy için şu adımları takip et:

## 1️⃣ Vercel'e Login Ol

Terminal'de çalıştır:
```bash
vercel login
```

Bu komut:
- Tarayıcıda bir sayfa açacak
- Vercel hesabınla giriş yap (GitHub, GitLab, Bitbucket veya Email)
- "Confirm" tıkla
- Terminal'e dön

## 2️⃣ Deploy Et

```bash
vercel
```

Soruları cevapla:
```
? Set up and deploy "C:\Users\yazar\Desktop\web sitesi"? [Y/n]
→ Y (Enter)

? Which scope do you want to deploy to?
→ Enter (varsayılan)

? Link to existing project? [y/N]
→ N (Enter)

? What's your project's name?
→ ip-logger (veya istediğin isim)

? In which directory is your code located?
→ ./ (Enter)

? Want to modify these settings? [y/N]
→ N (Enter)
```

✅ Deploy başlayacak!

## 3️⃣ Production'a Deploy Et

İlk deploy test için olacak. Production için:
```bash
vercel --prod
```

✅ Canlı link alacaksın!

## 4️⃣ Özel Domain Ekle (hksg.qzz.io)

### Yöntem 1: Vercel Dashboard'dan
1. https://vercel.com/dashboard git
2. Projeyi seç
3. "Settings" → "Domains" tıkla
4. "Add" tıkla
5. `hksg.qzz.io` yaz
6. DNS ayarlarını gösterecek

### Yöntem 2: CLI ile
```bash
vercel domains add hksg.qzz.io
```

## 5️⃣ DNS Ayarları

Domain sağlayıcında (qzz.io) şu ayarları yap:

### A Record:
```
Type: A
Name: hksg
Value: 76.76.21.21
```

### CNAME Record (Alternatif):
```
Type: CNAME
Name: hksg
Value: cname.vercel-dns.com
```

✅ 5-10 dakika içinde aktif olacak!

---

## 🎯 Hızlı Özet

```bash
# 1. Login
vercel login

# 2. Deploy
vercel

# 3. Production
vercel --prod

# 4. Domain ekle
vercel domains add hksg.qzz.io
```

---

## 📱 Sonuç

Deploy sonrası linkler:
- **Vercel Link**: `https://ip-logger-xyz.vercel.app`
- **Özel Domain**: `https://hksg.qzz.io`

URL örnekleri:
- Ziyaretçi: `https://hksg.qzz.io/v/abc123`
- Takip: `https://hksg.qzz.io/t/xyz789`

---

## ⚡ Şimdi Çalıştır!

Terminal'de:
```bash
vercel login
```

Sonra:
```bash
vercel --prod
```

**2 dakika sonra yayında! 🎉**
