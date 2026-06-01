import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ==================== BRAND COLORS ====================
const Color primaryColor = Color(0xffF97149);
const Color darkColor = Color(0xff333333);
const Color mediumDarkColor = Color(0xff545454);
const Color greyColor = Color(0xff808080);
const Color lightGreyColor = Color(0xffcccccc);
const Color bgColor = Color(0xfff7f7f7);

// ==================== GLOBAL CART ====================
List<Map<String, dynamic>> cart = [];

// ==================== API SERVICE ====================
const String baseUrl = 'http://localhost:3001/api'; // For web / iOS simulator

class ApiService {
  // Auth
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Signup failed');
    }
  }

  // Museums
  static Future<List<dynamic>> getMuseums() async {
    final res = await http.get(Uri.parse('$baseUrl/museums'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load museums');
  }

  static Future<dynamic> createMuseum(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/museums'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Create failed: ${res.body}');
  }

  static Future<dynamic> updateMuseum(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/museums/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Update failed: ${res.body}');
  }

  static Future<void> deleteMuseum(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/museums/$id'));
    if (res.statusCode != 204) throw Exception('Delete failed');
  }

  // Bookings
  static Future<List<dynamic>> getBookings() async {
    final res = await http.get(Uri.parse('$baseUrl/bookings'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load bookings');
  }

  static Future<dynamic> createBooking(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception('Create booking failed: ${res.body}');
  }

  static Future<dynamic> updateBookingStatus(int id, String status) async {
    final res = await http.put(
      Uri.parse('$baseUrl/bookings/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Update booking failed');
  }

  static Future<void> deleteBooking(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/bookings/$id'));
    if (res.statusCode != 204) throw Exception('Delete booking failed');
  }
}

// ==================== MAIN APP ====================
void main() => runApp(const MuseumPassApp());

class MuseumPassApp extends StatelessWidget {
  const MuseumPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuseumPass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: bgColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, primary: primaryColor),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/manage-museums': (context) => const ManageMuseumsScreen(),
        '/manage-bookings': (context) => const ManageBookingsScreen(),
      },
    );
  }
}

// ==================== AUTH SCREENS ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await ApiService.login(emailCtrl.text.trim(), passCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthContainer(
        title: "MuseumPass",
        subtitle: "Your digital museum pass wallet",
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomInput(label: "Email", icon: Icons.email, controller: emailCtrl, validator: true),
                const SizedBox(height: 14),
                CustomInput(label: "Password", icon: Icons.lock, isPassword: true, controller: passCtrl, validator: true),
              ],
            ),
          ),
          const SizedBox(height: 22),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(text: "Login", onPressed: _login),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            child: const Text("Create new account", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await ApiService.signup(nameCtrl.text.trim(), emailCtrl.text.trim(), passCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthContainer(
        title: "Create Account",
        subtitle: "Signup to buy digital museum passes",
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomInput(label: "Full Name", icon: Icons.person, controller: nameCtrl, validator: true),
                const SizedBox(height: 14),
                CustomInput(label: "Email", icon: Icons.email, controller: emailCtrl, validator: true),
                const SizedBox(height: 14),
                CustomInput(label: "Password", icon: Icons.lock, isPassword: true, controller: passCtrl, validator: true),
              ],
            ),
          ),
          const SizedBox(height: 22),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(text: "Signup", onPressed: _signup),
        ],
      ),
    );
  }
}

class AuthContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const AuthContainer({super.key, required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: whiteCard(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.confirmation_number, color: Colors.white, size: 42),
              ),
              const SizedBox(height: 18),
              Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: darkColor)),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: greyColor)),
              const SizedBox(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HOME SCREEN ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> museums = [];
  List<dynamic> filteredMuseums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMuseums();
  }

  Future<void> fetchMuseums() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getMuseums();
      setState(() {
        museums = data;
        filteredMuseums = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void searchMuseum(String value) {
    setState(() {
      filteredMuseums = museums.where((museum) {
        return museum['name'].toLowerCase().contains(value.toLowerCase()) ||
            museum['city'].toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  void addToCart(Map<String, dynamic> museum) {
    setState(() => cart.add(museum));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${museum['name']} added to cart'), backgroundColor: darkColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(
        title: 'MuseumPass',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: darkColor),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: Badge(
              backgroundColor: primaryColor,
              label: Text(cart.length.toString()),
              isLabelVisible: cart.isNotEmpty,
              child: const Icon(Icons.shopping_bag_outlined, color: darkColor),
            ),
            onPressed: () => Navigator.pushNamed(context, '/cart').then((_) => setState(() {})),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Text('MuseumPass Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Manage Museums'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage-museums').then((_) => fetchMuseums());
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('Manage Bookings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage-bookings');
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: CustomInput(label: 'Search museum or city', icon: Icons.search, onChanged: searchMuseum),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: filteredMuseums.length,
              itemBuilder: (context, index) {
                final museum = filteredMuseums[index];
                return WalletPassCard(
                  museum: museum,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(museum: museum, onAddToCart: addToCart),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== DETAIL SCREEN ====================
class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> museum;
  final Function(Map<String, dynamic>) onAddToCart;
  const DetailScreen({super.key, required this.museum, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: museum['name']),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            WalletPassCard(museum: museum, onTap: () {}),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: whiteCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pass Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkColor)),
                  const SizedBox(height: 10),
                  Text(museum['description'], style: const TextStyle(color: mediumDarkColor)),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ticket Price', style: TextStyle(color: greyColor)),
                      Text('Rs. ${museum['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Add to Cart',
              onPressed: () {
                onAddToCart(museum);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CART SCREEN ====================
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int getTotal() => cart.fold(0, (sum, item) => sum + (item['price'] as int));

  void removeItem(int index) {
    setState(() => cart.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: 'My Cart'),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty', style: TextStyle(color: greyColor, fontSize: 18)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final museum = cart[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: whiteCard(),
                  child: ListTile(
                    leading: Icon(Icons.museum, color: primaryColor),
                    title: Text(museum['name'], style: const TextStyle(color: darkColor, fontWeight: FontWeight.bold)),
                    subtitle: Text('Rs. ${museum['price']}', style: const TextStyle(color: greyColor)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: primaryColor),
                      onPressed: () => removeItem(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: whiteCard(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 18, color: darkColor)),
                    Text('Rs. ${getTotal()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
                  ],
                ),
                const SizedBox(height: 15),
                PrimaryButton(
                  text: 'Proceed to Checkout',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CHECKOUT SCREEN ====================
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = 'Bank Transfer';
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  int getTotal() => cart.fold(0, (sum, item) => sum + (item['price'] as int));

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    for (var museum in cart) {
      await ApiService.createBooking({
        'museum_id': museum['museum_id'],
        'quantity': 1,
        'total_price': museum['price'],
        'status': 'pending',
      });
    }
    cart.clear();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Order Successful'),
        content: Text('Your museum pass order has been placed using $paymentMethod.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
            child: const Text('Back to Home', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: whiteCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkColor)),
                    const SizedBox(height: 18),
                    CustomInput(label: 'Full Name', icon: Icons.person, controller: nameCtrl, validator: true),
                    const SizedBox(height: 14),
                    CustomInput(label: 'Email', icon: Icons.email, controller: emailCtrl, validator: true),
                    const SizedBox(height: 14),
                    CustomInput(label: 'Phone Number', icon: Icons.phone, controller: phoneCtrl, validator: true),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: whiteCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Method', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkColor)),
                    RadioListTile(
                      activeColor: primaryColor,
                      title: const Text('Bank Transfer'),
                      subtitle: const Text('Dummy Bank: Museum Bank\nAccount: 123456789'),
                      value: 'Bank Transfer',
                      groupValue: paymentMethod,
                      onChanged: (v) => setState(() => paymentMethod = v.toString()),
                    ),
                    RadioListTile(
                      activeColor: primaryColor,
                      title: const Text('Card Payment'),
                      subtitle: const Text('Dummy card payment option'),
                      value: 'Card Payment',
                      groupValue: paymentMethod,
                      onChanged: (v) => setState(() => paymentMethod = v.toString()),
                    ),
                    if (paymentMethod == 'Card Payment') ...[
                      const SizedBox(height: 10),
                      const CustomInput(label: 'Card Number', icon: Icons.credit_card),
                      const SizedBox(height: 14),
                      const CustomInput(label: 'Expiry Date', icon: Icons.date_range),
                      const SizedBox(height: 14),
                      const CustomInput(label: 'CVV', icon: Icons.lock),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: whiteCard(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: darkColor)),
                    Text('Rs. ${getTotal()}', style: const TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(text: 'Place Order', onPressed: _placeOrder),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PROFILE SCREEN ====================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: 'My Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: whiteCard(),
              child: const Column(
                children: [
                  CircleAvatar(radius: 45, backgroundColor: primaryColor, child: Icon(Icons.person, size: 50, color: Colors.white)),
                  SizedBox(height: 14),
                  Text('Shaheer Alam', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkColor)),
                  SizedBox(height: 5),
                  Text('shaheer@example.com', style: TextStyle(color: greyColor)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: whiteCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Update Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkColor)),
                  const SizedBox(height: 18),
                  profileInput('Full Name', Icons.person),
                  profileInput('Phone Number', Icons.phone),
                  profileInput('New Password', Icons.lock, isPassword: true),
                  profileInput('Confirm Password', Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    text: 'Update Profile',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: darkColor, content: Text('Profile updated successfully')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Logout',
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileInput(String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomInput(label: label, icon: icon, isPassword: isPassword),
    );
  }
}

// ==================== MANAGE MUSEUMS SCREEN ====================
class ManageMuseumsScreen extends StatefulWidget {
  const ManageMuseumsScreen({super.key});

  @override
  State<ManageMuseumsScreen> createState() => _ManageMuseumsScreenState();
}

class _ManageMuseumsScreenState extends State<ManageMuseumsScreen> {
  List<dynamic> museums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMuseums();
  }

  Future<void> fetchMuseums() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getMuseums();
      setState(() {
        museums = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteMuseum(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Museum'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.deleteMuseum(id);
        fetchMuseums();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _editMuseum(Map<String, dynamic> museum) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditMuseumScreen(museum: museum)),
    );
    if (result == true) fetchMuseums();
  }

  void _addMuseum() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditMuseumScreen()),
    );
    if (result == true) fetchMuseums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: 'Manage Museums', actions: [
        IconButton(onPressed: _addMuseum, icon: const Icon(Icons.add, color: primaryColor)),
      ]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: museums.length,
        itemBuilder: (ctx, i) {
          final m = museums[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: whiteCard(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('${m['city']} - Rs.${m['price']}'),
                      Text(m['description'], style: const TextStyle(fontSize: 12, color: greyColor)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(onPressed: () => _editMuseum(m), icon: const Icon(Icons.edit, color: Colors.blue)),
                    IconButton(onPressed: () => _deleteMuseum(m['museum_id']), icon: const Icon(Icons.delete, color: Colors.red)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddEditMuseumScreen extends StatefulWidget {
  final Map<String, dynamic>? museum;
  const AddEditMuseumScreen({super.key, this.museum});

  @override
  State<AddEditMuseumScreen> createState() => _AddEditMuseumScreenState();
}

class _AddEditMuseumScreenState extends State<AddEditMuseumScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl, cityCtrl, priceCtrl, descCtrl, iconCtrl;

  @override
  void initState() {
    super.initState();
    final m = widget.museum;
    nameCtrl = TextEditingController(text: m?['name'] ?? '');
    cityCtrl = TextEditingController(text: m?['city'] ?? '');
    priceCtrl = TextEditingController(text: m?['price']?.toString() ?? '');
    descCtrl = TextEditingController(text: m?['description'] ?? '');
    iconCtrl = TextEditingController(text: m?['icon'] ?? 'Icons.museum');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': nameCtrl.text,
      'city': cityCtrl.text,
      'price': int.parse(priceCtrl.text),
      'description': descCtrl.text,
      'icon': iconCtrl.text,
    };
    try {
      if (widget.museum == null) {
        await ApiService.createMuseum(data);
      } else {
        await ApiService.updateMuseum(widget.museum!['museum_id'], data);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: widget.museum == null ? 'Add Museum' : 'Edit Museum'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomInput(label: 'Name', icon: Icons.edit, controller: nameCtrl, validator: true),
              const SizedBox(height: 14),
              CustomInput(label: 'City', icon: Icons.location_city, controller: cityCtrl, validator: true),
              const SizedBox(height: 14),
              // CHANGED: Indian Rupee icon replaced with generic payments icon for Pakistani Rupee
              CustomInput(label: 'Price', icon: Icons.payments, controller: priceCtrl, isNumber: true, validator: true),
              const SizedBox(height: 14),
              CustomInput(label: 'Description', icon: Icons.description, controller: descCtrl, validator: true),
              const SizedBox(height: 14),
              CustomInput(label: 'Icon (string)', icon: Icons.abc, controller: iconCtrl, validator: true),
              const SizedBox(height: 30),
              PrimaryButton(text: 'Save', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== MANAGE BOOKINGS SCREEN ====================
class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getBookings();
      setState(() {
        bookings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      await ApiService.updateBookingStatus(id, newStatus);
      fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteBooking(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.deleteBooking(id);
        fetchBookings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: 'Manage Bookings'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (ctx, i) {
          final b = bookings[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('${b['museum_name']} (x${b['quantity']})'),
              subtitle: Text('Total: Rs.${b['total_price']} | Status: ${b['status']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: b['status'],
                    items: ['pending', 'confirmed', 'cancelled']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => _updateStatus(b['booking_id'], val!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBooking(b['booking_id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== WIDGETS ====================
PreferredSizeWidget cleanAppBar({required String title, List<Widget>? actions}) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: darkColor)),
    centerTitle: false,
    backgroundColor: bgColor,
    elevation: 0,
    iconTheme: const IconThemeData(color: darkColor),
    actions: actions,
  );
}

BoxDecoration whiteCard() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))],
  );
}

class CustomInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool isNumber;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final bool validator;

  const CustomInput({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.isNumber = false,
    this.onChanged,
    this.controller,
    this.validator = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      validator: validator
          ? (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (isNumber && int.tryParse(value) == null) return 'Enter a number';
        return null;
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: greyColor),
        prefixIcon: Icon(icon, color: greyColor),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class WalletPassCard extends StatelessWidget {
  final Map<String, dynamic> museum;
  final VoidCallback onTap;
  const WalletPassCard({super.key, required this.museum, required this.onTap});

  IconData getIcon(String iconName) {
    switch (iconName) {
      case 'Icons.account_balance':
        return Icons.account_balance;
      case 'Icons.palette':
        return Icons.palette;
      case 'Icons.science':
        return Icons.science;
      case 'Icons.museum':
        return Icons.museum;
      default:
        return Icons.museum;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffF97149), Color(0xffc33616)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.30), blurRadius: 22, offset: const Offset(0, 12))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.18),
                child: Icon(getIcon(museum['icon']), size: 28, color: Colors.white),
              ),
              const SizedBox(height: 28),
              Text(museum['name'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(museum['city'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Rs. ${museum['price']}", style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}