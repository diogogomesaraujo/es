import 'package:flutter/material.dart';


class FindSupermarketsPage extends StatelessWidget {
  const FindSupermarketsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Supermarkets',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Supermarket Item
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: const Text(
                    'Continente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: const Text(
                    '1512 Products Available',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Center(
                      child: Text(
                        'C',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    // Navigate to the Supermarket Profile Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupermarketProfilePage(
                          logoPath: '', // Placeholder for dynamic logos
                          supermarketName: 'Continente',
                          sustainabilityScore: 4.5,
                          foodNotWasted: '95%',
                          co2Saved: '120',
                          usePlaceholderLogo: true, // Pass to use circle logo
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class SupermarketProfilePage extends StatefulWidget {
  final String logoPath;
  final String supermarketName;
  final double sustainabilityScore;
  final String foodNotWasted;
  final String co2Saved;
  final bool usePlaceholderLogo;

  const SupermarketProfilePage({
    Key? key,
    required this.logoPath,
    required this.supermarketName,
    required this.sustainabilityScore,
    required this.foodNotWasted,
    required this.co2Saved,
    this.usePlaceholderLogo = false,
  }) : super(key: key);

  @override
  State<SupermarketProfilePage> createState() => _SupermarketProfilePageState();
}

class _SupermarketProfilePageState extends State<SupermarketProfilePage> {
  late double _userRating;
  bool _hasUserRated = false;

  @override
  void initState() {
    super.initState();
    _userRating = widget.sustainabilityScore;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Logo and Supermarket Name
              Column(
                children: [
                  widget.usePlaceholderLogo
                      ? Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Center(
                            child: Text(
                              'C',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                            ),
                          ),
                        )
                      : Image.asset(
                          widget.logoPath,
                          height: 80,
                          width: 80,
                        ),
                  const SizedBox(height: 8),
                  Text(
                    widget.supermarketName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sustainability Score Section
              const Text(
                'Sustainability Score',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildStarRating(_userRating),

              const SizedBox(height: 16),

              // Food Not Wasted Section
              _buildStatCard(
                color: Colors.red,
                title: widget.foodNotWasted,
                subtitle: 'Food Not Wasted',
                icon: Icons.food_bank_outlined,
              ),

              const SizedBox(height: 16),

              // CO2 Saved Section
              _buildStatCard(
                color: Colors.orange,
                title: widget.co2Saved,
                subtitle: 'CO2 Saved (tons)',
                icon: Icons.shopping_basket_outlined,
              ),

              const SizedBox(height: 16),

              // Graph Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF9F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Graph Placeholder',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required Color color,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Icon(icon, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildStarRating(double score) {
    const maxStars = 5;
    final fullStars = score.floor();
    final halfStars = (score - fullStars >= 0.5) ? 1 : 0;
    final emptyStars = maxStars - fullStars - halfStars;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(
          fullStars,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _userRating = index + 1.0;
                _hasUserRated = true;
              });
            },
            child: Icon(
              Icons.star,
              color: _hasUserRated ? Colors.purple : Colors.purple[200],
            ),
          ),
        ),
        ...List.generate(
          halfStars,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _userRating = fullStars + 0.5;
                _hasUserRated = true;
              });
            },
            child: Icon(
              Icons.star_half,
              color: _hasUserRated ? Colors.purple : Colors.purple[200],
            ),
          ),
        ),
        ...List.generate(
          emptyStars,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _userRating = fullStars + halfStars + index + 1.0;
                _hasUserRated = true;
              });
            },
            child: const Icon(Icons.star_border, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
