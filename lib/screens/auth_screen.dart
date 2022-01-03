import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'SastaShopify',
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          color: Theme.of(context)
                              .accentTextTheme
                              .headline6!
                              .color,
                          fontSize: 40,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("An error occurred"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"))
        ],
      ),
    );
  }

  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _containerAnimationController;
  // late Animation<Size> _heightAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fieldOpacity;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _containerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fieldOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _containerAnimationController,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _containerAnimationController,
        curve: Curves.linear,
      ),
    );

    // _heightAnimation = Tween<Size>(
    //   begin: const Size(double.infinity, 260),
    //   end: const Size(double.infinity, 320),
    // ).animate(
    //   CurvedAnimation(
    //     parent: _containerAnimationController,
    //     curve: Curves.linear,
    //   ),
    // );
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _containerAnimationController.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).signIn(
            _authData["email"] as String, _authData["password"] as String);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signUp(
            _authData["email"] as String, _authData["password"] as String);
      }
    } catch (error) {
      var errorMessage = "Network error, please try again later $error";
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _containerAnimationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _containerAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        // height: _heightAnimation.value.height,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        height: _authMode == AuthMode.Signup ? 320 : 260,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value as String;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value as String;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _fieldOpacity,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  TextButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                  ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                ),
              ],
            ),
          ),
        ),
      ),
      // child: AnimatedBuilder(
      //   animation: _heightAnimation,
      //   builder: (context, _child) => Container(
      //     // height: _authMode == AuthMode.Signup ? 320 : 260,
      //     height: _heightAnimation.value.height,
      //     constraints: BoxConstraints(
      //         minHeight: _authMode == AuthMode.Signup ? 320 : 260),
      //     width: deviceSize.width * 0.75,
      //     padding: const EdgeInsets.all(16.0),
      //     child: _child,
      //   ),
      //   child: Form(
      //     key: _formKey,
      //     child: SingleChildScrollView(
      //       child: Column(
      //         children: <Widget>[
      //           TextFormField(
      //             decoration: const InputDecoration(labelText: 'E-Mail'),
      //             keyboardType: TextInputType.emailAddress,
      //             validator: (value) {
      //               if (value!.isEmpty || !value.contains('@')) {
      //                 return 'Invalid email!';
      //               }
      //               return null;
      //             },
      //             onSaved: (value) {
      //               _authData['email'] = value as String;
      //             },
      //           ),
      //           TextFormField(
      //             decoration: const InputDecoration(labelText: 'Password'),
      //             obscureText: true,
      //             controller: _passwordController,
      //             validator: (value) {
      //               if (value!.isEmpty || value.length < 5) {
      //                 return 'Password is too short!';
      //               }
      //             },
      //             onSaved: (value) {
      //               _authData['password'] = value as String;
      //             },
      //           ),
      //           if (_authMode == AuthMode.Signup)
      //             TextFormField(
      //               enabled: _authMode == AuthMode.Signup,
      //               decoration:
      //                   const InputDecoration(labelText: 'Confirm Password'),
      //               obscureText: true,
      //               validator: _authMode == AuthMode.Signup
      //                   ? (value) {
      //                       if (value != _passwordController.text) {
      //                         return 'Passwords do not match!';
      //                       }
      //                     }
      //                   : null,
      //             ),
      //           const SizedBox(
      //             height: 20,
      //           ),
      //           if (_isLoading)
      //             const CircularProgressIndicator()
      //           else
      //             TextButton(
      //               child:
      //                   Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
      //               onPressed: _submit,
      //             ),
      //           TextButton(
      //             child: Text(
      //                 '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
      //             onPressed: _switchAuthMode,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
