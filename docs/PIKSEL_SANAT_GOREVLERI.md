# Piksel sanat görev listesi — Mirror Soul

## Cumartesi hedefi

Önce tek bir oynanabilir odada görsel dilin temelini belirleyin. Boyutlar mevcut prototipe uydurulacak **başlangıç hedefleridir**; kamera ve oynanış testinden sonra birlikte değiştirilebilir. Referansın yüksek kontrastı ve neon enerji hissi korunabilir; karakter siluetleri, arayüz ve desenler Mirror Soul'a özgü çizilmelidir. Diyalogdaki ruh için iskelet karakter bu toplantı kapsamındaki yeni istektir; ilk aşamada portre olarak tasarlayın.

## Çizim ve teslim kuralları

- PNG, şeffaf arka plan, tek kareler veya yatay sprite sheet; katmanlı Aseprite/Krita kaynak dosyasını da saklayın.
- Boyutlar tuval boyutudur, çarpışma alanı değildir. Bir karedeki ölçeği ve ayak/merkez hizasını aynı tutun. Spriteları büyütürken en yakın komşu (nearest neighbor) kullanın.
- Ortak palet: koyu kömür/siyah zemin, kırık beyaz taş ve cam, turkuaz ayna/kalkan, neon kırmızı düşman ateşi; boss için sınırlı mor vurgu. Renkleri ekipçe kesinleştirin.
- Piksel sanatta antialiasing ve yarı saydamlık kullanımı ekipçe kararlaştırılsın; hayalet ve parıltı saydamlığı oyunda da uygulanabilir. PNG ile mevcut kod şekilleri ayrı tutulmalı.
- Dosya adları küçük harf ve alt çizgi: `player_idle.png`, `shield_prism.png`. Animasyon kareleri eşit boyutlu ve soldan sağa dizili olsun. Sahnedeki mevcut ölçüler 1280×720 oyun koordinatıdır; aşağıdaki sprite ölçüleri yeniden ölçekleme gerektirebilir.

## Öncelik 1 — Oynanabilir tek oda

- [ ] **Oyuncu:** 32×32 px/kare. Boşta 4 kare, hareket 6 kare, dash 4 kare, hasar 2 kare. Dört yön ihtiyacını testte kararlaştırın; ilk teslim tek yön veya yatay çevrilebilir siluet. Ayak noktası tuvalin alt-orta kısmında.
- [ ] **Temel ayna kalkanı:** 32×64 px/kare. Açılma 4 kare, bekleme 4 kare, parry parlaması 4 kare, kırılma 6 kare. Dönme merkezi (pivot) kalkanın merkezi; oyunda her açıya döner, kenarlarda yeterli boşluk bırakın.
- [ ] **Ayna nöbetçisi / test taret:** 48×48 px/kare. Boşta 4, saldırı hazırlığı 4, hasar 2, yok oluş 6 kare. Kafatası yerine özgün cam/ayna silueti; iskelet yalnızca diyalog ruhudur.
- [ ] **Düşman mermisi:** 16×16 px/kare, 4 döngü karesi; yansımış sürüm için 16×16 açık renk varyantı.
- [ ] **Lazer:** 16×16 px tekrar edebilir merkez şeridi, 16×16 başlangıç ve 16×16 uç; kırmızı düşman ve açık renk yansıma varyantları. Mevcut prototip lazeri Line2D çiziyor: bu dokuların entegrasyonu yazılım işidir.
- [ ] **Vuruş/parry efektleri:** 32×32 px/kare, vuruş 4 ve parry 6 kare; sayısal hasar mevcut yazıyla gösterilebilir.
- [ ] **Zindan tileset:** 16×16 px tile. En az 4 zemin varyasyonu, düz duvarlar, iç/dış köşeler, 2 çatlak, 2 cam kırığı/dekor ve kapı; siyah/kırık beyaz ağırlıklı. Yerleşimi gösteren örnek 8×8 tile test sayfası ekleyin.
- [ ] **Diyalog ruhu:** 64×64 px portre; nötr, alaycı, şaşkın ve memnun olmak üzere 4 ifade. Kendi karakter tasarımımızı üretin. Portre henüz kodda bağlı değil.
- [ ] **Arayüz:** ölçeklenebilir diyalog kutusu için 9-slice çerçeve (köşeler 8×8 px), stamina dolgu deseni ve 16×16 px simgeler. Kutunun iç alanında en az iki satır Türkçe metin okunabilmeli.

## Öncelik 2 — Geliştirmeler ve boss

- [ ] **Prizma Kesim:** 32×64 kalkan varyantı; 16×16 ikon; 32×32 4 karelik parçalanma efekti.
- [ ] **Kavisli Cam:** 32×64 kalkan; 16×16 ikon; 32×32 4 kare birikme efekti; kalın ışın için ayrı doku önerisi.
- [ ] **Mıknatıslı Sır:** 32×64 kalkan; 16×16 ikon; 16×16 4 kare nişan işareti.
- [ ] **Hayalet Ayna:** 32×64 kalkan; 16×16 ikon; 4 karelik 32×64 belirme efekti.
- [ ] **Göz Boss'u / Overseer:** 64×64 px/kare. Boşta 6, saldırı hazırlığı 4, ateş 4, hasar 2, ölüm 8 kare. Merkez noktası tutarlı; beş farklı yöne ateş ettiği okunmalı.
- [ ] **Ek çevre:** 16×16 parçalarla kapı, kırık ayna, oda işaretleri; 64×64 veya daha büyük nesneleri ayrı sprite olarak verin.

## Kontrol ve devir

- [ ] İlk önce oyuncu + temel kalkan + bir düşman + 8×8 tile sayfası ile oyunda okunurluk testi.
- [ ] Telefon ekranında düşman mermisi ile yansımış mermi ve parry anı ayırt ediliyor mu?
- [ ] Her animasyonun kare sayısı, fps, tuval ölçüsü ve pivotu teslim notunda yazıyor mu?
- [ ] Referans alınan üçüncü taraf varlıklar ve lisansları ayrıca belirtilmiş mi?
