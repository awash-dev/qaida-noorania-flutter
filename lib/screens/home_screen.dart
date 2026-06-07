import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/storage.dart';
import 'login_screen.dart';

const int _total = 23;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 1;
  final _player = AudioPlayer();
  bool _playing = false;
  bool _loadingAudio = false;
  bool _pickerVisible = false;
  bool _looping = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  late PageController _pageController;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _page - 1);

    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur ?? Duration.zero);
    });
    _player.playingStream.listen((playing) {
      if (mounted) setState(() => _playing = playing);
    });
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            _playing = false;
            _position = Duration.zero;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _player.dispose();
    super.dispose();
  }

  String _audioPath(int page) => 'assets/audios/qaida voice $page.m4a';
  String _imagePath(int page) => 'assets/images/$page.jpg';

  Future<void> _loadPageAudio(int page, {bool autoPlay = false}) async {
    try {
      setState(() => _loadingAudio = true);
      await _player.stop();
      await _player.setAsset(_audioPath(page));
      await _player.setLoopMode(_looping ? LoopMode.one : LoopMode.off);
      if (autoPlay) await _player.play();
    } catch (e) {
      debugPrint('Audio error: $e');
    } finally {
      if (mounted) setState(() => _loadingAudio = false);
    }
  }

  Future<void> _goTo(int page) async {
    if (page < 1 || page > _total) return;
    final wasPlaying = _playing;
    await _player.stop();
    setState(() {
      _page = page;
      _pickerVisible = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    if (_pageController.hasClients &&
        (_pageController.page?.round() ?? 0) != page - 1) {
      _pageController.jumpToPage(page - 1);
    }
    await _loadPageAudio(page, autoPlay: wasPlaying);
  }

  Future<void> _onPageSwiped(int index) async {
    final targetPage = index + 1;
    if (targetPage == _page) return;
    final wasPlaying = _playing;
    await _player.stop();
    setState(() {
      _page = targetPage;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await _loadPageAudio(targetPage, autoPlay: wasPlaying);
  }

  Future<void> _handlePlayPause() async {
    if (_player.processingState == ProcessingState.idle) {
      await _loadPageAudio(_page, autoPlay: true);
      return;
    }
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _handleStop() async {
    await _player.stop();
    setState(() => _position = Duration.zero);
  }

  Future<void> _handleLoop() async {
    final next = !_looping;
    setState(() => _looping = next);
    await _player.setLoopMode(next ? LoopMode.one : LoopMode.off);
  }

  Future<void> _jumpBackward() async {
    final newPos = Duration(
        milliseconds: (_position.inMilliseconds - 10000)
            .clamp(0, _duration.inMilliseconds));
    await _player.seek(newPos);
  }

  Future<void> _jumpForward() async {
    final newPos = Duration(
        milliseconds: (_position.inMilliseconds + 10000)
            .clamp(0, _duration.inMilliseconds));
    await _player.seek(newPos);
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _handleLogout() async {
    await _player.stop();
    await Storage.clearLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: const Color(0xFF0a1912),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // ── Page image with swipe ──────────────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _controlsVisible ? padding.top + 60 : 0,
              bottom: _controlsVisible ? padding.bottom + 182 : 0,
              left: _controlsVisible ? 18 : 0,
              right: _controlsVisible ? 18 : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF6E8),
                  borderRadius:
                      BorderRadius.circular(_controlsVisible ? 16 : 0),
                  border: _controlsVisible
                      ? Border.all(
                          color: const Color(0x38D4AF37), width: 1.2)
                      : null,
                  boxShadow: _controlsVisible
                      ? const [
                          BoxShadow(
                              color: Colors.black45,
                              blurRadius: 14,
                              offset: Offset(0, 10))
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(_controlsVisible ? 16 : 0),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _total,
                    onPageChanged: _onPageSwiped,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => setState(
                            () => _controlsVisible = !_controlsVisible),
                        child: Image.asset(
                          _imagePath(index + 1),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Top bar ───────────────────────────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _controlsVisible ? padding.top + 8 : -60.0,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _controlsVisible ? 1.0 : 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleBtn(Icons.logout, _handleLogout),
                    GestureDetector(
                      onTap: () => setState(() => _pickerVisible = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.list,
                                color: Color(0xFF0a1912), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$_page / $_total',
                              style: const TextStyle(
                                  color: Color(0xFF0a1912),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Player panel ──────────────────────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: _controlsVisible ? padding.bottom + 12 : -220.0,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _controlsVisible ? 1.0 : 0.0,
                child: _buildPlayerPanel(),
              ),
            ),

            // ── Page picker modal ─────────────────────────────────────
            if (_pickerVisible) _buildPicker(padding),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xD00a1912),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x4DD4AF37)),
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
      ),
    );
  }

  Widget _buildPlayerPanel() {
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xF20a1912),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x38D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
              color: Colors.black45, blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Slider ──
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFD4AF37),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFFD4AF37),
              overlayColor: const Color(0x22D4AF37),
              trackHeight: 3.5,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: progress,
              onChanged: (v) {
                final ms = (v * _duration.inMilliseconds).round();
                _player.seek(Duration(milliseconds: ms));
              },
            ),
          ),

          // ── Time row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position),
                    style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                if (_loadingAudio)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37),
                      strokeWidth: 1.5,
                    ),
                  )
                else
                  Text(_formatTime(_duration),
                      style: const TextStyle(
                          color: Color(0x99D4AF37),
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Controls row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Loop
              _iconBtn(
                icon: Icons.repeat,
                onTap: _handleLoop,
                active: _looping,
              ),
              // -10s
              _labeledIconBtn(
                icon: Icons.replay_10,
                label: '-10s',
                onTap: _jumpBackward,
              ),
              // Prev
              IconButton(
                onPressed: _page > 1 ? () => _goTo(_page - 1) : null,
                icon: Icon(
                  Icons.skip_previous_rounded,
                  color: _page > 1
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF3a4a40),
                  size: 28,
                ),
                padding: EdgeInsets.zero,
              ),
              // Play / Pause
              GestureDetector(
                onTap: _handlePlayPause,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x73D4AF37),
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: _loadingAudio
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: Color(0xFF0a1912),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          _playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF0a1912),
                          size: 34,
                        ),
                ),
              ),
              // Next
              IconButton(
                onPressed: _page < _total ? () => _goTo(_page + 1) : null,
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: _page < _total
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF3a4a40),
                  size: 28,
                ),
                padding: EdgeInsets.zero,
              ),
              // +10s
              _labeledIconBtn(
                icon: Icons.forward_10,
                label: '+10s',
                onTap: _jumpForward,
              ),
              // Stop
              _iconBtn(
                icon: Icons.stop_rounded,
                onTap: _handleStop,
                active: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool active,
    double size = 22,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD4AF37) : Colors.white10,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFF0a1912) : const Color(0xFFD4AF37),
          size: size,
        ),
      ),
    );
  }

  Widget _labeledIconBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPicker(EdgeInsets padding) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _pickerVisible = false),
            child: Container(color: Colors.black54),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55),
              padding:
                  EdgeInsets.fromLTRB(16, 12, 16, padding.bottom + 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0f2519),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: Color(0x33D4AF37), width: 1.5),
                  left: BorderSide(color: Color(0x33D4AF37), width: 1.5),
                  right: BorderSide(color: Color(0x33D4AF37), width: 1.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0x59D4AF37),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Select Page',
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: _total,
                      itemBuilder: (_, i) {
                        final n = i + 1;
                        final active = n == _page;
                        return GestureDetector(
                          onTap: () => _goTo(n),
                          child: Container(
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFD4AF37)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active
                                    ? const Color(0xFFD4AF37)
                                    : Colors.white12,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$n',
                                style: TextStyle(
                                  color: active
                                      ? const Color(0xFF0a1912)
                                      : const Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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