class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class NoInternetException extends ApiException {
  NoInternetException() : super('No internet connection. Please check your network.');
}

class ServerException extends ApiException {
  ServerException([String message = 'Something went wrong on the server.'])
      : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException() : super('Requested resource was not found.');
}
