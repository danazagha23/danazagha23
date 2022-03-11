import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/components/custom_surfix_icon.dart';
import 'package:shop_app/components/default_button.dart';
import 'package:shop_app/components/form_error.dart';
import 'package:shop_app/screens/complete_profile/complete_profile_screen.dart';

import '../../../constants.dart';
import '../../../size_config.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shop_app/config.dart';



class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

String email;
String password;
String conform_password;
bool remember = false;
final List<String> errors = [];


void addError({String error}) {
  if (!errors.contains(error))
      errors.add(error);
}

void removeError({String error}) {
  if (errors.contains(error))
      errors.remove(error);
}



class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  GlobalKey<ScaffoldState> _scaffoldKey;
  ProgressDialog pr;
  // controller for the First TextField we are going to create.
  TextEditingController _passwordControllera = TextEditingController();
  TextEditingController _passwordControllerb = TextEditingController();
  // controller for the Last TextField we are going to create.
  TextEditingController _emailController = TextEditingController();

  // bool _isUpdating;
  // String _titleProgress;

  double screenHeight, screenWidth;
  bool _isChecked = false;
  bool _obscureText = true;




  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildConformPassFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          DefaultButton(
            text: "Continue",
            press: () {
              if (_formKey.currentState.validate()) {
                _onRegister();
                _formKey.currentState.save();
                // if all are valid then go to success screen
                Navigator.pushNamed(context, CompleteProfileScreen.routeName);//move to complete profile screen
              }

            },
          ),
        ],
      ),
    );

  }


  TextFormField buildConformPassFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => conform_password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.isNotEmpty && password == conform_password) {
          removeError(error: kMatchPassError);
        }
        conform_password = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      controller: _passwordControllera,
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  void _onRegister() {
    String _email = _emailController.text.toString();
    String _passworda = _passwordControllera.text.toString();
    String _passwordb = _passwordControllerb.text.toString();

    _registerUser(_email, _passworda);
  }

  Future<void> _registerUser(String email, String password) async {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    await pr.show();
    http.post(
        Uri.parse(CONFIG.SERVER +"/glam/php/register_user.php"),
        body: {
          "email": email,
          "password": password
        }).then((response) {
      print(response.body);
      if (response.body == "success") {
        Fluttertoast.showToast(
            msg:
            "Registration Success. Please check your email for verification link",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        pr.hide().then((isHidden) {
          print(isHidden);
        });
        // FocusScope.of(context).unfocus();
        // _passwordControllerb.clear();
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (content) => CompleteProfileScreen()));
      } else {
        Fluttertoast.showToast(
            msg: "Registration Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        pr.hide().then((isHidden) {
          print(isHidden);
        });
      }
    });
  }





}

