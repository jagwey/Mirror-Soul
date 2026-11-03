# Mirror Soul — Torimon Stüdyo

Başka bir dünyadan gelen bir gezgin, Shilda ile anlaşma yapar. Artık çıkaramadığı kalkanın içinde yaşayan ruh, onun tek silahıdır: düşmanların lazerlerini yakala, yönünü değiştir ve geri gönder.

Godot 4 / GDScript ile geliştirilen mobil odaklı 2D roguelite **oynanabilir prototip**. Tamamlanmış oyun veya mağaza sürümü değildir.

## Oynanış

- Dört farklı yöndeki nöbetçiler önce nişan çizgisi gösterir, sonra lazer ateşler. Başlangıçta saldırılar zaman olarak ayrılır; üst katlarda daha sıklaşır.
- Kalkan ışını yansıtır; kalkanı kaçıran ışın sürekli can azaltır. Dash sırasında kısa koruma vardır.
- Üç oda temizlendikten sonra üç geliştirmeden biri seçilir. Prizma, odaklama, otomatik nişan ve hayalet kalkan bulunur.
- İlk iki odanın sonunda sağda açılan geçide yürüyerek ilerleyin; kat sonunda ödül seçip üst kata çıkın.
- Shilda'nın konuşmaları aksiyonu durdurmadan alt panelde gösterilir.

## Kontroller

Masaüstü: **WASD** hareket, **sağ tık basılı** kalkan, **fare** yön, **boşluk** dash.

Mobil: sol yarıda sürükleme hareket; sağ yarıda dokunma kalkan, sürükleme yön. Sol tarafta çift dokunma veya hızlı kaydırma dash yapar.

## Açma ve test

Depoyu klonlayıp `project.godot` dosyasını Godot'a aktarın. F5 ile ana sahneyi çalıştırın. Son kontroller Godot **4.7.2** ile yapıldı.

```sh
godot --headless --path . --script res://tests/control_and_hits.gd
godot --headless --path . --script res://tests/dialogue_test.gd
godot --headless --path . --script res://tests/floor_progression.gd
godot --headless --path . --script res://tests/laser_combat.gd
```

Android için dışa aktarma şablonları, Java ve Android SDK ayrıca kurulmalı. Android dışa aktarma profilinde **Include Filter / Dahil et filtresi** alanına `*.json` ekleyin; Shilda'nın metinleri uygulamaya dahil olsun. Yerel export ayarları, Android derleme çıktıları ve imzalama dosyaları depoya alınmaz.

## Ekip belgeleri

- [Piksel sanat görevleri](docs/PIKSEL_SANAT_GOREVLERI.md)
- [Hikâye / JSON düzenleme rehberi](docs/HIKAYE_JSON_SABLONU.md)
- [Diyalog dosyası](resources/dialogues.tr.json)
- [Geliştirme entegrasyonu](UPGRADE_SISTEMI.md)

## Sınırlar

Odalar henüz aynı arena sınırlarını kullanır. Karakterler kod tabanlı özgün piksel desenleri ve basit hareketlerle çizilir. Kat dengesi gerçek oyuncu ve mobil cihaz testlerine ihtiyaç duyar. Sürekli kayıt, ses tasarımı, kapsamlı animasyonlar ve farklı geometrili odalar henüz yoktur.

Kaynak kodu [MIT lisansı](LICENSE) altındadır.
