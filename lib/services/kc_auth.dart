import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String keycloakServer = "http://localhost:8080";
  String? token; // Store the token after fetching it
  final String realm = "master"; // Adjust the realm as needed
  final String clientId = "test-mfa"; // Adjust the client-id as needed

  // Method to get the Auth Token
  Future<String?> getAuthToken() async {
    final url = Uri.parse(
        "$keycloakServer/realms/$realm/protocol/openid-connect/token");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "grant_type": "password",
        "client_id": clientId,
        "username": "admin",
        "password": "admin",
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      token = responseBody['access_token'];
      return token;
    } else {
      print("Failed to get token: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  // Method to create a new user
  Future<bool> createUser() async {
    if (token == null) {
      print("Token is not available. Fetch the token first.");
      return false;
    }

    final url = Uri.parse("$keycloakServer/admin/realms/$realm/users");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": "jonnyj",
        "enabled": true,
        "firstName": "New",
        "lastName": "User",
        "email": "jonnyjohnson1@gmail.com",
        "attributes": {
          "phoneNumber": "512-508-4318",
        },
      }),
    );

    if (response.statusCode == 201) {
      print("User created successfully!");
      return true;
    } else {
      print("Failed to create user: ${response.statusCode} ${response.body}");
      return false;
    }
  }

  // Method to login with username and password
  Future<String?> loginWithUsernameAndPassword(
      String username, String password) async {
    final url = Uri.parse(
        "$keycloakServer/realms/$realm/protocol/openid-connect/token");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "grant_type": "password",
        "client_id": "test-mfa",
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final accessToken = responseBody['access_token'];
      print("Login successful! Access Token: $accessToken");
      return accessToken;
    } else {
      print("Login failed: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  // Method to create a new user and set the password
  Future<bool> createUserAndSetPassword(
      String username, String password) async {
    if (token == null) {
      print("Token is not available. Fetch the token first.");
      return false;
    }

    // Create User
    final createUserUrl =
        Uri.parse("$keycloakServer/admin/realms/$realm/users");
    final createUserResponse = await http.post(
      createUserUrl,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "enabled": true,
        "firstName": "New",
        "lastName": "User",
        "email": "$username@example.com",
        "attributes": {
          "phoneNumber": "512-508-4318",
        },
      }),
    );

    if (createUserResponse.statusCode != 201) {
      print(
          "Failed to create user: ${createUserResponse.statusCode} ${createUserResponse.body}");
      return false;
    }

    // Retrieve User ID
    final getUserUrl = Uri.parse("$keycloakServer/admin/realms/$realm/users");
    final getUserResponse = await http.get(
      getUserUrl,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (getUserResponse.statusCode != 200) {
      print(
          "Failed to retrieve user ID: ${getUserResponse.statusCode} ${getUserResponse.body}");
      return false;
    }

    final users = jsonDecode(getUserResponse.body) as List<dynamic>;
    final user = users.firstWhere(
      (u) => u['username'] == username,
      orElse: () => null,
    );

    if (user == null) {
      print("User not found after creation.");
      return false;
    }

    final userId = user['id'];

    // Set Password
    final setPasswordUrl = Uri.parse(
        "$keycloakServer/admin/realms/$realm/users/$userId/reset-password");
    final setPasswordResponse = await http.put(
      setPasswordUrl,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "type": "password",
        "value": password,
        "temporary": false,
      }),
    );

    if (setPasswordResponse.statusCode != 204) {
      print(
          "Failed to set password: ${setPasswordResponse.statusCode} ${setPasswordResponse.body}");
      return false;
    }

    print("User created and password set successfully!");
    return true;
  }
}
