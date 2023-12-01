import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:pawsitive/screens/location_screen.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});
  static const id = 'email-ver';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Verify Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const Text(
              'Check your email to verify your registered Email',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                    ),
                    onPressed: () async {
                      var result = await OpenMailApp.openMailApp();

                      // If no mail apps found, show error
                      if (!result.didOpen && !result.canOpen) {
                        // ignore: use_build_context_synchronously
                        showNoMailAppsDialog(context);

                        // iOS: if multiple mail apps found, show dialog to select.
                        // There is no native intent/default app system in iOS so
                        // you have to do it yourself.
                      } else if (!result.didOpen && result.canOpen) {
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (_) {
                            return MailAppPickerDialog(
                              mailApps: result.options,
                            );
                          },
                        );
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, LocationScreen.id);
                    },
                    child: const Text('Verify Email'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
