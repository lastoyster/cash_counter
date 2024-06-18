import 'package:cashcounter/main.dart';
import 'package:cashcounter/provider/auth_provider.dart';
import 'package:cashcounter/screens/calculator.dart';
import 'package:cashcounter/screens/cashcount.dart';
import 'package:cashcounter/screens/creditdebit.dart';
import 'package:cashcounter/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthClass authClass = AuthClass();
    final _auth = ref.watch(authenticationProvider);

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size(100, 90),
          child: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      onPressed: () async {
                        await _auth.signOut();

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => const MyApp()),
                            (route) => false); // await authClass.logout();
                        await Fluttertoast.showToast(msg: "Logged Out");
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.black),
                      )),
                ),
              ],
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Calculator',
                ),
                Tab(
                  text: 'Cash Count',
                ),
                Tab(
                  text: 'Credit-Debit',
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // Expanded(
            //     child: DefaultTabController(
            //         length: 3,
            //         initialIndex: 0,
            //         child: Column(
            //           children: [
            //             const TabBar(
            //               tabs: [
            //                 Tab(
            //                   text: 'Calculator',
            //                 ),
            //                 Tab(
            //                   text: 'Cash Count',
            //                 ),
            //                 Tab(
            //                   text: 'Credit-Debit',
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ))),

            Expanded(
                child: TabBarView(children: [
              Calculator(),
              CashCounter(),
              Credit(),
            ]))
          ],
        ),
      ),
    );
  }
}
