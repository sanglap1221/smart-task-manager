const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Use environment variables for secrets as required by the PDF
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error("❌ Missing Supabase environment variables!");
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

module.exports = supabase;