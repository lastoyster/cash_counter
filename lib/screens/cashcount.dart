import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CashCounter extends StatefulWidget {
  const CashCounter({Key? key}) : super(key: key);

  @override
  State<CashCounter> createState() => _CashCounterState();
}

enum Menu { itemOne, itemTwo, itemThree, itemFour }

class _CashCounterState extends State<CashCounter> {
  var payerString = "<--- Enter The Amount Tally Payer";
  var calNum = 0;
  var notes = 0;
  var text = "";
  var plus = 0;
  var minus = 0;
  final FlutterTts tts = FlutterTts();

  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  String? selectedValue;

  late String _selectedMenu;
  List<TextEditingController> _controllers = [];
  TextEditingController plusCon = TextEditingController();
  TextEditingController minusCon = TextEditingController();
  TextEditingController nameCon = TextEditingController();
  TextEditingController mobCon = TextEditingController();
  TextEditingController acCon = TextEditingController();
  TextEditingController remarkCon = TextEditingController();

  late String name;
  late String ac;

  late String remark;
  late String mobNum;
  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    List<DropdownMenuItem<String>> _menuItems = [];
    for (var item in items) {
      _menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return _menuItems;
  }

  List<int> _getDividersIndexes() {
    List<int> _dividersIndexes = [];
    for (var i = 0; i < (items.length * 2) - 1; i++) {
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        _dividersIndexes.add(i);
      }
    }
    return _dividersIndexes;
  }

  List listNotes = [
    "2000",
    "500",
    "200",
    "100",
    "50",
    "20",
    "10",
    "5",
    "2",
    "1"
  ];
  List<Map<String, String>> listNotesCal = [
    {"2000": "0"},
    {"500": "0"},
    {"200": "0"},
    {"100": "0"},
    {"50": "0"},
    {"20": "0"},
    {"10": "0"},
    {"5": "0"},
    {"2": "0"},
    {"1": "0"}
  ];
  List<Map<String, String>> noteCal = [
    {"2000": "0"},
    {"500": "0"},
    {"200": "0"},
    {"100": "0"},
    {"50": "0"},
    {"20": "0"},
    {"10": "0"},
    {"5": "0"},
    {"2": "0"},
    {"1": "0"}
  ];
  TextEditingController controller = TextEditingController(
    text: '',
  );
  Map<String, String> weeks = {
    "Sunday": "रविवार ",
    "Monday": "सोमवार ",
    "Tuesday": "मंगलवार ",
    "Wednesday": "बुधवार ",
    "Thursday": "गुरुवार ",
    "Friday": "शुक्रवार ",
    "Saturday": "शनिवार "
  };
  late DateTime date = DateTime.now();
  // @override
  // void setState(VoidCallback fn) {
  //   // TODO: implement setState
  //   super.setState(fn);
  //   controller.addListener(() {
  //     setState(() {
  //       payerString = controller.text;
  //     });
  //   });
  //   listNotesCal.forEach((element) {
  //     element.forEach((key, value) {
  //       setState(() {
  //         calNum += int.parse(value);
  //       });
  //     });
  //   });

  //   print(calNum);
  // }
  @override
  void initState() {
    super.initState();
    tts.setLanguage('en');

    controller.addListener(() {
      if (controller.text.isEmpty) {
        setState(() {
          payerString = "<--- Enter The Amount Tally Payer";
        });
      } else if (calNum > int.parse(controller.text)) {
        setState(() {
          payerString = "Greater By +₹${calNum - int.parse(controller.text)}";
        });
      } else {
        setState(() {
          payerString =
              "Less By -₹${(calNum - int.parse(controller.text)).abs()}";
        });
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    calNum = 0;
    notes = 0;

    for (var element in listNotesCal) {
      element.forEach((key, value) {
        calNum += int.parse(value.toString());
      });
    }
    for (var element in noteCal) {
      element.forEach((key, value) {
        notes += int.parse(value.toString());
      });
    }
    calNum = calNum + plus;
    calNum = calNum - minus;
  }

  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: SizedBox(
          height: 115,
          child: Column(
            children: [
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: 35,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: IconButton(
                        onPressed: () async {
                          tts.stop();
                          await tts.speak(NumberToWordsEnglish.convert(calNum));
                        },
                        icon: const Icon(Icons.history),
                        iconSize: 20,
                        color: Colors.white,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                          weeks[DateFormat('EEEE').format(date)].toString())),
                  Expanded(
                    flex: 3,
                    child: TextButton(
                        onPressed: () async {
                          DateTime? dateTime = await showOmniDateTimePicker(
                            context: context,
                            primaryColor: Colors.cyan,
                            backgroundColor: Colors.blue,
                            calendarTextColor: Colors.white,
                            tabTextColor: Colors.white,
                            unselectedTabBackgroundColor: Colors.grey[700],
                            buttonTextColor: Colors.white,
                            timeSpinnerTextStyle: const TextStyle(
                                color: Colors.white70, fontSize: 18),
                            timeSpinnerHighlightedTextStyle: const TextStyle(
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
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(DateFormat('EEEE').format(date).toString()))
                ],
              ),
              const Divider(),
              SizedBox(
                height: 30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 8, top: 8),
                              decoration: const BoxDecoration(
                                // border: Border.all(color: Colors.blue, width: 1),
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: const Center(
                                  child: Text(
                                "Scr Shot",
                                style: TextStyle(color: Colors.white),
                              ))),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 8, top: 8),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 0, 74, 159),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: const Center(
                                  child: Text(
                                "Income/Expense",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 8, top: 8),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 9, 120, 12),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: const Center(
                                child: Text(
                                  "Share",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        elevation: 0,
      ),
      body: FooterLayout(
        footer: SizedBox(
          height: 145,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: 35,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            calNum = 0;
                            notes = 0;
                            listNotesCal = [
                              {"2000": "0"},
                              {"500": "0"},
                              {"200": "0"},
                              {"100": "0"},
                              {"50": "0"},
                              {"20": "0"},
                              {"10": "0"},
                              {"5": "0"},
                              {"2": "0"},
                              {"1": "0"}
                            ];
                            noteCal = [
                              {"2000": "0"},
                              {"500": "0"},
                              {"200": "0"},
                              {"100": "0"},
                              {"50": "0"},
                              {"20": "0"},
                              {"10": "0"},
                              {"5": "0"},
                              {"2": "0"},
                              {"1": "0"}
                            ];
                            plus = 0;
                            minus = 0;
                            controller.clear();
                            nameCon.clear();
                            acCon.clear();
                            remarkCon.clear();
                            mobCon.clear();
                            plusCon.clear();
                            minusCon.clear();

                            for (var element in _controllers) {
                              element.clear();
                            }
                          });

                          Fluttertoast.showToast(msg: "Cleared");
                        },
                        icon: const Icon(Icons.delete),
                        iconSize: 20,
                        color: Colors.white,
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16.0)),
                        child: Container(
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, bottom: 8, top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 1),
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16.0)),
                            ),
                            child: Center(
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text("Total ${notes} Notes")))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16.0)),
                        child: Container(
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, bottom: 8, top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 1),
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16.0)),
                            ),
                            child: Center(
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text("Total: ₹$calNum")))),
                      ),
                    ),
                  ),
                  Container(
                      height: 35,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: popupMenu()),
                ],
              ),
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 35,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: IconButton(
                        onPressed: () async {
                          tts.stop();
                          await tts.speak(NumberToWordsEnglish.convert(calNum));
                        },
                        icon: const Icon(Icons.volume_up),
                        iconSize: 20,
                        color: Colors.white,
                      )),
                  Expanded(
                      child: Text(NumberToWordsEnglish.convert(calNum.abs())
                          .toTitleCase())),
                ],
              ),
              const Divider(),
              SizedBox(
                height: 30,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 8, top: 8),
                              decoration: const BoxDecoration(
                                // border: Border.all(color: Colors.blue, width: 1),
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: const Center(
                                  child: Text(
                                "Save Out",
                                style: TextStyle(color: Colors.white),
                              ))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 8, top: 8),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 0, 74, 159),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: const Center(
                                  child: Text(
                                "VIEW",
                                style: TextStyle(color: Colors.white),
                              ))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          child: Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 8, top: 8),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 9, 120, 12),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.0)),
                              ),
                              child: const Center(
                                child: Text(
                                  "Save In",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        child: Column(children: <Widget>[
          Container(
            color: Colors.grey[300],
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  //create box textfield for cash
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                        ],
                        keyboardType: TextInputType.number,
                        controller: controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Payer',
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                      flex: 5,
                      child: Text(
                        payerString,
                        style: TextStyle(
                          color: (payerString.contains("+"))
                              ? Colors.green
                              : !payerString.contains("<--- ")
                                  ? payerString.contains("Matched")
                                      ? Colors.green
                                      : Colors.red
                                  : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListView.builder(
                  reverse: true, // here
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),

                  itemCount: listNotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    _controllers.add(TextEditingController());

                    var item = listNotes.reversed.toList()[index];
                    return Container(
                      color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          children: [
                            Image.asset('assets/notes/${index + 1}.jpg',
                                height: 40),
                            // SizedBox(width: 10),
                            SizedBox(
                              width: 50,
                              child: Text(
                                listNotes.reversed.toList()[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text(
                                "X",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.all(1),
                              child: SizedBox(
                                  height: 45,
                                  width: 60,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _controllers[index],
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[0-9]"))
                                      ],

                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: '0',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (String value) {
                                        // notes = 0;
                                        int tempNum = 0;
                                        if (value.isNotEmpty) {
                                          if (tempNum == 0) {
                                            tempNum = int.parse(listNotesCal
                                                .reversed
                                                .toList()[index][item]
                                                .toString());
                                          } else {
                                            tempNum = 0;
                                          }
                                        }

                                        // debugPrint(tempNum.toString());
                                        if (value == "") {
                                          calNum = 0;
                                          notes = 0;
                                          setState(() {
                                            noteCal.reversed.toList()[index]
                                                [item] = "0";
                                            listNotesCal.reversed
                                                .toList()[index][item] = "0";
                                          });
                                        } else {
                                          setState(() {
                                            noteCal.reversed.toList()[index]
                                                [item] = value;
                                            listNotesCal.reversed
                                                    .toList()[index]
                                                [item] = ((int.parse(value)) *
                                                    int.parse(listNotes.reversed
                                                        .toList()[index]))
                                                .toString();
                                          });
                                        }
                                        if (calNum >= 999999999) {
                                          noteCal.reversed.toList()[index]
                                              [item] = "0";
                                          listNotesCal.reversed.toList()[index]
                                              [item] = "0";
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Can Not Be More Than 1 ARAB");
                                        }
                                        if (controller.text.isEmpty) {
                                          setState(() {
                                            payerString =
                                                "<--- Enter The Amount Tally Payer";
                                          });
                                        } else if (calNum >
                                            int.parse(controller.text)) {
                                          setState(() {
                                            payerString =
                                                "Greater By +₹${calNum - int.parse(controller.text)}";
                                          });
                                        } else if (calNum ==
                                            int.parse(controller.text)) {
                                          setState(() {
                                            payerString =
                                                "Matched Success To Payer ✅";
                                          });
                                        } else {
                                          setState(() {
                                            payerString =
                                                "Less By -₹${(calNum - int.parse(controller.text)).abs()}";
                                          });
                                        }
                                        print(notes);

                                        // calNum = 0;
                                        // if (int.parse(value) < tempNum) {
                                        //   setState(() {
                                        //     calNum = int.parse(listNotesCal[index]
                                        //             [item]
                                        //         .toString());
                                        //   });
                                        // } else {
                                        //   calNum -= tempNum;
                                        // }

                                        // print("sd" +
                                        //     listNotesCal[index][item].toString());
                                      },

                                      // onChanged: (value) => {
                                      //   listNotesCal.add({
                                      //     "${listNotes.reversed.toList()[index]}":
                                      //         (int.parse(value) *
                                      //                 int.parse(listNotes.reversed
                                      //                     .toList()[index]))
                                      //             .toString()
                                      //   }),
                                      //   listNotesCal[listNotesCal.indexWhere(
                                      //           (element) =>
                                      //               element ==
                                      //               listNotes.reversed
                                      //                   .toList()[index])] =
                                      //       (int.parse(value) *
                                      //               int.parse(listNotes.reversed
                                      //                   .toList()[index]))
                                      //           .toString(),
                                      //   listNotesCal.forEach((element) {
                                      //     print(element[
                                      //         "${listNotes.reversed.toList()[index]}"]);
                                      //   }),
                                      // }
                                      // create setstate for textfield
                                    ),
                                  )),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "= ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              listNotesCal.reversed
                                  .toList()[index]
                                      ["${listNotes.reversed.toList()[index]}"]
                                  .toString(),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: TextField(
                                controller: plusCon,
                                onChanged: (value) {
                                  plus = 0;

                                  setState(() {
                                    if (value.isEmpty) {
                                      calNum -= plus;
                                    } else if (int.parse(value) < plus) {
                                      calNum -= plus;
                                    }
                                  });

                                  if (value.isEmpty) {
                                    calNum -= plus;
                                  } else {
                                    setState(() {
                                      plus = int.parse(value);
                                    });
                                  }
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]"))
                                ],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Plus Rs.',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_circle,
                                    size: 30,
                                    color: Colors.blue,
                                  ),
                                  Text("Manually Amount"),
                                  Icon(
                                    Icons.remove_circle,
                                    size: 30,
                                    color: Colors.blue,
                                  ),
                                ]),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: TextField(
                                controller: minusCon,
                                onChanged: (value) {
                                  minus = 0;
                                  setState(() {
                                    if (value.isEmpty) {
                                      calNum += minus;
                                    } else if (int.parse(value) < minus) {
                                      calNum += minus;
                                    }
                                  });

                                  if (value.isEmpty) {
                                    calNum += minus;
                                  } else {
                                    setState(() {
                                      minus = int.parse(value);
                                    });
                                  }
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]"))
                                ],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'Minus Rs',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: nameCon,
                          onChanged: (value) => {
                            setState(() {
                              name = value;
                            })
                          },
                          // textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: 'Person Name',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: TextField(
                                controller: mobCon,
                                onChanged: (value) => {
                                  setState(() {
                                    mobNum = value;
                                  })
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]"))
                                ],
                                keyboardType: TextInputType.number,
                                // textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone),
                                  hintText: 'Mobile Number',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: TextField(
                                controller: acCon,
                                onChanged: (value) => {
                                  setState(() {
                                    ac = value;
                                  })
                                },
                                // textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.account_balance_rounded),
                                  hintText: 'Acount Number',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: remarkCon,
                          onChanged: (value) => {
                            setState(() {
                              remark = value;
                            })
                          },

                          // textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            prefixIcon:
                                Icon(Icons.mark_unread_chat_alt_rounded),
                            hintText: 'Remark, Bank, Company, Party, Etc.',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  PopupMenuButton<Menu> popupMenu() {
    return PopupMenuButton<Menu>(
        iconSize: 20,
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        // Callback that sets the selected popup menu item.
        onSelected: (Menu item) {
          setState(() {
            _selectedMenu = item.name;
          });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                value: Menu.itemOne,
                child: Row(
                  children: const [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('PDF Receipt'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.itemTwo,
                child: Row(
                  children: const [
                    Icon(
                      Icons.whatsapp,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Share to watsapp'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.itemTwo,
                child: Row(
                  children: [
                    Icon(
                      Icons.copy,
                      color: Colors.blue[200],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Copy Details'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.itemTwo,
                child: Row(
                  children: const [
                    Icon(
                      Icons.stars,
                      color: Color.fromARGB(255, 255, 11, 92),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Give 5 Star'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                onTap: () {
                  Future.delayed(
                      const Duration(seconds: 0), () => newMethod(context));
                },
                value: Menu.itemTwo,
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Colors.blue[200],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Settings'),
                  ],
                ),
              ),
            ]);
  }

  Future<dynamic> newMethod(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('AlertDialog Title'),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Shop / Company / Your Name',
                  hintText: 'Enter The Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Address/Bank info',
                        hintText: 'Enter The Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        hintText: 'Enter The Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Center(
                  child: Text(
                "Personal info is display at bottom of PDF.",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
              const Divider(
                thickness: 1,
                color: Colors.black,
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4.0,
                  ),
                  itemCount: listNotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CheckboxListTile(
                      value: true,
                      onChanged: (value) {},
                      title: Text(listNotes[index]),
                    );
                  },
                ),
              ),
              Expanded(
                child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 4.0,
                    children: List.generate(
                      listNotes.length,
                      (index) => CheckboxListTile(
                        value: true,
                        onChanged: (value) {},
                        title: Text(listNotes[index]),
                      ),
                    ).toList()),
              )
            ],
          ),
        ),
        actions: <Widget>[
          //create textfield box
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
