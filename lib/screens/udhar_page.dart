import 'package:cashcounter/provider/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class UdharPage extends ConsumerStatefulWidget {
  const UdharPage({Key? key, this.data, required this.currentUid})
      : super(key: key);
  final dynamic data;
  final String? currentUid;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UdharPageState();

  // @override
  // State<UdharPage> createState() => _UdharPageState();
}

class _UdharPageState extends ConsumerState<UdharPage> {
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  NumberFormat numberFormat = NumberFormat.decimalPattern('hi');

  late DateTime date = DateTime.now();
  TextEditingController amountController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  num sum = 0;
  num cr = 0;
  num dr = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firestore
        .collection("users")
        .doc(_auth.currentUser?.uid)
        .collection("udhar")
        .doc(widget.currentUid)
        .collection("creditanddebit")
        .where('date',
            isLessThanOrEqualTo: DateTime.now().add(Duration(days: 20)))
        .snapshots()
        .listen((event) async {
      sum = 0;
      cr = 0;
      dr = 0;
      for (var element in event.docs) {
        if (mounted) {
          if (element.data()['type'] == 'credit') {
            setState(() {
              cr += element.data()['amount'];
            });
          } else if (element.data()['type'] == 'debit') {
            setState(() {
              dr += element.data()['amount'];
            });
          }
          setState(() {
            sum += element.data()['amount'];
          });
        }
      }
      var d = ref
          .read(databaseProvider)
          .checkDrCrBalance(widget.currentUid, cr, dr);
      d.then((value) => {
            if (value)
              {
                _firestore
                    .collection("users")
                    .doc(_auth.currentUser?.uid)
                    .collection("udhar")
                    .doc(widget.currentUid)
                    .update({
                  "credit": cr,
                  "debit": dr,
                  "closebalance": sum,
                })
              }
          });

      // print(await ref
      //     .read(databaseProvider)
      //     .checkDrCrBalance(widget.currentUid, cr, dr));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(100, 50),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          widget.data['name'].substring(0, 1),
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        backgroundColor: Color(
                                (math.Random().nextDouble() * 0xFFFFFF).toInt())
                            .withOpacity(1.0),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.data['name'],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            widget.data['number'],
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Spacer(flex: 1),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        // iconSize: 15,
                        icon: const Icon(Icons.filter_alt),
                        padding: EdgeInsets.all(0),
                      ),
                      IconButton(
                        onPressed: () {},
                        // iconSize: 15,
                        icon: Icon(Icons.menu),
                        padding: EdgeInsets.all(0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
            // create box decoration
            decoration: BoxDecoration(
              // set background color
              color: const Color.fromARGB(255, 153, 231, 164).withOpacity(0.2),
              // set the border
              border: const Border(
                top: BorderSide(
                  // set the width
                  width: 2.0,
                  // set the color
                  color: Colors.black,
                ),
              ),
            ),
            padding: const EdgeInsets.only(top: 5, bottom: 10),
            height: 70,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "Cr. ₹${numberFormat.format(cr)}",
                      style: TextStyle(
                          color: Color.fromARGB(255, 8, 95, 11),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Container(
                        height: 40, width: 95,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 8, 95, 11),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        // margin: const EdgeInsets.only(left: 5, right: 10),
                        child: IconButton(
                            onPressed: () async {
                              await creditndDebitDialog(context, database,
                                  "Credit Receive", false, "credit");
                            },
                            icon: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.download,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                Text(
                                  "Receive (in)",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                )
                              ],
                            )),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "Total Balanced",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Container(
                        height: 40, width: 95,
                        decoration: BoxDecoration(
                          // color: Color.fromARGB(255, 8, 95, 11),
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        // margin: const EdgeInsets.only(left: 5, right: 10),
                        child: IconButton(
                            onPressed: () {},
                            icon: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "₹${numberFormat.format(sum)}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.green[900],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                )
                              ],
                            )),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Dr. ₹${numberFormat.format(dr)}",
                      style: TextStyle(
                          color: Color.fromARGB(255, 234, 31, 27),
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Container(
                        height: 40, width: 95,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 234, 31, 27),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        // margin: const EdgeInsets.only(left: 5, right: 10),
                        child: IconButton(
                            onPressed: () async {
                              await creditndDebitDialog(context, database,
                                  "Credit Receive", true, "debit");
                            },
                            icon: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Give (Out)",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                ),
                                Icon(
                                  Icons.upload_sharp,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            )),
                      ),
                    )
                  ],
                )
              ],
            )),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: database.creditndDebita(widget.currentUid),
              builder: (context, snapshot) {
                //create loading spinner if data is not loaded
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Entry Not Found..! \n\nFirst, Do Any Entry",
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500));
                  } else {
                    // ignore: avoid_returning_null_for_void
                    setState(() => null);
                  }
                });
                //sum all the credit and debit amount
                // num sum1 = 0;
                // snapshot.data!.docs.forEach((element) {
                //   sum1 += element.data()["amount"];
                // });

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        var maindata = snapshot.data!.docs[index].data();
                        database.sum = 0;
                        database.sum += maindata["amount"];
                        if (maindata['type'] == 'credit') {
                          return getReceiverView(
                              clipper: ChatBubbleClipper5(
                                  type: BubbleType.sendBubble),
                              context: context,
                              Amount: maindata['amount'],
                              remark: maindata['remark'],
                              closingBalance: maindata['closebalance'],
                              date: maindata['date'].toDate(),
                              indexuid: snapshot.data!.docs[index].id,
                              database: database,
                              name: maindata['name'],
                              number: maindata['number'],
                              type: maindata['type']);
                        } else if (maindata['type'] == 'debit') {
                          return getSenderView(
                              ChatBubbleClipper5(
                                  type: BubbleType.receiverBubble),
                              context,
                              maindata['amount'],
                              maindata['remark'],
                              maindata['closebalance'],
                              maindata['date'].toDate());
                        }
                        return Text("No Data");
                      },
                    ),
                  ),
                );
              }),
        ));
  }

  creditndDebitDialog(BuildContext context, Database database, String text,
      bool minus, String type) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context,
                    void Function(void Function()) setState) =>
                AlertDialog(
              title: Center(child: Text(text)),
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Icon(Icons.payments)),
                          Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: amountController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]"))
                                  ],

                                  keyboardType: TextInputType.number,
                                  // controller:
                                  //     nameController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.currency_rupee,
                                    ),
                                    prefixIconConstraints: BoxConstraints(
                                      minWidth: 10,
                                      minHeight: 25,
                                    ),
                                    contentPadding: EdgeInsets.only(
                                        bottom: 0, right: 0, left: 5, top: 0),
                                    hintText: 'Enter Amount',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              )),
                          // Expanded(
                          //   flex: 1,
                          //   child: IconButton(
                          //       onPressed: () async {},
                          //       iconSize: 32,
                          //       color: Colors.blue[800],
                          //       icon: Icon(
                          //           Icons.contacts)),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Icon(Icons.sticky_note_2)),
                          Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  minLines: null,
                                  textInputAction: TextInputAction.newline,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  expands: true,
                                  // maxLength: 50,
                                  controller: remarkController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        bottom: 0, right: 0, left: 5, top: 0),
                                    hintText: 'Remark (अधिक माहिती)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          TextButton(
                              onPressed: () async {
                                DateTime? dateTime =
                                    await showOmniDateTimePicker(
                                  context: context,
                                  primaryColor: Colors.cyan,
                                  backgroundColor: Colors.blue,
                                  calendarTextColor: Colors.white,
                                  tabTextColor: Colors.white,
                                  unselectedTabBackgroundColor:
                                      Colors.grey[700],
                                  buttonTextColor: Colors.white,
                                  timeSpinnerTextStyle: const TextStyle(
                                      color: Colors.white70, fontSize: 18),
                                  timeSpinnerHighlightedTextStyle:
                                      const TextStyle(
                                          color: Colors.white, fontSize: 24),
                                  is24HourMode: false,
                                  isShowSeconds: false,
                                  startInitialDate: date,
                                  startFirstDate: DateTime(2020)
                                      .subtract(const Duration(days: 3652)),
                                  startLastDate: DateTime.now().add(
                                    const Duration(days: 3652),
                                  ),
                                  borderRadius: const Radius.circular(16),
                                );
                                setState(() {
                                  dateTime != null
                                      ? date = dateTime
                                      : date = DateTime.now();
                                });

                                // print(
                                //     DateFormat('EEEE').format(dateTime!).toString());
                                // // print(weeks['Saturday']);
                                // print(weeks[
                                //     DateFormat('EEEE').format(dateTime).toString()]);
                                // weeks.forEach((e) => print(e[DateFormat('EEEE')
                                //     .format(dateTime!)
                                //     .toString()]));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    dateFormat.format(date),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(DateFormat.jm().format(date).toString()),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                ],
                              )),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                await database
                                    .createCreditDebitAccount(
                                        number: widget.data['number'],
                                        name: widget.data['name'],
                                        currentUid: widget.currentUid,
                                        dateTime: date,
                                        closebalance: minus
                                            ? -int.parse(
                                                    amountController.text) +
                                                int.parse(sum.toString())
                                            : int.parse(amountController.text) +
                                                int.parse(sum.toString()),
                                        amount: minus
                                            ? -int.parse(amountController.text)
                                            : int.parse(amountController.text),
                                        remark: remarkController.text,
                                        type: type)
                                    .whenComplete(() {
                                  amountController.clear();
                                  remarkController.clear();
                                  Navigator.pop(context);
                                });
                              },
                              iconSize: 30,
                              color: Colors.green[800],
                              icon: Icon(Icons.check_box),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  updatecreditndDebitDialog(
      BuildContext context,
      Database database,
      String text,
      bool minus,
      String type,
      docuid,
      closingBalance,
      amount) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context,
                    void Function(void Function()) setState) =>
                AlertDialog(
              title: Center(child: Text(text)),
              content: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Icon(Icons.payments)),
                          Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: amountController,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]"))
                                  ],

                                  keyboardType: TextInputType.number,
                                  // controller:
                                  //     nameController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.currency_rupee,
                                    ),
                                    prefixIconConstraints: BoxConstraints(
                                      minWidth: 10,
                                      minHeight: 25,
                                    ),
                                    contentPadding: EdgeInsets.only(
                                        bottom: 0, right: 0, left: 5, top: 0),
                                    hintText: 'Enter Amount',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              )),
                          // Expanded(
                          //   flex: 1,
                          //   child: IconButton(
                          //       onPressed: () async {},
                          //       iconSize: 32,
                          //       color: Colors.blue[800],
                          //       icon: Icon(
                          //           Icons.contacts)),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Icon(Icons.sticky_note_2)),
                          Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  minLines: null,
                                  textInputAction: TextInputAction.newline,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  expands: true,
                                  // maxLength: 50,
                                  controller: remarkController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        bottom: 0, right: 0, left: 5, top: 0),
                                    hintText: 'Remark (अधिक माहिती)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          TextButton(
                              onPressed: () async {
                                DateTime? dateTime =
                                    await showOmniDateTimePicker(
                                  context: context,
                                  primaryColor: Colors.cyan,
                                  backgroundColor: Colors.blue,
                                  calendarTextColor: Colors.white,
                                  tabTextColor: Colors.white,
                                  unselectedTabBackgroundColor:
                                      Colors.grey[700],
                                  buttonTextColor: Colors.white,
                                  timeSpinnerTextStyle: const TextStyle(
                                      color: Colors.white70, fontSize: 18),
                                  timeSpinnerHighlightedTextStyle:
                                      const TextStyle(
                                          color: Colors.white, fontSize: 24),
                                  is24HourMode: false,
                                  isShowSeconds: false,
                                  startInitialDate: date,
                                  startFirstDate: DateTime(2020)
                                      .subtract(const Duration(days: 3652)),
                                  startLastDate: DateTime.now().add(
                                    const Duration(days: 3652),
                                  ),
                                  borderRadius: const Radius.circular(16),
                                );
                                setState(() {
                                  dateTime != null
                                      ? date = dateTime
                                      : date = DateTime.now();
                                });

                                // print(
                                //     DateFormat('EEEE').format(dateTime!).toString());
                                // // print(weeks['Saturday']);
                                // print(weeks[
                                //     DateFormat('EEEE').format(dateTime).toString()]);
                                // weeks.forEach((e) => print(e[DateFormat('EEEE')
                                //     .format(dateTime!)
                                //     .toString()]));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    dateFormat.format(date),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(DateFormat.jm().format(date).toString()),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                ],
                              )),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () async {
                                print(((int.parse(amountController.text) -
                                        amount) +
                                    closingBalance) as int);
                                print(closingBalance);
                                database.updateCreditDebitAccount(
                                    number: widget.data['number'],
                                    name: widget.data['name'],
                                    currentUid: widget.currentUid,
                                    dateTime: date,
                                    closebalance:
                                        ((int.parse(amountController.text) -
                                                amount) +
                                            closingBalance) as int,
                                    amount: minus
                                        ? -int.parse(amountController.text)
                                        : int.parse(amountController.text),
                                    remark: remarkController.text,
                                    type: type,
                                    docuid: docuid);
                                // await database
                                //     .createCreditDebitAccount(
                                //         number: widget.data['number'],
                                //         name: widget.data['name'],
                                //         currentUid: widget.currentUid,
                                //         dateTime: date,
                                //         closebalance: minus
                                //             ? -int.parse(
                                //                     amountController.text) +
                                //                 int.parse(sum.toString())
                                //             : int.parse(amountController.text) +
                                //                 int.parse(sum.toString()),
                                //         amount: minus
                                //             ? -int.parse(amountController.text)
                                //             : int.parse(amountController.text),
                                //         remark: remarkController.text,
                                //         type: type)
                                //     .whenComplete(() {
                                //   amountController.clear();
                                //   remarkController.clear();
                                //   Navigator.pop(context);
                                // });
                              },
                              iconSize: 30,
                              color: Colors.green[800],
                              icon: Icon(Icons.check_box),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  getTitleText(String title) => Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      );

  getSenderView(CustomClipper clipper, BuildContext context, int Amount,
          String remark, int closingBalance, DateTime date) =>
      ChatBubble(
        clipper: clipper,
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 10),
        backGroundColor: Colors.grey[50],
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          // width: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (remark != "")
                      ? Text(remark, style: TextStyle(color: Colors.black))
                      : Container(),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "₹${numberFormat.format(Amount)}",
                    style: TextStyle(color: Colors.red[900]),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Cls BL: ₹${numberFormat.format(closingBalance)}",
                    style: TextStyle(
                        color: (closingBalance == 0)
                            ? Colors.black
                            : (closingBalance.toString().contains("-"))
                                ? Colors.red[900]
                                : Colors.green,
                        fontSize: 10),
                  ),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(date),
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        DateFormat.jm().format(date).toString(),
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                constraints: BoxConstraints(maxWidth: 20),
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                ),
                padding: EdgeInsets.all(0),
              )
            ],
          ),
        ),
      );

  getReceiverView(
          {required CustomClipper clipper,
          required BuildContext context,
          required int Amount,
          required String remark,
          required int closingBalance,
          required DateTime date,
          required String indexuid,
          required Database database,
          required String type,
          required String name,
          required String number}) =>
      ChatBubble(
        clipper: clipper,
        backGroundColor: Color(0xffE7E7ED),
        margin: EdgeInsets.only(top: 10),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (remark != "")
                      ? Text(
                          remark,
                          style: TextStyle(color: Colors.black),
                          maxLines: 4,
                        )
                      : Container(),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "₹${numberFormat.format(Amount)}",
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Cls BL: ₹${numberFormat.format(closingBalance)}",
                    style: TextStyle(
                        color: (closingBalance == 0)
                            ? Colors.black
                            : (closingBalance.toString().contains("-"))
                                ? Colors.red[900]
                                : Colors.green,
                        fontSize: 10),
                  ),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(date),
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        DateFormat.jm().format(date).toString(),
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              // IconButton(
              //   constraints: BoxConstraints(maxWidth: 20),
              //   onPressed: () {},
              //   icon: Icon(
              //     Icons.more_vert,
              //   ),
              //   padding: EdgeInsets.all(0),
              // ),
              popupMenu(
                  amount: Amount,
                  currentUid: indexuid,
                  database: database,
                  closebalance: closingBalance,
                  dateTime: date,
                  remark: remark,
                  type: type,
                  name: name,
                  number: number,
                  indexuid: indexuid),
            ],
          ),
        ),
      );
  PopupMenuButton<Menu> popupMenu(
      {required Database database,
      number,
      required String currentUid,
      required String type,
      required int amount,
      required String remark,
      required int closebalance,
      required String name,
      required DateTime dateTime,
      required indexuid}) {
    return PopupMenuButton<Menu>(
        padding: const EdgeInsets.all(0),
        icon: const Icon(
          Icons.more_vert,
          color: Colors.black,
        ),
        // Callback that sets the selected popup menu item.
        // onSelected: (Menu item) {
        //   setState(() {
        //     _selectedMenu = item.name;
        //   });
        //   print("Selected menu ${item.name}");
        // },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                value: Menu.atoz,
                onTap: () async {
                  amountController.text = amount.toString();
                  remarkController.text = remark;
                  date = dateTime;
                  Future.delayed(Duration(milliseconds: 500), () async {
                    await updatecreditndDebitDialog(
                        context,
                        database,
                        "Credit Receive",
                        false,
                        "credit",
                        indexuid,
                        closebalance,
                        amount);
                  });
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Edit Entry'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.debit,
                child: Row(
                  children: const [
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Share Entry'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                onTap: () async {
                  Future.delayed(Duration(milliseconds: 500), () async {
                    await database.deleteCreditDebitAccount(
                        currentUid: widget.currentUid, docuid: indexuid);
                  });
                },
                value: Menu.credit,
                child: Row(
                  children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Delete Entry'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                onTap: () {
                  Future.delayed(Duration(milliseconds: 500), () async {
                    await database.convertDebitToCredit(
                        currentUid: widget.currentUid,
                        docuid: indexuid,
                        type: "debit",
                        amount: amount,
                        closebalance: closebalance);
                  });
                },
                value: Menu.time,
                child: Row(
                  children: const [
                    Icon(
                      Icons.sync,
                      color: Colors.cyan,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Convert to Debit'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.time,
                child: Row(
                  children: const [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.deepOrange,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('PDF Invoice Receipt'),
                  ],
                ),
              ),
            ]);
  }
}
