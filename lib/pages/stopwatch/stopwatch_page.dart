import 'dart:async';

import 'package:flutter/material.dart';

/// Status stopwatch. Dipakai untuk validasi: tombol yang boleh ditekan
/// berbeda-beda tergantung status ini, dan setiap aksi divalidasi ulang
/// terhadap status sebelum dieksekusi (bukan cuma mengandalkan tombol
/// disabled di UI).
enum _StopwatchStatus { idle, running, paused }

/// Menu Stopwatch.
///
/// Dibangun di atas [Stopwatch] bawaan Dart (bukan menghitung sendiri
/// pakai counter + Timer.periodic) supaya waktu yang ditampilkan akurat
/// dan tidak "ngedrift" walau frame UI sempat telat/skip. [Timer.periodic]
/// di sini HANYA dipakai untuk memicu rebuild tampilan, bukan sebagai
/// sumber waktu.
///
/// Error handling yang diterapkan (sesuai permintaan tugas):
/// - Setiap aksi (start/pause/lap/reset) divalidasi dulu terhadap status
///   saat ini SEBELUM dieksekusi -> kalau tidak valid, dilempar
///   [StateError] dengan pesan jelas, ditangkap, lalu ditampilkan lewat
///   [SnackBar] (bukan crash / silent fail).
/// - Tombol yang sedang tidak valid untuk status saat ini otomatis
///   di-nonaktifkan (disabled) di UI, jadi validasi di atas jadi lapisan
///   pertahanan kedua kalau ada race condition (mis. dua tap super cepat).
/// - [Timer] internal selalu dibatalkan dengan aman sebelum dibuat ulang
///   (mencegah timer dobel yang bisa bikin UI update 2x lebih cepat) dan
///   selalu di-cancel di [dispose] untuk mencegah memory leak.
/// - Semua `setState` dijaga dengan pengecekan [mounted], karena callback
///   [Timer.periodic] bisa saja masih tertunda saat halaman ini sudah
///   ditutup duluan oleh user.
class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  _StopwatchStatus _status = _StopwatchStatus.idle;
  final List<Duration> _laps = [];

  /// Pesan error terakhir untuk ditampilkan di UI (selain lewat SnackBar),
  /// supaya kalau user sempat tidak lihat SnackBar-nya, masih ada jejak
  /// pesannya di layar.
  String? _lastError;

  @override
  void dispose() {
    // WAJIB: kalau tidak di-cancel, timer tetap jalan di background walau
    // halaman sudah di-dispose -> memory leak & callback error karena
    // widget-nya sudah tidak ada.
    _ticker?.cancel();
    super.dispose();
  }

  /// Bungkus semua aksi user dengan penanganan error yang konsisten:
  /// jalankan [action], kalau berhasil bersihkan pesan error lama; kalau
  /// gagal (mis. [StateError] dari validasi status), tangkap, simpan
  /// pesannya, dan tampilkan SnackBar. Tidak ada aksi yang boleh membuat
  /// aplikasi crash hanya karena ditekan di waktu yang salah.
  void _runSafely(String actionName, void Function() action) {
    try {
      action();
      setState(() => _lastError = null);
    } on StateError catch (e) {
      setState(() => _lastError = e.message);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
    } catch (e) {
      // Jaring pengaman terakhir untuk error tak terduga di luar
      // StateError, supaya tetap tertangani rapi, bukan crash.
      final message = 'Terjadi kesalahan tak terduga: $e';
      setState(() => _lastError = message);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
      );
    }
  }

  void _startTicker() {
    // Cegah timer dobel: kalau sebelumnya sudah ada ticker aktif (mis.
    // karena start ditekan lebih dari sekali sebelum status sempat
    // ter-update), batalkan dulu yang lama sebelum bikin yang baru.
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted) {
        _ticker?.cancel();
        return;
      }
      setState(() {});
    });
  }

  void _handleStart() {
    _runSafely('start', () {
      if (_status == _StopwatchStatus.running) {
        throw StateError('Stopwatch sudah berjalan.');
      }
      _stopwatch.start();
      _startTicker();
      _status = _StopwatchStatus.running;
    });
  }

  void _handlePause() {
    _runSafely('pause', () {
      if (_status != _StopwatchStatus.running) {
        throw StateError('Stopwatch belum berjalan, tidak bisa dijeda.');
      }
      _stopwatch.stop();
      _ticker?.cancel();
      _status = _StopwatchStatus.paused;
    });
  }

  void _handleLap() {
    _runSafely('lap', () {
      if (_status != _StopwatchStatus.running) {
        throw StateError('Mulai stopwatch dulu sebelum mencatat lap.');
      }
      _laps.insert(0, _stopwatch.elapsed);
    });
  }

  void _handleReset() {
    _runSafely('reset', () {
      if (_status == _StopwatchStatus.running) {
        throw StateError('Jeda dulu sebelum mereset stopwatch.');
      }
      if (_status == _StopwatchStatus.idle && _laps.isEmpty) {
        throw StateError('Stopwatch masih di 00:00, tidak ada yang direset.');
      }
      _stopwatch.reset();
      _ticker?.cancel();
      _laps.clear();
      _status = _StopwatchStatus.idle;
    });
  }

  /// Format [Duration] jadi "MM:SS.cc" (menit:detik.centidetik), atau
  /// "H:MM:SS.cc" kalau sudah lewat 1 jam. Dibungkus try-catch supaya
  /// kalau suatu saat ada nilai durasi yang aneh (negatif/overflow),
  /// halaman tetap menampilkan sesuatu yang masuk akal alih-alih crash.
  String _formatDuration(Duration d) {
    try {
      if (d.isNegative) {
        throw const FormatException('Durasi tidak valid (negatif).');
      }
      final hours = d.inHours;
      final minutes = d.inMinutes.remainder(60);
      final seconds = d.inSeconds.remainder(60);
      final centis = (d.inMilliseconds.remainder(1000) / 10).floor();

      final mm = minutes.toString().padLeft(2, '0');
      final ss = seconds.toString().padLeft(2, '0');
      final cc = centis.toString().padLeft(2, '0');

      if (hours > 0) {
        return '$hours:$mm:$ss.$cc';
      }
      return '$mm:$ss.$cc';
    } catch (_) {
      return '00:00.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _status == _StopwatchStatus.running;
    final isPaused = _status == _StopwatchStatus.paused;
    final canReset = !isRunning && (isPaused || _laps.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              _formatDuration(_stopwatch.elapsed),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(switch (_status) {
              _StopwatchStatus.idle => 'Siap dimulai',
              _StopwatchStatus.running => 'Berjalan...',
              _StopwatchStatus.paused => 'Dijeda',
            }, style: TextStyle(color: Colors.grey.shade600)),
            if (_lastError != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _lastError!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  label: 'Lap',
                  icon: Icons.flag_outlined,
                  onPressed: isRunning ? _handleLap : null,
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  label: isRunning ? 'Jeda' : 'Mulai',
                  icon: isRunning ? Icons.pause : Icons.play_arrow,
                  isPrimary: true,
                  onPressed: isRunning ? _handlePause : _handleStart,
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  label: 'Reset',
                  icon: Icons.restart_alt,
                  onPressed: canReset ? _handleReset : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            Expanded(
              child: _laps.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada lap yang dicatat',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _laps.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final lapNumber = _laps.length - index;
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text(
                              '$lapNumber',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          title: Text('Lap $lapNumber'),
                          trailing: Text(
                            _formatDuration(_laps[index]),
                            style: const TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()],
                              fontWeight: FontWeight.w600,
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );

    return SizedBox(
      width: 84,
      height: 64,
      child: isPrimary
          ? FilledButton(onPressed: onPressed, child: child)
          : OutlinedButton(onPressed: onPressed, child: child),
    );
  }
}
