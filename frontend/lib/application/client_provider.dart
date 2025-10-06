import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:invoice/data/services/api_service.dart';

import '../data/dtos/client_create.dart';
import '../data/dtos/client_update.dart';
import '../data/models/client.dart';
import '../data/repositories/client_repository.dart';
import '../data/services/client_service.dart';

class ClientState {
  final List<Client> clients;
  final bool loading;
  final String? error;

  ClientState({this.clients = const [], this.loading = false, this.error});

  ClientState copyWith({List<Client>? clients, bool? loading, String? error}) {
    return ClientState(
      clients: clients ?? this.clients,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ClientController extends StateNotifier<ClientState> {
  final ClientRepository _clientRepository;

  ClientController(this._clientRepository) : super(ClientState());

  Future<void> loadClients({
    String? search,
    int skip = 0,
    int limit = 20,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final clients = await _clientRepository.getClients(
        search: search,
        skip: skip,
        limit: limit,
      );
      state = state.copyWith(clients: clients, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<Client?> loadClientById(int clientId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final client = await _clientRepository.getClientById(clientId);
      state = state.copyWith(loading: false);
      return client;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Client?> createClient(ClientCreate clientCreate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final client = await _clientRepository.createClient(clientCreate);
      // Add the new client to the list
      final updatedClients = [...state.clients, client];
      state = state.copyWith(clients: updatedClients, loading: false);
      return client;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<Client?> updateClient(int clientId, ClientUpdate clientUpdate) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final client = await _clientRepository.updateClient(
        clientId,
        clientUpdate,
      );
      // Update the client in the list
      final updatedClients =
          state.clients.map((c) => c.id == clientId ? client : c).toList();
      state = state.copyWith(clients: updatedClients, loading: false);
      return client;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> deleteClient(int clientId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _clientRepository.deleteClient(clientId);
      // Remove the client from the list
      final updatedClients =
          state.clients.where((c) => c.id != clientId).toList();
      state = state.copyWith(clients: updatedClients, loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final _clientServiceProvider = Provider(
  (ref) => ClientService(ref.read(apiServiceProvider)),
);
final _clientRepositoryProvider = Provider(
  (ref) => ClientRepository(ref.read(_clientServiceProvider)),
);
final clientProvider = StateNotifierProvider<ClientController, ClientState>(
  (ref) => ClientController(ref.read(_clientRepositoryProvider)),
);
