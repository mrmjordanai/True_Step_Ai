/// Voice commands for controlling TrueStep sessions
///
/// These commands can be triggered by voice input or UI buttons
/// during an active session.
enum SessionCommand {
  /// Advance to the next step in the guide
  nextStep,

  /// Go back to the previous step
  previousStep,

  /// Repeat the current instruction via TTS
  repeatInstruction,

  /// Preview what the next step will be
  previewNext,

  /// Pause the current session
  pause,

  /// Resume a paused session
  resume,

  /// Stop and exit the current session
  stop,

  /// Show available commands or help
  help,

  /// Skip the current step (usually from intervention)
  skip,
}

/// Maps voice command phrases to [SessionCommand] values
///
/// Supports multiple variations of each command for natural speech.
/// All keys are lowercase for case-insensitive matching.
const Map<String, SessionCommand> voiceCommands = {
  // Next step variations
  'next': SessionCommand.nextStep,
  'next step': SessionCommand.nextStep,
  'continue': SessionCommand.nextStep,
  'done': SessionCommand.nextStep,
  'finished': SessionCommand.nextStep,
  'complete': SessionCommand.nextStep,
  'go': SessionCommand.nextStep,
  'okay': SessionCommand.nextStep,
  'ok': SessionCommand.nextStep,

  // Previous step variations
  'back': SessionCommand.previousStep,
  'go back': SessionCommand.previousStep,
  'previous': SessionCommand.previousStep,
  'previous step': SessionCommand.previousStep,
  'undo': SessionCommand.previousStep,
  'last step': SessionCommand.previousStep,

  // Repeat variations
  'repeat': SessionCommand.repeatInstruction,
  'say again': SessionCommand.repeatInstruction,
  'again': SessionCommand.repeatInstruction,
  'what': SessionCommand.repeatInstruction,
  'pardon': SessionCommand.repeatInstruction,
  'sorry': SessionCommand.repeatInstruction,

  // Preview next variations
  "what's next": SessionCommand.previewNext,
  'whats next': SessionCommand.previewNext,
  'preview': SessionCommand.previewNext,
  'next one': SessionCommand.previewNext,

  // Pause variations
  'pause': SessionCommand.pause,
  'wait': SessionCommand.pause,
  'hold on': SessionCommand.pause,
  'hold': SessionCommand.pause,
  'one moment': SessionCommand.pause,
  'one second': SessionCommand.pause,

  // Resume variations
  'resume': SessionCommand.resume,
  'start': SessionCommand.resume,
  'ready': SessionCommand.resume,
  "let's go": SessionCommand.resume,
  'lets go': SessionCommand.resume,
  "i'm ready": SessionCommand.resume,
  'im ready': SessionCommand.resume,

  // Stop variations
  'stop': SessionCommand.stop,
  'cancel': SessionCommand.stop,
  'end': SessionCommand.stop,
  'end session': SessionCommand.stop,
  'quit': SessionCommand.stop,
  'exit': SessionCommand.stop,

  // Help variations
  'help': SessionCommand.help,
  'commands': SessionCommand.help,
  'what can i say': SessionCommand.help,
  'options': SessionCommand.help,

  // Skip variations
  'skip': SessionCommand.skip,
  'skip step': SessionCommand.skip,
  'skip this': SessionCommand.skip,
  'skip it': SessionCommand.skip,
  'move on': SessionCommand.skip,
};

/// Utility class for parsing voice commands
class CommandParser {
  /// Parse a transcript into a [SessionCommand]
  ///
  /// Returns null if no command is recognized.
  /// Uses exact matching first, then falls back to fuzzy matching.
  static SessionCommand? parse(String transcript) {
    final normalized = _normalize(transcript);

    // Try exact match first
    if (voiceCommands.containsKey(normalized)) {
      return voiceCommands[normalized];
    }

    // Sort entries by key length (descending) to match longer phrases first
    // This ensures "go back" matches before "go"
    final sortedEntries = voiceCommands.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    // Try to find a command within the transcript
    for (final entry in sortedEntries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    // Try fuzzy matching for single-word commands
    final words = normalized.split(' ');
    for (final word in words) {
      final match = _fuzzyMatch(word);
      if (match != null) {
        return match;
      }
    }

    return null;
  }

  /// Get suggestions for partial command input
  static List<String> getSuggestions(String partial) {
    final normalized = _normalize(partial);
    return voiceCommands.keys
        .where((cmd) => cmd.startsWith(normalized))
        .take(5)
        .toList();
  }

  /// Normalize text for matching
  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Fuzzy match for common misrecognitions
  static SessionCommand? _fuzzyMatch(String word) {
    // Common speech-to-text errors
    const fuzzyMappings = {
      'nxt': SessionCommand.nextStep,
      'bck': SessionCommand.previousStep,
      'bak': SessionCommand.previousStep,
      'repet': SessionCommand.repeatInstruction,
      'paus': SessionCommand.pause,
      'resum': SessionCommand.resume,
      'stp': SessionCommand.stop,
      'hlp': SessionCommand.help,
    };

    // Check if word is similar enough to a known command
    for (final entry in fuzzyMappings.entries) {
      if (_similarity(word, entry.key) > 0.7) {
        return entry.value;
      }
    }

    // Also check against actual command keys
    for (final entry in voiceCommands.entries) {
      if (_similarity(word, entry.key) > 0.8) {
        return entry.value;
      }
    }

    return null;
  }

  /// Calculate similarity between two strings (0.0 to 1.0)
  static double _similarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final distance = _levenshteinDistance(s1, s2);
    final maxLen = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distance / maxLen);
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> prev = List.generate(s2.length + 1, (i) => i);
    List<int> curr = List.filled(s2.length + 1, 0);

    for (int i = 1; i <= s1.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1, // insertion
          prev[j] + 1, // deletion
          prev[j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
      final temp = prev;
      prev = curr;
      curr = temp;
    }

    return prev[s2.length];
  }
}

/// Extension to get display-friendly command descriptions
extension SessionCommandExtension on SessionCommand {
  /// Human-readable name for the command
  String get displayName {
    switch (this) {
      case SessionCommand.nextStep:
        return 'Next Step';
      case SessionCommand.previousStep:
        return 'Previous Step';
      case SessionCommand.repeatInstruction:
        return 'Repeat';
      case SessionCommand.previewNext:
        return 'Preview Next';
      case SessionCommand.pause:
        return 'Pause';
      case SessionCommand.resume:
        return 'Resume';
      case SessionCommand.stop:
        return 'Stop';
      case SessionCommand.help:
        return 'Help';
      case SessionCommand.skip:
        return 'Skip';
    }
  }

  /// Example phrase for this command
  String get examplePhrase {
    switch (this) {
      case SessionCommand.nextStep:
        return 'Say "next" or "done"';
      case SessionCommand.previousStep:
        return 'Say "back" or "previous"';
      case SessionCommand.repeatInstruction:
        return 'Say "repeat" or "again"';
      case SessionCommand.previewNext:
        return 'Say "what\'s next"';
      case SessionCommand.pause:
        return 'Say "pause" or "wait"';
      case SessionCommand.resume:
        return 'Say "resume" or "ready"';
      case SessionCommand.stop:
        return 'Say "stop" or "cancel"';
      case SessionCommand.help:
        return 'Say "help" or "commands"';
      case SessionCommand.skip:
        return 'Say "skip" or "move on"';
    }
  }
}
