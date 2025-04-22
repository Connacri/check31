import 'package:check31/checkit/providerF.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';



class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final GlobalKey<FormFieldState>? fieldKey;
  final bool resetOnClear;
  final bool isNumberPhone;
  final VoidCallback? onTextCleared;

  AnimatedTextField({
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.fieldKey,
    this.resetOnClear = false,
    required this.isNumberPhone,
    this.onTextCleared,
  });

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // Ajout du listener en référence à une méthode correctement définie.
    widget.controller.addListener(_onControllerChanged);
  }

  // Méthode pour gérer les changements du controller
  void _onControllerChanged() {
    // Si le texte est vide et que l'icône est validée, on réinitialise _isValid.
    if (widget.controller.text.isEmpty && _isValid) {
      setState(() {
        _isValid = false;
      });
      // Appeler le callback si le texte est vide
      if (widget.onTextCleared != null) {
        widget.onTextCleared!();
      }
    }
  }

  @override
  void dispose() {
    // Retirer le listener pour éviter d'éventuels appels sur un state déjà détruit.
    widget.controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _validatePhoneNumber(String value) {
    final provider =
        Provider.of<SignalementProviderSupabase>(context, listen: false);
    setState(() {
      if (value.isEmpty) {
        _isValid = false;
      } else {
        _isValid = provider.isValidAlgerianPhoneNumber(value);
      }
    });
  }

  // void resetIcon() {
  //   if (widget.resetOnClear) {
  //     setState(() {
  //       _isValid = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            key: widget.fieldKey,
            controller: widget.controller,
            decoration: widget.isNumberPhone
                ? InputDecoration(
                    labelText: widget.labelText,
                    prefixIcon: widget.controller.text.isNotEmpty
                        ? _isValid
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.error, color: Colors.red)
                        : null,
                    suffixIcon: widget.controller.text.isNotEmpty
                        ? Transform.scale(
                            scale: 0.7,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              color: Colors.red,
                              onPressed: () {
                                FocusScope.of(context)
                                    .unfocus(); // Enlève le fo
                                setState(() {
                                  widget.controller.clear();
                                });
                                if (widget.onTextCleared != null) {
                                  widget.onTextCleared!();
                                }
                              },
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                     // borderSide: BorderSide.none,
                    ),
                    filled: true,
              fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.all(8),
                  )
                : InputDecoration(
                    labelText: widget.labelText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      //borderSide: BorderSide.none,
                    ),
                    filled: true,
              fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.all(8),
                  ),
            style: TextStyle(
              fontSize: 25, // Agrandir le texte ici
            ),
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: _validatePhoneNumber,
            textAlign: TextAlign.center,
          ),
        ));
  }
}

class AnimatedLongTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final GlobalKey<FormFieldState>? fieldKey;
  final bool resetOnClear;
  final bool isNumberPhone;

  AnimatedLongTextField({
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.fieldKey,
    this.resetOnClear = false,
    required this.isNumberPhone,
  });

  @override
  _AnimatedLongTextFieldState createState() => _AnimatedLongTextFieldState();
}

class _AnimatedLongTextFieldState extends State<AnimatedLongTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // Ajout du listener en référence à une méthode correctement définie.
    widget.controller.addListener(_onControllerChanged);
  }

  // Méthode pour gérer les changements du controller
  void _onControllerChanged() {
    // Si le texte est vide et que l'icône est validée, on réinitialise _isValid.
    if (widget.controller.text.isEmpty && _isValid) {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  void dispose() {
    // Retirer le listener pour éviter d'éventuels appels sur un state déjà détruit.
    widget.controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _validatePhoneNumber(String value) {
    final provider =
        Provider.of<SignalementProviderSupabase>(context, listen: false);
    setState(() {
      if (value.isEmpty) {
        _isValid = false;
      } else {
        _isValid = provider.isValidAlgerianPhoneNumber(value);
      }
    });
  }

  void resetIcon() {
    if (widget.resetOnClear) {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: TextFormField(
        key: widget.fieldKey,
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          alignLabelWithHint: true,
          hintText: 'Entrez un texte long ici...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: EdgeInsets.all(15),
        ),
        textInputAction: TextInputAction.newline,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        onChanged: _validatePhoneNumber,
        textAlign: TextAlign.start,
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        // permet une hauteur dynamique selon le contenu
        minLines: 5,
        // pour afficher directement plusieurs lignes
        expands:
            false, // false pour ne pas forcer à remplir tout l'espace parent
      ),
    );
  }
}
