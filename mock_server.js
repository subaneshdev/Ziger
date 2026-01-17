const http = require('http');
const https = require('https');
const crypto = require('crypto');

const PORT = 8080;
const SUPABASE_URL = 'https://crqvvcxmbvvcngfqdsnj.supabase.co/rest/v1';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNycXZ2Y3htYnZ2Y25nZnFkc25qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5MTUwODMsImV4cCI6MjA4MjQ5MTA4M30.KUfWjD66RT8v3p5D6y2zQieZ4ENCO-z6c0ZzTCICDnI';

const HEADERS = {
    'apikey': SUPABASE_KEY,
    'Authorization': `Bearer ${SUPABASE_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
};

const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS, PUT, DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-User-Id');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    let body = '';
    req.on('data', c => body += c);
    req.on('end', async () => {
        const url = req.url;
        const method = req.method;
        console.log(`[GATEWAY] ${method} ${url}`);
        if (body) console.log(`[BODY] ${body}`);

        const sendJSON = (data, code = 200) => {
            res.writeHead(code, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(data || {}));
        };

        try {
            if (url === '/api/auth/send-otp') {
                console.log(`[AUTH] OTP request received for body: ${body}`);
                return res.end('Sent');
            }

            if (url === '/api/auth/verify-otp') {
                const data = JSON.parse(body || '{}');
                const mobile = data.mobile;
                console.log(`[AUTH] Verifying: ${mobile}`);

                let profiles = await supabaseFetch(`/profiles?mobile=eq.${encodeURIComponent(mobile)}&select=*`);

                if (!Array.isArray(profiles) || profiles.length === 0) {
                    console.log(`[AUTH] User ${mobile} not found. Creating new profile...`);

                    // Create a new profile with pending KYC status
                    const newProfile = {
                        id: crypto.randomUUID(), // Generate UUID for the id field
                        mobile: mobile,
                        role: 'worker', // Default role, can be changed during role selection
                        kyc_status: 'approved',
                        wallet_balance: 0.0,
                        trust_score: 100
                    };

                    const created = await supabaseRequest('POST', '/profiles', newProfile);
                    profiles = Array.isArray(created) ? created : [created];
                    console.log(`[AUTH] Created new profile with ID: ${profiles[0]?.id}`);
                }

                const profile = profiles[0] || { id: 'unknown', role: 'worker', mobile: mobile };
                return sendJSON({
                    access_token: 'valid_token_' + profile.id,
                    profile: profile
                });
            }

            // --- CHAT ENDPOINTS ---
            const chatSendMatch = url.match(/\/api\/chat\/([a-f\d-]+)\/send/);
            if (chatSendMatch && method === 'POST') {
                const taskId = chatSendMatch[1];
                const userId = req.headers['x-user-id'];
                const data = JSON.parse(body || '{}');

                const message = {
                    task_id: taskId,
                    sender_id: userId,
                    content: data.content,
                    created_at: new Date().toISOString()
                };

                const result = await supabaseRequest('POST', '/chat_messages', message);
                return sendJSON(Array.isArray(result) ? result[0] : result);
            }

            const chatMessagesMatch = url.match(/\/api\/chat\/([a-f\d-]+)\/messages/);
            if (chatMessagesMatch && method === 'GET') {
                const taskId = chatMessagesMatch[1];
                const messages = await supabaseFetch(`/chat_messages?task_id=eq.${taskId}&select=*,sender:profiles(id,full_name,profile_photo_url)&order=created_at.desc`);
                return sendJSON(messages || []);
            }

            // --- GIGS ---
            if (url === '/api/gigs/assigned' && method === 'GET') {
                const uid = req.headers['x-user-id'];
                const tasks = await supabaseFetch(`/tasks?assigned_to=eq.${uid}&select=*`);
                return sendJSON(tasks || []);
            }

            if (url === '/api/gigs/my-gigs' && method === 'GET') {
                const uid = req.headers['x-user-id'];
                const tasks = await supabaseFetch(`/tasks?created_by=eq.${uid}&select=*`);
                return sendJSON(tasks || []);
            }

            // --- PROFILES & KYC ---
            const applicationsMatch = url.match(/\/api\/gigs\/([a-f\d-]+)\/applications/);
            if (applicationsMatch && method === 'GET') {
                const taskId = applicationsMatch[1];
                const apps = await supabaseFetch(`/task_applications?task_id=eq.${taskId}&select=*,worker:profiles(*)`);
                return sendJSON(apps || []);
            }

            // --- PROFILES & KYC ---
            const profileMatch = url.match(/\/api\/profiles\/([a-f\d-]+)/);
            if (profileMatch) {
                const id = profileMatch[1];
                if (method === 'POST' && url.includes('/kyc')) {
                    const p = JSON.parse(body || '{}');
                    const dbPayload = {
                        full_name: p.fullName || p.full_name,
                        kyc_status: 'pending',
                        id_type: p.idType || p.id_type,
                        id_card_number: p.idCardNumber || p.id_card_number,
                        dob: p.dob || p.date_of_birth,
                        gender: p.gender,
                        address: p.address,
                        city: p.city,
                        state: p.state,
                        pincode: p.pincode,
                        bank_account_name: p.bankAccountName || p.bank_account_name,
                        bank_account_number: p.bankAccountNumber || p.bank_account_number,
                        bank_ifsc: p.bankIfsc || p.bank_ifsc,
                        upi_id: p.upiId || p.upi_id,
                        id_card_front_url: p.idCardFrontUrl,
                        id_card_back_url: p.idCardBackUrl,
                        selfie_url: p.selfieUrl,
                        profile_photo_url: p.profilePhotoUrl
                    };
                    const updated = await supabaseRequest('PATCH', `/profiles?id=eq.${id}`, dbPayload);
                    return sendJSON(Array.isArray(updated) ? updated[0] : updated);
                }
                if (method === 'GET') {
                    const data = await supabaseFetch(`/profiles?id=eq.${id}&select=*`);
                    if (data.length === 0) return sendJSON({ id: id, error: 'Not Found' }, 200); // Return dummy profile to avoid Dart type errors
                    return sendJSON(data[0]);
                }
            }

            if (url.startsWith('/api/gigs/feed')) {
                const tasks = await supabaseFetch('/tasks?select=*');
                return sendJSON(tasks || []);
            }

            if (url === '/api/wallet/balance') {
                const uid = req.headers['x-user-id'];
                const p = await supabaseFetch(`/profiles?id=eq.${uid}&select=wallet_balance`);
                return sendJSON({ balance: (p[0] && p[0].wallet_balance) || 0.0 });
            }

            sendJSON({ status: 'ok' });
        } catch (e) {
            console.error('[GW ERROR]', e);
            sendJSON({ error: e.message }, 500);
        }
    });
});

async function supabaseFetch(path) {
    return new Promise((res, rej) => https.get(SUPABASE_URL + path, { headers: HEADERS }, r => {
        let d = ''; r.on('data', c => d += c); r.on('end', () => {
            try { res(JSON.parse(d)); } catch (e) { res([]); }
        });
    }).on('error', rej));
}

async function supabaseRequest(method, path, payload) {
    return new Promise((res, rej) => {
        const req = https.request(SUPABASE_URL + path, { method, headers: HEADERS }, rs => {
            let d = '';
            rs.on('data', c => d += c);
            rs.on('end', () => {
                console.log(`[SUPABASE ${method}] Response: ${d.substring(0, 200)}`);
                try {
                    const parsed = JSON.parse(d);
                    res(parsed);
                } catch (e) {
                    console.error(`[SUPABASE ${method}] Parse error:`, e.message);
                    res(null);
                }
            });
        });
        req.on('error', (e) => {
            console.error(`[SUPABASE ${method}] Request error:`, e.message);
            rej(e);
        });
        if (payload) req.write(JSON.stringify(payload));
        req.end();
    });
}

server.listen(PORT, '0.0.0.0', () => console.log('--- GATEWAY LOGGING ON ---'));
