import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(const VoxLinkApp());
}

class VoxLinkApp extends StatelessWidget {
  const VoxLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOXLINK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.white,
        ),
      ),
      home: const JoinScreen(),
    );
  }
}

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  bool _isJoining = false;

  Future<void> _handleJoin() async {
    final name = _nameController.text.trim();
    final room = _roomController.text.trim();

    if (name.isEmpty || room.isEmpty) return;

    setState(() => _isJoining = true);

    // In a real app, you'd fetch this from your backend: https://vcrepo.vercel.app/api/get-token
    // For now, we will simulate the connection or you can replace this with your token fetch logic.
    
    try {
      // Request microphone permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Microphone permission denied');
      }

      // Navigate to Room Screen
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RoomScreen(
            userName: name,
            roomName: room,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mesh Background Simulation
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8, -0.6),
                  radius: 1.5,
                  colors: [Color(0xFF111111), Colors.black],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(LucideIcons.mic, color: Colors.black, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'VOXLINK',
                    style: GoogleFonts.cinzel(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.shield, size: 12, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text(
                          'ULTRA SECURE',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildInputField(
                    label: 'IDENTIFICATION',
                    hint: 'Enter your name',
                    icon: LucideIcons.user,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    label: 'ACCESS ROOM',
                    hint: 'Enter Room ID',
                    icon: LucideIcons.hash,
                    controller: _roomController,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isJoining ? null : _handleJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: _isJoining
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'ESTABLISH LINK',
                                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
                                ),
                                const SizedBox(width: 10),
                                const Icon(LucideIcons.zap, size: 18),
                              ],
                            ),
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: Icon(icon, color: Colors.white38, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class RoomScreen extends StatefulWidget {
  final String userName;
  final String roomName;

  const RoomScreen({
    super.key,
    required this.userName,
    required this.roomName,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  Room? _room;
  bool _isMicEnabled = true;
  final List<Participant> _participants = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    try {
      const serverUrl = 'wss://wasd-9bjnbp7j.livekit.cloud';
      final backendUrl = 'https://vcrepo.vercel.app/api/get-token?room=${widget.roomName}&user=${widget.userName}';

      setState(() => _isConnected = false);

      // Fetch Token from Backend
      final response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch token from backend: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final token = data['token'];

      _room = Room();
      
      // Connect to LiveKit
      await _room!.connect(serverUrl, token);

      setState(() {
        _isConnected = true;
        _isMicEnabled = _room!.localParticipant?.isMicrophoneEnabled() ?? true;
      });

      _room!.addListener(_onRoomUpdate);
      _onRoomUpdate();
    } catch (e) {
      print('Connect error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Failed: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _onRoomUpdate() {
    if (_room == null) return;
    setState(() {
      _participants.clear();
      _participants.addAll(_room!.remoteParticipants.values);
    });
  }

  @override
  void dispose() {
    _room?.removeListener(_onRoomUpdate);
    _room?.disconnect();
    _room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _PulseIndicator(),
                            const SizedBox(width: 8),
                            Text(
                              'LIVE SIGNAL',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.roomName.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('SECURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1)),
                      Text('AES-256', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1)),
                    ],
                  )
                ],
              ),
            ),

            // Participants Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _participants.length + 1, // +1 for local
                itemBuilder: (context, index) {
                  final participant = index == 0 ? _room?.localParticipant : _participants[index - 1];
                  if (participant == null) return const SizedBox();
                  return _ParticipantTile(
                    participant: participant,
                    isLocal: index == 0,
                  );
                },
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ControlButton(
                      icon: _isMicEnabled ? LucideIcons.mic : LucideIcons.micOff,
                      color: _isMicEnabled ? Colors.white : Colors.redAccent,
                      onTap: () async {
                        await _room?.localParticipant?.setMicrophoneEnabled(!_isMicEnabled);
                        setState(() => _isMicEnabled = !_isMicEnabled);
                      },
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(width: 12),
                    _ControlButton(
                      icon: LucideIcons.settings,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.phoneOff, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'TERMINATE',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Participant participant;
  final bool isLocal;

  const _ParticipantTile({required this.participant, required this.isLocal});

  @override
  Widget build(BuildContext context) {
    final isSpeaking = participant.isSpeaking;
    final isMuted = !participant.isMicrophoneEnabled();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSpeaking ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSpeaking ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isLocal ? Colors.white : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    (participant.identity ?? '?').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isLocal ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
              if (isSpeaking)
                const Positioned(
                  bottom: -10,
                  child: _VoiceWaves(),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                participant.identity ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              if (isLocal) const Text(' (YOU)', style: TextStyle(fontSize: 10, color: Colors.white54)),
              if (isMuted) ...[
                const SizedBox(width: 6),
                const Icon(LucideIcons.micOff, size: 12, color: Colors.redAccent),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  const _PulseIndicator();

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10)],
        ),
      ),
    );
  }
}

class _VoiceWaves extends StatelessWidget {
  const _VoiceWaves();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) => _WaveBar(index: index)),
    );
  }
}

class _WaveBar extends StatefulWidget {
  final int index;
  const _WaveBar({required this.index});

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller.drive(Tween(begin: 1.0, end: 1.8)),
      child: Container(
        width: 3,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
