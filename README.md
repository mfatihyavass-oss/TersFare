# TersFare

TersFare, MacBook izleme dörtgeni ile harici tekerlekli farenin kaydırma yönünü ayrı kullanmak için yazılmış küçük bir macOS menü çubuğu uygulamasıdır.

macOS'ta "Doğal Kaydırma / Natural Scrolling" ayarı pratikte fare ve izleme dörtgenini birlikte etkiler. Bu yüzden izleme dörtgeninde doğal kaydırmayı koruyup, klasik tekerlekli farede ters yönde kaydırmak isteyen kullanıcılar her cihaz değişiminde ayar değiştirmek zorunda kalabilir. TersFare bu sorunu tek bir arka plan uygulamasıyla çözer.

## Ne Yapar?

- MacBook izleme dörtgeninin iki parmak kaydırma yönünü değiştirmez.
- Harici klasik tekerlekli fareden gelen dikey kaydırmayı ters çevirir.
- Menü çubuğunda küçük bir simge olarak çalışır.
- Menüden geçici olarak açılıp kapatılabilir.
- macOS Erişilebilirlik izniyle çalışır.
- İnternet bağlantısı kullanmaz, veri toplamaz, dışarıya veri göndermez.

## Kimler İçin?

Bu uygulama özellikle şu kullanım için tasarlandı:

- İzleme dörtgeni: doğal kaydırma açık kalsın.
- Harici fare: tekerlek kaydırması klasik Windows mantığı gibi çalışsın.

Örnek beklenti:

- İzleme dörtgeninde iki parmakla yukarı kaydırınca içerik doğal macOS davranışında kalsın.
- Fare tekerleğinde yukarı çevirdiğinde sayfa klasik fare davranışıyla yukarı gitsin.

## Gereksinimler

- macOS 13 veya daha yeni bir sürüm.
- Swift derleyicisi. Komut Satırı Araçları yeterlidir.
- Klasik tekerlekli harici fare.

Tam Xcode projesi gerekmez. Bu repo, `swiftc` ile doğrudan küçük bir `.app` paketi üretir.

## Kurulum

Projeyi indirdikten sonra klasör içinde şu komutu çalıştırın:

```zsh
./build.sh
```

Bu komut aynı klasörde `TersFare.app` oluşturur.

Sonra:

1. `TersFare.app` dosyasını `/Applications` klasörüne taşıyın.
2. Uygulamayı `/Applications` içinden açın.
3. macOS izin isterse Erişilebilirlik iznini verin.
4. Sistem Ayarları > İzleme Dörtgeni > Kaydırma ve Büyütme bölümünde Doğal Kaydırma açık kalsın.

## Erişilebilirlik İzni

TersFare, fare kaydırma olaylarını okuyup sadece tekerlekli fare olaylarını ters çevirebilmek için macOS Erişilebilirlik iznine ihtiyaç duyar.

İzin vermek için:

1. Sistem Ayarları'nı açın.
2. Gizlilik ve Güvenlik > Erişilebilirlik bölümüne gidin.
3. `TersFare` uygulamasını listede etkinleştirin.

Uygulamayı önce farklı bir klasörden çalıştırıp sonra `/Applications` klasörüne taşıdıysanız, eski izin kaydını kaldırıp `/Applications/TersFare.app` için tekrar izin vermeniz gerekebilir.

## Otomatik Açılış

Mac açıldığında TersFare otomatik başlasın istiyorsanız:

1. Sistem Ayarları > Genel > Giriş Öğeleri bölümünü açın.
2. `TersFare.app` uygulamasını giriş öğelerine ekleyin.

Bu adımdan sonra uygulama her oturum açıldığında menü çubuğunda otomatik çalışır.

## Kullanım

Uygulama açıldığında menü çubuğunda `↕` simgesi görünür.

Menüden şunları yapabilirsiniz:

- Durumu kontrol etmek.
- Fare ters çevirmeyi açıp kapatmak.
- Erişilebilirlik ayarlarını açmak.
- Olay dinleyicisini yeniden denemek.
- Uygulamadan çıkmak.

## Kaldırma

Uygulamayı kaldırmak için:

1. Menü çubuğundaki `↕` simgesinden Çık seçeneğini kullanın.
2. `/Applications/TersFare.app` dosyasını silin.
3. Sistem Ayarları > Gizlilik ve Güvenlik > Erişilebilirlik bölümünden `TersFare` kaydını kaldırın.
4. Giriş Öğeleri'ne eklediyseniz oradan da kaldırın.

## Teknik Çalışma Mantığı

TersFare, macOS'in Quartz Event Services altyapısını kullanarak kaydırma olaylarını dinler.

Uygulama sadece `scrollWheel` olaylarıyla ilgilenir. Bir kaydırma olayının sürekli olup olmadığını kontrol eder:

- İzleme dörtgenleri ve Magic Mouse gibi dokunmatik yüzeyli cihazlar genellikle sürekli kaydırma olayı üretir.
- Klasik tekerlekli fareler genellikle kesikli kaydırma olayı üretir.

TersFare yalnızca kesikli, tekerlek tipi olaylarda dikey eksen değerini ters çevirir. Bu sayede izleme dörtgeni kaydırması olduğu gibi kalır.

## Sınırlar

- Uygulama klasik tekerlekli fareler için tasarlandı.
- Magic Mouse gibi dokunmatik yüzeyli fareler macOS tarafından izleme dörtgenine benzer sürekli olaylar olarak algılanabilir; bu durumda ters çevrilmeyebilir.
- Uygulama yatay kaydırmayı değiştirmez.
- Uygulama kaydırma hızını veya ivmesini değiştirmez.
- macOS güvenlik modeli nedeniyle Erişilebilirlik izni olmadan çalışmaz.

## Sorun Giderme

### Menü çubuğunda simge görünüyor ama fare yönü değişmiyor

Erişilebilirlik izninin açık olduğundan emin olun. Uygulama `/Applications` klasörüne taşındıysa izni tekrar vermeniz gerekebilir.

### Uygulama "izin bekleniyor" durumunda kalıyor

Menüden "Erişilebilirlik iznini aç" seçeneğini kullanın. İzni verdikten sonra menüden "Yeniden dene" seçeneğine basın veya uygulamayı kapatıp tekrar açın.

### İzleme dörtgeni de ters dönüyor gibi hissediliyor

Sistem Ayarları > İzleme Dörtgeni > Kaydırma ve Büyütme bölümünde Doğal Kaydırma ayarını kontrol edin. Bu uygulamanın beklenen kurulumu, izleme dörtgeninde doğal kaydırmanın açık olmasıdır.

### Magic Mouse ile çalışmıyor

Magic Mouse klasik tekerlekli fare gibi davranmaz. macOS onu sürekli kaydırma üreten dokunmatik bir cihaz gibi ele alabilir. Bu uygulama özellikle klasik tekerlekli fareleri hedefler.

## Geliştirme

Kaynak kodu:

```text
Sources/TersFare/main.swift
```

Uygulamayı yeniden üretmek için:

```zsh
./build.sh
```

Betik şunları yapar:

- `TersFare.app` paketini oluşturur.
- Swift kaynak kodunu derler.
- `Info.plist` dosyasını yazar.
- Uygulamayı yerel ad-hoc imzayla imzalar.

## Gizlilik

TersFare yerel çalışır. Ağ isteği yapmaz, kullanıcı verisi saklamaz, telemetri veya analiz göndermez. Sadece macOS'in kaydırma olaylarını çalışma anında işler.

## Lisans

Bu repo için henüz açık kaynak lisansı seçilmedi.
