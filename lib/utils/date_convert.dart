/// Kumpulan fungsi konversi tanggal & kalender untuk Menu Konversi.
///
/// Semua fungsi di sini murni (pure function) — tidak bergantung pada
/// Flutter widget ataupun database (Supabase), sesuai kriteria tugas
/// bahwa menu ini TIDAK terhubung dengan fitur shopping list.

// =======================================================================
// 1. KONVERSI TANGGAL MASEHI -> HIJRIAH
// =======================================================================
// Memakai algoritma aritmetik "Kuwaiti" (tabular Islamic calendar) --
// dihitung murni dari rumus matematis berbasis Julian Day Number, TANPA
// data rukyatul hilal. Sudah divalidasi terhadap beberapa tanggal acuan
// (mis. 19 Maret 2026 -> 30 Ramadan 1447H, sesuai kalender Hijriah yang
// dipublikasikan). Karena berbasis rumus (bukan pengamatan hilal
// langsung), hasilnya MUNGKIN berbeda 1 hari dari kalender Hijriah
// resmi/rukyat di beberapa kondisi batas awal bulan.

class HijriDate {
  final int day;
  final int month; // 1-12
  final int year;

  const HijriDate({required this.day, required this.month, required this.year});

  static const List<String> monthNames = [
    'Muharram',
    'Safar',
    'Rabiul Awal',
    'Rabiul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    "Sya'ban",
    'Ramadhan',
    'Syawal',
    "Dzulqa'dah",
    'Dzulhijjah',
  ];

  String get monthName => monthNames[month - 1];

  @override
  String toString() => '$day $monthName $year H';
}

/// Konversi tanggal Masehi [date] ke tanggal Hijriah.
HijriDate convertToHijri(DateTime date) {
  final jdn = _gregorianToJulianDayNumber(date.year, date.month, date.day);

  int l = jdn - 1948440 + 10632;
  final n = ((l - 1) / 10631).floor();
  l = l - 10631 * n + 354;
  final j =
      ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
      (l / 5670).floor() * ((43 * l) / 15238).floor();
  l =
      l -
      ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
      (j / 16).floor() * ((15238 * j) / 43).floor() +
      29;
  final monthH = ((24 * l) / 709).floor();
  final dayH = l - ((709 * monthH) / 24).floor();
  final yearH = 30 * n + j - 30;

  return HijriDate(day: dayH, month: monthH, year: yearH);
}

/// Julian Day Number dari tanggal Masehi (proleptic Gregorian calendar).
/// Ini adalah dasar perhitungan untuk konversi Hijriah di atas.
int _gregorianToJulianDayNumber(int year, int month, int day) {
  final a = ((14 - month) / 12).floor();
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;

  return day +
      ((153 * m + 2) / 5).floor() +
      365 * y +
      (y / 4).floor() -
      (y / 100).floor() +
      (y / 400).floor() -
      32045;
}

// =======================================================================
// 2. KONVERSI TANGGAL LAHIR -> UMUR
// =======================================================================
// Menghitung umur dari [birthDate] sampai [now] dalam 2 bentuk:
// - breakdown kalender: X tahun Y bulan Z hari (cara umum menyebut umur)
// - total dalam satu satuan saja: total bulan, hari, jam, menit, detik
//   sejak lahir (asumsi jam lahir 00:00:00 karena date picker cuma
//   mengambil tanggal, tanpa jam).

class AgeResult {
  final int years;
  final int months;
  final int days;
  final int totalMonths;
  final int totalDays;
  final int totalHours;
  final int totalMinutes;
  final int totalSeconds;

  const AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalMonths,
    required this.totalDays,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalSeconds,
  });
}

/// Hitung umur dari [birthDate] sampai [now] (default: waktu sekarang).
AgeResult calculateAge(DateTime birthDate, {DateTime? now}) {
  final today = now ?? DateTime.now();

  int years = today.year - birthDate.year;
  int months = today.month - birthDate.month;
  int days = today.day - birthDate.day;

  if (days < 0) {
    months -= 1;
    // DateTime(y, m, 0) otomatis "meluber" jadi hari terakhir bulan
    // sebelum bulan m -- trik standar buat cari jumlah hari bulan lalu.
    final daysInPrevMonth = DateTime(today.year, today.month, 0).day;
    days += daysInPrevMonth;
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }

  final totalMonths = years * 12 + months;
  final duration = today.difference(birthDate);

  return AgeResult(
    years: years,
    months: months,
    days: days,
    totalMonths: totalMonths,
    totalDays: duration.inDays,
    totalHours: duration.inHours,
    totalMinutes: duration.inMinutes,
    totalSeconds: duration.inSeconds,
  );
}

