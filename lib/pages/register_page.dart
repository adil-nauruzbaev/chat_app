import 'dart:io';
import 'package:chat_app_test/constants/colors.dart';
import 'package:chat_app_test/constants/regexps.dart';
import 'package:chat_app_test/models/user_profile.dart';
import 'package:chat_app_test/services/alert_service.dart';
import 'package:chat_app_test/services/auth_service.dart';
import 'package:chat_app_test/services/database_service.dart';
import 'package:chat_app_test/services/media_service.dart';
import 'package:chat_app_test/services/navigation_service.dart';
import 'package:chat_app_test/services/storage_service.dart';
import 'package:chat_app_test/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  File? selectedImage;
  late NavigationService _navigationService;
  late AuthService _authService;
  late AlertService _alertService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  final GlobalKey<FormState> _registerFromKey = GlobalKey();
  String? name, email, password;
  bool isLoading = false;

  @override
  void initState() {
    _authService = _getIt.get<AuthService>();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _storageService = _getIt.get<StorageService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
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
                const SizedBox(height: 32.0),
                if (!isLoading) _registerFormFields(),
                if (!isLoading) _registerButton(),
                if (!isLoading) _bottomRow(),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _uploadProfleImage() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : const NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _headerText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Давайте начнем!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Чтобы продолжить зарегистрируйтесь ниже",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _registerFormFields() {
    return Form(
      key: _registerFromKey,
      child: Column(
        children: [
          _uploadProfleImage(),
          const SizedBox(height: 32.0),
          CustomFormField(
            onSaved: (value) {
              setState(() {
                name = value;
              });
            },
            hintText: 'Имя',
            validationRegExp: NAME_VALIDATION_REGEX,
          ),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _registerButton() {
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
          setState(() {
            isLoading = true;
          });

          if ((_registerFromKey.currentState?.validate() ?? false) &&
              selectedImage != null) {
            _registerFromKey.currentState?.save();
            bool result = await _authService.register(email!, password!);
            if (result) {
              String? picURL = await _storageService.uploadUserPic(
                  file: selectedImage!, uid: _authService.user!.uid);
              if (picURL != null) {
                await _databaseService.createUserProfile(
                    userProfile: UserProfile(
                        uid: _authService.user!.uid,
                        name: name,
                        picURL: picURL));
                _navigationService.goBack();
                _navigationService.pushReplacementNamed('/home');
                _alertService.showToast(
                  text: "Вы успешно зарегистрировались!",
                  icon: Icons.check,
                );
              }
            } else {
              setState(() {
                isLoading = false;
              });
              _alertService.showToast(
                text: "Ошибка при регистрации, попробуйте еще раз",
                icon: Icons.error,
              );
            }
          } else {
            setState(() {
              isLoading = false;
            });
            _alertService.showToast(
              text: "Необходимо заполнить все поля и загрузить фото",
              icon: Icons.error,
            );
          }
        },
        child: const Text(
          'Зарегистрироваться',
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
          const Text('Есть аккаунт? '),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              'Авторизуйтесь',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
