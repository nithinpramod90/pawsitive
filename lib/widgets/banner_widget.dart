import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:pawsitive/donation_item/product_by_category_screen.dart';
import 'package:pawsitive/services/firebase_services.dart';
import 'package:pawsitive/screens/provider/cat_provider.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var catProvider = Provider.of<CategoryProvider>(context);
    FirebaseService service = FirebaseService();

    return FutureBuilder<QuerySnapshot>(
        future: service.categories.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          // Assuming you want to use the first document in your categories collection
          // ignore: unused_local_variable
          var doc = snapshot.data!.docs.first;
          return Neumorphic(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .25,
              color: const Color(0xFF846A85),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 100.0,
                                child: DefaultTextStyle(
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    isRepeatingAnimation: true,
                                    animatedTexts: [
                                      FadeAnimatedText(
                                        'Adopt and donate \nto give dogs and \ncats loving homes, \nand help prevent \nstrays.',
                                        duration: const Duration(seconds: 4),
                                      ),
                                      FadeAnimatedText(
                                        "The best things in \nlife are rescued.",
                                        duration: const Duration(seconds: 4),
                                      ),
                                      FadeAnimatedText(
                                        "Don't shop. Adopt.",
                                        duration: const Duration(seconds: 4),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Neumorphic(
                            style: const NeumorphicStyle(
                              color: Colors.white,
                              oppositeShadowLightSource: true,
                            ),
                            child: SizedBox(
                              width: 170,
                              child: Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/pawsitive-6323c.appspot.com/o/banner%2Fbanner.png?alt=media&token=c6b4498e-92e6-4fdb-993b-d48fadc54859',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: NeumorphicButton(
                            onPressed: () {
                              String categoryName = 'Dogs'; // Assuming this is the correct way to get the category name as a String

                              catProvider.getCategory(categoryName);
                              Navigator.pushNamed(context, ProductByCategory.id);
                            },
                            style: const NeumorphicStyle(color: Colors.white),
                            child: const Text(
                              'Dogs',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: NeumorphicButton(
                            onPressed: () {
                              String categoryName = 'Cats'; // Assuming this is the correct way to get the category name as a String

                              catProvider.getCategory(categoryName);
                              Navigator.pushNamed(context, ProductByCategory.id);
                            },
                            style: const NeumorphicStyle(color: Colors.white),
                            child: const Text(
                              'Cats',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
