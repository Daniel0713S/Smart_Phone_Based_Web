import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  String text = '0';
  bool isResultDisplayed = false;

  Widget calcButton(String btnTxt, Color btnColor, Color txtColor) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () {
          calculation(btnTxt);
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: btnColor, 
          padding: const EdgeInsets.all(15),
        ),
        child: Text(
          btnTxt,
          style: TextStyle(
            fontSize: 30,
            color: txtColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      text,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                calcButton('AC', Colors.grey, Colors.black),
                calcButton('/', Colors.amber[700]!, Colors.white),
                calcButton('*', Colors.amber[700]!, Colors.white), 
                calcButton('-', Colors.amber[700]!, Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            for (var row in [
              ['7', '8', '9'],
              ['4', '5', '6'],
              ['1', '2', '3']
            ]) 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((item) => calcButton(item, Colors.grey[850]!, Colors.white)).toList(),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                calcButton('0', Colors.grey[850]!, Colors.white),
                calcButton('.', Colors.grey[850]!, Colors.white),
                calcButton('+', Colors.amber[700]!, Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                calcButton('=', Colors.green[700]!, Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void calculation(String btnText) {
    setState(() {
      if (btnText == 'AC') {
        text = '0';
        isResultDisplayed = false;
      } else if (btnText == '=') {
        if (!isResultDisplayed) {  // Calculate result only if last operation was not '='
          text = _evaluate(text);
          isResultDisplayed = true;
        }
      } else if (['+', '-', '*', '/'].contains(btnText)) {
        if (isResultDisplayed) {  // If result is displayed and operator is pressed, continue from result
          text += ' $btnText ';
          isResultDisplayed = false;  // Keep using the result
        } else {
            // Change the last operator if another operator is immediately pressed again
            if (text.endsWith(' + ') || text.endsWith(' - ') || text.endsWith(' * ') || text.endsWith(' / ')) {
                text = '${text.substring(0, text.length - 3)} $btnText ';
            } else {
                text += ' $btnText ';
            }
        } 
      }
      else {
        if (isResultDisplayed || text == '0') {
          text = (btnText == '.' ? '0.' : btnText);  // Start new entry for numbers and decimal
          isResultDisplayed = false;
        } else {
          text += btnText;
        }
      }
    });
  }

  String _evaluate(String expression) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      // Use scientific notation for large numbers
      if (eval % 1 == 0) {
        return eval.toInt().toString();
      } else {
        // Use scientific notation for very large or very small numbers
        if (eval.abs() >= 1.0e9 || eval.abs() <= 1.0e-9) {
          return eval.toStringAsExponential(2);
        }
        return eval.toStringAsFixed(2);
      }
    } catch (e) {
      return 'Error';
    }
  }
}
