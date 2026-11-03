# Hikâye ve diyalog görev şablonu

## Düzenlenecek dosya

Gerçek oyun verisi: [`resources/dialogues.tr.json`](../resources/dialogues.tr.json). UTF-8 destekleyen bir metin editörüyle açıp kaydedin. Oyun içindeki metinler bu dosyadan okunur; dosya kod değildir ve diyalog yazmak için GDScript düzenlemeniz gerekmez. Bu klasördeki kopyayı değiştirin; Android'e aktarılmış sürüm kendiliğinden güncellenmez, yeni oyun paketi gerekir.

Dosyada başlangıç için **10 örnek diyalog** ve 4 geliştirme açıklaması bulunuyor. Aynadaki alaycı iskelet ruhunun portresi henüz oyuna bağlanmadı; şu anda metin gösterilir. Şaka dili karaktere ve dünyaya özgü kalmalı; oyuncunun okumak için savaşı bırakması gerekmemeli.

## Yapı

- `dialogues.on_game_start`: oyun başlangıcı.
- `dialogues.on_shield_broken`: kalkan dayanıklılığı tükenince.
- `dialogues.on_perfect_parry_combo`: varsayılan olarak 3 gerçek saniye içinde ikinci perfect parry gerçekleşince. Pencere ve eşik Player ayarlarından değiştirilebilir; combo sıfırlanana kadar tekrar tetiklenmez.
- `dialogues.on_upgrade_picked`: ilgili geliştirme seçildiğinde `prism`, `focus`, `auto_aim`, `ghost` anahtarından bir cümle.
- `upgrades`: aynı anahtarlardaki `name` ve `description` metinleri; gelecekteki ödül ekranı bunları okuyabilir. Ödül ekranı henüz yapılmadı.

Her olayın köşeli parantezi içinde istediğiniz kadar metin yazın. Olay her tekrarlandığında listedeki sonraki metin seçilir, sonrasında başa dönülür. Yeni bir geliştirme kimliği veya yeni olay türü eklemek için yazılımcının onu oyunda bağlaması gerekir; mevcut listelere yüzlerce cümle ekleyebilirsiniz. Ekran en fazla 8 bekleyen metni sıraya alır; doluyken yeni istek atlanır.

```json
{
  "dialogues": {
    "on_game_start": ["İlk cümle.", "İkinci cümle."],
    "on_shield_broken": ["Kalkan kırıldı."],
    "on_perfect_parry_combo": ["İki güzel savuşturma."],
    "on_upgrade_picked": {
      "prism": ["Prizma yorumu."],
      "focus": ["Odak yorumu."],
      "auto_aim": ["Nişan yorumu."],
      "ghost": ["Hayalet yorumu."]
    }
  },
  "upgrades": {
    "prism": {"name": "Prizma Kesim", "description": "Kısa açıklama."},
    "focus": {"name": "Kavisli Cam", "description": "Kısa açıklama."},
    "auto_aim": {"name": "Mıknatıslı Sır", "description": "Kısa açıklama."},
    "ghost": {"name": "Hayalet Ayna", "description": "Kısa açıklama."}
  }
}
```

## Yazarken dikkat

1. Anahtarları değiştirmeyin; yalnızca tırnakların içindeki metinleri düzenleyin veya listedeki örnekleri çoğaltın.
2. Listedeki cümlelerin arasına virgül koyun; **son cümleden sonra virgül koymayın**.
3. Cümlenin içinde çift tırnak gerekiyorsa `\"` yazın. Yeni satır için `\n` kullanın. Gerçek metin dosyasını UTF-8 kaydedin.
4. Metinler düz yazıdır; BBCode veya HTML komutları çalışmaz. En iyi okunurluk için çoğunlukla kısa, 1–2 satırlık cümleler yazın.
5. Dosya biçimi bozulursa oyun devam eder, ilgili diyaloglar gösterilmez ve Godot hata çıktısında uyarı görünür. Kaydetmeden önce bir JSON doğrulayıcı kullanın.
6. Oyun sürerken diyaloglar sırayla gösterilir; her karakter yazıldıktan sonra yaklaşık 2,5 saniye kalır. Oyun durmaz, kutu dokunmaları yakalamaz.

## Cumartesi teslimi

- [ ] Dört olay türüne en az 5'er kısa alternatif yaz.
- [ ] Dört ayna geliştirmesi için iki alternatif yorum ve anlaşılır açıklama yaz.
- [ ] Karakterin tonu, kaçınılacak şakalar ve hikâyenin ilk oda açılışını yarım sayfada özetle.
- [ ] JSON dosyasını doğrula ve bir cümleyi oyunda dene.
