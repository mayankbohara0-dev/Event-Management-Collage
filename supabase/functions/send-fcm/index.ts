import { createClient } from 'jsr:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'

console.log("FCM Function Booted!");

Deno.serve(async (req) => {
  try {
    const payload = await req.json()
    console.log("Webhook Payload:", payload);
    
    if (payload.type !== 'INSERT' || payload.table !== 'events') {
      return new Response("Not a new event insert, skipping.", { status: 200 })
    }

    const newEvent = payload.record;
    
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: students, error } = await supabaseClient
      .from('student_profiles')
      .select('fcm_token')
      .not('fcm_token', 'is', null)

    if (error) throw error;
    if (!students || students.length === 0) return new Response("No students found.", { status: 200 })

    const tokens = [...new Set(students.map(s => s.fcm_token))].filter(Boolean) as string[];
    if (tokens.length === 0) return new Response("No valid tokens found.", { status: 200 })

    const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
    if (!serviceAccountStr) throw new Error("FIREBASE_SERVICE_ACCOUNT secret is missing");
    
    const serviceAccount = JSON.parse(serviceAccountStr)
    const jwtClient = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    
    const tokensRes = await jwtClient.getAccessToken()
    const accessToken = tokensRes.token
    
    const projectId = serviceAccount.project_id
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`
    
    let successCount = 0;
    
    for (const token of tokens) {
      const fcmPayload = {
        message: {
          token: token,
          notification: {
            title: 'Fresh Event Squeezed! 🍋',
            body: `${newEvent.title} just dropped on Zest. Grab your pass!`,
          },
          data: { eventId: newEvent.id.toString(), click_action: 'FLUTTER_NOTIFICATION_CLICK' }
        }
      }
      
      const res = await fetch(fcmUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`
        },
        body: JSON.stringify(fcmPayload)
      })
      
      if (res.ok) successCount++;
      else console.error(`Failed to send to ${token}:`, await res.text());
    }

    return new Response(JSON.stringify({ message: `Successfully sent ${successCount} notifications` }), { headers: { 'Content-Type': 'application/json' }, status: 200 })
  } catch (err: any) {
    console.error("Function error:", err);
    return new Response(String(err?.message ?? err), { status: 500 })
  }
})
