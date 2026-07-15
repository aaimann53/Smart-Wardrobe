import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'src/middleware/auth.dart';
import 'src/middleware/cors.dart';
import 'src/routes/profile.dart';
import 'src/routes/clothing.dart';
import 'src/routes/health.dart';

Future<void> main() async {
  final router = Router()
    ..get('/health', healthHandler)
    ..mount('/api/profile', ProfileRoutes().router)
    ..mount('/api/clothing', ClothingRoutes().router);

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware)
      .addMiddleware(authMiddleware)
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(pipeline, InternetAddress.anyIPv4, port);

  print('Smart Wardrobe server running on port ${server.port}');
  print('Endpoints:');
  print('  GET    /health');
  print('  GET    /api/profile');
  print('  POST   /api/profile');
  print('  PUT    /api/profile');
  print('  DELETE /api/profile');
  print('  GET    /api/clothing');
  print('  POST   /api/clothing');
  print('  PUT    /api/clothing/:id');
  print('  DELETE /api/clothing/:id');
  print('  PUT    /api/clothing/:id/favorite');
}
