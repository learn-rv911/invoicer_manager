import '../dtos/client_create.dart';
import '../dtos/client_update.dart';
import '../models/client.dart';
import '../services/client_service.dart';

class ClientRepository {
  final ClientService _clientService;

  ClientRepository(this._clientService);

  Future<List<Client>> getClients({
    String? search,
    int skip = 0,
    int limit = 20,
  }) {
    return _clientService.getClients(search: search, skip: skip, limit: limit);
  }

  Future<Client> getClientById(int clientId) {
    return _clientService.getClientById(clientId);
  }

  Future<Client> createClient(ClientCreate clientCreate) {
    return _clientService.createClient(clientCreate);
  }

  Future<Client> updateClient(int clientId, ClientUpdate clientUpdate) {
    return _clientService.updateClient(clientId, clientUpdate);
  }

  Future<void> deleteClient(int clientId) {
    return _clientService.deleteClient(clientId);
  }
}
