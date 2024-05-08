import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:vibration/vibration.dart';

class BlindTutorialScreen extends StatelessWidget {

  static const String routeName = "/volunteerTutorialScreen";
  final FlutterTts flutterTTs = FlutterTts();

  final String allText = """
Çağrı Gönderin
Yoldaş'ta Hızlı Arama ve Özel Arama şeklinde iki farklı arama seçeneği vardır. İlgili butonlar girişte açılan Arama sayfasında bulunur.
1- Hızlı Arama: Bu arama seçeneği, sizi en kısa zamanda en uygun gönüllü kullanıcı ile eşleştirmeyi sağlar.
2- Özel Arama: Bu arama seçeneği, aramanızı belli bir kategoride özelleştirmenizi sağlar. İlgili butona tıkladığınızda karşınıza 'Gönüllü Ara' ve 'Görme Engelli Ara' butonları çıkacaktır.
2.1- Gönüllü Özel Arama: 'Gönüllü Ara' butonuna tıkladığınızda karşınıza Sağlık, Müzik, Aşçılık gibi kategorileri seçmeyi sağlayan bir menü çıkar. İlgili kategoriyi seçtikten sonra 'Aramayı Başlat' butonuna tıklayarak aramanızı başlatabilirsiniz.
2.2- Görme Engelli Arama: 'Görme Engelli Ara' seçeneği ile diğer görme engellilerden destek alabilirsiniz.
Yapay Zeka Modellerini Kullanın
Yoldaş'ta Para tanıma, Resim tanıma, Metin tanıma ve Belge tanıma olmak üzere dört farklı yapay zeka modeli bulunmaktadır. Bu modelleri kullanarak çevrenizdeki nesneleri tanıyabilir, metinleri okuyabilir ve belgelerinizi tarayabilirsiniz.
1- Yapay zeka sayfasına gitmek için 'Yapay Zeka' sekmesine tıklayın.
2- İlgili modeli seçtikten sonra 'Modeli Başlat' butonuna tıklayarak kamerayı aktif hale getirin.
3- Modeli kullanmak için kameranızı ilgili nesneye tutun ve ekrana dokunarak resmini çekin. Model, nesneyi tanıyarak size sesli geri bildirimde bulunacaktır.
Profilinizi düzenleyin
1- Ayarlardan Profil'e tıklayın.'
2- Profil bilgilerinizi düzenleyin
3- Profil bilgilerinizi güncellemek için 'Kaydet' butonuna tıklayın
Görme Engellilere Danışmanlık Yapın
1- Profil sayfasından danışmanlık durumunu aktif ederek destek almak veya sohbet etmek isteyen kişilere yardımcı olabilirsiniz.
2- Çağrı geldiğinde yanıtlamak için 'Kabul et' butonuna tıklayın
3- Eğer müsait değilseniz 'Reddet' butonuna tıklayabilirsiniz. Bu durumda başka bir görme engelli ile bağlantı kurulur.
Talkback ile Kullanın
1- Uygulamayı daha rahat kullanabilmek için Talkback özelliğini aktif hale getirebilirsiniz. Talkback özelliği, uygulamadaki tüm butonları ve metinleri sesli olarak okur. Bu sayede uygulamayı daha rahat kullanabilirsiniz.
2- Uygulamanın 'Ayarlar' sayfasından 'Erişilebilirlik' sekmesine tıklayın. Bu sizi telefonunuzdaki Erişilebilirlik ayarlarına yönlendirecektir.
3- Erişilebilirlik ayarlarından TalkBack'i etkinleştiriniz
4- Daha sonra Talkback metin okuma ayarlarından Google Ses Tanıma Hizmetini seçiniz. Ardından Dili Türkçe olarak seçiniz.
""";

