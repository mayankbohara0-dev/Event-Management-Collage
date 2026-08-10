-- Create the Webhook Trigger to call the FCM Edge Function on new events
CREATE OR REPLACE TRIGGER "New Event Notification"
  AFTER INSERT ON "public"."events"
  FOR EACH ROW
  EXECUTE FUNCTION "supabase_functions"."http_request"(
    'https://fgdrvtonfgeuboggucoe.supabase.co/functions/v1/send-fcm',
    'POST',
    '{"Content-type":"application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnZHJ2dG9uZmdldWJvZ2d1Y29lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQyNzAsImV4cCI6MjEwMTY3MDI3MH0.A7Oghf0CjCjZKEmZ5PqhHKXLXP86MaPUWFMy_aoVaJM"}',
    '{}',
    '5000'
  );
