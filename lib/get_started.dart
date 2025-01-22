import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_manager.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AudioPlayer _themeAudioPlayer;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController and Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Repeats the animation up and down

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Initialize the theme song audio player
    _themeAudioPlayer = AudioPlayer();
    _playThemeSong();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose animation controller
    _stopThemeSong(); // Ensure the theme song stops
    super.dispose();
  }

  Future<void> _playThemeSong() async {
    // Play the theme song in a loop
    await _themeAudioPlayer.setSource(AssetSource('audio/theme_song.mp3'));
    _themeAudioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the audio
    await _themeAudioPlayer.resume();
  }

  Future<void> _stopThemeSong() async {
    // Stop the theme song immediately
    await _themeAudioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Stop the theme song before navigating
        await _stopThemeSong();
        // Play the click effect globally
        AudioManager().playClickEffect();
        // Navigate to the SignIn screen
        Navigator.pushNamed(context, '/signin');
      },
      child: Scaffold(
        backgroundColor: Color(0xFFE3FF63), // Updated background color
        body: Stack(
          children: [
            // Logo Positioned
            Positioned(
              left: 45, // X coordinate
              top: 300, // Y coordinate
              child: Center(
                child: Image.asset(
                  'assets/wildlogo.png', // Path to your logo image
                  width: 312, // Updated width
                  height: 191, // Updated height
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Animated Text Positioned
            Positioned(
              left: 113, // X coordinate
              top: 567, // Y coordinate
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value), // Move up and down
                    child: Text(
                      'Tap anywhere to start',
                      style: TextStyle(
                        fontFamily: 'Minecraft', // Use the Minecraft font
                        fontSize: 15, // Updated font size
                        color: Colors.grey.withOpacity(0.9), // Gray color with 59% opacity
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
