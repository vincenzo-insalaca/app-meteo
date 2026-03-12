import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Astrae il controllo della connessione internet.
abstract class ConnectivityService {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class ConnectivityServiceImpl implements ConnectivityService {
  final InternetConnection _internetConnection;

  ConnectivityServiceImpl()
      : _internetConnection = InternetConnection.createInstance();

  @override
  Future<bool> get isConnected => _internetConnection.hasInternetAccess;

  @override
  Stream<bool> get onConnectivityChanged =>
      _internetConnection.onStatusChange.map(
        (status) => status == InternetStatus.connected,
      );
}
