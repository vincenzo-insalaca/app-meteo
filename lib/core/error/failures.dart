import 'package:equatable/equatable.dart';

/// Gerarchia sealed di errori del dominio.
/// Ogni sottoclasse rappresenta una categoria di errore specifica.
sealed class Failure extends Equatable implements Exception {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Nessuna connessione internet']);
}

final class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

final class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Impossibile ottenere la posizione']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Errore imprevisto']);
}
