-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enums
CREATE TYPE user_role AS ENUM ('student', 'admin', 'super_admin');
CREATE TYPE event_visibility AS ENUM ('draft', 'published', 'archived');
CREATE TYPE registration_status AS ENUM ('pending', 'approved', 'rejected', 'waitlisted');
CREATE TYPE attendance_method AS ENUM ('qr_scan', 'manual', 'bulk');
CREATE TYPE question_type AS ENUM (
    'short_answer', 'paragraph', 'email', 'phone', 'number', 'date', 'time',
    'dropdown', 'radio', 'checkbox', 'file_upload', 'image_upload', 'signature',
    'rating', 'linear_scale', 'yes_no', 'student_selector', 'roll_number', 
    'department', 'semester', 'branch'
);

-- Departments Table
CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Student Profiles (Links to auth.users)
CREATE TABLE student_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    roll_number TEXT UNIQUE,
    enrollment_number TEXT UNIQUE,
    department_id UUID REFERENCES departments(id),
    year INTEGER,
    semester INTEGER,
    division TEXT,
    gender TEXT,
    phone_number TEXT,
    blood_group TEXT,
    skills TEXT[],
    interests TEXT[],
    achievements TEXT,
    participation_score INTEGER DEFAULT 0,
    volunteer_score INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Admin Profiles (Links to auth.users)
CREATE TABLE admin_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'admin',
    department_id UUID REFERENCES departments(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Event Categories
CREATE TABLE event_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Events Table
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    short_description TEXT NOT NULL,
    long_description TEXT,
    department_id UUID REFERENCES departments(id),
    category_id UUID REFERENCES event_categories(id),
    venue TEXT,
    google_maps_link TEXT,
    building TEXT,
    room TEXT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    registration_start TIMESTAMPTZ,
    registration_end TIMESTAMPTZ,
    max_seats INTEGER,
    min_seats INTEGER DEFAULT 1,
    eligibility TEXT,
    rules TEXT,
    requirements TEXT,
    schedule JSONB,
    agenda TEXT,
    prize_details TEXT,
    sponsors TEXT,
    coordinator TEXT,
    faculty_in_charge TEXT,
    contact_number TEXT,
    email TEXT,
    website TEXT,
    documents_required TEXT,
    dress_code TEXT,
    tags TEXT[],
    banner_url TEXT,
    cover_image_url TEXT,
    visibility event_visibility DEFAULT 'draft',
    created_by UUID REFERENCES admin_profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Registration Forms (1-to-1 with Event)
CREATE TABLE registration_forms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE UNIQUE,
    auto_approval BOOLEAN DEFAULT FALSE,
    allow_waitlist BOOLEAN DEFAULT FALSE,
    one_response_only BOOLEAN DEFAULT TRUE,
    editable_response BOOLEAN DEFAULT FALSE,
    confirmation_message TEXT,
    max_responses INTEGER,                   -- NULL means unlimited
    close_on_limit BOOLEAN DEFAULT FALSE,    -- Auto-close when max_responses reached
    form_open_date TIMESTAMPTZ,              -- NULL means open immediately
    form_close_date TIMESTAMPTZ,             -- NULL means never auto-close
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Form Sections
CREATE TABLE form_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    form_id UUID REFERENCES registration_forms(id) ON DELETE CASCADE,
    title TEXT,
    description TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Form Questions
CREATE TABLE form_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID REFERENCES form_sections(id) ON DELETE CASCADE,
    question_type question_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    is_required BOOLEAN DEFAULT FALSE,
    placeholder TEXT,
    default_value TEXT,
    character_limit INTEGER,
    regex_validation TEXT,
    min_value NUMERIC,
    max_value NUMERIC,
    is_hidden BOOLEAN DEFAULT FALSE,
    is_read_only BOOLEAN DEFAULT FALSE,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Question Options (For dropdowns, checkboxes, etc)
CREATE TABLE question_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID REFERENCES form_questions(id) ON DELETE CASCADE,
    value TEXT NOT NULL,
    label TEXT,
    order_index INTEGER NOT NULL DEFAULT 0
);

-- Registrations
CREATE TABLE registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    student_id UUID REFERENCES student_profiles(id) ON DELETE CASCADE,
    status registration_status DEFAULT 'pending',
    registration_number TEXT UNIQUE,
    qr_code_data TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(event_id, student_id)
);

-- Registration Answers
CREATE TABLE registration_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    registration_id UUID REFERENCES registrations(id) ON DELETE CASCADE,
    question_id UUID REFERENCES form_questions(id) ON DELETE CASCADE,
    answer_value TEXT,
    answer_json JSONB, -- For complex answers like files or multiple choices
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(registration_id, question_id)
);

-- Attendance
CREATE TABLE attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    registration_id UUID REFERENCES registrations(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    student_id UUID REFERENCES student_profiles(id) ON DELETE CASCADE,
    check_in_time TIMESTAMPTZ DEFAULT NOW(),
    check_out_time TIMESTAMPTZ,
    is_late BOOLEAN DEFAULT FALSE,
    method attendance_method DEFAULT 'qr_scan',
    marked_by UUID REFERENCES admin_profiles(id),
    UNIQUE(registration_id)
);

-- Certificates
CREATE TABLE certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    registration_id UUID REFERENCES registrations(id) ON DELETE CASCADE,
    student_id UUID REFERENCES student_profiles(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    certificate_number TEXT UNIQUE NOT NULL,
    file_url TEXT,
    issued_date TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(registration_id)
);

-- Announcements
CREATE TABLE announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    is_pinned BOOLEAN DEFAULT FALSE,
    target_audiences TEXT[], -- e.g. ['all', 'cs_dept', 'first_year']
    created_by UUID REFERENCES admin_profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply timestamp triggers
CREATE TRIGGER set_timestamp_student_profiles BEFORE UPDATE ON student_profiles FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_admin_profiles BEFORE UPDATE ON admin_profiles FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_events BEFORE UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_registration_forms BEFORE UPDATE ON registration_forms FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_registrations BEFORE UPDATE ON registrations FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
