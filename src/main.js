import { onAuthChange } from './auth.js'
import { headerPartial } from './header.js'
import { supaAuth } from './auth.js'

// Initialize header on auth state change
onAuthChange(user => headerPartial(user))

// Check auth and verification on every page
const { data: { session } } = await supaAuth.auth.getSession()

if (session?.user && !session.user.email_confirmed_at) {
  // User logged in but not verified - force to verification page
  if (!location.pathname.includes('verify-email')) {
    location.href = '/verify-email.html'
  }
}