import 'package:flutter/material.dart';
import 'database.dart'; // Certifique-se de importar o backend

class ProductsStockPage extends StatefulWidget {
  const ProductsStockPage({Key? key}) : super(key: key);

  @override
  State<ProductsStockPage> createState() => _ProductsStockPageState();
}

class _ProductsStockPageState extends State<ProductsStockPage> {
  String _activeTab = 'All Products'; // Aba ativa
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Product> _products = []; // Lista de produtos da aba atual

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Carregar produtos ao iniciar
  }

  Future<void> _loadProducts() async {
    await _dbHelper.updateProductStatuses(); // Atualiza status dos produtos
    final products = await _dbHelper.getProducts(_activeTab);
    setState(() {
      _products = products;
    });
  }

  Future<void> _addProduct({Product? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price ?? '');
    DateTime? selectedDate = product?.expirationDate != null
        ? DateTime.parse(product!.expirationDate)
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Select Expiration Date'
                        : 'Expires on: ${selectedDate?.toLocal().toString().split(' ')[0] ?? ''}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final now = DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (product != null)
            TextButton(
              onPressed: () async {
                await _dbHelper.deleteProduct(product.id!);
                Navigator.pop(context);
                _loadProducts();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  selectedDate == null) {
                return;
              }
              final newProduct = Product(
                id: product?.id,
                name: nameController.text,
                price: '${priceController.text}€', // Adiciona símbolo do euro
                expirationDate:
                    selectedDate!.toIso8601String().split('T')[0],
                status: _calculateStatus(selectedDate!.toIso8601String().split('T')[0]),
              );

              if (product == null) {
                await _dbHelper.addProduct(newProduct);
              } else {
                await _dbHelper.updateProduct(newProduct);
              }
              Navigator.pop(context);
              _loadProducts();
            },
            child: Text(product == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  String _calculateStatus(String expirationDate) {
  final currentDate = DateTime.now();
  final expireDate = DateTime.parse(expirationDate);

  // Garantir apenas a comparação de datas (ignorar horas)
  final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
  final expireDay = DateTime(expireDate.year, expireDate.month, expireDate.day);

  final difference = expireDay.difference(today).inDays;

  if (difference < 0) return 'expired'; // Passou da data
  if (difference >= 0 && difference <= 5) return 'almost_expired'; // Até 5 dias
  return 'valid';
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Stock',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildProductList()),
          _buildAddProductButton(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['All Products', 'Almost Expired', 'Expired'].map((title) {
          final isActive = _activeTab == title;
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeTab = title;
                _loadProducts();
              });
            },
            child: Chip(
              backgroundColor:
                  isActive ? Colors.amber.shade100 : Colors.transparent,
              label: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.orange : Colors.grey.shade400)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductItem(product);
      },
    );
  }

Widget _buildProductItem(Product product) {
  final bool isExpired = product.status == 'expired';
  final bool isAlmostExpired = product.status == 'almost_expired';

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    decoration: BoxDecoration(
      color: isExpired
          ? Colors.grey.shade100
          : isAlmostExpired
              ? Colors.orange.shade50
              : Colors.amber.shade50,
      borderRadius: BorderRadius.circular(20), // Arredondamento
    ),
    padding: const EdgeInsets.all(16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Nome do produto + Data de expiração
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  GestureDetector(
                    onTap: () => _addProduct(product: product),
                    child: const Icon(Icons.edit, size: 18.0, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4.0), // Espaço entre textos
              Text(
                'Would Expire ${product.expirationDate}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
        // Preço do produto com o símbolo do euro
        Text(
          product.price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildAddProductButton() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 156, 48, 238),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          onPressed: () => _addProduct(),
          child: const Text(
            'Add Product',
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
