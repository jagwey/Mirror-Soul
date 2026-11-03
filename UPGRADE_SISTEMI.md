# Geliştirme ve düşman entegrasyonu

TestDungeon sahnesinde 128 mermilik havuz, iskelet taret ve beş mermilik Overseer bulunur. Taretin `use_laser` özelliği açıldığında kısa süreli lazer ateşler; Overseer için de aynı ayar kullanılabilir. Havuz dolarsa yeni atış, boş yuva açılıncaya kadar atlanır. `ProjectilePool.initial_size` ile kapasite ayarlanabilir.

## Ödül seçimi

Ödül arayüzü seçilen `MirrorUpgrade` kaynağını oyuncunun kalkanına uygular:

```gdscript
var reward := MirrorUpgrade.new()
reward.kind = MirrorUpgrade.Kind.PRISM
reward.prism_count = 5 # 3 veya 5
$Player/ShieldPivot/ShieldArea.apply_upgrade(reward)
```

Diğer değerler: `MirrorUpgrade.Kind.FOCUS`, `AUTO_AIM` ve `GHOST`. Bu entegrasyon ödül seçimi arayüzünü oluşturmaz. Geliştirmeler bir arada çalışabilir: odaklayıcı gelen atışı emer; diğer durumlarda prizma ve otomatik nişan yansımalara uygulanır. Hayalet kalkan odaklamaz, yansıtır.

Odaklayıcı fiziksel merminin hasarını, sürekli lazerin ise temas süresindeki hasarını biriktirir. Sağ parmak bırakıldığında birikim kalkanın baktığı yönde tek vuruşluk, normal lazerin beş katı genişliğinde ışın olarak boşaltılır. Dash veya stamina tükenmesiyle kalkanın kapanması birikimi siler. Dash kopyası üç oyun saniyesi yaşar. Prizma parçalarının her biri gelen atışın hasarını taşır. Otomatik nişan yansıma açısını en yakın düşmana doğru %35 döndürür; sonrasında hedef takibi yapmaz.

Düşman sahnesi `Enemy.gd` bağlı bir CharacterBody2D olabilir. `Enemy` grubu ve yoksa basit bir çarpışma şekli otomatik eklenir. Çarpışma katmanı/maskesi varsayılan 1. katmanla eşleşmelidir. Havuz sahnede düşmanlardan önce hazır olmalıdır. Sürekli ışınlar fiziksel yansıma başına kombo çarpanı uygular. Mevcut Player.gd hasar/can sistemi içermediğinden düşman atışlarının oyuncuya hasar vermesi için ayrıca `take_damage(amount)` eklenmelidir.
