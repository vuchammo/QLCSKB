import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';

class TeamSyncView extends StatefulWidget {
  const TeamSyncView({super.key});

  @override
  State<TeamSyncView> createState() => _TeamSyncViewState();
}

class _TeamSyncViewState extends State<TeamSyncView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers Tham gia
  final _joinCodeController = TextEditingController();
  final _joinNameController = TextEditingController();

  // Controllers Tạo nhóm
  final _createTeamNameController = TextEditingController();
  final _createOwnerNameController = TextEditingController();

  // Controllers Cấu hình Supabase
  final _supabaseUrlController = TextEditingController();
  final _supabaseKeyController = TextEditingController();

  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final provider = context.read<AppProvider>();
    _supabaseUrlController.text = provider.supabaseUrl;
    _supabaseKeyController.text = provider.supabaseAnonKey;
    _joinNameController.text = provider.memberName;
    _createOwnerNameController.text = provider.memberName;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _joinCodeController.dispose();
    _joinNameController.dispose();
    _createTeamNameController.dispose();
    _createOwnerNameController.dispose();
    _supabaseUrlController.dispose();
    _supabaseKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đồng Bộ Trực Tuyến & Quản Lý Đội Nhóm',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chia sẻ kho CSKB, máy dò và doanh thu bán hàng real-time giữa các thành viên',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: provider.isOnlineMode
                        ? AppTheme.successGreen.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.isOnlineMode ? AppTheme.successGreen : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: provider.isOnlineMode ? AppTheme.successGreen : Colors.grey,
                        size: 10,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.isOnlineMode
                            ? 'Trực Tuyến: ${provider.currentTeamCode}'
                            : 'Chế Độ Cục Bộ (Offline)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: provider.isOnlineMode ? AppTheme.successGreen : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // NẾU ĐÃ KẾT NỐI VÀO NHÓM
            if (provider.isOnlineMode) ...[
              _buildConnectedTeamCard(context, provider),
            ] else ...[
              // NẾU CHƯA KẾT NỐI VÀO NHÓM
              _buildNotConnectedView(context, provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedTeamCard(BuildContext context, AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.successGreen, width: 2),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withOpacity(0.12),
                  AppTheme.cardDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_done, color: AppTheme.successGreen, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.currentTeamName ?? 'Đội nhóm',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Đang đồng bộ tự động với máy chủ Cloud • Realtime WebSockets',
                              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerRed.withOpacity(0.2),
                        foregroundColor: AppTheme.dangerRed,
                        side: const BorderSide(color: AppTheme.dangerRed),
                      ),
                      onPressed: () {
                        provider.leaveTeamOnline();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã rời nhóm và quay về chế độ Cục bộ (Offline).')),
                        );
                      },
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Rời Nhóm'),
                    ),
                  ],
                ),
                const Divider(height: 32, color: AppTheme.borderDark),

                // Mã chia sẻ
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MÃ NHÓM ĐỂ CHIA SẺ VỚI ANH EM:',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  provider.currentTeamCode ?? '',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: provider.currentTeamCode ?? ''));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã copy mã nhóm ${provider.currentTeamCode}! Hãy gửi mã này cho đồng đội.')),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('Copy Mã'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BẠN ĐANG THAO TÁC VỚI TÊN:', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            provider.memberName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.kiCyan),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Danh sách thành viên trong nhóm
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.groups, color: AppTheme.kiCyan, size: 20),
                        SizedBox(width: 8),
                        Text('Thành Viên Trong Đội Nhóm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('${provider.teamMembers.length} thành viên', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
                const Divider(height: 24, color: AppTheme.borderDark),
                if (provider.teamMembers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('Đang tải danh sách thành viên...', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.teamMembers.length,
                    separatorBuilder: (_, __) => const Divider(height: 12, color: AppTheme.borderDark),
                    itemBuilder: (context, index) {
                      final m = provider.teamMembers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: m.role == 'OWNER' ? AppTheme.primaryGold : AppTheme.cardDark,
                          foregroundColor: m.role == 'OWNER' ? Colors.black : Colors.white,
                          child: Icon(m.role == 'OWNER' ? Icons.star : Icons.person, size: 18),
                        ),
                        title: Text(
                          m.memberName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: m.memberName == provider.memberName ? AppTheme.primaryGold : Colors.white,
                          ),
                        ),
                        subtitle: Text('Hoạt động: ${DateFormatter.formatFull(m.lastActive)}', style: const TextStyle(fontSize: 11)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: m.role == 'OWNER' ? AppTheme.primaryGold.withOpacity(0.2) : Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m.role == 'OWNER' ? 'Trưởng nhóm' : 'Thành viên',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: m.role == 'OWNER' ? AppTheme.primaryGold : Colors.white70,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotConnectedView(BuildContext context, AppProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryGold,
              labelColor: AppTheme.primaryGold,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.group_add), text: '1. Tham Gia Nhóm'),
                Tab(icon: Icon(Icons.add_circle_outline), text: '2. Tạo Nhóm Mới'),
                Tab(icon: Icon(Icons.cloud_sync), text: '3. Cấu Hình Supabase'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJoinTab(context, provider),
                  _buildCreateTab(context, provider),
                  _buildConfigTab(context, provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinTab(BuildContext context, AppProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tham gia vào một đội nhóm đã có sẵn:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Nhập mã nhóm do trưởng nhóm gửi cho bạn để xem và cập nhật chung kho CSKB',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),

          const Text('Mã nhóm (Team Code):', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _joinCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: CSKB-7891 hoặc CSKB-DEMO',
              prefixIcon: Icon(Icons.vpn_key, color: AppTheme.primaryGold),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Tên của bạn:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _joinNameController,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Tuấn Anh, Nick Goku...',
              prefixIcon: Icon(Icons.person, color: AppTheme.kiCyan),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _isActionLoading
                ? null
                : () async {
                    final code = _joinCodeController.text.trim();
                    final name = _joinNameController.text.trim();
                    if (code.isEmpty || name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập đầy đủ mã nhóm và tên của bạn!')),
                      );
                      return;
                    }

                    setState(() => _isActionLoading = true);
                    final success = await provider.joinTeamOnline(code, name);
                    setState(() => _isActionLoading = false);

                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã tham gia nhóm $code thành công! Dữ liệu đã đồng bộ.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không tìm thấy mã nhóm này hoặc chưa kết nối Supabase! Vui lòng kiểm tra lại Tab 3.'),
                          ),
                        );
                      }
                    }
                  },
            icon: _isActionLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.login),
            label: const Text('Tham Gia Nhóm & Bắt Đầu Đồng Bộ'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTab(BuildContext context, AppProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tạo một đội nhóm mới cho anh em cày:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Hệ thống sẽ tự tạo một Mã Nhóm duy nhất để bạn chia sẻ cho các thành viên trong team',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),

          const Text('Tên đội nhóm:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _createTeamNameController,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Team Up CSKB Đảo Kame, Bang Vũ Trụ 1...',
              prefixIcon: Icon(Icons.groups, color: AppTheme.primaryOrange),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Tên trưởng nhóm (Bạn):', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _createOwnerNameController,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Huy Hoàng (Chủ team)...',
              prefixIcon: Icon(Icons.star, color: AppTheme.primaryGold),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _isActionLoading
                ? null
                : () async {
                    final teamName = _createTeamNameController.text.trim();
                    final ownerName = _createOwnerNameController.text.trim();
                    if (teamName.isEmpty || ownerName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập tên đội nhóm và tên của bạn!')),
                      );
                      return;
                    }

                    setState(() => _isActionLoading = true);
                    final newTeam = await provider.createTeamOnline(teamName, ownerName);
                    setState(() => _isActionLoading = false);

                    if (context.mounted) {
                      if (newTeam != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã tạo thành công nhóm ${newTeam.name}! Mã nhóm: ${newTeam.code}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chưa thể tạo nhóm! Hãy đảm bảo bạn đã cấu hình kết nối Supabase ở Tab 3.'),
                          ),
                        );
                      }
                    }
                  },
            icon: _isActionLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.check_circle),
            label: const Text('Tạo Nhóm Mới & Lấy Mã Chia Sẻ'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab(BuildContext context, AppProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cấu hình kết nối Supabase Cloud:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Nhập Project URL và Anon Key từ dự án Supabase miễn phí của bạn để kích hoạt tính năng Cloud',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),

          const Text('Project URL:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _supabaseUrlController,
            decoration: const InputDecoration(
              hintText: 'https://xyzcompany.supabase.co',
              prefixIcon: Icon(Icons.link, color: AppTheme.kiCyan),
            ),
          ),
          const SizedBox(height: 14),

          const Text('Anon Public Key:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _supabaseKeyController,
            decoration: const InputDecoration(
              hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
              prefixIcon: Icon(Icons.key, color: AppTheme.primaryGold),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final url = _supabaseUrlController.text.trim();
                  final key = _supabaseKeyController.text.trim();
                  if (url.isEmpty || key.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập đầy đủ Supabase URL và Anon Key!')),
                    );
                    return;
                  }

                  final success = await provider.connectSupabase(url, key);
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã kết nối thành công với máy chủ Supabase Cloud!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kết nối thất bại! Vui lòng kiểm tra lại URL hoặc Key.')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Lưu & Kết Nối Máy Chủ'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // Hướng dẫn mở supabase_schema.sql
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hướng Dẫn 3 Bước Tạo Supabase'),
                      content: const SizedBox(
                        width: 450,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1. Truy cập https://supabase.com và bấm "Start your project" (hoàn toàn miễn phí).'),
                            SizedBox(height: 8),
                            Text('2. Vào mục SQL Editor, mở file "supabase_schema.sql" trong thư mục ứng dụng, copy và dán vào rồi bấm RUN.'),
                            SizedBox(height: 8),
                            Text('3. Vào Project Settings -> API -> Copy "Project URL" và "anon public key" dán vào màn hình này là xong!'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đã Hiểu')),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Xem Hướng Dẫn'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
