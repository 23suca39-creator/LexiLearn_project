class VoiceCommands {
  static const openLibrary = 'open library';
  static const startQuiz = 'start quiz';
  static const checkProgress = 'check progress';
  static const changeThemeDark = 'change theme to dark';
  
  static bool matchesCommand(String input, String command) {
    return input.contains(command);
  }
}
