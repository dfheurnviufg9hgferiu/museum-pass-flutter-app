import 'package:flutter/material.dart';

void main() {
  runApp(const MuseumPassApp());
}

// Brand Colors
const Color primaryColor = Color(0xffF97149);
const Color darkColor = Color(0xff333333);
const Color mediumDarkColor = Color(0xff545454);
const Color greyColor = Color(0xff808080);
const Color lightGreyColor = Color(0xffcccccc);
const Color bgColor = Color(0xfff7f7f7);

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class Museum {
  final String name;
  final String city;
  final int price;
  final String description;
  final IconData icon;

  Museum({
    required this.name,
    required this.city,
    required this.price,
    required this.description,
    required this.icon,
  });
}

List<Museum> museums = [
  Museum(
    name: "National Museum",
    city: "Karachi",
    price: 500,
    description: "Explore historical artifacts, culture, and heritage.",
    icon: Icons.account_balance,
  ),
  Museum(
    name: "Art Gallery Museum",
    city: "Lahore",
    price: 700,
    description: "View paintings, sculptures, and modern art collections.",
    icon: Icons.palette,
  ),
  Museum(
    name: "Science Museum",
    city: "Islamabad",
    price: 600,
    description: "Learn science through interactive exhibitions.",
    icon: Icons.science,
  ),
  Museum(
    name: "Heritage Museum",
    city: "Peshawar",
    price: 400,
    description: "Discover traditional culture and historical displays.",
    icon: Icons.museum,
  ),
];

