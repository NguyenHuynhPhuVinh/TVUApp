class ApiConstants {
  static const String baseUrl = 'https://ttsv.tvu.edu.vn';
  static const int timeout = 10000;

  // Auth
  static const String login = '/api/auth/login';

  // Schedule
  static const String schedule = '/api/sch/w-locdstkbtuanusertheohocky';
  static const String semesters = '/api/sch/w-locdshockytkbuser';

  // Grades
  static const String grades = '/api/srm/w-locdsdiemsinhvien';

  // Tuition
  static const String tuition = '/api/rms/w-locdstonghophocphisv';

  // Student Info
  static const String studentInfo = '/api/dkmh/w-locsinhvieninfo';

  // Curriculum
  static const String curriculum = '/api/sch/w-locdsctdtsinhvien';

  // News/Notifications
  static const String notifications = '/api/web/w-locdsthongbao';
}
