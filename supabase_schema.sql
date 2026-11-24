-- ==============================================================================
-- SCRIPT KHỞI TẠO CƠ SỞ DỮ LIỆU SUPABASE (POSTGRESQL REALTIME)
-- ỨNG DỤNG: QUẢN LÝ UP CSKB (CAPSULE KÌ BÍ) - NGỌC RỒNG ONLINE
-- ==============================================================================
-- Hướng dẫn: Mở Supabase Dashboard -> Chọn dự án -> SQL Editor -> Dán toàn bộ script này và bấm RUN.

-- 1. BẢNG NHÓM (TEAMS)
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE, -- Mã nhóm (ví dụ: CSKB-7891)
    name TEXT NOT NULL,        -- Tên nhóm (ví dụ: Team Up CSKB Kame)
    owner_name TEXT NOT NULL,  -- Tên trưởng nhóm
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2. BẢNG THÀNH VIÊN TRONG NHÓM (TEAM MEMBERS)
CREATE TABLE IF NOT EXISTS public.team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_code TEXT NOT NULL REFERENCES public.teams(code) ON DELETE CASCADE,
    member_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'MEMBER', -- OWNER, FARMER, TRADER, MEMBER
    last_active TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(team_code, member_name)
);

-- 3. BẢNG NHẬP MÁY DÒ (DETECTOR PURCHASES)
CREATE TABLE IF NOT EXISTS public.detector_purchases (
    id TEXT PRIMARY KEY,
    team_code TEXT NOT NULL REFERENCES public.teams(code) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    total_price NUMERIC NOT NULL,
    currency TEXT NOT NULL DEFAULT 'VND',
    created_at TIMESTAMPTZ NOT NULL,
    note TEXT,
    created_by TEXT -- Người nhập
);

-- 4. BẢNG CA TREO UP CSKB (FARMING SESSIONS)
CREATE TABLE IF NOT EXISTS public.farming_sessions (
    id TEXT PRIMARY KEY,
    team_code TEXT NOT NULL REFERENCES public.teams(code) ON DELETE CASCADE,
    detectors_used INTEGER NOT NULL,
    cskb_collected INTEGER NOT NULL,
    server TEXT NOT NULL DEFAULT 'Vũ trụ 1',
    account_name TEXT,
    created_at TIMESTAMPTZ NOT NULL,
    note TEXT,
    created_by TEXT -- Người up
);

-- 5. BẢNG ĐƠN BÁN HÀNG CSKB X999 (CSKB SALES)
CREATE TABLE IF NOT EXISTS public.cskb_sales (
    id TEXT PRIMARY KEY,
    team_code TEXT NOT NULL REFERENCES public.teams(code) ON DELETE CASCADE,
    pack_count INTEGER NOT NULL,
    loose_count INTEGER NOT NULL DEFAULT 0,
    unit_price_per_pack NUMERIC NOT NULL,
    total_revenue NUMERIC NOT NULL,
    currency TEXT NOT NULL DEFAULT 'VND',
    customer_name TEXT,
    server TEXT NOT NULL DEFAULT 'Vũ trụ 1',
    created_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'PAID', -- PAID, DEBT
    note TEXT,
    created_by TEXT -- Người bán
);

-- 6. BẢNG CHI PHÍ VẬN HÀNH PHỤ (OTHER EXPENSES)
CREATE TABLE IF NOT EXISTS public.other_expenses (
    id TEXT PRIMARY KEY,
    team_code TEXT NOT NULL REFERENCES public.teams(code) ON DELETE CASCADE,
    title TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    currency TEXT NOT NULL DEFAULT 'VND',
    created_at TIMESTAMPTZ NOT NULL,
    note TEXT,
    created_by TEXT
);

-- 7. BẢNG CÀI ĐẶT NHÓM (TEAM SETTINGS)
CREATE TABLE IF NOT EXISTS public.team_settings (
    team_code TEXT NOT NULL REFERENCES public.teams(code) ON DELETE CASCADE,
    key TEXT NOT NULL,
    value TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY(team_code, key)
);

-- ==============================================================================
-- BẬT REALTIME REPLICATION (ĐỒNG BỘ TỨC THÌ ĐA THIẾT BỊ QUA WEBSOCKET)
-- ==============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.teams;
ALTER PUBLICATION supabase_realtime ADD TABLE public.team_members;
ALTER PUBLICATION supabase_realtime ADD TABLE public.detector_purchases;
ALTER PUBLICATION supabase_realtime ADD TABLE public.farming_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.cskb_sales;
ALTER PUBLICATION supabase_realtime ADD TABLE public.other_expenses;
ALTER PUBLICATION supabase_realtime ADD TABLE public.team_settings;

-- ==============================================================================
-- PHÂN QUYỀN TRUY CẬP (ROW LEVEL SECURITY - RLS)
-- Cho phép đọc/ghi công khai dựa trên mã Team Code
-- ==============================================================================
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detector_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farming_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cskb_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.other_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Cho phép truy cập teams" ON public.teams FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Cho phép truy cập team_members" ON public.team_members FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Cho phép truy cập detector_purchases" ON public.detector_purchases FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Cho phép truy cập farming_sessions" ON public.farming_sessions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Cho phép truy cập cskb_sales" ON public.cskb_sales FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Cho phép truy cập other_expenses" ON public.other_expenses FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Cho phép truy cập team_settings" ON public.team_settings FOR ALL USING (true) WITH CHECK (true);

-- TẠO NHÓM MẪU BAN ĐẦU ĐỂ TEST
INSERT INTO public.teams (code, name, owner_name)
VALUES ('CSKB-DEMO', 'Nhóm Test Thử Nghiệm', 'Trưởng Nhóm Demo')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.team_settings (team_code, key, value)
VALUES ('CSKB-DEMO', 'exchange_rate_tv_to_vnd', '350')
ON CONFLICT (team_code, key) DO NOTHING;
