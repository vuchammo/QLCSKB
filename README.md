# Quản Lý Up CSKB (Capsule Kì Bí) - Ngọc Rồng Online 🐉

Ứng dụng Desktop chuyên nghiệp trên Windows và macOS dành cho dân cày và game thủ tựa game **Ngọc Rồng Online (Chú Bé Rồng - TeaMobi)** nhằm theo dõi, quản trị và tối ưu hóa lợi nhuận khi up Capsule Kì Bí (CSKB).

---

## 🌟 Tính Năng Nổi Bật

1. **Quản Lý Máy Dò Capsule Kì Bí**:
   - Ghi nhận chi phí mua máy dò: Số lượng, tổng tiền, ngày giờ mua chi tiết.
   - Hỗ trợ thanh toán bằng **VND** (tiền mặt / MoMo) hoặc **Thỏi Vàng (TV)** trong game.
   - Theo dõi số lượng máy dò: Đã mua, đã dùng và tồn kho còn lại.

2. **Kho CSKB & Quy Đổi Gói Chuẩn x999**:
   - Tự động hiển thị tổng số viên Capsule Kì Bí hiện có trong kho.
   - Bộ quy chuẩn game: Tự động tách thành **gói tiêu chuẩn (x999 CSKB)** và **số viên lẻ dư**.
   - Ghi nhận ca treo máy (Farming session): Số máy dò đã kích hoạt, số viên CSKB thu hoạch được, tự động tính **tỷ lệ rơi (Drop Rate: xx viên / máy)**.

3. **Quản Lý Bán Hàng & Doanh Thu**:
   - Tạo đơn xuất bán theo gói x999 hoặc số lượng tùy chỉnh.
   - Quản lý đơn giá theo gói, thành tiền tự động, tên khách hàng và server giao dịch (Vũ trụ 1 - 13).
   - Theo dõi công nợ: Trạng thái **ĐÃ THU** hoặc **GHI NỢ** (chuyển đổi 1 chạm).

4. **Báo Cáo Lời / Lỗ Tài Chính Toàn Diện (P&L)**:
   - Bộ lọc thời gian: Tất cả, Hôm nay, Hôm qua, 7 ngày qua, Tháng này.
   - **Doanh thu thuần**: Tổng tiền bán CSKB.
   - **Giá vốn máy dò tiêu hao (COGS)**: Tính toán chính xác theo lượng CSKB đã bán.
   - **Chi phí phụ**: Tiền bùa thu hút/dẻo dai, đậu thần, tiền điện, thuê VPS treo acc.
   - **Lợi nhuận ròng (Net Profit)** & Tỷ suất sinh lời **ROI %**.
   - **Định giá tài sản tồn kho**: Giá trị quy đổi của máy dò còn lại và CSKB chưa bán.

5. **Công Cụ Tiện Ích**:
   - **Máy tính nhanh CSKB**: Đổi viên lẻ sang gói x999 và tính tiền; Đổi gói sang tổng viên.
   - **Quy đổi tỷ giá**: Chuyển đổi linh hoạt giữa Thỏi Vàng (TV) và VND theo tỷ giá thị trường.

6. **Đồng Bộ Trực Tuyến & Quản Lý Đội Nhóm (Supabase Realtime Cloud)** 👥:
   - **Dùng chung nhiều người**: Cho phép cả nhóm bạn cùng kết nối vào một kho CSKB chung thông qua **Mã Nhóm (Team Code)** (ví dụ: `CSKB-7891`).
   - **Phân công nhiệm vụ**: Người chuyên cắm acc ghi ca up, người chuyên mua máy dò, người phụ trách bán hàng x999.
   - **Nhảy số tức thì (Realtime WebSockets)**: Khi máy A ghi nhận ca up hoặc bán gói x999, màn hình máy B lập tức cập nhật tồn kho ngay sau 0.5s!
   - **Kiến trúc Offline-First**: Mất mạng vẫn hoạt động mượt mà với SQLite cục bộ; khi có mạng tự động đồng bộ lên Cloud.
   - **Kèm sẵn Script SQL [supabase_schema.sql](supabase_schema.sql)** để khởi tạo CSDL miễn phí trên Supabase chỉ trong 1 click.

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### 1. Hướng Dẫn Cho macOS
#### Chạy trực tiếp trên macOS:
```bash
# Di chuyển vào thư mục dự án
cd QLCSKB

# Cài đặt thư viện
flutter pub get

# Chạy ứng dụng trên macOS
flutter run -d macos
```

