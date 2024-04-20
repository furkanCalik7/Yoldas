import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';

class VolunteerTutorialScreen extends StatelessWidget {
  const VolunteerTutorialScreen({Key? key}) : super(key: key);

  static const String routeName = "/volunteerTutorialScreen";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Yeteneklerinizi seçin", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: textColorLight
            ),),
            Image.asset("assets/tutorial_1.png", alignment: Alignment.center,),
            Text("1- Ayarlardan Yeteneklerim'e tıklayın.'", style: TextStyle(fontSize: 14, color: textColorLight
            ),),
            Text("2- Yeteneğizi seçtikten sonra 'Ekle' butonuna tıklayın", style: TextStyle(fontSize: 14, color: textColorLight
            ),),
            Text("3- Yetenek seçme işlemini tamamlamak için 'Kaydet' butonuna tıklayın", style: TextStyle(fontSize: 14, color: textColorLight
            ),),
        
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

            Text("Çağrıları yanıtlayın", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: textColorLight
            ),),
            Image.asset("assets/tutorial_3.png", alignment: Alignment.center,),
            Text("1- Görme engelli bir kişi yardım talep ettiğinde, "
                "gönüllü kullanıcılar arasından uygun olanlar seçilir ve çağrı gönderilir.",
              style: TextStyle(fontSize: 14, color: textColorLight
            ),),
            Text("2- Çağrıyı yanıtlamak için 'Kabul et' butonuna tıklayın", style: TextStyle(fontSize: 14, color: textColorLight
            ),),
            Text("3- Eğer müsait değilseniz 'Reddet' butonuna tıklayabilirsiniz. Bu durumda başka bir gönüllü ile bağlantı kurulur.", style: TextStyle(fontSize: 14, color: textColorLight
            ),),
          ],
        ),
        ),
    );
        

  }
}
