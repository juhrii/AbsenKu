/// Kumpulan seluruh teks onboarding AbsenKu dalam bahasa Indonesia.
/// Disimpan terpusat agar mudah ditinjau, diubah, atau dilokalisasi.
abstract final class OnboardingCopy {
  static const String appName = 'AbsenKu';
  static const String skipAction = 'Lewati';
  static const String nextAction = 'Lanjut';
  static const String backAction = 'Kembali';
  static const String startAction = 'Mulai';
  static const String allowAction = 'Izinkan';
  static const String grantedAction = 'Aktif';
  static const String openSettingsAction = 'Pengaturan';

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

  // Layar 3: Rekap kelas & izin perangkat + tombol masuk/daftar
  static const String historyTag = 'REKAP & PERSIAPAN';
  static const String historyTitle = 'Rekap tersusun, siap absen.';
  static const String historyDescription =
      'Pantau rekap mingguan per jurusan maupun kelas, dan aktifkan izin di bawah bila ingin langsung presensi.';
  static const String historySampleHeader = 'Rekap mingguan · XII RPL 1';
  static const String historySampleMetric = 'Tersinkron';
  static const String historySemanticsIllustration =
      'Ilustrasi grafik batang rekap mingguan dan tanda centang terverifikasi';

  // Izin perangkat ringkas (dijelaskan sebelum dialog sistem muncul)
  static const String locationLabel = 'Lokasi sekolah';
  static const String locationReason =
      'Dicek hanya saat menekan tombol absen agar posisi di area sekolah.';
  static const String locationPermanentDeniedHelp =
      'Izin lokasi dimatikan di setelan HP. Ketuk Pengaturan untuk mengaktifkan.';
  static const String locationSemanticsIllustration =
      'Ikon pin lokasi untuk verifikasi area sekolah';

  static const String cameraLabel = 'Kamera depan';
  static const String cameraReason =
      'Dipakai mendaftarkan dan memindai wajah saat presensi berlangsung.';
  static const String cameraPermanentDeniedHelp =
      'Izin kamera terkunci di setelan HP. Ketuk Pengaturan saat siap presensi wajah.';
  static const String cameraSemanticsIllustration =
      'Ikon lensa kamera untuk pendaftaran dan presensi wajah';

  static const String notificationLabel = 'Pengingat masuk';
  static const String notificationReason =
      'Memberi pengingat sebelum jam masuk dan status sinkronisasi absen.';
  static const String notificationPermanentDeniedHelp =
      'Notifikasi nonaktif di setelan HP. Anda tetap bisa masuk aplikasi.';
  static const String notificationSemanticsIllustration =
      'Ikon lonceng pengingat jam masuk sekolah';

  static const String optionalPermissionsNote =
      'Izin boleh diaktifkan nanti tanpa mengganggu akses masuk akun.';
  static const String loginButton = 'Masuk';
  static const String registerButton = 'Daftar akun baru';

  static String progressSemantics(int current, int total) =>
      'Layar $current dari $total';
}
