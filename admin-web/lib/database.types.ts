export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type UserRole = "student" | "admin" | "super_admin";
export type EventVisibility = "draft" | "published" | "archived";
export type RegistrationStatus = "pending" | "approved" | "rejected" | "waitlisted";
export type AttendanceMethod = "qr_scan" | "manual" | "bulk";
export type QuestionType =
  | "short_answer"
  | "paragraph"
  | "email"
  | "phone"
  | "number"
  | "date"
  | "time"
  | "dropdown"
  | "radio"
  | "checkbox"
  | "file_upload"
  | "image_upload"
  | "signature"
  | "rating"
  | "linear_scale"
  | "yes_no"
  | "student_selector"
  | "roll_number"
  | "department"
  | "semester"
  | "branch";

export interface Database {
  public: {
    Tables: {
      departments: {
        Row: {
          id: string;
          name: string;
          code: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          code: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          code?: string;
          created_at?: string;
          updated_at?: string;
        };
      };
      student_profiles: {
        Row: {
          id: string;
          name: string;
          roll_number: string | null;
          enrollment_number: string | null;
          department_id: string | null;
          year: number | null;
          semester: number | null;
          division: string | null;
          gender: string | null;
          phone_number: string | null;
          blood_group: string | null;
          skills: string[] | null;
          interests: string[] | null;
          achievements: string | null;
          participation_score: number;
          volunteer_score: number;
          points: number;
          avatar_url: string | null;
          fcm_token: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          name: string;
          roll_number?: string | null;
          enrollment_number?: string | null;
          department_id?: string | null;
          year?: number | null;
          semester?: number | null;
          division?: string | null;
          gender?: string | null;
          phone_number?: string | null;
          blood_group?: string | null;
          skills?: string[] | null;
          interests?: string[] | null;
          achievements?: string | null;
          participation_score?: number;
          volunteer_score?: number;
          points?: number;
          avatar_url?: string | null;
          fcm_token?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          roll_number?: string | null;
          enrollment_number?: string | null;
          department_id?: string | null;
          year?: number | null;
          semester?: number | null;
          division?: string | null;
          gender?: string | null;
          phone_number?: string | null;
          blood_group?: string | null;
          skills?: string[] | null;
          interests?: string[] | null;
          achievements?: string | null;
          participation_score?: number;
          volunteer_score?: number;
          points?: number;
          avatar_url?: string | null;
          fcm_token?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      admin_profiles: {
        Row: {
          id: string;
          name: string;
          role: UserRole;
          department_id: string | null;
          avatar_url: string | null;
          fcm_token: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          name: string;
          role?: UserRole;
          department_id?: string | null;
          avatar_url?: string | null;
          fcm_token?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          role?: UserRole;
          department_id?: string | null;
          avatar_url?: string | null;
          fcm_token?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      event_categories: {
        Row: {
          id: string;
          name: string;
          description: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          description?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          description?: string | null;
          created_at?: string;
        };
      };
      events: {
        Row: {
          id: string;
          title: string;
          short_description: string;
          long_description: string | null;
          department_id: string | null;
          category_id: string | null;
          venue: string | null;
          google_maps_link: string | null;
          building: string | null;
          room: string | null;
          start_date: string;
          end_date: string;
          registration_start: string | null;
          registration_end: string | null;
          max_seats: number | null;
          max_capacity: number | null;
          min_seats: number | null;
          eligibility: string | null;
          rules: string | null;
          requirements: string | null;
          schedule: Json | null;
          agenda: string | null;
          prize_details: string | null;
          sponsors: string | null;
          coordinator: string | null;
          faculty_in_charge: string | null;
          contact_number: string | null;
          email: string | null;
          website: string | null;
          documents_required: string | null;
          dress_code: string | null;
          tags: string[] | null;
          banner_url: string | null;
          cover_image_url: string | null;
          visibility: EventVisibility;
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          title: string;
          short_description: string;
          long_description?: string | null;
          department_id?: string | null;
          category_id?: string | null;
          venue?: string | null;
          google_maps_link?: string | null;
          building?: string | null;
          room?: string | null;
          start_date: string;
          end_date: string;
          registration_start?: string | null;
          registration_end?: string | null;
          max_seats?: number | null;
          max_capacity?: number | null;
          min_seats?: number | null;
          eligibility?: string | null;
          rules?: string | null;
          requirements?: string | null;
          schedule?: Json | null;
          agenda?: string | null;
          prize_details?: string | null;
          sponsors?: string | null;
          coordinator?: string | null;
          faculty_in_charge?: string | null;
          contact_number?: string | null;
          email?: string | null;
          website?: string | null;
          documents_required?: string | null;
          dress_code?: string | null;
          tags?: string[] | null;
          banner_url?: string | null;
          cover_image_url?: string | null;
          visibility?: EventVisibility;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          title?: string;
          short_description?: string;
          long_description?: string | null;
          department_id?: string | null;
          category_id?: string | null;
          venue?: string | null;
          google_maps_link?: string | null;
          building?: string | null;
          room?: string | null;
          start_date?: string;
          end_date?: string;
          registration_start?: string | null;
          registration_end?: string | null;
          max_seats?: number | null;
          max_capacity?: number | null;
          min_seats?: number | null;
          eligibility?: string | null;
          rules?: string | null;
          requirements?: string | null;
          schedule?: Json | null;
          agenda?: string | null;
          prize_details?: string | null;
          sponsors?: string | null;
          coordinator?: string | null;
          faculty_in_charge?: string | null;
          contact_number?: string | null;
          email?: string | null;
          website?: string | null;
          documents_required?: string | null;
          dress_code?: string | null;
          tags?: string[] | null;
          banner_url?: string | null;
          cover_image_url?: string | null;
          visibility?: EventVisibility;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      registration_forms: {
        Row: {
          id: string;
          event_id: string;
          auto_approval: boolean;
          allow_waitlist: boolean;
          one_response_only: boolean;
          editable_response: boolean;
          confirmation_message: string | null;
          max_responses: number | null;
          close_on_limit: boolean;
          form_open_date: string | null;
          form_close_date: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          event_id: string;
          auto_approval?: boolean;
          allow_waitlist?: boolean;
          one_response_only?: boolean;
          editable_response?: boolean;
          confirmation_message?: string | null;
          max_responses?: number | null;
          close_on_limit?: boolean;
          form_open_date?: string | null;
          form_close_date?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          event_id?: string;
          auto_approval?: boolean;
          allow_waitlist?: boolean;
          one_response_only?: boolean;
          editable_response?: boolean;
          confirmation_message?: string | null;
          max_responses?: number | null;
          close_on_limit?: boolean;
          form_open_date?: string | null;
          form_close_date?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      form_sections: {
        Row: {
          id: string;
          form_id: string;
          title: string | null;
          description: string | null;
          order_index: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          form_id: string;
          title?: string | null;
          description?: string | null;
          order_index?: number;
          created_at?: string;
        };
        Update: {
          id?: string;
          form_id?: string;
          title?: string | null;
          description?: string | null;
          order_index?: number;
          created_at?: string;
        };
      };
      form_questions: {
        Row: {
          id: string;
          section_id: string;
          question_type: QuestionType;
          title: string;
          description: string | null;
          is_required: boolean;
          placeholder: string | null;
          default_value: string | null;
          character_limit: number | null;
          regex_validation: string | null;
          min_value: number | null;
          max_value: number | null;
          is_hidden: boolean;
          is_read_only: boolean;
          order_index: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          section_id: string;
          question_type: QuestionType;
          title: string;
          description?: string | null;
          is_required?: boolean;
          placeholder?: string | null;
          default_value?: string | null;
          character_limit?: number | null;
          regex_validation?: string | null;
          min_value?: number | null;
          max_value?: number | null;
          is_hidden?: boolean;
          is_read_only?: boolean;
          order_index?: number;
          created_at?: string;
        };
        Update: {
          id?: string;
          section_id?: string;
          question_type?: QuestionType;
          title?: string;
          description?: string | null;
          is_required?: boolean;
          placeholder?: string | null;
          default_value?: string | null;
          character_limit?: number | null;
          regex_validation?: string | null;
          min_value?: number | null;
          max_value?: number | null;
          is_hidden?: boolean;
          is_read_only?: boolean;
          order_index?: number;
          created_at?: string;
        };
      };
      question_options: {
        Row: {
          id: string;
          question_id: string;
          value: string;
          label: string | null;
          order_index: number;
        };
        Insert: {
          id?: string;
          question_id: string;
          value: string;
          label?: string | null;
          order_index?: number;
        };
        Update: {
          id?: string;
          question_id?: string;
          value?: string;
          label?: string | null;
          order_index?: number;
        };
      };
      registrations: {
        Row: {
          id: string;
          event_id: string;
          student_id: string;
          status: RegistrationStatus;
          registration_number: string | null;
          qr_code_data: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          event_id: string;
          student_id: string;
          status?: RegistrationStatus;
          registration_number?: string | null;
          qr_code_data?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          event_id?: string;
          student_id?: string;
          status?: RegistrationStatus;
          registration_number?: string | null;
          qr_code_data?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      registration_answers: {
        Row: {
          id: string;
          registration_id: string;
          question_id: string;
          answer_value: string | null;
          answer_json: Json | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          registration_id: string;
          question_id: string;
          answer_value?: string | null;
          answer_json?: Json | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          registration_id?: string;
          question_id?: string;
          answer_value?: string | null;
          answer_json?: Json | null;
          created_at?: string;
        };
      };
      attendance: {
        Row: {
          id: string;
          registration_id: string;
          event_id: string;
          student_id: string;
          check_in_time: string;
          check_out_time: string | null;
          is_late: boolean;
          method: AttendanceMethod;
          marked_by: string | null;
        };
        Insert: {
          id?: string;
          registration_id: string;
          event_id: string;
          student_id: string;
          check_in_time?: string;
          check_out_time?: string | null;
          is_late?: boolean;
          method?: AttendanceMethod;
          marked_by?: string | null;
        };
        Update: {
          id?: string;
          registration_id?: string;
          event_id?: string;
          student_id?: string;
          check_in_time?: string;
          check_out_time?: string | null;
          is_late?: boolean;
          method?: AttendanceMethod;
          marked_by?: string | null;
        };
      };
      event_feedback: {
        Row: {
          id: string;
          event_id: string;
          student_id: string;
          rating: number;
          review: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          event_id: string;
          student_id: string;
          rating: number;
          review?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          event_id?: string;
          student_id?: string;
          rating?: number;
          review?: string | null;
          created_at?: string;
        };
      };
      notifications: {
        Row: {
          id: string;
          user_id: string;
          title: string;
          message: string;
          type: string;
          is_read: boolean;
          link_id: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          title: string;
          message: string;
          type: string;
          is_read?: boolean;
          link_id?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          title?: string;
          message?: string;
          type?: string;
          is_read?: boolean;
          link_id?: string | null;
          created_at?: string;
        };
      };
      announcements: {
        Row: {
          id: string;
          title: string;
          content: string;
          is_pinned: boolean;
          target_audiences: string[] | null;
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          title: string;
          content: string;
          is_pinned?: boolean;
          target_audiences?: string[] | null;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          title?: string;
          content?: string;
          is_pinned?: boolean;
          target_audiences?: string[] | null;
          created_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
    };
  };
}
