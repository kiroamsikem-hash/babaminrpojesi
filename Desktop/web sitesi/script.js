// Kullanım şartları modalını göster
function showTerms() {
    document.getElementById('termsModal').classList.remove('hidden');
}

// Kullanım şartları modalını kapat
function closeTerms() {
    document.getElementById('termsModal').classList.add('hidden');
}

// Modal'dan şartları kabul et
function acceptTermsFromModal() {
    document.getElementById('acceptTerms').checked = true;
    closeTerms();
    showToast('Kullanım şartları kabul edildi', 'success');
}

// Toast Bildirimi
function showToast(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    
    const icon = type === 'success' ? 'fa-check-circle' : 
                 type === 'error' ? 'fa-exclamation-circle' : 
                 'fa-info-circle';
    
    toast.innerHTML = `
        <i class="fa-solid ${icon}"></i>
        <span>${message}</span>
    `;
    
    document.body.appendChild(toast);
    
    // Animasyon
    setTimeout(() => toast.classList.add('show'), 100);
    
    // Kaldır
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// Link oluştur
async function createLink() {
    const title = document.getElementById('linkTitle').value;
    const redirectUrl = document.getElementById('redirectUrl').value;
    const acceptTerms = document.getElementById('acceptTerms').checked;

    if (!acceptTerms) {
        showToast('Lütfen kullanım şartlarını kabul edin!', 'error');
        return;
    }

    // Rastgele link ID oluştur
    const linkId = generateRandomId();
    const trackingId = generateRandomId();

    // Link oluştur (kısa URL)
    const baseUrl = window.location.origin;
    const generatedLink = `${baseUrl}/v/${linkId}`;
    const trackingLink = `${baseUrl}/t/${trackingId}`;

    // Database'e kaydet
    try {
        const response = await fetch('/api/create-link', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                linkId,
                trackingId,
                title: title || 'İsimsiz Link',
                redirectUrl: redirectUrl || ''
            })
        });

        if (!response.ok) {
            throw new Error('Link oluşturulamadı');
        }
    } catch (error) {
        console.error('Database kayıt hatası:', error);
        showToast('Link oluşturulurken hata oluştu!', 'error');
        return;
    }

    // LocalStorage'a da kaydet (yedek)
    const linkData = {
        id: linkId,
        trackingId: trackingId,
        title: title || 'İsimsiz Link',
        redirectUrl: redirectUrl || '',
        createdAt: new Date().toISOString(),
        visits: []
    };
    
    localStorage.setItem(`link_${linkId}`, JSON.stringify(linkData));
    localStorage.setItem(`tracking_${trackingId}`, linkId);

    // Linkleri göster
    document.getElementById('generatedLink').value = generatedLink;
    document.getElementById('trackingLink').value = trackingLink;

    // Sayfaları değiştir
    document.getElementById('homePage').classList.add('hidden');
    document.getElementById('linkCreatedPage').classList.remove('hidden');
    
    showToast('Link başarıyla oluşturuldu!', 'success');
}

// Rastgele ID oluştur (kısa ve sade)
function generateRandomId() {
    // 6 karakterlik kısa ID
    return Math.random().toString(36).substring(2, 8);
}

// Link kopyala
function copyLink() {
    const linkInput = document.getElementById('generatedLink');
    linkInput.select();
    document.execCommand('copy');
    showToast('Link kopyalandı!', 'success');
}

// Takip linki kopyala
function copyTrackingLink() {
    const linkInput = document.getElementById('trackingLink');
    linkInput.select();
    document.execCommand('copy');
    showToast('Takip linki kopyalandı!', 'success');
}

// Ana sayfaya dön
function goHome() {
    document.getElementById('homePage').classList.remove('hidden');
    document.getElementById('linkCreatedPage').classList.add('hidden');
    
    // Formu temizle
    document.getElementById('linkTitle').value = '';
    document.getElementById('redirectUrl').value = '';
    document.getElementById('acceptTerms').checked = false;
}

// Modal dışına tıklayınca kapat
document.getElementById('termsModal')?.addEventListener('click', (e) => {
    if (e.target.id === 'termsModal') {
        closeTerms();
    }
});
