
import 'package:finance_manager_app/pages/Home/veiws/HomePage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';




// class OTPScreen extends StatefulWidget {
//   final String email;

//   const OTPScreen({Key? key, required this.email}) : super(key: key);

//   @override
//   _OTPScreenState createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   final List<TextEditingController> _controllers =
//       List.generate(6, (index) => TextEditingController());
//   final List<FocusNode> _focusNodes =
//       List.generate(6, (index) => FocusNode());
//   String _enteredOTP = '';
//   bool _isVerifying = false;

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _verifyOTP() async {
//     setState(() {
//       _isVerifying = true;
//     });
//     _enteredOTP = _controllers.map((controller) => controller.text).join();

//     if (success) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => MyHomePage()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(authProvider.errorMessage ?? "OTP Verification failed")));
//       setState(() {
//         _isVerifying = false;
//       });
//     }
//   }

//   void _clearOTP() {
//     for (var controller in _controllers) {
//       controller.clear();
//     }
//     _focusNodes[0].requestFocus();
//   }

//   Widget _buildOTPTextField(int index) {
//     return Container(
//       width: 50,
//       height: 60,
//       decoration: BoxDecoration(
//         color: HexColor("191d2d"),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: HexColor("f1a410")),
//       ),
//       child: TextField(
//         controller: _controllers[index],
//         focusNode: _focusNodes[index],
//         onChanged: (value) {
//           if (value.isNotEmpty) {
//             if (index < 5) {
//               _focusNodes[index + 1].requestFocus();
//             } else {
//               _focusNodes[index].unfocus();
//               bool allFilled =
//                   _controllers.every((controller) => controller.text.isNotEmpty);
//               if (allFilled) {
//                 _verifyOTP();
//               }
//             }
//           }
//         },
//         style: TextStyle(
//           color: HexColor("FFFFFF"),
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//         ),
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         decoration: const InputDecoration(
//           border: InputBorder.none,
//           counterText: '',
//         ),
//         inputFormatters: [
//           LengthLimitingTextInputFormatter(1),
//           FilteringTextInputFormatter.digitsOnly,
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: HexColor("191d2d"),
//       appBar: AppBar(
//         backgroundColor: HexColor("191d2d"),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: HexColor("FFFFFF")),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 30),
//               Text(
//                 'Verification',
//                 style: TextStyle(
//                   color: HexColor("FFFFFF"),
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Text(
//                 'Enter the 6-digit verification code',
//                 style: TextStyle(
//                   color: HexColor("f1a410"),
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 50),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     6,
//                     (index) => Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 5),
//                       child: _buildOTPTextField(index),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: _isVerifying ? null : _verifyOTP,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: HexColor("F2C341"),
//                   disabledBackgroundColor: HexColor("F2C341").withOpacity(0.5),
//                   foregroundColor: HexColor("191d2d"),
//                   minimumSize: const Size(double.infinity, 55),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: _isVerifying
//                     ? SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(HexColor("191d2d")),
//                         ),
//                       )
//                     : const Text(
//                         'Verify',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: TextButton(
//                   onPressed: _clearOTP,
//                   child: Text(
//                     'Clear',
//                     style: TextStyle(
//                       color: HexColor("f1a410"),
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


class OTPScreen extends StatefulWidget {
  final String expectedOTP;

  const OTPScreen({
    Key? key,
    required this.expectedOTP,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPScreen> {
  // Controllers for each OTP field
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Focus nodes for each OTP field
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  String _enteredOTP = '';
  bool _isVerifying = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOTP() {
    setState(() {
      _isVerifying = true;
    });

    // Collect OTP from all fields
    _enteredOTP = _controllers.map((controller) => controller.text).join();

    // Simulate a slight delay for verification
    Future.delayed(Duration(milliseconds: 800), () {
      // Simple verification - compare with expected OTP
      if (_enteredOTP == widget.expectedOTP) {
        // Navigate to MyHomePage on success
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
          (route) => false, // This removes all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please try again.',
                style: TextStyle(color: HexColor("FFFFFF"))),
            backgroundColor: HexColor("f3696e"),
          ),
        );
        setState(() {
          _isVerifying = false;
        });
        Navigator.pop(context);
      }
    });
  }

  void _clearOTP() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("191d2d"),
      appBar: AppBar(
        backgroundColor: HexColor("191d2d"),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: HexColor("FFFFFF")),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                'Verification',
                style: TextStyle(
                  color: HexColor("FFFFFF"),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Enter the 6-digit verification code',
                style: TextStyle(
                  color: HexColor("f1a410"),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _buildOTPTextField(index),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("F2C341"),
                  disabledBackgroundColor: HexColor("F2C341").withOpacity(0.5),
                  foregroundColor: HexColor("191d2d"),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isVerifying
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(HexColor("191d2d")),
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _clearOTP,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: HexColor("f1a410"),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPTextField(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: HexColor("191d2d"),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HexColor("f1a410")),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              // Verify OTP automatically when all fields are filled
              bool allFilled = _controllers
                  .every((controller) => controller.text.isNotEmpty);
              if (allFilled) {
                _verifyOTP();
              }
            }
          }
        },
        style: TextStyle(
          color: HexColor("FFFFFF"),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}