List<Museum> cart = [];

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthContainer(
        title: "MuseumPass",
        subtitle: "Your digital museum pass wallet",
        children: [
          const CustomInput(label: "Email", icon: Icons.email),
          const SizedBox(height: 14),
          const CustomInput(
            label: "Password",
            icon: Icons.lock,
            isPassword: true,
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            text: "Login",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            },
            child: const Text(
              "Create new account",
              style: TextStyle(color: primaryColor),
            ),
          )
        ],
      ),
    );
  }
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthContainer(
        title: "Create Account",
        subtitle: "Signup to buy digital museum passes",
        children: [
          const CustomInput(label: "Full Name", icon: Icons.person),
          const SizedBox(height: 14),
          const CustomInput(label: "Email", icon: Icons.email),
          const SizedBox(height: 14),
          const CustomInput(
            label: "Password",
            icon: Icons.lock,
            isPassword: true,
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            text: "Signup",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AuthContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const AuthContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

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
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.confirmation_number,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: greyColor),
              ),
              const SizedBox(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Museum> filteredMuseums = museums;

  void searchMuseum(String value) {
    setState(() {
      filteredMuseums = museums.where((museum) {
        return museum.name.toLowerCase().contains(value.toLowerCase()) ||
            museum.city.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  void addToCart(Museum museum) {
    setState(() {
      cart.add(museum);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkColor,
        content: Text("${museum.name} added to cart"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(
        title: "MuseumPass",
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: darkColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Badge(
              backgroundColor: primaryColor,
              label: Text(cart.length.toString()),
              isLabelVisible: cart.isNotEmpty,
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: darkColor,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ).then((value) => setState(() {}));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: CustomInput(
              label: "Search museum or city",
              icon: Icons.search,
              onChanged: searchMuseum,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: filteredMuseums.length,
              itemBuilder: (context, index) {
                Museum museum = filteredMuseums[index];

                return WalletPassCard(
                  museum: museum,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(
                          museum: museum,
                          onAddToCart: addToCart,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class WalletPassCard extends StatelessWidget {
  final Museum museum;
  final VoidCallback onTap;

  const WalletPassCard({
    super.key,
    required this.museum,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffF97149),
            Color(0xffc33616),

          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 12),
          )
        ],
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
                child: Icon(
                  museum.icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                museum.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                museum.city,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rs. ${museum.price}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Museum museum;
  final Function(Museum) onAddToCart;

  const DetailScreen({
    super.key,
    required this.museum,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: museum.name),
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
                  const Text(
                    "Pass Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    museum.description,
                    style: const TextStyle(color: mediumDarkColor),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ticket Price",
                        style: TextStyle(color: greyColor),
                      ),
                      Text(
                        "Rs. ${museum.price}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: "Add to Cart",
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

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int getTotal() {
    int total = 0;
    for (var item in cart) {
      total += item.price;
    }
    return total;
  }

  void removeItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: "My Cart"),
      body: cart.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(color: greyColor, fontSize: 18),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                Museum museum = cart[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: whiteCard(),
                  child: ListTile(
                    leading: Icon(museum.icon, color: primaryColor),
                    title: Text(
                      museum.name,
                      style: const TextStyle(
                        color: darkColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Rs. ${museum.price}",
                      style: const TextStyle(color: greyColor),
                    ),
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
                    const Text(
                      "Total",
                      style: TextStyle(fontSize: 18, color: darkColor),
                    ),
                    Text(
                      "Rs. ${getTotal()}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                PrimaryButton(
                  text: "Proceed to Checkout",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(total: getTotal()),
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final int total;

  const CheckoutScreen({super.key, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = "Bank Transfer";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: "Checkout"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: whiteCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Customer Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  SizedBox(height: 18),
                  CustomInput(label: "Full Name", icon: Icons.person),
                  SizedBox(height: 14),
                  CustomInput(label: "Email", icon: Icons.email),
                  SizedBox(height: 14),
                  CustomInput(label: "Phone Number", icon: Icons.phone),
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
                  const Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  RadioListTile(
                    activeColor: primaryColor,
                    title: const Text("Bank Transfer"),
                    subtitle: const Text(
                      "Dummy Bank: Museum Bank\nAccount: 123456789",
                    ),
                    value: "Bank Transfer",
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: primaryColor,
                    title: const Text("Card Payment"),
                    subtitle: const Text("Dummy card payment option"),
                    value: "Card Payment",
                    groupValue: paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value.toString();
                      });
                    },
                  ),
                  if (paymentMethod == "Card Payment") ...[
                    const SizedBox(height: 10),
                    const CustomInput(
                      label: "Card Number",
                      icon: Icons.credit_card,
                    ),
                    const SizedBox(height: 14),
                    const CustomInput(
                      label: "Expiry Date",
                      icon: Icons.date_range,
                    ),
                    const SizedBox(height: 14),
                    const CustomInput(label: "CVV", icon: Icons.lock),
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
                  const Text(
                    "Total Amount",
                    style: TextStyle(color: darkColor),
                  ),
                  Text(
                    "Rs. ${widget.total}",
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: "Place Order",
              onPressed: () {
                cart.clear();

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Order Successful"),
                    content: Text(
                      "Your museum pass order has been placed using $paymentMethod.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                                (route) => false,
                          );
                        },
                        child: const Text(
                          "Back to Home",
                          style: TextStyle(color: primaryColor),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget profileInput(String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomInput(
        label: label,
        icon: icon,
        isPassword: isPassword,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cleanAppBar(title: "My Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: whiteCard(),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: primaryColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Shaheer Alam",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "shaheer@example.com",
                    style: TextStyle(color: greyColor),
                  ),
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
                  const Text(
                    "Update Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  profileInput("Full Name", Icons.person),
                  profileInput("Phone Number", Icons.phone),
                  profileInput("New Password", Icons.lock, isPassword: true),
                  profileInput(
                    "Confirm Password",
                    Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    text: "Update Profile",
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: darkColor,
                          content: Text("Profile updated successfully"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: "Logout",
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

PreferredSizeWidget cleanAppBar({
  required String title,
  List<Widget>? actions,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: darkColor,
      ),
    ),
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
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 20,
        offset: const Offset(0, 10),
      )
    ],
  );
}

class CustomInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final Function(String)? onChanged;

  const CustomInput({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: greyColor),
        prefixIcon: Icon(icon, color: greyColor),
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
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

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}