  @override
  Widget build(BuildContext context) {
    flutterTTs.speak("Kullanım kılavuzu sayfasına hoş geldiniz. Uygulamayı daha iyi anlamanız için bu sayfada uygulamanın nasıl kullanılacağı hakkında bilgiler bulunmaktadır. Ekrana uzun basılı tutarak kılavuzu dinleyebilirsiniz. Çift tıklayarak kılavuzu durdurabilirsiniz.");
    return Scaffold(
      appBar: AppbarCustom(
        title: "Nasıl Kullanılır?",),

      body: SingleChildScrollView(
        child: Container(
          decoration: getBackgroundDecoration(),
          padding: EdgeInsets.all(20),
          child: GestureDetector(
            onLongPress: () {
              Vibration.vibrate(duration: 100);
              flutterTTs.speak(allText);
            },
            onDoubleTap: () {
              Vibration.vibrate(duration: 100);
              flutterTTs.stop();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                Text("Çağrı Gönderin", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: textColorLight
                ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      child: Image.asset("assets/blind_tutorial_1.png", alignment: Alignment.center,),
                    ),
                    Container(
                      height: 150,
                      width: 150,
                      child: Image.asset("assets/blind_tutorial_2.png", alignment: Alignment.center,),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "Yoldaş'ta Hızlı Arama ve Özel Arama şeklinde iki farklı arama seçeneği vardır. İlgili butonlar girişte açılan Arama sayfasında bulunur.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "1- Hızlı Arama: Bu arama seçeneği, sizi en kısa zamanda en uygun gönüllü kullanıcı ile eşleştirmeyi sağlar.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "2- Özel Arama: Bu arama seçeneği, aramanızı belli bir kategoride özelleştirmenizi sağlar. İlgili butona tıkladığınızda karşınıza 'Gönüllü Ara' ve 'Görme Engelli Ara' butonları çıkacaktır.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "2.1- Gönüllü Özel Arama: 'Gönüllü Ara' butonuna tıkladığınızda karşınıza Sağlık, Müzik, Aşçılık gibi kategorileri seçmeyi sağlayan bir menü çıkar. İlgili kategoriyi seçtikten sonra 'Aramayı Başlat' butonuna tıklayarak aramanızı başlatabilirsiniz.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "2.2- Görme Engelli Arama: 'Görme Engelli Ara' seçeneği ile diğer görme engellilerden destek alabilirsiniz.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),

                Text("Yapay Zeka Modellerini Kullanın", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: textColorLight
                ),),
                Image.asset("assets/blind_tutorial_3.png", alignment: Alignment.center,),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "Yoldaş'ta Para tanıma, Resim tanıma, Metin tanıma ve Belge tanıma olmak üzere dört farklı yapay zeka modeli bulunmaktadır. Bu modelleri kullanarak çevrenizdeki nesneleri tanıyabilir, metinleri okuyabilir ve belgelerinizi tarayabilirsiniz.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "1- Yapay zeka sayfasına gitmek için 'Yapay Zeka' sekmesine tıklayın.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "2- İlgili modeli seçtikten sonra 'Modeli Başlat' butonuna tıklayarak kamerayı aktif hale getirin.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text(
                    "3- Modeli kullanmak için kameranızı ilgili nesneye tutun ve ekrana dokunarak resmini çekin. Model, nesneyi tanıyarak size sesli geri bildirimde bulunacaktır.",
                    style: TextStyle(fontSize: 14, color: textColorLight),
                  ),
                ),

                SizedBox(height: 20,),

                Text("Profilinizi düzenleyin", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: textColorLight
                ),),
                Image.asset("assets/tutorial_2.png", alignment: Alignment.center,),
                Text("1- Ayarlardan Profil'e tıklayın.'", style: TextStyle(fontSize: 14, color: textColorLight
                ),),
                Text("2- Profil bilgilerinizi düzenleyin", style: TextStyle(fontSize: 14, color: textColorLight
                ),),
                Text("3- Profil bilgilerinizi güncellemek için 'Kaydet' butonuna tıklayın", style: TextStyle(fontSize: 14, color: textColorLight
                ),),

                SizedBox(height: 20,),

                Text("Görme Engellilere Danışmanlık Yapın", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: textColorLight
                ),),
                Image.asset("assets/tutorial_3.png", alignment: Alignment.center,),
                Text("1- Profil sayfasından danışmanlık durumunu aktif ederek destek almak veya sohbet etmek isteyen kişilere yardımcı olabilirsiniz.",
                  style: TextStyle(fontSize: 14, color: textColorLight
                  ),),
                Text("2- Çağrı geldiğinde yanıtlamak için 'Kabul et' butonuna tıklayın", style: TextStyle(fontSize: 14, color: textColorLight
                ),),
                Text("3- Eğer müsait değilseniz 'Reddet' butonuna tıklayabilirsiniz. Bu durumda başka bir görme engelli ile bağlantı kurulur.", style: TextStyle(fontSize: 14, color: textColorLight
                ),),

                SizedBox(height: 20,),

                Text("Talkback ile Kullanın", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: textColorLight
                ),),
                Container(
                  margin: EdgeInsets.only(bottom: 8.0), // Adjust margin as needed
                  child: Text("Uygulamayı daha rahat kullanabilmek için Talkback özelliğini aktif hale getirebilirsiniz. Talkback özelliği, uygulamadaki tüm butonları ve metinleri sesli olarak okur. Bu sayede uygulamayı daha rahat kullanabilirsiniz.",
                    style: TextStyle(fontSize: 14, color: textColorLight
                    ),),
                ),
                Text("1- Uygulamanın 'Ayarlar' sayfasından 'Erişilebilirlik' sekmesine tıklayın. Bu sizi telefonunuzdaki Erişilebilirlik ayarlarına yönlendirecektir." , style: TextStyle(fontSize: 14, color: textColorLight
                ),),
                Text("2- Erişilebilirlik ayarlarından TalkBack'i etkinleştiriniz", style: TextStyle(fontSize: 14, color: textColorLight
                ),),
                Text("3- Daha sonra Talkback metin okuma ayarlarından Google Ses Tanıma Hizmetini seçiniz. Ardından Dili Türkçe olarak seçiniz.", style: TextStyle(fontSize: 14, color: textColorLight
                ),),
              ],
            ),
          ),
        ),
      ),
    );


  }
}
