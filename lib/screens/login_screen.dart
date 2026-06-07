import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/storage.dart';
import 'home_screen.dart';

const _password = 'hamazuka@kalid2025';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showPassword = false;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the password');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    await Future.delayed(const Duration(milliseconds: 500));

    if (_controller.text == _password) {
      await Storage.setLoggedIn(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() { _loading = false; _error = 'Incorrect password. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a1912),
      resizeToAvoidBottomInset: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // ── Background image ──
            Positioned.fill(
              child: Image.asset('assets/images/login.jpg', fit: BoxFit.cover),
            ),
            // ── Dark tint ──
            Positioned.fill(
              child: Container(color: const Color(0x80050E0A)),
            ),
            // ── Top gradient ──
            Positioned(
              top: 0, left: 0, right: 0, height: 220,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0a1912), Color(0xDD0a1912), Colors.transparent],
                  ),
                ),
              ),
            ),
            // ── Bottom gradient ──
            Positioned(
              bottom: 0, left: 0, right: 0, height: 400,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xF00a1912), Color(0xFF0a1912)],
                  ),
                ),
              ),
            ),
            // ── Scrollable card ──
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        // ✅ left/right margin so card doesn't touch edges
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: _buildCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: const Color(0xEE081810),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x55D4AF37), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Logo ──
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
              boxShadow: const [
                BoxShadow(color: Color(0x55D4AF37), blurRadius: 18, spreadRadius: 2),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(44),
              child: Image.asset('assets/images/icon.jpg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),

          // ── Arabic title ──
          const Text(
            'القاعدة النورانية',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),

          // ── English subtitle ──
          const Text(
            'Al-Qaida Al-Nooraniya',
            style: TextStyle(
              color: Color(0x88D4AF37),
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 28),

          // ── Password input ──
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xBF0A140F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _error.isNotEmpty
                    ? const Color(0xFFFF6B6B)
                    : const Color(0x4DC5A880),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: Color(0xFFC5A880), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    obscureText: !_showPassword,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter password...',
                      hintStyle: TextStyle(color: Color(0x55C5A880)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _handleLogin(),
                    textInputAction: TextInputAction.go,
                    autocorrect: false,
                    onChanged: (_) => setState(() => _error = ''),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showPassword = !_showPassword),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFFC5A880),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Error message ──
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // ── Enter button ──
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                disabledBackgroundColor: const Color(0x80D4AF37),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 6,
                shadowColor: const Color(0x88D4AF37),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Color(0xFF0f3425), strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Enter',
                            style: TextStyle(
                                color: Color(0xFF0f3425),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Color(0xFF0f3425), size: 18),
                      ],
                    ),
            ),
          ),
          // ✅ footer completely removed
        ],
      ),
    );
  }
}