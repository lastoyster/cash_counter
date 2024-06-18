import 'package:cashcounter/model/firestore_model.dart';
import 'package:cashcounter/provider/firestore_provider.dart';
import 'package:cashcounter/widgets/mybtn.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:math_expressions/math_expressions.dart';

class Calculator extends StatefulWidget {
  Calculator({Key? key}) : super(key: key);

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  var userInput = '';
  var answer = '';
  var sgst = '';
  var cgst = '';
  var oginput = '';
  bool gst = false;
  bool gstplus = false;
  var tempGst = "";
  // Array of button
  final List<String> buttons = [
    'C',
    '+/-',
    '%',
    'DEL',
    '7',
    '8',
    '9',
    '/',
    '4',
    '5',
    '6',
    'x',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '=',
    '+',
  ];

  // final List<String> gst1plus = ["+3%", "+5%", "+12%", "+18%", "+28%"];
  // final List<String> gst1minus = ["-3%", "-5%", "-12%", "-18%", "-28%"];
  final List<String> gst1 = [
    "3",
    "5",
    "12",
    "18",
    "28",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        (cgst != '')
            ? Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    const Text("CGST: "),
                    Text(cgst,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    const Text(" SGST: "),
                    Text(sgst,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : Container(),
        Expanded(
          flex: 2,
          child: Consumer(
            builder: (context, ref, child) {
              final database = ref.read(databaseProvider);
              return Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: StreamBuilder<
                                        DocumentSnapshot<Map<String, dynamic>>>(
                                    stream: database.getUserDetail,
                                    builder: (context, snapshot) {
                                      if (snapshot.error != null &&
                                          snapshot.data == null) {
                                        print(snapshot.error);
                                        return const Center(
                                            child: Text(
                                                'Some error occurred')); // Show an error just in case(no internet etc)
                                      }
                                      // if (snapshot.connectionState ==
                                      //     ConnectionState.waiting) {
                                      //   return Center(
                                      //       child:
                                      //           CircularProgressIndicator()); // Show a CircularProgressIndicator when the stream is loading

                                      // }
                                      if (!snapshot.hasData &&
                                          snapshot.data == null) {
                                        return const Center(
                                            child:
                                                CircularProgressIndicator()); // Show a CircularProgressIndicator when the stream is loading
                                      } else {
                                        return (gst == true)
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: IconButton(
                                                    onPressed: () {
                                                      FlutterClipboard.copy(
                                                              '${oginput}\n${gstplus == true ? '+' : '-'}${double.parse(cgst) + double.parse(sgst)} (${gstplus == true ? '+' + tempGst + '%' : '-' + tempGst + '%'})\n============= \n=${answer}')
                                                          .whenComplete(() =>
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          "Copied to Clipboard"));
                                                    },
                                                    icon: Icon(Icons.copy)),
                                              )
                                            : Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: IconButton(
                                                    onPressed: () {
                                                      dialogBox(context,
                                                          snapshot, database);
                                                    },
                                                    icon: const Icon(
                                                        Icons.settings)));
                                      }
                                    }),
                              ),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      alignment: Alignment.centerRight,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          userInput,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 0, left: 5, right: 5, top: 0),
                                      alignment: Alignment.centerRight,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          answer,
                                          style: const TextStyle(
                                              fontSize: 30,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ]),
                  ),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: database.getUserDetail,
                      builder: (context, snapshot) {
                        // if (snapshot.connectionState ==
                        //     ConnectionState.waiting) {
                        //   return Center(
                        //       child:
                        //           CircularProgressIndicator()); // Show a CircularProgressIndicator when the stream is loading

                        // }
                        if (snapshot.error != null && snapshot.data == null) {
                          return const Center(
                              child: Text(
                                  'Some error occurred')); // Show an error just in case(no internet etc)
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(
                              child:
                                  CircularProgressIndicator()); // Show a CircularProgressIndicator when the stream is loading
                        } else {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: const Text(
                                          "GST:",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(
                                            snapshot.data?['gstplus'].length,
                                            (index) => Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5, right: 5),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (userInput.isEmpty &&
                                                            userInput == '') {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Enter Value to calculate gst");
                                                        } else {
                                                          gstplus = true;
                                                          gst = true;
                                                          oginput = userInput;
                                                          tempGst = snapshot
                                                              .data!['gstplus']
                                                                  [gst1[index]]
                                                              .toString();
                                                          // userInput = userInput +
                                                          //     "+" +
                                                          //     "(${userInput}*0.0${gst1plus[index].toString().replaceAll("%", "").replaceAll("+", "")})";
                                                          // 5-(5*0.03)
                                                          userInput =
                                                              "$userInput*(1+${snapshot.data?['gstplus'][gst1[index]].toString().replaceAll("%", "").replaceAll("+", "")}/100)";
                                                          equalPressed();
                                                          cgst = ((num.parse(
                                                                          answer) -
                                                                      num.parse(
                                                                          oginput)) /
                                                                  2)
                                                              .abs()
                                                              .toStringAsFixed(
                                                                  5)
                                                              .toString();
                                                          sgst = cgst;
                                                        }
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration: const BoxDecoration(
                                                            color: Colors.green,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        child: Text(
                                                          "+" +
                                                              snapshot.data?[
                                                                      'gstplus']
                                                                  [
                                                                  gst1[index]] +
                                                              "%",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: const Text(
                                          "GST:",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(
                                            snapshot.data?['gstminus'].length,
                                            (index) => Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5, right: 5),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (userInput.isEmpty) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Enter Value to calculate gst");
                                                        } else {
                                                          gstplus = false;
                                                          gst = true;
                                                          oginput = userInput;
                                                          tempGst = snapshot
                                                              .data!['gstminus']
                                                                  [gst1[index]]
                                                              .toString();

                                                          // userInput = userInput +
                                                          //     "-" +
                                                          //     "(${userInput}*0.0${gst1plus[index].toString().replaceAll("%", "").replaceAll("+", "")})";
                                                          userInput =
                                                              "$userInput/(1+${snapshot.data?['gstminus'][gst1[index]].toString().replaceAll("%", "").replaceAll("-", "")}/100)";
                                                          // 5-(5*0.03)
                                                          equalPressed();
                                                          cgst = ((num.parse(
                                                                          answer) -
                                                                      num.parse(
                                                                          oginput)) /
                                                                  2)
                                                              .abs()
                                                              .toStringAsFixed(
                                                                  5)
                                                              .toString();
                                                          sgst = cgst;
                                                        }
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration: const BoxDecoration(
                                                            color: Colors.red,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        child: Text(
                                                          "-" +
                                                              snapshot.data?[
                                                                      'gstminus']
                                                                  [
                                                                  gst1[index]] +
                                                              "%",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ],
              );
            },
          ),
        ),
        Expanded(
          flex: 4,
          child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 70, // here set custom Height You Want
              ),
              itemBuilder: (BuildContext context, int index) {
                // Clear Button
                if (index == 0) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        gst = false;
                        cgst = '';
                        sgst = '';
                        userInput = '';
                        answer = '0';
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }

                // +/- button
                else if (index == 1) {
                  return MyButton(
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }
                // % Button
                else if (index == 2) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        userInput += buttons[index];
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }
                // Delete Button
                else if (index == 3) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        gst = false;
                        userInput =
                            userInput.substring(0, userInput.length - 1);
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.blue[50],
                    textColor: Colors.black,
                  );
                }
                // Equal_to Button
                else if (index == 18) {
                  return MyButton(
                    buttontapped: () {
                      setState(() {
                        equalPressed();
                      });
                    },
                    buttonText: buttons[index],
                    color: Colors.orange[700],
                    textColor: Colors.white,
                  );
                }

                //  other buttons
                else {
                  return SizedBox(
                    height: 50,
                    child: MyButton(
                      buttontapped: () {
                        setState(() {
                          userInput += buttons[index];
                        });
                      },
                      buttonText: buttons[index],
                      color: isOperator(buttons[index])
                          ? Colors.blueAccent
                          : Colors.white,
                      textColor: isOperator(buttons[index])
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }
              }),
        ),
      ],
    );
  }

  Future<dynamic> dialogBox(
      BuildContext context,
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
      Database database) {
    Map<String, Object?> map1 = Map();
    Map<String, Object?> map2 = Map();
    snapshot.data?['gstplus'].forEach((key, value) => {
          map1.addAll({key: value}),
        });
    snapshot.data?['gstminus'].forEach((key, value) => {
          map2.addAll({key: value}),
        });
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Change Slot Value GST Plus (+)",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Divider(
                thickness: 1,
                color: Colors.black,
              ),
              SizedBox(
                height: 230.0, // Change as per your requirement
                width: 400.0, // Change as per your requirement
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data?['gstplus'].length,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("(GST +) Slot 1 ="),
                        SizedBox(
                          height: 30,
                          width: 50,
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            onChanged: (value) {
                              setState(() {
                                map1[gst1[index]] = value;
                              });
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 10),
                              isDense: true,
                              // labelText:
                              //     gst1plus[index],
                              hintText:
                                  snapshot.data?['gstplus'][gst1[index]] + ".0",
                              // border:
                              //     OutlineInputBorder(
                              //   borderRadius:
                              //       BorderRadius
                              //           .circular(
                              //               10),
                              // ),
                            ),
                          ),
                        ),
                        const Text("%")
                      ],
                    );
                  },
                ),
              ),
              const Text("Change Slot Value GST Minus (-)",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Divider(
                thickness: 1,
                color: Colors.black,
              ),
              SizedBox(
                height: 230.0, // Change as per your requirement
                width: 400.0, // Change as per your requirement
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data?['gstminus'].length,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("(GST -) Slot 1 ="),
                        SizedBox(
                          height: 30,
                          width: 50,
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                map2[gst1[index]] = value;
                              });
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 10),
                              isDense: true,
                              // labelText:
                              //     gst1plus[index],
                              hintText: snapshot.data?['gstminus']
                                      [gst1[index]] +
                                  ".0",
                              // border:
                              //     OutlineInputBorder(
                              //   borderRadius:
                              //       BorderRadius
                              //           .circular(
                              //               10),
                              // ),
                            ),
                          ),
                        ),
                        const Text("%")
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  database.updateGst({
                    'gstplus': map1,
                    'gstminus': map2,
                  }).whenComplete(() => Navigator.pop(context));
                },
                child: Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool isOperator(String x) {
    if (x == '/' || x == 'x' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

  void gstPressed(gst) {
    String finaluserinput = userInput + gst;
    finaluserinput = userInput.replaceAll('x', '*');

    Parser p = Parser();
    Expression exp = p.parse(finaluserinput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    setState(() {
      answer = eval.toString();
    });
  }

// function to calculate the input operation
  void equalPressed() {
    String finaluserinput = userInput;
    finaluserinput = userInput.replaceAll('x', '*');

    Parser p = Parser();
    Expression exp = p.parse(finaluserinput);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);
    setState(() {
      if (gst) {
        answer = eval.toStringAsFixed(5);
      } else {
        answer = eval.toString();
      }
    });
  }
}
