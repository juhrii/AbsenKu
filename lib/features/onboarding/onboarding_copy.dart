/// Kumpulan seluruh teks onboarding AbsenKu dalam bahasa Indonesia.
/// Disimpan terpusat agar mudah ditinjau, diubah, atau dilokalisasi.
abstract final class OnboardingCopy {
  static const String appName = 'AbsenKu';
  static const String skipAction = 'Lewati';
  static const String nextAction = 'Lanjut';
  static const String backAction = 'Kembali';
  static const String startAction = 'Mulai';

  // Layar 1: Selamat datang (AbsenKu)
  static const String welcomeTag = 'PRESENSI SEKOLAH';
  static const String welcomeTitle = 'Masuk sekolah tercatat rapi.';
  static const String welcomeDescription =
      'Catat kehadiran siswa lewat kamera wajah dan lokasi, lalu pantau rekap kelas dari satu aplikasi.';
  static const String welcomeCardCaption = 'Masuk pagi · 07.00 WIB';
  static const String welcomeCardSubcaption = 'Tercatat otomatis di log sekolah';
  static const String welcomeSemanticsIllustration =
      'Ilustrasi jam masuk sekolah dan penanda waktu hadir';

  // Layar 2: Absen wajah & lokasi (Geofence + Selfie)
  static const String geofenceTag = 'WAJAH & LOKASI';
  static const String geofenceTitle = 'Tatap kamera di area sekolah.';
  static const String geofenceDescription =
      'Aplikasi mencocokkan wajah dan memeriksa radius lokasi sebelum jam hadir dicatat. Jika ada kendala, petugas bisa mencatat manual per kelas.';
  static const String geofenceBadge = 'Area sekolah';
  static const String geofenceStatus = 'Wajah terverifikasi';
  static const String geofenceSemanticsIllustration =
      'Ilustrasi radius lokasi sekolah dan bingkai kamera wajah';

  // Layar 3: Rekap kelas & tombol masuk/daftar
  static const String historyTag = 'REKAP KEHADIRAN';
  static const String historyTitle = 'Rekap kelas tersusun otomatis.';
  static const String historyDescription =
      'Pantau jam masuk, jam pulang, dan rekap mingguan per jurusan maupun kelas kapan saja. Data tetap tersimpan saat sinyal lemah.';
  static const String historySampleHeader = 'Rekap mingguan';
  static const String historySampleMetric = 'XII RPL 1';
  static const String historySemanticsIllustration =
      'Ilustrasi grafik batang rekap mingguan dan tanda centang terverifikasi';

  static const String loginButton = 'Masuk';
  static const String registerButton = 'Daftar akun baru';

  static String progressSemantics(int current, int total) =>
      'Layar $current dari $total';
}
