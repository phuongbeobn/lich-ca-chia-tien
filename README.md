# Lịch ca & Chia tiền

Ứng dụng web tĩnh bằng HTML, CSS và JavaScript thuần. Trang được triển khai bằng GitHub Pages; dữ liệu quỹ chi tiêu đồng bộ qua Supabase Realtime.

## Tính năng

- Lịch ca ngày/đêm theo chu kỳ làm 12 tiếng, nghỉ 24 tiếng; đồng hồ dùng múi giờ Việt Nam.
- Theo dõi ca tiếp theo, ngày nghỉ lễ và các mốc giờ vào/ra theo từng ngày.
- Ghi khoản chi của Phương, Dũng, Dương; chia đều và làm tròn số tiền hiển thị theo nghìn đồng.
- Người đăng nhập bằng email sẽ tự vào quỹ công khai; mọi tài khoản đều có thể xem và thêm khoản chi. Mỗi người chỉ xóa được khoản do mình ghi.
- Khoản chi được lưu trong Supabase và cập nhật trực tiếp trên các thiết bị.
- Trước khi cấu hình Supabase, trang giữ chế độ lưu cục bộ và báo rõ rằng dữ liệu chưa được đồng bộ. Khoản chi cũ có thể được nhập vào nhóm sau khi kết nối.

## Chạy trên máy

Mở `index.html` trong trình duyệt.

## Thiết lập đồng bộ chi tiêu lần đầu

1. Tạo một dự án Supabase.
2. Trong SQL Editor, chạy toàn bộ `supabase/schema.sql`.
3. Tạo quỹ công khai:

   ```sql
   insert into public.shared_groups (name) values ('Quỹ chi tiêu công khai');
   ```

4. Lấy **Project URL** và **Publishable key** từ Project Settings → API Keys; điền vào `supabase-config.js`. Không dùng `secret key` hoặc `service_role` key trong trang web.
5. Trong Authentication → URL Configuration, đặt Site URL và Redirect URL là địa chỉ GitHub Pages của trang.
6. Commit và push `supabase-config.js` lên `main`. Project URL và Publishable key được thiết kế để dùng ở trình duyệt; quyền truy cập dữ liệu được giới hạn bằng schema SQL/RLS.
7. Mỗi người tạo tài khoản bằng email và đăng nhập. Không cần mã mời.

### Mở nhóm đã cài đặt trước đây

Trong SQL Editor, chạy `supabase/open-group.sql`. Tác vụ này bỏ mã mời cũ, tự thêm mọi tài khoản đã đăng nhập vào quỹ chung và giới hạn xóa ở các khoản do chính tài khoản đó ghi. Sau đó bất kỳ tài khoản mới nào cũng có thể xem và thêm khoản chi.

## Cập nhật GitHub Pages

Trang được phục vụ từ thư mục gốc của nhánh `main`. Mỗi lần đẩy commit mới lên `main`, GitHub Pages tự cập nhật trang.
