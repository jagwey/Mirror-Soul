# Mirror Soul — Ayna Kalkanı

**Saldırmak yerine yansıt.** Mirror Soul, düşman ateşini bir ayna kalkanıyla geri çevirme fikri üzerine kurulu, mobil odaklı bir 2D roguelite prototipidir. Oyuncu hareket eder, doğru anda kalkanını kaldırır ve düşmanların saldırılarını onlara karşı kullanır. Godot 4 ve GDScript ile geliştiriliyor.

> **Proje durumu:** Erken prototip. Bu depo bir test odası ve temel mekanikleri içerir; tamamlanmış bir oyun veya mobil mağaza sürümü değildir.

## Oynanış fikri

Zindanda hayatta kalırken kalkanın yönünü ayarla, gelen mermileri ve lazerleri geri gönder. Kalkanı doğru zamanda açmak **perfect parry** sağlar; hareket, stamina yönetimi ve dash ile pozisyon almak da önemlidir. Hedeflenen roguelite döngüsünde zindan ödülleri kalkanın davranışını değiştirir.

### Ayna geliştirmeleri

- **Prizma Kesim:** Yansıyan saldırıyı 15 derece aralıklı 3 veya 5 yöne böler.
- **Kavisli Cam:** Gelen saldırıların hasarını biriktirir; sağ parmak bırakıldığında geniş bir ışın olarak ateşler.
- **Mıknatıslı Sır:** Yansımanın açısını en yakın düşmana doğru %35 düzeltir.
- **Hayalet Ayna:** Dash başlangıcında üç oyun saniyesi boyunca ışınları yansıtan saydam bir kalkan bırakır.

Geliştirmeler kod aracılığıyla uygulanabilir. Ödül seçim ekranı ve tam zindan ilerleyişi henüz uygulanmadı. Kombinasyonlar ve entegrasyon örneği için [geliştirme notlarına](UPGRADE_SISTEMI.md) bakın.

## Kontroller

- **Sol ekran:** Dokunup sürükleyerek hareket et. Hızlı kaydırma veya çift dokunuş dash yapar.
- **Sağ ekran:** Dokunarak kalkanı aç; sürükleyerek yönelt. Parmağı bırakınca kalkan kapanır ve birikmiş odak hasarı varsa ateşlenir.
- **Masaüstü:** Projede fareden dokunma emülasyonu açıktır. Tek fare işaretçisi aynı anda iki parmak kullanımını tam olarak temsil etmez; çoklu dokunma için gerçek cihazda test gerekir.

## Projeyi açma

1. Godot Engine 4.x standart sürümünü kurun.
2. Bu depoyu klonlayın veya indirin:
   ```sh
   git clone https://github.com/jagwey/Mirror-Soul.git
   ```
3. Godot Proje Yöneticisi'nde **Import / İçe Aktar** seçeneğini kullanın ve klasördeki `project.godot` dosyasını seçin.
4. Projeyi açın ve **F6** veya **F5** ile test sahnesini başlatın. Ana sahne `scenes/TestDungeon.tscn` olarak ayarlıdır.

Mobil dışa aktarma için Godot'nun ilgili platforma ait export şablonlarını ve platform geliştirme araçlarını ayrıca kurmanız gerekir. Depoda hazır Android/iOS paketi bulunmaz.

## Proje yapısı

- `scenes/TestDungeon.tscn` — test odası, oyuncu, düşmanlar ve mermi havuzu.
- `scenes/Player.tscn` — oyuncu ve kalkan düğümleri.
- `scripts/Player.gd` — dokunmatik hareket, dash, stamina ve kalkan girdisi.
- `scripts/Shield.gd`, `scripts/MirrorUpgrade.gd` — kalkan ve geliştirilebilir davranışları.
- `scripts/LaserBeam.gd` — ışın çizimi, yansıma ve hasar.
- `scripts/Enemy.gd` — iskelet taret ve Overseer prototipleri.
- `scripts/ProjectilePool.gd`, `scripts/PooledProjectile.gd` — yeniden kullanılan fiziksel mermiler.

## Bilinen eksikler

Oyuncu canı ve hasar alma, HUD bağlantısı, ödül seçim arayüzü, tam zindan döngüsü ve gerçek cihaz performans testleri henüz tamamlanmadı. Kapsam ve güncel test durumu için [PROGRESS.md](PROGRESS.md) dosyasına bakın.

## Lisans

Kaynak kodu ve bu depodaki proje dosyaları [MIT Lisansı](LICENSE) kapsamında sunulur. Üçüncü taraf içerik eklendiğinde kendi lisansları ayrıca belirtilmelidir.
