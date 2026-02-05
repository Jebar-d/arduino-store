import { createClient } from '@supabase/supabase-js'

export const supaAuth = createClient(
  import.meta.env.VITE_SUPA_URL,
  import.meta.env.VITE_SUPA_ANON_KEY
)

export async function signIn(email, pwd) {
  return await supaAuth.auth.signInWithPassword({ email, password: pwd })
}

export async function signUp(email, pwd) {
  return await supaAuth.auth.signUp({ email, password: pwd })
}

export async function signOut() {
  return await supaAuth.auth.signOut()
}

export function onAuthChange(cb) {
  return supaAuth.auth.onAuthStateChange((e, s) => cb(s?.user || null))
}