import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const VoxLinkApp());
}

// â”€â”€â”€ App Root â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class VoxLinkApp extends StatelessWidget {
  const VoxLinkApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoxLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: Color(0xFF0A0A0A),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const JoinScreen(),
    );
  }
}

// â”€â”€â”€ Join Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});
  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  bool _isJoining = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final name = _nameCtrl.text.trim();
    final room = _roomCtrl.text.trim();
    if (name.isEmpty || room.isEmpty) return;

    setState(() => _isJoining = true);
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) throw Exception('Microphone permission denied');

      // Fetch token from backend
      final uri = Uri.parse(
        'https://vcrepo.vercel.app/api/get-token?room=${Uri.encodeComponent(room)}&user=${Uri.encodeComponent(name)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw Exception('Backend error: ${res.statusCode}');

      final token = jsonDecode(res.body)['token'] as String;

      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RoomScreen(roomName: room, userName: name, token: token),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Background gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.5),
                radius: 1.4,
                colors: [Color(0xFF151515), Color(0xFF000000)],
              ),
            ),
          ),
        ),
        // Subtle grid lines
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        // Content
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.white.withOpacity(0.25), blurRadius: 40, spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.black, size: 36),
                  ),
                  const SizedBox(height: 24),
                  Text('VOXLINK', style: GoogleFonts.cinzel(
                    fontSize: 36, fontWeight: FontWeight.w900,
                    letterSpacing: 8, color: Colors.white,
                  )),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white.withOpacity(0.04),
                    ),
                    child: Text('ULTRA SECURE  â€¢  LOW LATENCY',
                      style: GoogleFonts.outfit(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        letterSpacing: 2, color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),
                  // Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Premium Voice Control',
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('Lightweight, encrypted, high-fidelity audio.',
                          style: GoogleFonts.outfit(fontSize: 13, color: Colors.white38)),
                        const SizedBox(height: 32),
                        _InputField(label: 'IDENTIFICATION', hint: 'Enter your name', icon: Icons.person_outline_rounded, controller: _nameCtrl),
                        const SizedBox(height: 20),
                        _InputField(label: 'ACCESS ROOM', hint: 'Enter Room ID', icon: Icons.tag_rounded, controller: _roomCtrl),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity, height: 58,
                          child: ElevatedButton(
                            onPressed: _isJoining ? null : _handleJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.white24,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isJoining
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text('ESTABLISH LINK', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.bolt_rounded, size: 20),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.lock_outline_rounded, size: 12, color: Colors.white30),
                    const SizedBox(width: 6),
                    Text('END-TO-END ENCRYPTED', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white30, letterSpacing: 1.5)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label, hint;
  final IconData icon;
  final TextEditingController controller;
  const _InputField({required this.label, required this.hint, required this.icon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.5, color: Colors.white38)),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.white30, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
        ),
      ),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;
    const step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// â”€â”€â”€ Room Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class RoomScreen extends StatefulWidget {
  final String roomName, userName, token;
  const RoomScreen({super.key, required this.roomName, required this.userName, required this.token});
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late Room _room;
  late EventsListener<RoomEvent> _listener;
  bool _micEnabled = true;
  final List<RemoteParticipant> _remoteParticipants = [];
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _room = Room();
    _listener = _room.createListener();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    try {
      await _room.connect(
        'wss://wasd-9bjnbp7j.livekit.cloud',
        widget.token,
        roomOptions: const RoomOptions(
          defaultAudioPublishOptions: AudioPublishOptions(name: 'microphone'),
        ),
      );
      await _room.localParticipant?.setMicrophoneEnabled(true);
      _listener
        ..on<ParticipantConnectedEvent>((e) { setState(() => _remoteParticipants.add(e.participant)); })
        ..on<ParticipantDisconnectedEvent>((e) { setState(() => _remoteParticipants.remove(e.participant)); })
        ..on<RoomDisconnectedEvent>((_) { if (mounted) Navigator.of(context).pop(); });

      setState(() {
        _connected = true;
        _remoteParticipants.addAll(_room.remoteParticipants.values);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e'), backgroundColor: Colors.redAccent),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    _room.disconnect();
    _room.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final enabled = !_micEnabled;
    await _room.localParticipant?.setMicrophoneEnabled(enabled);
    setState(() => _micEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final allParticipants = <_ParticipantInfo>[
      _ParticipantInfo(identity: widget.userName, isLocal: true,
        isMuted: !_micEnabled,
        isSpeaking: _room.localParticipant?.isSpeaking ?? false),
      ..._remoteParticipants.map((p) => _ParticipantInfo(
        identity: p.identity, isLocal: false,
        isMuted: !p.isMicrophoneEnabled(),
        isSpeaking: p.isSpeaking,
      )),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _PulseDot(),
                  const SizedBox(width: 8),
                  Text('LIVE SIGNAL', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.white60)),
                ]),
                const SizedBox(height: 4),
                Text(widget.roomName.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('SECURE', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white38)),
                Text('AES-256', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.white38)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          // Participants
          Expanded(
            child: !_connected
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  const SizedBox(height: 16),
                  Text('CONNECTING...', style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 2, color: Colors.white38)),
                ]))
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: allParticipants.length,
                  itemBuilder: (_, i) => _ParticipantTile(info: allParticipants[i]),
                ),
          ),
          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _CtrlBtn(
                  icon: _micEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                  color: _micEnabled ? Colors.white : Colors.redAccent,
                  bgColor: _micEnabled ? Colors.white.withOpacity(0.08) : Colors.redAccent.withOpacity(0.15),
                  onTap: _toggleMic,
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 28, color: Colors.white.withOpacity(0.1)),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _room.disconnect().then((_) => Navigator.of(context).pop()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(children: [
                    const Icon(Icons.phone_disabled_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text('TERMINATE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ParticipantInfo {
  final String identity;
  final bool isLocal, isMuted, isSpeaking;
  const _ParticipantInfo({required this.identity, required this.isLocal, required this.isMuted, required this.isSpeaking});
}

class _ParticipantTile extends StatelessWidget {
  final _ParticipantInfo info;
  const _ParticipantTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: info.isSpeaking ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: info.isSpeaking ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.06)),
        boxShadow: info.isSpeaking ? [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 20)] : [],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: info.isLocal ? Colors.white : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: info.isLocal ? null : Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Center(child: Text(
            info.identity.isEmpty ? '?' : info.identity[0].toUpperCase(),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: info.isLocal ? Colors.black : Colors.white),
          )),
        ),
        if (info.isSpeaking) ...[
          const SizedBox(height: 10),
          const _WaveIndicator(),
        ] else
          const SizedBox(height: 10),
        const SizedBox(height: 4),
        Text(
          info.isLocal ? '${info.identity} (You)' : info.identity,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        if (info.isMuted) ...[
          const SizedBox(height: 4),
          const Icon(Icons.mic_off_rounded, size: 13, color: Colors.redAccent),
        ],
      ]),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final Color color, bgColor;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.color, required this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}
class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(
        width: 7, height: 7,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.white, blurRadius: 8)],
        ),
      ),
    );
  }
}

class _WaveIndicator extends StatefulWidget {
  const _WaveIndicator();
  @override
  State<_WaveIndicator> createState() => _WaveIndicatorState();
}
class _WaveIndicatorState extends State<_WaveIndicator> with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(vsync: this, duration: Duration(milliseconds: 400 + i * 120))
        ..repeat(reverse: true);
      _controllers.add(c);
    }
  }
  @override
  void dispose() { for (final c in _controllers) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _controllers[i],
        builder: (_, __) => Container(
          width: 3,
          height: 6 + _controllers[i].value * 10,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        ),
      );
    }));
  }
}
