import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/modules/settings/controllers/setting_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(title: const Text('الإعدادات'), elevation: 0),
      body: GetBuilder<SettingsController>(
        builder: (c) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // ========== قسم المنتجات ==========
            _SettingsSection(
              icon: Icons.inventory_2_rounded,
              iconColor: Colors.deepPurple,
              title: 'المنتجات',
              subtitle: 'إعدادات تعريف وإدارة المنتجات',
              children: [
                _SettingRow(
                  title: 'نوع مفتاح المنتج',
                  description: 'اختر كيف يتم تعريف المنتجات في النظام',
                  child: _SegmentedChoice(
                    options: const ['upc', 'sku'],
                    selected: c.productKey,
                    onSelected: c.setProductKey,
                  ),
                ),
              ],
            ),

            // ========== قسم حقول بيانات المنتج ==========
            _SettingsSection(
              icon: Icons.tune_rounded,
              iconColor: Colors.teal,
              title: 'حقول بيانات المنتج',
              subtitle: 'تحكم بالحقول الظاهرة في الإضافة والتعديل',
              children: [
                _SwitchRow(
                  title: 'Size',
                  description: 'إظهار حقل المقاس عند إضافة أو تعديل منتج',
                  value: c.showSize,
                  onChanged: c.setShowSize,
                ),
                const Divider(height: 1),
                _SwitchRow(
                  title: 'Condition',
                  description: 'إظهار حقل الحالة عند إضافة أو تعديل منتج',
                  value: c.showCondition,
                  onChanged: c.setShowCondition,
                ),
              ],
            ),

            // ========== لإضافة قسم جديد مستقبلاً ==========
            // انسخ _SettingsSection وغيّر العنوان والأيقونة والإعدادات
          ],
        ),
      ),
    );
  }
}

// =============================================================
// قسم إعدادات (بطاقة بعنوان وأيقونة)
// =============================================================
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس القسم
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // محتوى القسم
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// صف إعداد واحد (عنوان + وصف + عنصر التحكم)
// =============================================================
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// =============================================================
// صف إعداد بمفتاح تشغيل/إيقاف (عنوان + وصف + Switch)
// =============================================================
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.deepPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// اختيار مجزّأ (UPC / SKU)
// =============================================================
class _SegmentedChoice extends StatelessWidget {
  const _SegmentedChoice({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      opt.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