// =======================================================================
// 3. KONVERSI KE WETON (Kalender Jawa)
// =======================================================================
// Weton = gabungan siklus 7 hari (dina: Senin-Minggu) dan siklus 5 hari
// pasaran (Legi, Pahing, Pon, Wage, Kliwon). Kedua siklus ini berjalan
// terus-menerus tanpa koreksi, jadi bisa dihitung murni dari selisih
// hari terhadap 1 tanggal referensi yang wetonnya sudah pasti diketahui.
//
// Referensi yang dipakai: 25 Maret 2020 = Rabu Kliwon.
// Sudah divalidasi cocok dengan beberapa tanggal lain juga (mis.
// 19 Maret 2026 = Kamis Kliwon, 30 September 2020 = Rabu Wage).

const List<String> _hariNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const List<String> _pasaranNames = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];

class WetonResult {
  final String hari;
  final String pasaran;

  const WetonResult({required this.hari, required this.pasaran});

  String get label => '$hari $pasaran';
}

WetonResult calculateWeton(DateTime date) {
  // Hari (siklus 7 hari) langsung dari DateTime.weekday:
  // 1 = Senin, ..., 7 = Minggu -> pas dengan urutan _hariNames.
  final hari = _hariNames[date.weekday - 1];

  // Pasaran (siklus 5 hari), dihitung dari referensi 25 Maret 2020 = Kliwon.
  final referensi = DateTime(2020, 3, 25);
  const referensiIndex = 4; // index 'Kliwon' di _pasaranNames

  // Buang komponen jam/menit/detik dulu supaya selisih hari akurat,
  // tidak terpengaruh sisa waktu di tanggal yang dipilih.
  final tanggalSaja = DateTime(date.year, date.month, date.day);
  final selisihHari = tanggalSaja.difference(referensi).inDays;

  // Catatan: operator `%` di Dart selalu mengembalikan hasil non-negatif
  // kalau pembaginya positif, jadi aman dipakai walau selisihHari
  // negatif (tanggal sebelum tanggal referensi).
  final pasaranIndex = (referensiIndex + selisihHari) % 5;

  return WetonResult(hari: hari, pasaran: _pasaranNames[pasaranIndex]);
}

// =======================================================================
// 4. KONVERSI TAHUN SAKA (Kalender Bali)
// =======================================================================
// Tahun Saka Bali dimulai setiap Hari Raya Nyepi (sekitar pertengahan
// Maret, tanggal pastinya berubah tiap tahun mengikuti kalender lunar).
// Perhitungan bulan & wuku Saka secara penuh membutuhkan tabel pawukon
// yang kompleks dan berada di luar cakupan implementasi ini -- yang
// dihitung di sini HANYA tahunnya.
//
// Rumus umum: Tahun Saka = Tahun Masehi - 78, dengan penyesuaian kalau
// tanggal yang dipilih masih SEBELUM Nyepi tahun itu (diperkirakan
// pertengahan Maret), maka tahun Saka-nya masih tahun sebelumnya.
//
// Divalidasi terhadap 2 tanggal Nyepi asli:
// - 19 Maret 2026 = Nyepi Tahun Baru Saka 1948  (2026 - 78 = 1948 ✓)
// - 25 Maret 2020 = Nyepi Tahun Baru Saka 1942  (2020 - 78 = 1942 ✓)
//
// CATATAN: tanggal Nyepi asli tiap tahun bisa jatuh dari akhir Februari
// sampai akhir Maret. Ambang batas "15 Maret" di bawah ini adalah
// PERKIRAAN kasar, bukan tanggal Nyepi sesungguhnya -- jadi hasil di
// sekitar tanggal itu (akhir Feb - akhir Maret) berpotensi meleset.
int calculateTahunSaka(DateTime date) {
  int tahunSaka = date.year - 78;

  final belumMelewatiPerkiraanNyepi =
      date.month < 3 || (date.month == 3 && date.day < 15);

  if (belumMelewatiPerkiraanNyepi) {
    tahunSaka -= 1;
  }

  return tahunSaka;
}
