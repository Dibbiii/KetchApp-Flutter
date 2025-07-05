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

class ConflictException extends ApiException {
  ConflictException([String message = 'Conflitto sulla risorsa.'])
      : super(message, 409);
}

class UserAlreadyExistsException extends ConflictException {
  UserAlreadyExistsException([super.message = 'L\'utente esiste già.']);
}

class UsernameAlreadyExistsException extends ConflictException {
  UsernameAlreadyExistsException([super.message = 'Questo username è già in uso.']);
}

class EmailAlreadyExistsInBackendException extends ConflictException {
  EmailAlreadyExistsInBackendException([super.message = 'Questa email è già registrata nel sistema.']);
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException(
      [String message = 'Errore interno del server.'])
      : super(message, 500);
}

class FetchDataException extends ApiException {
  FetchDataException([super.message = 'Errore durante il recupero dei dati.']);
}
