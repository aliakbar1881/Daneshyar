import 'package:flutter/material.dart';

class ScientificField {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> subfields;

  ScientificField({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.subfields,
  });

  static List<ScientificField> getFields() {
    return [
      ScientificField(
        id: 'ai',
        name: 'هوش مصنوعی',
        icon: Icons.psychology,
        color: Colors.cyan.shade300,
        subfields: [
          'یادگیری ماشین',
          'یادگیری عمیق',
          'یادگیری تقویتی',
          'سیستم‌های عامل (Agentic)',
          'نظریه بازی‌ها',
          'پردازش زبان طبیعی',
          'بینایی کامپیوتر'
        ],
      ),
      ScientificField(
        id: 'cyber',
        name: 'علوم سایبری',
        icon: Icons.security,
        color: Colors.red.shade300,
        subfields: [
          'امنیت تهاجمی (Offensive)',
          'امنیت تدافعی (Defensive)',
          'ادله دیجیتال (Forensic)',
          'رمزنگاری',
          'امنیت شبکه',
          'حملات سایبری و تحلیل بدافزار',
        ],
      ),
      ScientificField(
        id: 'telecom_sys',
        name: 'مخابرات',
        icon: Icons.wifi,
        color: Colors.green.shade300,
        subfields: [
          'مخابرات سیستم',
          'مخابرات میدان',
          'مخابرات نوری',
          'شبکه‌های بی‌سیم',
          'پردازش سیگنال مخابراتی',
        ],
      ),
      ScientificField(
        id: 'electronics',
        name: 'الکترونیک',
        icon: Icons.electrical_services,
        color: Colors.orange.shade300,
        subfields: [
          'مدار مجتمع',
          'الکترونیک قدرت',
          'مدارهای فرکانس بالا',
          'طراحی PCB',
          'الکترونیک دیجیتال',
        ],
      ),
      ScientificField(
        id: 'mechanics',
        name: 'مکانیک',
        icon: Icons.settings,
        color: Colors.grey.shade400,
        subfields: [
          'جامدات',
          'سیالات',
          'دینامیک و ارتعاشات',
          'طراحی اجزاء',
          'ترمودینامیک',
        ],
      ),
      ScientificField(
        id: 'aerospace',
        name: 'هوافضا',
        icon: Icons.flight,
        color: Colors.indigo.shade300,
        subfields: [
          'آیرودینامیک',
          'پیشرانه',
          'ساختارهای فضایی',
          'ناوبری و کنترل ماهواره',
          'دینامیک پرواز',
        ],
      ),
      ScientificField(
        id: 'control',
        name: 'کنترل',
        icon: Icons.tune,
        color: Colors.purple.shade300,
        subfields: [
          'کنترل خطی',
          'کنترل غیرخطی',
          'کنترل مقاوم',
          'کنترل تطبیقی',
          'کنترل بهینه',
          'کنترل هوشمند',
        ],
      ),
    ];
  }
}