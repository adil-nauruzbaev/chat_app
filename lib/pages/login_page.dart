import 'package:chat_app_test/constants/colors.dart';
import 'package:chat_app_test/constants/regexps.dart';
import 'package:chat_app_test/services/alert_service.dart';
import 'package:chat_app_test/services/auth_service.dart';
import 'package:chat_app_test/services/navigation_service.dart';
import 'package:chat_app_test/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  String? email, password;

  @override
  void initState() {
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _headerText(),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                _loginFormFields(),
                const SizedBox(height: 16),
                _loginButton(),
                _bottomRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Добро пожаловать",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Чтобы продолжить авторизуйтесь ниже",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _loginFormFields() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          CustomFormField(
            onSaved: (value) {
              setState(() {
                email = value;
              });
            },
            hintText: 'Email',
            validationRegExp: EMAIL_VALIDATION_REGEX,
          ),
          CustomFormField(
            onSaved: (value) {
              setState(() {
                password = value;
              });
            },
            hintText: 'Пароль',
            validationRegExp: PASSWORD_VALIDATION_REGEX,
            obscureText: true,
          ),
        ],
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.05,
      width: MediaQuery.sizeOf(context).width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorSelect.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email!, password!);
            if (result) {
              _navigationService.pushReplacementNamed('/home');
              _alertService.showToast(
                text: "Вы успешно вошли в аккаунт!",
                icon: Icons.check,
              );
            } else {
              _alertService.showToast(
                text: "Ошибка при входе, попробуйте еще раз",
                icon: Icons.error,
              );
            }
          }
        },
        child: const Text(
          'Войти',
          style: TextStyle(color: ColorSelect.primaryText, fontSize: 16),
        ),
      ),
    );
  }

  Widget _bottomRow() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('Нет аккаунта? '),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed('/register');
            },
            child: const Text(
              'Зарегистрируйтесь',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
