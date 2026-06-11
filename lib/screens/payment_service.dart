import 'dart:convert';
import 'package:http/http.dart' as http;

class MidtransService {
  // 🔥 Server Key lu dari screenshot udah gua masukin!
  static const String serverKey = 'YOUR_MIDTRANS_SERVER_KEY'; // TODO: Use .env for secrets

  static Future<String?> dapatkanLinkPembayaran({
    required String orderId,
    required int grossAmount,
    required String namaEvent,
  }) async {
    // Endpoint API Midtrans Sandbox
    const String url = 'https://app.sandbox.midtrans.com/snap/v1/transactions';
    
    // Syarat dari Midtrans: Server Key harus di-encode pakai Base64
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

    final Map<String, dynamic> body = {
      "transaction_details": {
        "order_id": orderId,
        "gross_amount": grossAmount
      },
      "item_details": [
        {
          "id": "TIKET-01",
          "price": grossAmount,
          "quantity": 1,
          "name": namaEvent.length > 50 ? namaEvent.substring(0, 50) : namaEvent
        }
      ],
      "customer_details": {
        "first_name": "Peserta",
        "last_name": "Titik Kumpul",
        "email": "user@titikkumpul.com"
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Ngambil link URL halaman pembayaran dari Midtrans
        return responseData['redirect_url']; 
      } else {
        print('Error Midtrans: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error Exception: $e');
      return null;
    }
  }
}