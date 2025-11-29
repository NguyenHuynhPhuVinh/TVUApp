
#!/usr/bin/env python3
"""
Script gửi thư hòm thư trên Firebase Firestore
Sử dụng: python send_mail.py

Yêu cầu:
- pip install firebase-admin
- File service account JSON từ Firebase Console
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import random
import string

# ============ CẤU HÌNH ============
SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"  # Đường dẫn file service account
# ==================================

def init_firebase():
    """Khởi tạo Firebase Admin SDK"""
    if not firebase_admin._apps:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    return firestore.client()

def generate_mail_id():
    """Tạo mail ID ngẫu nhiên"""
    chars = string.ascii_lowercase + string.digits
    suffix = ''.join(random.choice(chars) for _ in range(6))
    return f"mail_{int(datetime.now().timestamp())}_{suffix}"

# ============ MAIL TYPES ============
MAIL_TYPES = {
    '1': ('system', 'Hệ thống'),
    '2': ('reward', 'Quà thưởng'),
    '3': ('event', 'Sự kiện'),
    '4': ('welcome', 'Chào mừng'),
    '5': ('update', 'Cập nhật'),
}

def send_global_mail(
    db,
    mail_id: str = None,
    title: str = "Thông báo",
    content: str = "",
    mail_type: str = "system",
    coins: int = 0,
    diamonds: int = 0,
    xp: int = 0,
    expires_days: int = 30,
):
    """
    Gửi thư cho TẤT CẢ user
    
    Args:
        db: Firestore client
        mail_id: ID thư (tự động tạo nếu None)
        title: Tiêu đề thư
        content: Nội dung thư
        mail_type: Loại thư (system/reward/event/welcome/update)
        coins: Số coins thưởng
        diamonds: Số diamonds thưởng
        xp: Số XP thưởng
        expires_days: Số ngày hết hạn
    
    Returns:
        str: Mail ID đã tạo
    """
    if mail_id is None:
        mail_id = generate_mail_id()
    
    # Kiểm tra mail đã tồn tại chưa
    doc_ref = db.collection('mailbox').document('global').collection('mails').document(mail_id)
    if doc_ref.get().exists:
        print(f"❌ Mail ID '{mail_id}' đã tồn tại!")
        return None
    
    # Tạo data
    now = datetime.now()
    expires_at = now + timedelta(days=expires_days)
    
    data = {
        'title': title,
        'content': content,
        'type': mail_type,
        'sent_at': firestore.SERVER_TIMESTAMP,
        'expires_at': expires_at,
        'is_active': True,
    }
    
    # Thêm reward nếu có
    if coins > 0 or diamonds > 0 or xp > 0:
        data['reward'] = {
            'coins': coins,
            'diamonds': diamonds,
            'xp': xp,
        }
    
    # Lưu lên Firebase
    doc_ref.set(data)
    
    print(f"\n✅ Đã gửi thư GLOBAL thành công!")
    _print_mail_info(mail_id, title, content, mail_type, coins, diamonds, xp, expires_days, "Tất cả user")
    
    return mail_id

def send_user_mail(
    db,
    mssv: str,
    mail_id: str = None,
    title: str = "Thông báo",
    content: str = "",
    mail_type: str = "system",
    coins: int = 0,
    diamonds: int = 0,
    xp: int = 0,
    expires_days: int = 30,
):
    """
    Gửi thư cho USER cụ thể
    
    Args:
        db: Firestore client
        mssv: Mã số sinh viên
        mail_id: ID thư (tự động tạo nếu None)
        title: Tiêu đề thư
        content: Nội dung thư
        mail_type: Loại thư
        coins, diamonds, xp: Phần thưởng
        expires_days: Số ngày hết hạn
    
    Returns:
        str: Mail ID đã tạo
    """
    if mail_id is None:
        mail_id = generate_mail_id()
    
    # Tạo data
    now = datetime.now()
    expires_at = now + timedelta(days=expires_days)
    
    data = {
        'title': title,
        'content': content,
        'type': mail_type,
        'sent_at': firestore.SERVER_TIMESTAMP,
        'expires_at': expires_at,
        'is_active': True,
    }
    
    # Thêm reward nếu có
    if coins > 0 or diamonds > 0 or xp > 0:
        data['reward'] = {
            'coins': coins,
            'diamonds': diamonds,
            'xp': xp,
        }
    
    # Lưu lên Firebase
    doc_ref = db.collection('mailbox').document('users').collection(mssv).document(mail_id)
    doc_ref.set(data)
    
    return mail_id

def send_mail_to_multiple_users(
    db,
    mssv_list: list,
    mail_id_prefix: str = None,
    title: str = "Thông báo",
    content: str = "",
    mail_type: str = "system",
    coins: int = 0,
    diamonds: int = 0,
    xp: int = 0,
    expires_days: int = 30,
):
    """
    Gửi thư cho NHIỀU user cụ thể
    """
    if mail_id_prefix is None:
        mail_id_prefix = generate_mail_id()
    
    print(f"\n📧 Gửi thư: \"{title}\"")
    if coins > 0 or diamonds > 0 or xp > 0:
        print(f"   💰 {coins:,} xu | 💎 {diamonds:,} kim cương | ⭐ {xp:,} XP")
    print(f"   📤 Gửi cho {len(mssv_list)} user...")
    
    success = 0
    failed = 0
    
    for mssv in mssv_list:
        try:
            mail_id = f"{mail_id_prefix}_{mssv}"
            send_user_mail(
                db, mssv, mail_id, title, content, mail_type,
                coins, diamonds, xp, expires_days
            )
            print(f"   ✓ {mssv}")
            success += 1
        except Exception as e:
            print(f"   ✗ {mssv}: {e}")
            failed += 1
    
    print(f"   → Thành công: {success}, Thất bại: {failed}")
    return success

def list_global_mails(db, limit=20):
    """Liệt kê thư global"""
    docs = db.collection('mailbox').document('global').collection('mails').limit(limit).stream()
    
    print(f"\n{'='*60}")
    print("📋 DANH SÁCH THƯ GLOBAL")
    print(f"{'='*60}")
    
    count = 0
    for doc in docs:
        count += 1
        data = doc.to_dict()
        reward = data.get('reward', {})
        
        print(f"\n📧 {doc.id}")
        print(f"   📌 {data.get('title', 'N/A')}")
        print(f"   📝 {data.get('type', 'system')}")
        if reward:
            print(f"   💰 {reward.get('coins', 0):,} | 💎 {reward.get('diamonds', 0):,} | ⭐ {reward.get('xp', 0):,}")
    
    print(f"\n{'='*60}")
    print(f"Tổng: {count} thư")
    print(f"{'='*60}\n")

def delete_global_mail(db, mail_id: str):
    """Xóa thư global"""
    doc_ref = db.collection('mailbox').document('global').collection('mails').document(mail_id)
    
    if not doc_ref.get().exists:
        print(f"❌ Mail '{mail_id}' không tồn tại!")
        return False
    
    doc_ref.delete()
    print(f"✅ Đã xóa mail '{mail_id}'")
    return True

def _print_mail_info(mail_id, title, content, mail_type, coins, diamonds, xp, expires_days, target):
    """In thông tin thư"""
    print(f"{'='*50}")
    print(f"📧 ID: {mail_id}")
    print(f"📌 Tiêu đề: {title}")
    print(f"📝 Loại: {mail_type}")
    print(f"📄 Nội dung: {content[:50]}..." if len(content) > 50 else f"📄 Nội dung: {content}")
    if coins > 0 or diamonds > 0 or xp > 0:
        print(f"💰 Coins: {coins:,}")
        print(f"💎 Diamonds: {diamonds:,}")
        print(f"⭐ XP: {xp:,}")
    else:
        print(f"🎁 Quà: Không có")
    print(f"⏰ Hết hạn: {expires_days} ngày")
    print(f"👥 Gửi đến: {target}")
    print(f"{'='*50}\n")

def interactive_menu():
    """Menu tương tác"""
    db = init_firebase()
    
    while True:
        print("\n" + "="*50)
        print("📬 QUẢN LÝ HÒM THƯ - TVU App")
        print("="*50)
        print("1. Gửi thư cho TẤT CẢ user (Global)")
        print("2. Gửi thư cho USER cụ thể")
        print("3. Gửi thư cho NHIỀU user")
        print("4. Xem danh sách thư Global")
        print("5. Xóa thư Global")
        print("6. Gửi thư nhanh (có quà)")
        print("0. Thoát")
        print("="*50)
        
        choice = input("Chọn: ").strip()
        
        if choice == "1":
            print("\n--- GỬI THƯ GLOBAL ---")
            mail_id = input("Mail ID (Enter = tự động): ").strip() or None
            title = input("Tiêu đề: ").strip() or "Thông báo"
            content = input("Nội dung: ").strip() or ""
            
            print("\nLoại thư:")
            for k, v in MAIL_TYPES.items():
                print(f"  {k}. {v[1]}")
            type_choice = input("Chọn loại (1-5): ").strip() or "1"
            mail_type = MAIL_TYPES.get(type_choice, ('system', 'Hệ thống'))[0]
            
            print("\n--- Phần thưởng (Enter = 0) ---")
            coins = int(input("Coins: ").strip() or 0)
            diamonds = int(input("Diamonds: ").strip() or 0)
            xp = int(input("XP: ").strip() or 0)
            expires_days = int(input("Hết hạn sau (ngày, mặc định 30): ").strip() or 30)
            
            send_global_mail(
                db, mail_id, title, content, mail_type,
                coins, diamonds, xp, expires_days
            )
            
        elif choice == "2":
            print("\n--- GỬI THƯ CHO USER ---")
            mssv = input("MSSV: ").strip()
            if not mssv:
                print("❌ MSSV không được để trống!")
                continue
                
            title = input("Tiêu đề: ").strip() or "Thông báo"
            content = input("Nội dung: ").strip() or ""
            
            print("\nLoại thư:")
            for k, v in MAIL_TYPES.items():
                print(f"  {k}. {v[1]}")
            type_choice = input("Chọn loại (1-5): ").strip() or "1"
            mail_type = MAIL_TYPES.get(type_choice, ('system', 'Hệ thống'))[0]
            
            print("\n--- Phần thưởng (Enter = 0) ---")
            coins = int(input("Coins: ").strip() or 0)
            diamonds = int(input("Diamonds: ").strip() or 0)
            xp = int(input("XP: ").strip() or 0)
            expires_days = int(input("Hết hạn sau (ngày, mặc định 30): ").strip() or 30)
            
            mail_id = send_user_mail(
                db, mssv, None, title, content, mail_type,
                coins, diamonds, xp, expires_days
            )
            print(f"\n✅ Đã gửi thư cho {mssv}")
            _print_mail_info(mail_id, title, content, mail_type, coins, diamonds, xp, expires_days, mssv)
            
        elif choice == "3":
            print("\n--- GỬI THƯ CHO NHIỀU USER ---")
            mssv_input = input("Danh sách MSSV (cách nhau bởi dấu phẩy): ").strip()
            if not mssv_input:
                print("❌ Danh sách MSSV không được để trống!")
                continue
            
            mssv_list = [m.strip() for m in mssv_input.split(',') if m.strip()]
            print(f"📋 Sẽ gửi cho {len(mssv_list)} user: {mssv_list}")
            
            title = input("Tiêu đề: ").strip() or "Thông báo"
            content = input("Nội dung: ").strip() or ""
            
            print("\nLoại thư:")
            for k, v in MAIL_TYPES.items():
                print(f"  {k}. {v[1]}")
            type_choice = input("Chọn loại (1-5): ").strip() or "1"
            mail_type = MAIL_TYPES.get(type_choice, ('system', 'Hệ thống'))[0]
            
            print("\n--- Phần thưởng (Enter = 0) ---")
            coins = int(input("Coins: ").strip() or 0)
            diamonds = int(input("Diamonds: ").strip() or 0)
            xp = int(input("XP: ").strip() or 0)
            expires_days = int(input("Hết hạn sau (ngày, mặc định 30): ").strip() or 30)
            
            send_mail_to_multiple_users(
                db, mssv_list, None, title, content, mail_type,
                coins, diamonds, xp, expires_days
            )
            
        elif choice == "4":
            list_global_mails(db)
            
        elif choice == "5":
            mail_id = input("Nhập Mail ID cần xóa: ").strip()
            if mail_id:
                confirm = input(f"Xác nhận xóa '{mail_id}'? (y/N): ").lower()
                if confirm == 'y':
                    delete_global_mail(db, mail_id)
                    
        elif choice == "6":
            print("\n--- GỬI THƯ NHANH (CÓ QUÀ) ---")
            print("1. Global (tất cả user)")
            print("2. User cụ thể")
            sub_choice = input("Chọn: ").strip()
            
            title = input("Tiêu đề: ").strip() or "Quà tặng đặc biệt!"
            content = input("Nội dung: ").strip() or "Đây là phần quà dành cho bạn!"
            coins = int(input("Coins: ").strip() or 10000)
            diamonds = int(input("Diamonds: ").strip() or 50)
            xp = int(input("XP: ").strip() or 100)
            
            if sub_choice == "1":
                send_global_mail(
                    db, None, title, content, "reward",
                    coins, diamonds, xp, 7
                )
            elif sub_choice == "2":
                mssv_input = input("MSSV (nhiều user cách nhau bởi dấu phẩy): ").strip()
                mssv_list = [m.strip() for m in mssv_input.split(',') if m.strip()]
                if mssv_list:
                    send_mail_to_multiple_users(
                        db, mssv_list, None, title, content, "reward",
                        coins, diamonds, xp, 7
                    )
                    
        elif choice == "0":
            print("👋 Tạm biệt!")
            break

if __name__ == "__main__":
    print("🚀 Khởi động script quản lý hòm thư...")
    try:
        interactive_menu()
    except FileNotFoundError:
        print(f"\n❌ Không tìm thấy file '{SERVICE_ACCOUNT_PATH}'")
        print("📝 Hướng dẫn:")
        print("   1. Vào Firebase Console > Project Settings > Service Accounts")
        print("   2. Click 'Generate new private key'")
        print("   3. Lưu file JSON vào thư mục scripts/ với tên 'serviceAccountKey.json'")
    except Exception as e:
        print(f"\n❌ Lỗi: {e}")
