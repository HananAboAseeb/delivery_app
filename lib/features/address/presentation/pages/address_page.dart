import 'package:flutter/material.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final List<Map<String, dynamic>> _savedAddresses = [
    {
      "id": "1",
      "name": "المنزل",
      "street": "شارع حدة الدائري",
      "building": "مبنى 15، شقة 4",
      "phone": "777 123 456",
      "isDefault": true,
    },
    {
      "id": "2",
      "name": "العمل",
      "street": "الزبيري بلس",
      "building": "برج التجارية، الدور 5",
      "phone": "777 987 654",
      "isDefault": false,
    }
  ];

  void _showAddAddressSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        bool isDefault = false;
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('إضافة عنوان جديد',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  _buildTextField(
                      'اسم الموقع (مثال: المنزل)', Icons.label_outline),
                  const SizedBox(height: 16),
                  _buildTextField('الشارع', Icons.add_road),
                  const SizedBox(height: 16),
                  _buildTextField('المبنى/الشقة', Icons.apartment),
                  const SizedBox(height: 16),
                  _buildTextField('رقم الهاتف للتواصل', Icons.phone_outlined),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('تعيين كعنوان افتراضي',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    value: isDefault,
                    activeColor: theme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setModalState(() => isDefault = val ?? false);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('تم إضافة العنوان بنجاح')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('حفظ العنوان',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildTextField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('عناويني',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: theme.primaryColor),
            onPressed: () => _showAddAddressSheet(context),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _savedAddresses.length,
        itemBuilder: (context, index) {
          final addr = _savedAddresses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: addr['isDefault']
                  ? Border.all(color: theme.primaryColor, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: addr['isDefault']
                        ? theme.primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    addr['name'] == 'المنزل' ? Icons.home : Icons.work,
                    color: addr['isDefault']
                        ? theme.primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(addr['name'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          if (addr['isDefault']) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('الافتراضي',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${addr['street']}، ${addr['building']}',
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text('رقم الهاتف: ${addr['phone']}',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  onPressed: () => _showAddAddressSheet(context), // Mock edit
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة عنوان',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