#### Đóng gói file ứng dụng `.app` / `.zip` trên macOS:
```bash
# Build bản Release macOS
flutter build macos --release
```
File ứng dụng `qlcskb.app` sau khi biên dịch nằm tại:
```
build/macos/Build/Products/Release/qlcskb.app
```
Bạn có thể kéo thả `qlcskb.app` vào thư mục `/Applications` để dùng như một ứng dụng macOS native thông thường.

---

### 2. Hướng Dẫn Cho Windows
#### Chạy trực tiếp trên Windows:
```bash
# Di chuyển vào thư mục dự án
cd QLCSKB

# Cài đặt các thư viện cần thiết
flutter pub get

# Chạy ứng dụng trên Windows
flutter run -d windows
```

#### Đóng gói file chạy `.exe` bản Release trên Windows:
```bash
# Build bản phát hành Windows 64-bit
flutter build windows --release
```
Sau khi build xong, thư mục chứa file chạy `.exe` hoàn chỉnh nằm tại:
```
build\windows\x64\runner\Release\
```
Bạn chỉ cần nén toàn bộ thư mục `Release` này thành file `.zip` là có thể chia sẻ hoặc đem sang bất kỳ máy tính Windows nào để chạy trực tiếp (Portable) mà không cần cài thêm phần mềm!

---

## 📁 Cấu Trúc Mã Nguồn

```
QLCSKB/
├── lib/
│   ├── main.dart                      # Điểm khởi chạy ứng dụng & SQLite FFI
│   ├── core/
│   │   ├── constants/                 # Hằng số (x999/pack, tỷ giá mặc định)
│   │   ├── database/                  # SQLite database connection & schema
│   │   ├── theme/                     # Giao diện Cyber Gaming / Dragon Ball
│   │   ├── utils/                     # Format tiền tệ VND/TV, ngày giờ chi tiết
│   │   └── widgets/                   # StatCard, DateFilterBar
│   ├── models/
│   │   ├── detector_purchase.dart     # Model nhập máy dò
│   │   ├── farming_session.dart       # Model ca treo up CSKB
│   │   ├── cskb_sale.dart             # Model đơn bán x999 CSKB
│   │   ├── other_expense.dart         # Model chi phí phụ
│   │   └── profit_loss_summary.dart   # Model chỉ số tài chính & tồn kho
│   ├── services/
│   │   ├── database_service.dart      # Thao tác CRUD SQLite
│   │   └── calculation_service.dart   # Thuật toán tính lời lỗ, COGS & quy đổi x999
│   ├── providers/
│   │   └── app_provider.dart          # State management (Provider)
│   └── views/
│       ├── main_screen.dart           # Sidebar navigation
│       ├── dashboard/                 # Bảng điều khiển KPI & thống kê
│       ├── detector/                  # Quản lý nhập máy dò
│       ├── farming/                   # Quản lý kho CSKB & ca up
│       ├── sales/                     # Quản lý bán hàng x999
│       ├── reports/                   # Báo cáo lời lỗ chi tiết
│       ├── calculator/                # Máy tính quy đổi nhanh
│       └── settings/                  # Cài đặt tỷ giá & chi phí phụ
├── test/
│   ├── calculation_service_test.dart  # Unit tests thuật toán tài chính & x999
│   └── model_test.dart                # Unit tests Data Models
├── windows/                           # Cấu hình Native Windows runner
└── .github/workflows/                 # CI/CD tự động build Windows .exe
```

---

## 🧪 Kiểm Thử Tự Động (Unit Tests)

Chạy bộ kiểm thử tự động toàn diện:
```bash
flutter test
```
Toàn bộ logic quy đổi x999, giá vốn hàng bán (COGS), tỷ lệ rơi (Drop Rate) và lợi nhuận ròng đều được bảo đảm bằng các test cases chặt chẽ.
