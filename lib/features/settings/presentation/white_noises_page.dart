import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class WhiteNoisesPage extends StatefulWidget {
  const WhiteNoisesPage({Key? key}) : super(key: key);

  @override
  State<WhiteNoisesPage> createState() => _WhiteNoisesPageState();
}

class _WhiteNoisesPageState extends State<WhiteNoisesPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingMusic; // null = nessuna musica in riproduzione
  bool _isPaused = false;

  Future<void> _playMusic(int musicNumber) async {
    if (_playingMusic == musicNumber && !_isPaused) {
      await _audioPlayer.pause();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isPaused = true;
        });
      });
      return;
    }
    if (_playingMusic == musicNumber && _isPaused) {
      await _audioPlayer.resume();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isPaused = false;
        });
      });
      return;
    }
    await _audioPlayer.stop();

    final assetPath = 'audio/music_$musicNumber.mp3';
    print('Tentativo di riproduzione: $assetPath');
    await _audioPlayer.play(AssetSource(assetPath));
    // Non controlliamo più il risultato, la funzione play ora restituisce Future<void>
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _playingMusic = musicNumber;
        _isPaused = false;
      });
    });
  }

  Future<void> _pauseMusic() async {
    await _audioPlayer.pause();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isPaused = true;
      });
    });
  }

  Future<void> _resumeMusic() async {
    await _audioPlayer.resume();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isPaused = false;
      });
    });
  }

  Future<void> _stopMusic() async {
    await _audioPlayer.stop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _playingMusic = null;
        _isPaused = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('White Noises'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.background,
        foregroundColor: colors.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Scegli una musica per concentrarti',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              for (int i = 1; i <= 11; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Card(
                    elevation: _playingMusic == i ? 4 : 1,
                    color: _playingMusic == i ? colors.primaryContainer : colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _playingMusic == i ? colors.primary : colors.secondary,
                        child: Icon(
                          _playingMusic == i
                              ? (_isPaused ? Icons.play_arrow : Icons.pause)
                              : Icons.music_note,
                          color: colors.onPrimary,
                        ),
                      ),
                      title: Text(
                        'Musica $i',
                        style: TextStyle(
                          color: _playingMusic == i ? colors.primary : colors.onSurface,
                          fontWeight: _playingMusic == i ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _playingMusic == i
                              ? (_isPaused ? Icons.play_arrow : Icons.pause)
                              : Icons.play_arrow,
                          color: _playingMusic == i ? colors.primary : colors.onSurface,
                        ),
                        onPressed: () => _playMusic(i),
                        tooltip: _playingMusic == i
                            ? (_isPaused ? 'Riprendi' : 'Metti in pausa')
                            : 'Riproduci',
                      ),
                      onTap: () => _playMusic(i),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              if (_playingMusic != null)
                ElevatedButton.icon(
                  onPressed: _stopMusic,
                  icon: const Icon(Icons.stop),
                  label: const Text('Ferma la riproduzione'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

