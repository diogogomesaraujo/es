import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Product {
  final int? id;
  final String name;
  final String price;
  final String expirationDate; // Data de expiração no formato yyyy-MM-dd
  final String status; // valid, almost_expired, expired

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.expirationDate,
    required this.status,
  });

  // Converte Product para Map (para inserir no DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'expirationDate': expirationDate,
      'status': status,
    };
  }

  // Converte Map para Product (para ler do DB)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      expirationDate: map['expirationDate'],
      status: map['status'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Inicializar o banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Criar tabela
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price TEXT NOT NULL,
        expirationDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  // Adicionar produto
  Future<void> addProduct(Product product) async {
    final db = await database;

    // Calcula status antes de inserir
    final status = _calculateStatus(product.expirationDate);
    await db.insert('products', product.toMap()..['status'] = status);
  }

  // Atualizar um produto existente
  Future<void> updateProduct(Product product) async {
    final db = await database;

    // Calcula o novo status antes de atualizar
    final status = _calculateStatus(product.expirationDate);
    await db.update(
      'products',
      product.toMap()..['status'] = status,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Deletar um produto pelo ID
  Future<void> deleteProduct(int id) async {
    final db = await database;

    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Buscar um produto pelo ID
  Future<Product?> getProductById(int id) async {
    final db = await database;

    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  // Buscar todos os produtos (com filtro)
  Future<List<Product>> getProducts(String filter) async {
  final db = await database;

  // Atualiza o status de todos os produtos
  await updateProductStatuses();

  late List<Map<String, dynamic>> result;
  if (filter == 'All Products') {
    result = await db.query('products'); // Todos os produtos
  } else {
    result = await db.query(
      'products',
      where: 'status = ?',
      whereArgs: [filter],
    );
  }

  return result.map((e) => Product.fromMap(e)).toList();
}


  // Atualizar status dos produtos
  Future<void> updateProductStatuses() async {
    final db = await database;

    final products = await db.query('products');
    for (var product in products) {
      final newStatus = _calculateStatus(product['expirationDate'] as String);
      await db.update(
        'products',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [product['id']],
      );
    }
  }

  // Função para calcular status
  String _calculateStatus(String expirationDate) {
    final currentDate = DateTime.now();
    final expireDate = DateTime.parse(expirationDate);
    
    // Remove time component to compare only dates
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final expiryDay = DateTime(expireDate.year, expireDate.month, expireDate.day);
    
    final difference = expiryDay.difference(today).inDays;

    if (difference <= 0) return 'expired';
    if (difference <= 5) return 'almost_expired';
    return 'valid';
  }
}
