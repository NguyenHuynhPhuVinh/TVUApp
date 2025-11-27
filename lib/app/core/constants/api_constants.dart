class ApiConstants {
  static const String baseUrl = 'https://ttsv.tvu.edu.vn';
  static const int timeout = 10000;

  // Auth
  static const String login = '/api/auth/login';

  // Schedule
  static const String schedule = '/api/sch/w-locdstkbtuanusertheohocky';

  // Grades
  static const String grades = '/public/api/srm/w-locdsdiemsinhvien';

  // Tuition
  static const String tuition = '/public/api/rms/w-locdstonghophocphisv';

  // Student Info
  static const String studentInfo = '/public/api/dkmh/w-locsinhvieninfo';

  // Curriculum
  static const String curriculum = '/public/api/sch/w-locdsctdtsinhvien';

  // News
  static const String news = '/public/api/web/w-locdsbaidang';
}
