# 🌐 Domain Ayarları - hksg.qzz.io

## 📋 DNS Ayarları

Domain sağlayıcında (qzz.io) şu ayarları yapman gerekiyor:

### Yöntem 1: A Record (Önerilen)

```
Type: A
Name: hksg
Value: 76.76.21.21
TTL: 3600 (veya Auto)
```

### Yöntem 2: CNAME Record

```
Type: CNAME
Name: hksg
Value: cname.vercel-dns.com
TTL: 3600 (veya Auto)
```

---

## 🔧 Vercel'de Domain Ekleme

### CLI ile:
```bash
vercel domains add hksg.qzz.io
```

### Dashboard'dan:
1. https://vercel.com/dashboard
2. Projeyi seç
3. Settings → Domains
4. "Add" tıkla
5. `hksg.qzz.io` yaz
6. "Add" tıkla

---

## ✅ Doğrulama

DNS ayarlarını yaptıktan sonra kontrol et:

```bash
# Windows'ta
nslookup hksg.qzz.io

# Veya tarayıcıdan
https://dnschecker.org/#A/hksg.qzz.io
```

---

## ⏱️ Bekleme Süresi

- **Minimum**: 5-10 dakika
- **Maksimum**: 24-48 saat
- **Ortalama**: 1-2 saat

---

## 🎯 Sonuç

Domain aktif olunca:

### Ana Sayfa:
```
https://hksg.qzz.io
```

### Ziyaretçi Linkleri:
```
https://hksg.qzz.io/v/abc123
https://hksg.qzz.io/v/xyz789
```

### Takip Linkleri:
```
https://hksg.qzz.io/t/m7p4q1
https://hksg.qzz.io/t/k3n8x2
```

---

## 🔒 HTTPS

Vercel otomatik olarak SSL sertifikası ekler:
- ✅ Ücretsiz
- ✅ Otomatik yenileme
- ✅ Let's Encrypt

---

## 💡 İpuçları

1. **DNS Propagation**: DNS değişiklikleri dünya çapında yayılması zaman alır
2. **Cache Temizle**: Tarayıcı cache'ini temizle (Ctrl+Shift+Delete)
3. **Incognito**: Gizli pencerede test et
4. **Sabırlı Ol**: İlk kurulumda 1-2 saat bekleyebilirsin

---

## 🆘 Sorun Giderme

### Domain çalışmıyor?

1. **DNS Kontrol**:
   ```bash
   nslookup hksg.qzz.io
   ```
   
2. **Vercel Kontrol**:
   - Dashboard'a git
   - Domain durumunu kontrol et
   - "Refresh" tıkla

3. **DNS Sağlayıcı**:
   - qzz.io paneline git
   - DNS ayarlarını kontrol et
   - Doğru IP/CNAME girdiğinden emin ol

### SSL Hatası?

- 10-15 dakika bekle
- Vercel otomatik SSL ekleyecek
- Sorun devam ederse: Vercel support

---

## 📞 Yardım

Sorun yaşarsan:
- Vercel Docs: https://vercel.com/docs/custom-domains
- Vercel Support: https://vercel.com/support
- DNS Checker: https://dnschecker.org

---

**Domain aktif olunca süper kısa linkler! 🚀**

```
hksg.qzz.io/v/abc123
```
