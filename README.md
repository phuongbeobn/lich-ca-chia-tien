# Lịch ca & Chia tiền

Ứng dụng web tĩnh bằng HTML, CSS và JavaScript thuần. Trang được triển khai bằng GitHub Pages; dữ liệu quỹ chi tiêu đồng bộ qua Supabase Realtime.

## Tính năng

- Lịch ca ngày/đêm theo chu kỳ làm 12 tiếng, nghỉ 24 tiếng; đồng hồ dùng múi giờ Việt Nam.
- Theo dõi ca tiếp theo, ngày nghỉ lễ và các mốc giờ vào/ra theo từng ngày.
- Ghi khoản chi của Phương, Dũng, Dương; chia đều và làm tròn số tiền hiển thị theo nghìn đồng.
- Sau khi cấu hình Supabase, người trong nhóm đăng nhập bằng email và tham gia bằng mã mời; Row Level Security giới hạn dữ liệu cho thành viên nhóm.
- Khi đã kết nối, khoản chi được lưu dùng chung trong Supabase và cập nhật trực tiếp trên các thiết bị.
- Trước khi cấu hình Supabase, trang giữ chế độ lưu cục bộ và báo rõ rằng dữ liệu chưa được đồng bộ. Khoản chi cũ có thể được nhập vào nhóm sau khi kết nối.

## Chạy trên máy

Mở `index.html` trong trình duyệt.

## Thiết lập đồng bộ chi tiêu lần đầu

1. Tạo một dự án Supabase.
2. Trong SQL Editor, chạy toàn bộ `supabase/schema.sql`.
3. Tạo mã mời dài, ngẫu nhiên và riêng tư. Chạy câu lệnh sau trong SQL Editor sau khi thay hai giá trị mẫu. Không đưa mã mời thật vào GitHub:

   ```sql
   insert into public.shared_groups (name, invite_code_hash)
   values (
     'Nhóm chi tiêu',
     encode(extensions.digest(convert_to('THAY_BANG_MA_MOI_RIENG', 'UTF8'), 'sha256'), 'hex')
   );
   ```

4. Lấy **Project URL** và **Publishable key** từ Project Settings → API Keys; điền vào `supabase-config.js`. Không dùng `secret key` hoặc `service_role` key trong trang web.
5. Trong Authentication → URL Configuration, đặt Site URL và Redirect URL là địa chỉ GitHub Pages của trang.
6. Commit và push `supabase-config.js` lên `main`. Project URL và Publishable key được thiết kế để dùng ở trình duyệt; quyền truy cập dữ liệu được giới hạn bằng schema SQL/RLS.
7. Mỗi thành viên tạo tài khoản bằng email, xác nhận email nếu được yêu cầu, đăng nhập rồi nhập cùng mã mời nhóm.

## Cập nhật GitHub Pages

Trang được phục vụ từ thư mục gốc của nhánh `main`. Mỗi lần đẩy commit mới lên `main`, GitHub Pages tự cập nhật trang.
