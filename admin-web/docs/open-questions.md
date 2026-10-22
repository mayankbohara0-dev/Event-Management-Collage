# ZEST Admin — Database Schema & Open Architecture Notes

## 1. Registration Forms & Questions Architecture

### Discovered Schema in Database & Flutter Codebase
While the prompt referred to `registration_forms.questions` as potentially a JSONB column, inspection of `supabase/01_schema.sql` and the Flutter source code (`form_builder_screen.dart` lines 140–260 and `registration_form_screen.dart` lines 138–160) reveals that the existing database actually uses a **normalized relational architecture**:

1. `registration_forms`:
   - `id`: UUID (Primary Key)
   - `event_id`: UUID (Foreign Key $\to$ `events.id`, UNIQUE)
   - `auto_approval`: BOOLEAN (default FALSE)
   - `allow_waitlist`: BOOLEAN (default FALSE)
   - `one_response_only`: BOOLEAN (default TRUE)
   - `editable_response`: BOOLEAN (default FALSE)
   - `confirmation_message`: TEXT (default 'Thank you for registering!')
   - `max_responses`: INTEGER (NULL for unlimited)
   - `close_on_limit`: BOOLEAN (default FALSE)
   - `form_open_date`: TIMESTAMPTZ
   - `form_close_date`: TIMESTAMPTZ

2. `form_sections`:
   - `id`: UUID (Primary Key)
   - `form_id`: UUID (Foreign Key $\to$ `registration_forms.id`)
   - `title`: TEXT
   - `description`: TEXT
   - `order_index`: INTEGER

3. `form_questions`:
   - `id`: UUID (Primary Key)
   - `section_id`: UUID (Foreign Key $\to$ `form_sections.id`)
   - `question_type`: ENUM (`short_answer`, `paragraph`, `radio`, `checkbox`, `dropdown`, `linear_scale`, `rating`, `yes_no`, `date`, `time`, `email`, `phone`, `number`, `file_upload`, `image_upload`, `roll_number`, `department`, `semester`)
   - `title`: TEXT
   - `description`: TEXT
   - `is_required`: BOOLEAN
   - `character_limit`: INTEGER
   - `min_value`: NUMERIC
   - `max_value`: NUMERIC
   - `order_index`: INTEGER

4. `question_options`:
   - `id`: UUID (Primary Key)
   - `question_id`: UUID (Foreign Key $\to$ `form_questions.id`)
   - `value`: TEXT
   - `label`: TEXT
   - `order_index`: INTEGER

5. `registration_answers`:
   - `id`: UUID (Primary Key)
   - `registration_id`: UUID (Foreign Key $\to$ `registrations.id`)
   - `question_id`: UUID (Foreign Key $\to$ `form_questions.id`)
   - `answer_value`: TEXT
   - `answer_json`: JSONB

### Approach in ZEST Admin:
- **Zero Schema Changes**: ZEST Admin will read and write to `form_sections`, `form_questions`, and `question_options` exactly like the old Flutter `form_builder_screen.dart` did!
- In our form builder UI and data repository, we serialize/deserialize questions using the identical model structure:
  ```ts
  interface FormQuestion {
    id: string;
    section_id?: string;
    title: string;
    description?: string;
    question_type: QuestionType;
    is_required: boolean;
    character_limit?: number;
    min_value?: number;
    max_value?: number;
    order_index: number;
    options: { value: string; label: string; order_index: number }[];
  }
  ```
- This ensures **100% backward and forward compatibility** with the student Flutter app!

---

## 2. Attendance & Gate XP Trigger
- Gate check-in inserts into `attendance`:
  - `registration_id`: UUID
  - `event_id`: UUID
  - `student_id`: UUID
  - `check_in_time`: TIMESTAMPTZ
  - `marked_by`: UUID (admin id)
  - `method`: 'qr_scan' | 'manual'
- Database trigger `trg_reward_attendance_xp` on `attendance` fires automatically and adds +80 XP to `student_profiles.points`. No frontend XP manipulation needed.

---

## 3. Storage Buckets
- `event-banners`: Public bucket for event posters/cover images.
- `avatars`: Public bucket for admin and student profile photos.
