import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';
import 'dart:convert';
import 'dart:io';
// Removed 'package:args/args;' as it's no longer used for parsing arguments

/// Converts App Store Connect API key information into a signed JWT.
///
/// This function intelligently handles the private key argument:
/// It first attempts to read it as a local file path.
/// If that fails, it assumes the argument is the raw private key content.
///
/// [yourKeyId]: Your Apple App Store Connect API Key ID (e.g., 'ABCDEFG123').
/// [yourIssuerId]: Your Apple App Store Connect Issuer ID (e.g., 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx').
/// [privateKeySource]: The file path (e.g., 'keys/AuthKey_ABCDEFG123.p8')
///                     or the raw content of your downloaded private key.
Future<String> convertInfoToJwt(
  String yourKeyId,
  String yourIssuerId,
  String privateKeySource, // Renamed for clarity, can be path or content
) async {
  try {
    String keyData;

    // First, try to treat privateKeySource as a local file path.
    final privateKeyFile = File(privateKeySource);
    if (await privateKeyFile.exists()) {
      keyData = await privateKeyFile.readAsString();
      stderr.writeln('Private key read successfully from local file: $privateKeySource');
    } else {
      // If it's not a file path, assume it's the raw private key content.
      // This is common when passing secrets directly in CI/CD pipelines.
      keyData = privateKeySource;
      stderr.writeln('Private key source is not a file; assuming raw content.');
    }

    // Define the issued at and expiration times for the JWT.
    // The token is valid for 5 minutes (maximum allowed by Apple).
    DateTime issuedAt = DateTime.now().toUtc();
    DateTime expiresAt = issuedAt.add(Duration(minutes: 5));

    // Define the payload (claims) of the JWT.
    // 'iss': Issuer ID (yourIssuerId)
    // 'iat': Issued at time (Unix timestamp)
    // 'exp': Expiration time (Unix timestamp)
    // 'aud': Audience (always 'appstoreconnect-v1' for App Store Connect API)
    // 'scope': Optional scopes to limit token permissions (here, only listing apps).
    Map<String, dynamic> payload = <String, dynamic>{
      'iss': yourIssuerId,
      'iat': issuedAt.millisecondsSinceEpoch ~/ 1000,
      'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
      'aud': 'appstoreconnect-v1',
      //'scope': ['GET /v1/apps'], // Example scope: allows listing apps
    };

    // Create JSON Web Token claims from the payload map.
    var claims = JsonWebTokenClaims.fromJson(payload);

    // Build the JSON Web Signature.
    var builder = JsonWebSignatureBuilder()
      ..jsonContent = claims.toJson() // Set the claims as the content.
      ..setProtectedHeader('alg', 'ES256') // Algorithm used for signing (ES256 is required by Apple).
      ..setProtectedHeader('kid', yourKeyId) // Key ID.
      ..setProtectedHeader('typ', 'JWT') // Type of token (always 'JWT').
      ..addRecipient(
        // Add the private key for signing. JsonWebKey.fromPem expects PEM format.
        JsonWebKey.fromPem(keyData, keyId: yourKeyId),
        algorithm: 'ES256', // Signing algorithm for the recipient.
      );

    // Build the JWS and return its compact serialization (the JWT string).
    return builder.build().toCompactSerialization();
  } catch (e) {
    // Print any errors to standard error, to keep stdout clean for the JWT.
    stderr.writeln('Error generating JWT: $e');
    return ''; // Return an empty string to indicate failure.
  }
}

/// Main function to demonstrate JWT generation, taking arguments directly from the command line.
void main(List<String> arguments) async {
  // Validate that exactly three arguments are provided.
  // Assign command-line arguments to variables based on their position.
  final String keyId = arguments[0];
  final String issuerId = arguments[1];
  final String privateKeySource = arguments[2]; // Can be path or content

  // Print a message indicating the start of JWT generation to stderr.
  stderr.writeln('Attempting to generate JWT...');
  final jwt = await convertInfoToJwt(
    keyId,
    issuerId,
    privateKeySource,
  );

  // Check if the JWT was successfully generated (i.e., not empty).
  if (jwt.isNotEmpty) {
    // Print the full JWT string to standard output.
    // This is crucial for shell commands that capture stdout (e.g., `JWT=$(...)`).
    stderr.writeln(jwt);
    print(jwt);
  } else {
    // If JWT generation failed (jwt is empty), print a general error message to stderr.
    // The `convertInfoToJwt` function already prints specific error details.
    stderr.writeln('Failed to generate JWT.');
    exit(1); // Exit with a non-zero status code to indicate failure.
  }
}
