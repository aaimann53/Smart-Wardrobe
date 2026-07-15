import 'package:shelf/shelf.dart';

/// CORS middleware for allowing cross-origin requests from the Flutter app.
Middleware get corsMiddleware => (Handler innerHandler) {
      return (Request request) async {
        // Handle preflight OPTIONS requests
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: {
            'access-control-allow-origin': '*',
            'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'access-control-allow-headers':
                'Content-Type, Authorization, X-Requested-With',
            'access-control-max-age': '86400',
          });
        }

        final response = await innerHandler(request);
        return response.change(headers: {
          'access-control-allow-origin': '*',
          'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'access-control-allow-headers':
              'Content-Type, Authorization, X-Requested-With',
        });
      };
    };
