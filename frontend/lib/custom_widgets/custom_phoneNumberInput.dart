import "package:flutter/material.dart";
import "package:frontend/custom_widgets/colors.dart";
import "package:intl_phone_number_input/intl_phone_number_input.dart";

class CustomPhoneNumberInput extends StatelessWidget {
  CustomPhoneNumberInput(
      {super.key,
      this.hintText = "Phone Number",
      required this.controller,
      required this.validator});

  final String hintText;
  final TextEditingController controller;
  final Function validator;
  final PhoneNumber initialValue = PhoneNumber(isoCode: "TR");

  PhoneNumber phoneNumber = PhoneNumber(isoCode: "TR");

  String getPhoneNumber() {
    return "${phoneNumber.phoneNumber}";
  }

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      spaceBetweenSelectorAndTextField: 0,
      onInputChanged: (PhoneNumber newNumber) {
        phoneNumber = newNumber;
      },
      onSaved: (PhoneNumber newNumber) {
        phoneNumber = newNumber;
      },
      textFieldController: controller,
      initialValue: initialValue,
      formatInput: true,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
      ),
      inputDecoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) => validator(value),
    );
  }
}
