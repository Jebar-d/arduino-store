import { createClient } from '@supabase/supabase-js'
export const supaDB = createClient(
  import.meta.env.VITE_SUPA_URL,
  import.meta.env.VITE_SUPA_ANON_KEY
)