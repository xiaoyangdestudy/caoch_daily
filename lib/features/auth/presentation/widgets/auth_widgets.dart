import 'dart:ui';
import 'package:flutter/material.dart';

// --- Constants ---
class AuthColors {
  static const bgDark = Color(0xFF141414);
  static const neonGreen = Color(0xFF00FF85);
  static const electricBlue = Color(0xFF00E5FF);
  static const brightOrange = Color(0xFFFF5500);
  static const textWhite = Color(0xFFFFFFFF);
  static const textGray = Color(0xFFAAAAAA);
  static final cardBg = const Color(0xFF282828).withValues(alpha: 0.6);
}

// --- Background Effect ---
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(color: AuthColors.bgDark),
        
        // Radial Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 1.2,
                colors: [
                  AuthColors.neonGreen.withValues(alpha: 0.1),
                  AuthColors.bgDark,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),

        // Abstract Lines (Simulated with CustomPainter or simplified gradients)
        // Using a simple pattern overlay for performance and look
        Positioned.fill(
          child: CustomPaint(
            painter: _GridPainter(),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AuthColors.electricBlue.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Draw some diagonal lines
    for (double i = -size.height; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    
    final paint2 = Paint()
      ..color = AuthColors.neonGreen.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width + size.height; i += 60) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Logo ---
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'auth_logo',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AuthColors.neonGreen, width: 2),
          boxShadow: [
            BoxShadow(
              color: AuthColors.neonGreen.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.self_improvement, // Or use a custom SVG if available
          size: 40,
          color: AuthColors.neonGreen,
        ),
      ),
    );
  }
}

// --- TextField ---
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool enabled;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.focusNode,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.isPassword;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AuthColors.electricBlue.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        obscureText: _obscureText,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted != null ? (_) => widget.onSubmitted!() : null,
        style: const TextStyle(
          fontSize: 16,
          color: AuthColors.textWhite,
        ),
        cursorColor: AuthColors.electricBlue,
        decoration: InputDecoration(
          // Label handled differently in this design, maybe just hint?
          // But keeping label for accessibility/usability
          labelText: widget.label,
          labelStyle: TextStyle(
            color: _isFocused ? AuthColors.electricBlue : AuthColors.textGray,
          ),
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: AuthColors.textGray,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused ? AuthColors.electricBlue : AuthColors.textGray,
            size: 22,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: _isFocused ? AuthColors.electricBlue : AuthColors.textGray,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AuthColors.electricBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red[600]!, width: 2),
          ),
          filled: true,
          fillColor: _isFocused ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.2),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}

// --- Button ---
class AuthButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.isLoading || widget.onPressed == null
                  ? [Colors.grey[700]!, Colors.grey[700]!]
                  : [
                      AuthColors.brightOrange,
                      const Color(0xFFFF3300),
                    ],
            ),
            boxShadow: widget.isLoading || widget.onPressed == null
                ? []
                : _isPressed
                    ? [
                        BoxShadow(
                          color: AuthColors.brightOrange.withValues(alpha: 0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AuthColors.brightOrange.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: widget.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
