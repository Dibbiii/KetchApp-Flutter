class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    String result = 'ApiException: $message';
    if (statusCode != null) {
      result += ' (Status Code: $statusCode)';
    }
    return result;
  }
}

class UserAlreadyExistsException extends ApiException {
  UserAlreadyExistsException([String message = 'L\'utente esiste già nel sistema.'])
      : super(message, 409);
}

class BadRequestException extends ApiException {
  BadRequestException([String message = 'Richiesta non valida.'])
      : super(message, 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Non autorizzato.'])
      : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Accesso negato.']) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Risorsa non trovata.'])
      : super(message, 404);
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException(
      [String message = 'Errore interno del server.'])
      : super(message, 500);
}

// Puoi aggiungere altre eccezioni specifiche se necessario