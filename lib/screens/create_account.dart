import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/firebase.dart';
import '../models/id_storage.dart';
import '../widgets/title_text.dart';
import 'select_spaceship.dart';

// Shown the first time a player presses Play: asks for a player
// name and creates an online account used for the scoreboard.
class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  static const int maxNameLength = 16;

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _fb = FireBase();
  final _idStorage = IDStorage();

  bool _busy = false;
  String? _serverError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'You deserve a name';
    if (name.length < 3) return 'At least 3 characters';
    return _serverError;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _serverError = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    final name = _controller.text.trim();
    try {
      final id = await _fb.createAccount(name);
      await _idStorage.writeID(id);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SelectSpaceship()),
      );
    } on NameTakenException catch (e) {
      _serverError = e.toString();
      _formKey.currentState!.validate();
    } catch (e) {
      _serverError = 'Could not reach the server. Check your connection.';
      _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SelectSpaceship()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TitleText('Hi There!\nNew Player!'),
              SizedBox(
                width: width / 1.5,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    enabled: !_busy,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    maxLength: maxNameLength,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    onChanged: (_) => _serverError = null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'What should we call you?',
                    ),
                    validator: _validate,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: width / 2,
                child: ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Let\'s Rock'),
                ),
              ),
              TextButton(
                onPressed: _busy ? null : _skip,
                child: const Text('Play offline'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
